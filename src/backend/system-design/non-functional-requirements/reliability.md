# Reliability

**Reliability** is the probability that the system performs its intended function correctly without failure over a given time period. A reliable system produces correct results even when components fail.

Availability is about being **reachable**. Reliability is about being **correct**.

## Techniques

- **Retries** -- attempt failed operations again with backoff
- **Circuit Breaker** -- stop calling a failing dependency temporarily
- **Idempotency** -- safe retries without side effects
- **Durable Queues** -- persist messages so work is not lost on failure

## Key Concepts

- **Correctness** -- the system returns the right data and processes operations accurately
- **Durability** -- committed data survives failures (a subset of reliability)
- **Fault tolerance** -- the system continues operating despite component failures
- **Graceful degradation** -- reduced functionality rather than total failure

## How to Achieve Reliability

### Redundancy

- Multiple instances behind a load balancer
- Database replication (primary-replica or multi-primary)
- Multi-AZ and multi-region deployment
- No single point of failure in the critical path

### Retries and Backoff

- Retry failed requests with **exponential backoff** (1s, 2s, 4s, 8s...)
- Add **jitter** to prevent thundering herd
- Limit max retries to avoid infinite loops
- Only retry idempotent operations (GET, PUT, DELETE with idempotency keys)

### Circuit Breakers

- Detect when a dependency is failing
- Stop sending requests temporarily (open circuit)
- Periodically test if the dependency has recovered (half-open)
- Prevent cascading failures across services

### Idempotency

- An operation is **idempotent** if doing it multiple times has the same effect as doing it once
- Essential for safe retries in distributed systems
- Implement with idempotency keys or deduplication

### Timeouts

- Set explicit timeouts on every external call
- A slow dependency should not block the entire system
- Combine with circuit breakers for full protection

### Bulkheads

- Isolate failures to a single component
- Separate connection pools, worker pools, or queues per dependency
- A failing service cannot drain resources from healthy ones

## Reliability vs Cost

- Perfect reliability is impossible -- every component eventually fails
- The goal is to meet the business requirement at acceptable cost
- Focus reliability investment on the critical path

## Levers

- Idempotency for safe retries
- Retries with dead-letter queues
- Database constraints and transactions
- Exactly-once semantics where possible
- Chaos testing and fault injection
- Circuit breakers, bulkheads, timeouts

## Mid/Senior Interview Questions and Answers

### 1. How do you make a system resilient to failures?

**Answer:** Assume every dependency can fail. Use redundancy and failover,
timeouts and retries with backoff, circuit breakers, bulkheads to isolate
failures, and graceful degradation so a partial outage does not cascade.

Make retried operations idempotent, and design so that a non-critical dependency
failing (say, recommendations) never breaks the core flow (checkout).

### 2. What is the difference between availability and reliability?

**Answer:** Availability means the system is reachable and responsive.
Reliability means the system produces correct results.

A system can be highly available but unreliable (always responds, but sometimes
with wrong data). A system can be reliable but not very available (correct when
up, but frequently down). You need both.

### 3. How do circuit breakers prevent cascading failures?

**Answer:** When a dependency fails repeatedly, the circuit breaker opens and
stops sending requests. This prevents the failing service from consuming
resources (threads, connections, memory) in the caller.

After a timeout, the circuit breaker enters half-open state and allows a test
request. If it succeeds, the circuit closes and normal operation resumes. If it
fails, the circuit opens again.
