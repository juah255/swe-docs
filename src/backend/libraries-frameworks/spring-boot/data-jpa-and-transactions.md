# Data, JPA, and Transactions

Spring Data JPA reduces repository boilerplate, while JPA and the database still
determine entity state, SQL, locking, constraints, and transaction behavior.
Repository convenience is not a substitute for understanding those layers.

## Entity Design

```java
@Entity
@Table(
    name = "orders",
    uniqueConstraints = @UniqueConstraint(
        name = "uk_orders_reference",
        columnNames = "reference"))
public class Order {

    @Id
    private UUID id;

    @Version
    private long version;

    @Column(nullable = false, length = 40)
    private String reference;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OrderStatus status;

    protected Order() {
    }
}
```

Use database constraints for persistent invariants. Consider identifier strategy,
equality, collection ownership, cascade behavior, and deletion semantics
carefully. An unrestricted `CascadeType.ALL` can cause surprising writes or
deletes.

## Repositories and Queries

Repository interfaces provide CRUD, paging, sorting, and derived queries:

```java
public interface OrderRepository extends JpaRepository<Order, UUID> {

    Optional<Order> findByReference(String reference);

    @EntityGraph(attributePaths = "lines")
    Optional<Order> findDetailedById(UUID id);
}
```

Use derived methods for readable, modest queries. Use JPQL, criteria,
specifications, projections, or native SQL when they express a query more
clearly. Avoid enormous method names and unbounded `findAll()` calls.

## Persistence Context

Loaded entities are managed within a persistence context. Changes can be flushed
automatically before commit or before queries that require consistency. `save()`
is not the only point SQL may execute, and a successful method call does not mean
the transaction has committed yet.

Lazy relationships load when accessed inside an open context. Access later can
fail or create hidden N+1 queries. Fetch the data required by the use case with
an entity graph, fetch join, projection, or explicit query. Do not solve the
problem globally by making every association eager.

## Transaction Boundaries

Place `@Transactional` on public application service methods that represent a
consistent unit of work:

```java
@Service
public class OrderService {

    @Transactional
    public Order cancel(UUID id) {
        Order order = orders.findById(id)
            .orElseThrow(() -> new OrderNotFound(id));
        order.cancel();
        return order;
    }
}
```

Transactions are commonly proxy-based. Self-invocation does not cross the proxy,
and visibility rules vary by proxy strategy. Keep the boundary obvious instead
of scattering transactional annotations through private methods.

By default, runtime exceptions trigger rollback while checked exceptions do not.
Configure rollback rules intentionally when the default does not match the
operation. `readOnly = true` is an optimization hint, not an authorization rule
and not a universal guarantee that writes are impossible.

## Concurrency

`@Version` enables optimistic locking and detects a conflicting update. Pessimistic
locks can protect short critical sections but increase contention and deadlock
risk. Conditional updates and unique constraints are often simpler.

Keep transactions short and avoid remote API calls while holding database locks.
A database transaction cannot atomically include an external payment service or
message broker without a larger coordination pattern.

## Events and the Outbox Pattern

An event published before commit can describe data that later rolls back. A
transactional event listener can defer in-process handling, but a process crash
can still lose an external message. For durable integration, store an outbox row
in the same transaction and have a relay publish it idempotently.

Consumers must also handle duplicates because at-least-once delivery is common.

## Schema Migrations

Use Flyway or Liquibase as the owned history of production schema changes. Do
not rely on automatic Hibernate schema updates in production.

Design migrations for rolling releases:

1. Add backward-compatible schema.
2. Deploy code that tolerates old and new forms.
3. Backfill in bounded, resumable batches.
4. switch reads and enforce new constraints.
5. Remove obsolete schema in a later release.

Review locks, table rewrites, replica lag, and rollback strategy before applying
a migration to a large dataset.

