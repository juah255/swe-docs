# Locks and Semaphores

## Lock / Mutex

A **lock** or **mutex** allows only one worker at a time to enter a critical section.

Use a mutex when shared data must be protected from concurrent modification.

## Semaphore

A **semaphore** controls access to a limited number of resources.

Unlike a mutex, a semaphore can allow more than one worker to proceed at the same time.

Example:

- a database connection pool with 10 available connections
- only 10 workers can acquire a connection at once

## Mutex vs Semaphore

- **Mutex**: one owner at a time
- **Semaphore**: limited number of concurrent owners

## Critical Section

A **critical section** is the part of the code that accesses shared resources and must be protected.

## Mid/Senior Interview Questions and Answers

### 1. When should you use a mutex?

**Answer:** Use a mutex when exactly one worker should access a critical section
or mutate shared state at a time.

A mutex is appropriate for protecting in-memory maps, counters, caches, or
compound operations that must be atomic inside one process. It does not protect
state across multiple processes or servers unless it is a distributed lock.

### 2. When should you use a semaphore?

**Answer:** Use a semaphore to limit concurrency for a finite resource, such as
database connections, external API calls, upload processing, or worker slots.

A semaphore is about capacity control. It allows up to `N` workers through
instead of exactly one.

### 3. What makes critical sections risky?

**Answer:** Critical sections reduce concurrency and can introduce deadlocks,
priority inversion, and latency spikes if they do too much work.

Keep them small. Avoid slow I/O, network calls, or callbacks while holding a
lock unless the design explicitly requires it.

### 4. What is the difference between local locks and distributed locks?

**Answer:** Local locks coordinate workers inside one process. Distributed locks
coordinate work across processes or machines using an external system such as a
database, Redis, ZooKeeper, or etcd.

Distributed locks are harder because they must handle timeouts, process crashes,
network partitions, and ownership expiry. Prefer database constraints or
idempotent design when they solve the problem.
