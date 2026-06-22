# Locks and Semaphores

## Lock / Mutex

A mutex (Mutual Exclusion) is a synchronization mechanism used to ensure that only one thread or process can access a shared resource at a time.

A **lock** or **mutex** allows only one worker at a time to enter a critical section.

Use a mutex when shared data must be protected from concurrent modification.

Common examples:

- updating a shared counter
- writing to a shared file
- modifying an in-memory cache
- updating inventory or order state inside one worker process

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

## Lock Scope

Mutexes and semaphores are usually application synchronization primitives, but
their enforcement may be backed by the operating system.

| Lock type | Scope | Typical use |
| --- | --- | --- |
| In-process mutex | Threads or tasks inside one process | Protect shared memory in one application process |
| OS-backed process lock | Multiple processes on one machine | Coordinate file writes or shared memory |
| Database lock | Transactions across application instances | Protect rows, tables, or database invariants |
| Distributed lock | Multiple machines or services | Coordinate work through Redis, etcd, ZooKeeper, or similar systems |

A normal in-memory mutex in one process is not visible to another process.
Cross-process coordination needs a lock object managed by the OS, a database, or
an external coordination service.

## Thread vs Process Mutex in Python

Threads in one process share memory, so they can coordinate with the same
`threading.Lock` object:

```py
import threading

counter = 0
lock = threading.Lock()

def increment():
    global counter

    for _ in range(100_000):
        with lock:
            counter += 1

threads = [
    threading.Thread(target=increment),
    threading.Thread(target=increment),
]

for thread in threads:
    thread.start()

for thread in threads:
    thread.join()

print(counter)  # 200000
```

Separate processes do not share normal process memory. Use shared memory plus an
OS-backed lock:

```py
from multiprocessing import Lock, Process, Value

counter = Value("i", 0)
lock = Lock()

def increment():
    for _ in range(100_000):
        with lock:
            counter.value += 1

processes = [
    Process(target=increment),
    Process(target=increment),
]

for process in processes:
    process.start()

for process in processes:
    process.join()

print(counter.value)  # 200000
```

Without the process lock, both processes can read and write the shared value at
the same time, so the final count can be lower than expected.

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

### 5. Can a mutex protect multiple processes?

**Answer:** Yes, but only if the mutex is backed by something all processes can
coordinate through, such as the operating system, shared memory, a database, or a
distributed lock service.

Threads can share an in-memory mutex because they live inside the same process.
Separate processes have separate memory spaces, so a mutex stored only in one
process cannot protect another process.
