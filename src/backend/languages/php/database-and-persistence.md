# Database and Persistence

## PDO Connections

PDO provides a consistent API across database drivers, while SQL features,
placeholder behavior, transaction semantics, and buffering remain driver-specific.

```php
$pdo = new PDO(
    $dsn,
    $username,
    $password,
    [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ],
);
```

Native prepared statements are preferable when the driver supports the required
behavior, but test the exact driver and server. Keep credentials out of source
control and impose connection, query, and application deadlines through the
available stack.

## Prepared Statements

Bind untrusted values instead of interpolating them into SQL:

```php
$statement = $pdo->prepare(
    'SELECT id, email FROM users WHERE tenant_id = :tenant AND email = :email'
);
$statement->execute([
    'tenant' => $tenantId,
    'email' => $email,
]);
$user = $statement->fetch();
```

Parameters represent values, not table names, column names, sort directions, or
SQL fragments. Map those dynamic choices from a fixed allowlist.

Prepared statements prevent SQL syntax injection, but `%` and `_` remain
wildcards inside a `LIKE` value. Escape them when the product expects a literal
substring search.

## Transactions

Use a transaction around one database unit of work:

```php
function transactional(PDO $pdo, callable $operation): mixed
{
    $pdo->beginTransaction();

    try {
        $result = $operation($pdo);
        $pdo->commit();
        return $result;
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }

        throw $exception;
    }
}
```

Not every storage engine or statement is transactional. Some databases perform
implicit commits for particular DDL operations. Avoid remote network calls while
holding locks, and keep the boundary in an application service rather than an
HTTP controller.

Nested transactions are not portable PDO behavior. If an abstraction uses
savepoints, understand how inner failures and rollback-only state are handled.

## Concurrency

A transaction does not automatically prevent a stale read or lost update. Use
the appropriate combination of:

- unique, foreign-key, and check constraints;
- atomic conditional updates;
- version columns for optimistic concurrency;
- row locks for short critical sections;
- an isolation level chosen for the anomaly being prevented.

Deadlocks and serialization failures can be normal under contention. Retry only
the whole idempotent transaction with a small bounded policy, not an arbitrary
statement in the middle.

## ORMs and Query Builders

An ORM can provide mapping, unit-of-work behavior, relationships, migrations,
and query composition. It does not remove SQL or database costs.

Watch for N+1 queries, implicit lazy loading, oversized object graphs, unbounded
collections, missing indexes, and long-lived identity maps in workers. Use
projections, explicit eager loading, pagination, and batch operations from
measured access patterns.

Keep persistence entities away from direct request binding and public response
serialization. An API contract and a database model evolve for different
reasons.

## Schema Migrations

Treat migrations as ordered production code. Review the SQL, locks, table
rewrites, backfill cost, and rollback strategy.

For a rolling release:

1. Add backward-compatible schema.
2. Deploy code that works with old and new representations.
3. Backfill in bounded, resumable batches.
4. Switch reads and enforce new constraints.
5. Remove obsolete schema in a later release.

Run migrations once through a controlled deployment job rather than letting
every web replica race at startup.

