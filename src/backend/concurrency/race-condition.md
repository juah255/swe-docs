# Race Condition

A **race condition** happens when multiple threads, processes, or async tasks access shared data at the same time, and the final result depends on the order of execution.

## Why it happens

Race conditions happen when:

- multiple workers access the same shared state
- at least one worker modifies that state
- access is not properly synchronized

## Example

Suppose two requests try to increment the same counter:

1. Request A reads value `5`
2. Request B reads value `5`
3. Request A writes `6`
4. Request B writes `6`

The expected result was `7`, but the final value becomes `6`.

## How to prevent race conditions

- use locks or mutexes
- use atomic operations
- avoid shared mutable state
- use database transactions when the shared state is in the database
- design idempotent operations where possible
