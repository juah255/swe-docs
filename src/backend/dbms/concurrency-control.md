# Concurrency Control

Databases handle **concurrency**: multiple users or processes reading and
modifying data at the same time without producing inconsistent or corrupt
results. They do this through a combination of locking, transactions, isolation
levels, multi-version storage, conflict detection, constraints, and atomic
operations.

See also [Transaction](transaction.md) for ACID and isolation-level detail.

## Mechanisms

### 1. Locking

Locks coordinate access so conflicting operations cannot run at the same time.

- **Shared lock (read lock):** many transactions can read the same data at once.
- **Exclusive lock (write lock):** only one transaction can modify the data;
  others wait until the lock is released.

Consider a balance starting at `1000`, with two concurrent operations:

```sql
CREATE TABLE accounts (
    id INT PRIMARY KEY,
    balance INT
);

INSERT INTO accounts VALUES (1, 1000);
```

**Without locking**, both transactions read `1000` before either writes:

```text
Transaction A: read 1000, then write 1000 - 200 = 800
Transaction B: read 1000, then write 1000 + 500 = 1500
Final balance = 1500   (B overwrote A)
```

The correct result is `1300` (`1000 - 200 + 500`). The lost write is the
**lost update problem**.

**With locking**, `FOR UPDATE` takes an exclusive row lock:

```sql
-- Transaction A
BEGIN;

SELECT *
FROM accounts
WHERE id = 1
FOR UPDATE;          -- B blocks here until A commits

UPDATE accounts
SET balance = balance - 200
WHERE id = 1;

COMMIT;
```

Transaction B waits until A commits, reads the updated `800`, adds `500`, and
ends at the correct `1300`.

### 2. Transactions

A transaction groups operations into a single unit that fully succeeds or fully
fails. Transactions guarantee the **ACID** properties:

- **Atomicity:** all operations succeed, or none do.
- **Consistency:** the database moves from one valid state to another.
- **Isolation:** concurrent transactions do not interfere.
- **Durability:** committed changes survive crashes.

Without a transaction, a crash between two statements can lose money:

```sql
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- crash here: the $100 disappears
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
```

Wrapping the work in a transaction makes it all-or-nothing:

```sql
BEGIN;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;        -- on failure: ROLLBACK restores the prior state
```

### 3. Isolation Levels

Isolation levels trade correctness against concurrency. Higher isolation
prevents more anomalies but reduces parallelism.

| Isolation Level  | Dirty Read | Non-repeatable Read | Phantom Read          |
| ---------------- | ---------- | ------------------- | --------------------- |
| Read Uncommitted | Possible   | Possible            | Possible              |
| Read Committed   | No         | Possible            | Possible              |
| Repeatable Read  | No         | No                  | Possible (DB-dependent) |
| Serializable     | No         | No                  | No                    |

- **Read Uncommitted** can return a **dirty read**: transaction B reads a value
  transaction A later rolls back, so B used data that never officially existed.
- **Read Committed** only returns committed data, eliminating dirty reads.
- **Repeatable Read** guarantees a row read twice in the same transaction
  returns the same value, even if another transaction commits a change between
  the reads.
- **Serializable** makes transactions behave as if they ran one after another.
  Two buyers competing for the last ticket cannot both succeed, so the count
  never goes negative.

### 4. Multi-Version Concurrency Control (MVCC)

Many modern databases (PostgreSQL, MySQL/InnoDB) use **MVCC** so readers and
writers do not block each other. Instead of overwriting a row in place, a writer
creates a new version; readers keep seeing the previous committed version until
the writer commits.

```text
Time 1: balance = 100  (version 1)

Transaction A: UPDATE balance -> 80   (creates version 2, uncommitted)
Transaction B: SELECT balance         -> reads 100 (version 1), no waiting

Transaction A: COMMIT
Future transactions:  SELECT balance  -> read 80 (version 2)
```

This greatly improves read performance under contention.

### 5. Optimistic Concurrency Control

Instead of locking up front, the application reads a **version number** (or
timestamp) and only commits if that version is unchanged. It works well when
conflicts are rare.

```sql
CREATE TABLE accounts (
    id INT PRIMARY KEY,
    balance INT,
    version INT
);
-- row: id=1, balance=1000, version=5
```

```sql
-- Transaction A read version 5, then another transaction bumped it to 6.
-- A's conditional update now matches no rows:
UPDATE accounts
SET balance = 800,
    version = 6
WHERE id = 1
  AND version = 5;     -- 0 rows updated -> conflict -> retry
```

Because the version no longer matches, `0` rows are updated, the conflict is
detected, and the application retries. A typical retry loop in C++:

