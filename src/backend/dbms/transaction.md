# Transaction

A database transaction groups one or more operations into a single logical unit of work.

## Core Topics

- ACID properties
- `COMMIT` and `ROLLBACK`
- Isolation levels
- Dirty reads, non-repeatable reads, and phantom reads
- Locks and deadlocks
- Optimistic and pessimistic concurrency control

## ACID Properties

ACID is the standard set of guarantees for database transactions.

| Property | Meaning | How it is achieved |
| --- | --- | --- |
| Atomicity | All operations succeed together or none do | `BEGIN`, `COMMIT`, `ROLLBACK` |
| Consistency | The database stays valid before and after the transaction | Constraints, invariants, and application rules |
| Isolation | Concurrent transactions do not interfere in unsafe ways | Isolation levels, locks, MVCC, conditional updates |
| Durability | Committed changes survive crashes | Transaction logs, flushes, replication depending on the database |

### How each property is enforced

#### Atomicity

Atomicity is enforced by wrapping related statements in one transaction and
ending it with either `COMMIT` or `ROLLBACK`.

Typical mechanisms:

- Transaction boundaries: `BEGIN`, `COMMIT`, `ROLLBACK`
- Error handling in application code
- Savepoints for partial rollback inside a larger transaction

If one statement fails, the whole unit of work is rolled back so the database
does not end up half-updated.

#### Consistency

Consistency means the transaction moves the database from one valid state to
another valid state. The database and the application both help enforce this.

Typical mechanisms:

- Primary key, foreign key, unique, and `CHECK` constraints
- Triggers for rules that must run in the database
- Transaction validation in application code
- Domain invariants checked before `COMMIT`

Consistency is broader than SQL constraints alone. The business rule still has
to be encoded somewhere, but the database should protect the parts that must
never be violated.

#### Isolation

Isolation is enforced by preventing one transaction from seeing or corrupting
another transaction's in-progress work.

Typical mechanisms:

- Row, table, and page locks
- Locking reads such as `SELECT ... FOR UPDATE`
- Multi-version concurrency control (`MVCC`)
- Isolation levels such as read committed, repeatable read, and serializable
- Optimistic concurrency control with version checks

The stronger the isolation level, the fewer anomalies you allow, but the lower
the concurrency may be.

#### Durability

Durability is enforced by making committed changes survive process crashes,
machine failures, and restarts.

Typical mechanisms:

- Write-ahead logging (`WAL`)
- Transaction logs
- `fsync` or disk flushes
- Checkpoints
- Crash recovery on restart

Durability is usually a storage-engine concern. The application asks for a
commit; the database guarantees the commit is persisted according to its
durability settings.

### Practical example

Imagine a money transfer that must debit one account and credit another.

```sql
BEGIN;

SELECT balance
FROM accounts
WHERE id = 1
FOR UPDATE;

UPDATE accounts
SET balance = balance - 100
WHERE id = 1
  AND balance >= 100;

UPDATE accounts
SET balance = balance + 100
WHERE id = 2;

COMMIT;
```

If any step fails, the application rolls back:

```sql
ROLLBACK;
```

This example shows how ACID works in practice:

- **Atomicity**: both balance changes happen together, or neither happens.
- **Consistency**: the `balance >= 100` condition prevents overdrawing the
  account, and other constraints can enforce additional rules.
- **Isolation**: `FOR UPDATE` prevents another transaction from changing the
  same row at the same time.
- **Durability**: once `COMMIT` succeeds, the database guarantees the result
  survives a crash according to its durability settings.

In application code, the pattern usually looks like this:

```python
def transfer_money(db, from_id, to_id, amount):
    try:
        db.begin()

        db.execute(
            "SELECT balance FROM accounts WHERE id = %s FOR UPDATE",
            [from_id],
        )

        updated = db.execute(
            "UPDATE accounts "
            "SET balance = balance - %s "
            "WHERE id = %s AND balance >= %s",
            [amount, from_id, amount],
        )

        if updated.rowcount != 1:
            raise ValueError("insufficient funds")

        db.execute(
            "UPDATE accounts SET balance = balance + %s WHERE id = %s",
            [amount, to_id],
        )

        db.commit()
    except Exception:
        db.rollback()
        raise
```

The important part is not the exact syntax. The important part is that the
database enforces correctness through one transaction, row locking, and
conditional updates rather than through ad hoc in-memory state.

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
