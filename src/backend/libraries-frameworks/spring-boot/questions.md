# Spring Boot Questions

These questions emphasize behavior, trade-offs, and production failure modes.

## 1. What does Spring Boot add to Spring Framework?

It adds opinionated auto-configuration, starters and dependency management,
embedded-server packaging, externalized configuration, testing utilities, and
operational support through Actuator. The underlying Spring container and
framework modules still provide the core programming model.

## 2. How does auto-configuration work?

Boot registers configuration conditionally based on the classpath, existing or
missing beans, properties, application type, and other environment signals.
Application-defined beans often cause a default to back off. The condition
evaluation report explains matches and non-matches.

## 3. Why prefer constructor injection?

It exposes required collaborators, permits immutable fields, fails clearly when
a dependency is absent, and allows plain unit construction. Field injection
hides requirements and couples tests to container or reflection behavior.

## 4. Why can `@Transactional` appear not to work?

Transaction advice is commonly applied through a proxy. Self-invocation does not
cross that proxy, unmanaged objects are not advised, and method visibility or
exception rollback rules may differ from assumptions. Inspect the real call
boundary and transaction manager.

## 5. What does `@Transactional(readOnly = true)` guarantee?

It communicates intent and may let the transaction manager or provider optimize
behavior. It is not an authorization control and is not a portable guarantee
that no write can occur. Database permissions and application design enforce
stronger constraints.

## 6. How do you prevent N+1 queries with JPA?

Observe generated SQL, then fetch the required graph using a fetch join, entity
graph, projection, or tailored query. Avoid making all relationships eager,
which replaces hidden queries with oversized and sometimes duplicated results.

## 7. Optimistic or pessimistic locking?

Optimistic locking with a version detects conflicts and suits relatively rare
contention. Pessimistic locking prevents concurrent modification for a critical
section but holds database locks and can deadlock. Conditional updates and
constraints may offer a simpler alternative.

## 8. Why not expose JPA entities from a REST controller?

Entities couple the contract to persistence, can reveal fields, trigger lazy
queries during serialization, create cycles, and permit unsafe binding. Explicit
request and response models give the transport boundary its own evolution and
validation rules.

## 9. How should API errors be represented?

Map known exceptions centrally to stable status codes and a consistent problem
shape. Provide machine-readable codes when clients need them, include a trace or
request ID, and avoid leaking stack traces, SQL, secrets, or internal class names.

## 10. Spring MVC or WebFlux?

MVC is a strong default for imperative applications and blocking dependencies.
WebFlux fits high-concurrency or streaming workloads with an end-to-end
non-blocking stack. Wrapping blocking JPA in reactive types does not make it
non-blocking.

## 11. Is `@Async` a background job queue?

No. It runs work in an application executor, so a crash can lose it and a full
queue can reject it. Use durable messaging or a job system when work needs
delivery guarantees, retries, scheduling, or audit history.

## 12. How do you publish a message consistently with a database write?

For strong durability, write an outbox record in the same database transaction
as the domain update, then publish it through a retrying relay. Consumers should
be idempotent because duplicate delivery remains possible.

## 13. What makes a cache key safe?

It includes every input that changes the result, including tenant, identity or
permission scope, locale, and version. The cache also needs bounded size,
expiry, invalidation ownership, stampede handling, and serialization policy.

## 14. Why can a caching annotation be skipped?

Caching is commonly proxy-based. A call from one method to another on the same
object does not cross the cache proxy. The same proxy-boundary concern affects
transactions, async execution, retries, and method security.

## 15. What is the difference between a test slice and `@SpringBootTest`?

A slice loads focused framework configuration for one layer, making failures
faster and more local. `@SpringBootTest` loads the application context and is
appropriate for wiring and cross-layer behavior. Plain unit tests need neither.

## 16. Why use Testcontainers for persistence tests?

It can run the same database or broker technology as production, exposing real
SQL, types, locking, migrations, and protocol behavior that an in-memory fake
may hide. It costs more startup time, so use it for integration boundaries.

## 17. How should Actuator be secured?

Expose only required endpoints, separately control access, and restrict them
through Spring Security, network policy, or both. Endpoints such as environment,
configuration, heap dump, mappings, and loggers can disclose or mutate sensitive
operational state.

## 18. What belongs in a liveness check?

Only evidence that the process cannot continue and should be restarted. A remote
database or API outage should usually not fail liveness because restarting every
instance amplifies the incident. Readiness can represent the ability to receive
traffic.

## 19. How do you deploy schema changes without downtime?

Use expand-and-contract migrations: add compatible schema, deploy tolerant code,
backfill gradually, switch behavior, enforce constraints, and remove old schema
later. Old and new processes coexist during rolling deployment.

## 20. How do you scale a Spring Boot service?

Measure the bottleneck, optimize queries and allocations, bound pools and remote
calls, cache appropriate work, separate durable background processing, and then
scale stateless instances within database and downstream capacity. Replica count
alone does not create capacity everywhere.

