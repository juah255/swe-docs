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
