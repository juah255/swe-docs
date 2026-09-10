# Concurrency and Async I/O

Concurrency lets multiple operations make progress during the same time window.
Parallelism means work literally executes at the same time. Choosing correctly
depends on whether the workload spends its time waiting for I/O or using the
CPU.

## The Global Interpreter Lock

In the usual CPython runtime configuration, the **Global Interpreter Lock
(GIL)** allows only one thread in a process to execute Python bytecode at a
time. It simplifies interpreter internals and makes reference-count updates
safe.

The lock does not prevent concurrency. Many blocking I/O operations and some
native libraries release it while they wait or perform native work. Its main
effect is that multiple threads generally do not speed up CPU-bound Python
bytecode.

The GIL is not an application mutex. It does not make a multi-step operation on
shared state logically atomic, and it does not remove the need for locks or
other synchronization.

## Choosing a Model

| Workload | Usually prefer | Reason |
| --- | --- | --- |
| Blocking file, HTTP, or database I/O | Threads | Existing synchronous libraries can overlap waits. |
| Many concurrent connections using async libraries | `asyncio` | One event loop can coordinate many waiting tasks. |
| CPU-bound Python code | Processes | Separate interpreters can execute on different CPU cores. |
| CPU-heavy native-library operation | Library-specific threading or workers | Native code may release the GIL and parallelize internally. |

Measure the real workload. Serialization overhead can make a process pool worse
for small tasks, while an async design cannot help if its libraries perform
blocking calls.

## Threads

Threads share process memory, so communication is cheap but mutable state needs
synchronization. They are a practical choice when a blocking library must serve
several I/O operations concurrently.

Use bounded pools rather than creating an unbounded thread per request. A pool
that is too small can be starved by slow dependencies; one that is too large
increases memory use, context switching, and pressure on downstream services.

## Processes

Each process has its own interpreter and memory space. Processes provide CPU
parallelism and failure isolation, but values passed between them generally
need serialization.

Process workers are a good fit for image transforms, document parsing,
scientific calculations, and other substantial CPU work. A durable task queue
is often more appropriate when work must survive a web-worker restart.

## Coroutines and the Event Loop

Calling an `async def` function creates a coroutine object. It runs when it is
awaited directly or scheduled as a task. At an `await`, the current coroutine
can suspend so the event loop can run other ready work.

```py
import asyncio


async def load_dashboard(user_id: int) -> tuple[Profile, list[Order]]:
    profile, orders = await asyncio.gather(
        fetch_profile(user_id),
        fetch_recent_orders(user_id),
    )
    return profile, orders
```

Concurrency is useful here only if the two operations are independent. Do not
run operations together when one depends on the other's result or when doing so
violates a transaction or downstream capacity limit.

## Structured Concurrency

Related tasks should share a clear lifetime. A task group waits for its child
tasks and cancels siblings when one fails:

```py
import asyncio


async def refresh(user_id: int) -> None:
    async with asyncio.TaskGroup() as group:
        group.create_task(refresh_profile(user_id))
        group.create_task(refresh_permissions(user_id))
```

Avoid fire-and-forget tasks inside request handlers. Without a durable owner,
their exceptions can be lost and deployment may stop them before completion.

## Cancellation and Timeouts

Cancellation is normal control flow in async systems. Use `try/finally` or
`async with` to release resources, and do not swallow cancellation accidentally.

Every external call should have a finite timeout. A request deadline should be
propagated into child operations where possible, so abandoned work does not
continue consuming connections and worker capacity.

## Blocking the Event Loop

One blocking call can pause every coroutine on the same event-loop thread.
Common causes include:

- synchronous HTTP or database clients inside `async def`;
- CPU-heavy parsing, compression, or cryptography;
- large synchronous file operations;
- lock contention or accidental calls to `time.sleep()`.

Use async-compatible libraries, move short blocking I/O to a bounded thread
pool, and move substantial CPU work to a process or job worker. Never assume
that adding `async` to a function makes its internals non-blocking.

## Backpressure

Concurrency should be bounded. Semaphores, bounded queues, connection-pool
limits, and worker caps keep a fast producer from overwhelming memory or a slow
dependency. Limits should reflect the downstream system's capacity, not just
the application's ability to create tasks.
