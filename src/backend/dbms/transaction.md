# Transaction

A database transaction groups one or more operations into a single logical unit of work.

## Core Topics

- ACID properties
- `COMMIT` and `ROLLBACK`
- Isolation levels
- Dirty reads, non-repeatable reads, and phantom reads
- Locks and deadlocks
- Optimistic and pessimistic concurrency control

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
