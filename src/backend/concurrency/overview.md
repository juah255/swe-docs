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
