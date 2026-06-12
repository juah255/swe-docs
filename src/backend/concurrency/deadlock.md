# Deadlock

A **deadlock** happens when two or more workers wait on each other forever, so none of them can continue.

## Example

1. Thread A locks resource X
2. Thread B locks resource Y
3. Thread A waits for Y
4. Thread B waits for X

Now both threads are stuck.

## Common causes

- inconsistent lock ordering
- holding multiple locks at once
- long-running work while holding locks

## How to reduce deadlocks

- acquire locks in a consistent order
- keep critical sections small
- avoid unnecessary locks
- use timeouts or retry strategies where appropriate
