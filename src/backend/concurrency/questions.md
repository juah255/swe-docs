# Concurrency Questions

## Mid/Senior Interview Questions and Answers

### 1. What is concurrency?

**Answer:** Concurrency is the ability to manage multiple tasks during
overlapping time periods. It helps backend systems handle many requests,
background jobs, I/O waits, and independent workflows.

Concurrency is a design property. It does not always mean multiple tasks are
running at the exact same CPU instant.

### 2. What is thread safety?

**Answer:** Code is thread-safe when it behaves correctly even when multiple
threads call it at the same time.

Thread safety usually requires immutability, synchronization, atomic operations,
single ownership, or avoiding shared state.

### 3. What is a critical section?

**Answer:** A critical section is code that accesses shared mutable state and
therefore must be protected from concurrent modification.

Keep critical sections short and avoid slow I/O while holding locks.

### 4. What is the difference between a mutex and a semaphore?

**Answer:** A mutex allows one owner at a time into a critical section. A
semaphore allows a fixed number of concurrent owners.

Use mutexes for exclusive access. Use semaphores for capacity limits.

### 5. What is the difference between a thread and a process?

**Answer:** A process has its own memory space and resources. A thread runs
inside a process and shares that process memory.

Threads are cheaper to create but easier to corrupt with shared-state bugs.
Processes offer stronger isolation but higher communication overhead.

### 6. What is blocking versus non-blocking I/O?

**Answer:** Blocking I/O waits until the operation finishes before the worker
continues. Non-blocking I/O lets the worker continue and receive completion
later through an event loop, callback, future, or promise.

Non-blocking I/O improves concurrency, but it still needs resource limits and
timeouts.

### 7. How can two requests create a race condition in a backend application?

**Answer:** They can read the same value, independently decide an operation is
allowed, and then both write updates that violate the intended invariant.

Examples include overselling inventory, double-spending balance, duplicate
coupon redemption, and duplicate job processing.

### 8. How would you protect shared in-memory data from concurrent writes?

**Answer:** Use a mutex, atomic structure, channel ownership model, immutable
snapshot, or single-threaded event loop ownership depending on the runtime.

For multi-instance deployments, in-memory locks are not enough. Use database or
distributed coordination for shared external state.

### 9. How can database transactions help with concurrency issues?

**Answer:** Transactions group reads and writes into a consistent unit and can
use locks, isolation levels, constraints, and atomic updates to protect data.

For strong invariants, combine transaction logic with database constraints so
concurrent application instances cannot bypass the rule.

### 10. How would you debug a deadlock in production?

**Answer:** Collect thread dumps, database lock graphs, slow query logs,
transaction statements, and timing around recent changes. Identify the cycle of
resources and workers waiting on each other.

Then fix lock ordering, reduce transaction scope, improve indexes, or remove
unnecessary shared locks.
