# Transaction

A database transaction groups one or more operations into a single logical unit of work.

## Core Topics

- ACID properties
- `COMMIT` and `ROLLBACK`
- Isolation levels
- Dirty reads, non-repeatable reads, and phantom reads
- Locks and deadlocks
- Optimistic and pessimistic concurrency control

## Database-Level Locks

Database locks are managed by the database engine so concurrent transactions do
not corrupt shared data.

Common lock types:

- **Row lock:** locks specific rows, usually during `UPDATE`, `DELETE`, or
  `SELECT ... FOR UPDATE`.
- **Table lock:** locks an entire table for operations that need broad
  protection.
- **Shared lock:** allows multiple readers but prevents conflicting writes.
- **Exclusive lock:** allows one transaction to write while conflicting readers
  or writers wait.
- **Page lock:** locks a storage page that contains multiple rows.
- **Intent lock:** records that a transaction intends to lock lower-level
  resources such as rows or pages.

Example pessimistic row lock:

```sql
BEGIN;

SELECT *
FROM accounts
WHERE id = 1
FOR UPDATE;

UPDATE accounts
SET balance = balance - 100
WHERE id = 1;

COMMIT;
```

Another transaction trying to update the same row usually waits until the first
transaction commits or rolls back.

Optimistic locking avoids taking the lock first. The application writes only if
a version or timestamp has not changed:

```sql
UPDATE accounts
SET balance = balance - 100,
    version = version + 1
WHERE id = 1
  AND version = 5;
```

If no row is updated, another transaction changed the row first and the
application should retry or reject the operation.

## Mid/Senior Interview Questions and Answers

### 1. What are the ACID properties?

**Answer:** Atomicity means all operations commit or none do. Consistency means
the transaction preserves database rules. Isolation means concurrent
transactions do not interfere beyond the configured level. Durability means
committed changes survive failures.

ACID is about correctness under failure and concurrency, not just syntax around
`BEGIN` and `COMMIT`.

### 2. What is the difference between `COMMIT` and `ROLLBACK`?

**Answer:** `COMMIT` makes transaction changes permanent. `ROLLBACK` discards
changes made in the current transaction.

Applications should roll back on failure and avoid leaving transactions open,
because open transactions can hold locks and block other work.

### 3. What are dirty reads, non-repeatable reads, and phantom reads?

**Answer:** A dirty read sees uncommitted data from another transaction. A
non-repeatable read sees the same row change between reads. A phantom read sees
new or removed rows matching a predicate between reads.

Isolation levels define which anomalies are allowed or prevented.

### 4. How do optimistic and pessimistic locking differ?

**Answer:** Optimistic locking detects conflicts at write time using a version
or condition. Pessimistic locking prevents conflicts by locking rows before
work proceeds.

Optimistic locking is good when conflicts are rare. Pessimistic locking is
useful when conflicts are common or retries are expensive.

### 5. Why should transactions be kept short?

**Answer:** Long transactions hold locks longer, increase contention, delay
vacuum or cleanup in some databases, and make deadlocks more likely.

Do not wait for user input, remote APIs, or slow background work inside a
database transaction unless there is a strong reason.

### 6. What are database-level locks?

**Answer:** Database-level locks are locks managed by the database engine to
coordinate concurrent transactions. They can apply to rows, pages, tables, or
internal metadata depending on the database and query.

In day-to-day backend work, row locks are the most common. They protect updates
to the same record and prevent lost updates, inconsistent balances, duplicate
state transitions, and similar race conditions.

### 7. How do database locks differ from application mutexes?

**Answer:** An application mutex protects work inside the scope that can see the
mutex, usually one process unless it is OS-backed or distributed. A database
lock protects database state across every application instance using the same
database.

For database invariants, prefer transactions, constraints, row locks, and
conditional updates. An in-process mutex is not enough when the service runs on
multiple processes or servers.
