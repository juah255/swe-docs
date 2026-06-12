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
