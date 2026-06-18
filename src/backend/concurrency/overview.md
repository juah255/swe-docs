# Concurrency

Concurrency is the ability of a system to make progress on multiple tasks during overlapping periods of time.

In backend systems, concurrency is important for:

- handling many requests at once
- improving throughput
- using CPU and I/O resources efficiently
- avoiding blocking work from stopping the whole system

Common concurrency topics include:

- threads and processes
- `async` / `await`
- race conditions
- locks and semaphores
- deadlocks
- thread safety

Concurrency is not the same as parallelism:

- **Concurrency** is about managing multiple tasks at the same time.
- **Parallelism** is about literally executing multiple tasks at the same instant, usually on multiple CPU cores.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between concurrency and parallelism?

**Answer:** Concurrency is structuring a system to make progress on multiple
tasks during overlapping time periods. Parallelism is actually executing
multiple tasks at the same instant, usually on multiple CPU cores.

A single-threaded event loop can be concurrent without being parallel. A
multi-core CPU running multiple worker threads can be both concurrent and
parallel.

### 2. Why does concurrency create bugs in backend systems?

**Answer:** Backend systems often share data through memory, databases, caches,
files, or external services. When multiple requests modify the same state
without coordination, the final result can depend on timing.

Common bugs include lost updates, duplicate processing, inconsistent reads,
deadlocks, and resource exhaustion.

### 3. How do you choose between threads, async, and processes?

**Answer:** Use async for high-concurrency I/O when the libraries are
non-blocking. Use threads when the runtime and libraries are blocking or when
work needs separate execution paths. Use processes for CPU-heavy work or
isolation.

The right choice depends on runtime behavior, workload type, memory cost, and
operational complexity.

### 4. How can databases help with concurrency?

**Answer:** Databases provide transactions, locks, isolation levels, unique
constraints, atomic updates, and optimistic concurrency controls.

Application locks are not enough when multiple application instances can update
the same database rows. Critical invariants should be protected at the database
level too.
