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

## Blocking I/O

Blocking I/O means the current worker waits until the I/O operation finishes.

Examples:

- reading a file with a blocking file API
- calling a database with a blocking driver
- making an HTTP request with a blocking client
- waiting for a socket read before continuing

While the worker is blocked, it cannot do other useful work. In a threaded
server, this usually means the thread is occupied until the I/O finishes. The
server can still handle other requests if it has more worker threads or
processes, but each blocked operation consumes one worker.

Example:

```py
response = http_client.get("https://api.example.com/users/1")
save_user(response.json())
```

In this style, `save_user()` cannot run until the HTTP request completes, and
the worker cannot handle another task while it waits.

## Non-Blocking I/O

Non-blocking I/O starts an operation without forcing the current worker to sit
idle until the operation finishes. Completion is handled later through an event
loop, callback, future, promise, or `async` / `await`.

Example:

```py
response = await http_client.get("https://api.example.com/users/1")
save_user(response.json())
```

The `await` still makes this function wait for the result, but the event loop can
run other ready tasks during the wait. This is why async servers can handle many
I/O-heavy requests with fewer threads.

Non-blocking I/O is useful for:

- many simultaneous HTTP calls
- chat or realtime connections
- streaming responses
- database calls with async drivers
- queues and network services

Non-blocking I/O does not remove the need for limits. Async systems still need
timeouts, connection pools, backpressure, and concurrency caps so they do not
overload databases or downstream services.

## Blocking vs Non-Blocking

| Topic | Blocking I/O | Non-blocking I/O |
| --- | --- | --- |
| Worker behavior | Waits until the operation completes | Can let other tasks run while waiting |
| Common model | Thread per request or worker pool | Event loop with async tasks |
| Good for | Simpler code, blocking libraries, lower concurrency | High-concurrency I/O workloads |
| Risk | Too many blocked workers | Too many in-flight tasks or blocked event loop |

## Main difference

- **Threads** are a lower-level execution model.
- **Async** is a programming model for structuring non-blocking tasks.

Async does not automatically mean parallel execution.

## Backend rule of thumb

- use **async** for I/O-bound tasks
- use **threads** or worker processes for CPU-bound tasks
- do not call blocking I/O directly inside an async event loop
- use async-compatible libraries when choosing an async framework

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

### 5. What is the difference between blocking and non-blocking I/O?

**Answer:** Blocking I/O occupies the current worker until the operation
finishes. Non-blocking I/O lets the runtime start the operation and continue
running other ready tasks while waiting for completion.

Blocking I/O is simpler and works well with thread pools, but each wait consumes
a worker. Non-blocking I/O improves I/O concurrency, but blocking calls inside
the event loop can still stall every task sharing that loop.