```cpp
int expectedVersion = readVersion(id);

bool success = updateAccount(id, newBalance, expectedVersion);

if (!success) {
    // Another transaction won the race; reload and retry.
    std::cout << "Retry transaction\n";
}
```

### 6. Deadlock Detection

A **deadlock** occurs when transactions wait on each other in a cycle:

```text
Transaction A: locks Row 1, then wants Row 2
Transaction B: locks Row 2, then wants Row 1
Neither can proceed.
```

```sql
-- Transaction A
BEGIN;
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;   -- locks row 1
SELECT * FROM accounts WHERE id = 2 FOR UPDATE;   -- waits on B

-- Transaction B
BEGIN;
SELECT * FROM accounts WHERE id = 2 FOR UPDATE;   -- locks row 2
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;   -- waits on A
```

The database detects the cycle, aborts one transaction (the *victim*), and lets
the other proceed. The aborted transaction should be retried by the application.
Acquiring locks in a consistent order (always row 1 before row 2) avoids most
deadlocks.

### 7. Constraints

Constraints preserve integrity even under concurrent writes. They include
primary keys, foreign keys, unique constraints, and check constraints.

```sql
CREATE TABLE users (
    id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE
);
```

If two sessions insert the same `username` at the same time, exactly one
succeeds; the other fails with a duplicate-key error. The database enforces this
without any application-side coordination.

```sql
CREATE TABLE orders (
    customer_id INT REFERENCES customers(id)
);
-- Inserting customer_id = 500 fails unless customer 500 exists.
```

### 8. Atomic SQL Operations

Many read-modify-write sequences can be expressed as a single atomic statement,
avoiding the lost-update problem entirely.

Instead of reading, modifying in application code, and writing back:

```sql
-- Bad: two concurrent likes can both read 100 and both write 101.
likes = SELECT likes FROM posts WHERE id = 5;
likes = likes + 1;
UPDATE posts SET likes = likes WHERE id = 5;
```

Let the database compute the new value in place:

```sql
-- Good: each increment is applied exactly once.
UPDATE posts
SET likes = likes + 1
WHERE id = 5;
```

## Common Concurrency Problems

| Problem             | Example                                              | Database solution                         |
| ------------------- | ---------------------------------------------------- | ----------------------------------------- |
| Lost update         | Two users overwrite each other's changes             | Locks, MVCC, optimistic concurrency       |
| Dirty read          | Reading another transaction's uncommitted data       | Isolation levels (Read Committed or higher) |
| Non-repeatable read | Same query returns different values in a transaction | Repeatable Read or higher                 |
| Phantom read        | New rows appear between two queries                  | Serializable isolation                    |
| Deadlock            | Transactions wait on each other in a cycle           | Deadlock detection and resolution         |

## Putting It All Together

A money transfer combines several mechanisms at once:

```sql
BEGIN;

SELECT balance
FROM accounts
WHERE id = 1
FOR UPDATE;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;
```

- **Transactions** make the transfer complete entirely or not at all.
- **Locks** stop other transactions from modifying the locked account mid-transfer.
- **Isolation levels** control what other transactions can see while it runs.
- **MVCC** lets other transactions keep reading the last committed balance instead of blocking.
- **Deadlock detection** resolves circular waits between concurrent transfers.
- **Constraints** keep the data valid.
- **Atomic updates** apply each statement as an indivisible unit.

Together these mechanisms let banking systems, e-commerce platforms, and social
networks serve thousands or millions of concurrent users while keeping data
consistent.

## Mid/Senior Interview Questions and Answers

### 1. What is the lost update problem and how do you prevent it?

**Answer:** Two transactions read the same value, modify it independently, and
write back; the second write overwrites the first. Prevent it with row locks
(`SELECT ... FOR UPDATE`), an atomic in-place update (`SET balance = balance -
20`), or optimistic concurrency using a version column.

### 2. When would you choose optimistic over pessimistic concurrency control?

**Answer:** Optimistic control suits low-contention workloads where conflicts
are rare and retries are cheap, since it avoids lock overhead. Pessimistic
locking suits high-contention or expensive-to-retry work, where blocking up
front is cheaper than repeatedly redoing aborted transactions.

### 3. How does MVCC let readers avoid blocking on writers?

**Answer:** Writers create a new row version instead of overwriting in place, so
readers continue to see the previous committed version until the writer commits.
Reads do not wait for write locks, which improves throughput under contention.

### 4. How do databases handle deadlocks?

**Answer:** The engine tracks lock dependencies, detects a cycle, and aborts one
transaction as the victim so the others can proceed. The application should
catch the error and retry. Acquiring locks in a consistent order reduces how
often deadlocks happen.
