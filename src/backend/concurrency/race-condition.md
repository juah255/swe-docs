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

## Mid/Senior Interview Questions and Answers

### 1. How can two HTTP requests create a race condition?

**Answer:** Two requests can read the same state, make decisions from stale
values, and write conflicting updates. For example, both requests may see one
item left in stock and both create orders.

The fix is not just application-level checks. Use database transactions,
conditional updates, locks, or unique constraints to protect the invariant.

### 2. How do optimistic and pessimistic concurrency differ?

**Answer:** Optimistic concurrency assumes conflicts are rare. It detects them
using versions, timestamps, or conditional updates and retries or rejects stale
writes. Pessimistic concurrency locks data before modifying it.

Optimistic control works well for low-conflict workloads. Pessimistic locking is
useful when conflicts are frequent or the cost of retrying is high.

### 3. How do unique constraints prevent race conditions?

**Answer:** Unique constraints let the database reject duplicate rows even when
multiple application instances race. For example, a unique index on
`(user_id, event_id)` can prevent duplicate registrations.

This is stronger than checking first in application code because the check and
insert are protected by the database.

### 4. How do you test for race conditions?

**Answer:** Use stress tests, parallel test execution, race detectors where the
runtime supports them, and targeted tests that fire many concurrent requests at
the same resource.

Race tests can be nondeterministic. The best protection is design: atomic
operations, constraints, idempotency keys, and small critical sections.
