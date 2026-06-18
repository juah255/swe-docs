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

## Mid/Senior Interview Questions and Answers

### 1. What conditions are usually required for a deadlock?

**Answer:** Deadlocks require mutual exclusion, hold-and-wait, no preemption,
and circular wait. If all four conditions hold, workers can end up waiting on
each other forever.

Breaking any one of these conditions can prevent or reduce deadlocks.

### 2. How do you reduce deadlocks in application code?

**Answer:** Use consistent lock ordering, keep critical sections small, avoid
holding locks during I/O, prefer single ownership of mutable state, and use
timeouts where recovery is possible.

Senior-level code should also make locking rules visible in design, not hidden
across unrelated functions.

### 3. How do you handle database deadlocks?

**Answer:** Treat database deadlocks as retryable transaction failures when the
operation is safe to retry. Keep transactions short, touch rows in a consistent
order, index queries properly, and avoid user interaction inside transactions.

Retries need limits, backoff, and idempotency so they do not create duplicate
side effects.

### 4. How would you debug a deadlock in production?

**Answer:** Capture thread dumps, database deadlock logs, lock wait information,
transaction queries, and recent deployment changes. Identify which resources are
held and which resources are being waited on.

The fix is usually changing lock ordering, reducing transaction scope, adding
indexes, or removing unnecessary shared state.
