# Threads vs Async

## Threads

Threads allow a program to run multiple flows of execution.

They are useful for:

- CPU-bound work
- parallel execution on multiple cores
- workloads that need independent execution paths

## Async

`async` / `await` is usually used to manage non-blocking I/O efficiently.

It is useful for:

- network requests
- file I/O
- high-concurrency servers

## Main difference

- **Threads** are a lower-level execution model.
- **Async** is a programming model for structuring non-blocking tasks.

Async does not automatically mean parallel execution.

## Backend rule of thumb

- use **async** for I/O-bound tasks
- use **threads** or worker processes for CPU-bound tasks

## Mid/Senior Interview Questions and Answers

### 1. Why does async not automatically make code faster?

**Answer:** Async improves concurrency for waiting-heavy I/O. It does not make
CPU-bound work faster, and blocking calls inside async code can still stop the
event loop.

Async code is useful when there are many waits that can overlap, such as
database calls, HTTP calls, or file operations with non-blocking drivers.

### 2. When are threads a better choice than async?

**Answer:** Threads are useful when libraries are blocking, when work needs
independent execution paths, or when the runtime can execute CPU work in
parallel.

In runtimes with a global interpreter lock or single-threaded CPU execution,
threads may still help I/O-bound work but not CPU-heavy work.

### 3. How can async servers still fail under high traffic?

**Answer:** Async servers can still run out of database connections, memory,
file descriptors, CPU, downstream capacity, or event-loop time. Async increases
the number of tasks that can be in flight, which can amplify pressure on
dependencies.

Use limits, pools, timeouts, backpressure, and bulkheads instead of allowing
unbounded concurrency.

### 4. What is backpressure?

**Answer:** Backpressure is a mechanism that slows producers when consumers or
downstream systems cannot keep up.

Without backpressure, queues grow, memory rises, latency spikes, and failures
spread across the system.
