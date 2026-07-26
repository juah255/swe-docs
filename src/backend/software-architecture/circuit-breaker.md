# Circuit Breaker

A **circuit breaker** prevents a failing dependency from consuming resources and cascading failures across the system. It monitors calls to a dependency and temporarily stops sending requests when failures exceed a threshold.

## How It Works

```text
Closed State (normal) -> failures exceed threshold -> Open State (stop calls)
                                                          |
                                                    timeout expires
                                                          |
                                                     Half-Open State
                                                    /                \
                                            success                 failure
                                              /                        \
                                       Closed State               Open State
```

Three states:

- **Closed** -- normal operation. Requests flow through. Failures are counted.
- **Open** -- dependency is failing. Requests are rejected immediately without calling the dependency.
- **Half-Open** -- after a timeout, allow a test request through. If it succeeds, close the circuit. If it fails, open it again.

## Why Circuit Breakers Are Needed

Without a circuit breaker, a failing dependency causes:

- **Thread pool exhaustion** -- threads block waiting for slow responses
- **Connection pool exhaustion** -- all connections are used by the failing call
- **Cascading failures** -- the failing service drags down callers, which drag down their callers
- **Resource starvation** -- CPU, memory, and network are consumed by retries and timeouts

## Configuration

Key parameters:

- **Failure threshold** -- number of failures before opening the circuit (e.g., 5 failures in 10 seconds)
- **Timeout** -- how long to wait in open state before trying half-open (e.g., 30 seconds)
- **Success threshold** -- number of successful half-open requests before closing (e.g., 3 consecutive successes)

## Relationship with Timeouts and Retries

Circuit breakers work together with timeouts and retries:

1. **Timeout** -- prevent indefinite blocking on a slow dependency
2. **Retry** -- attempt the operation again on transient failures
3. **Circuit breaker** -- stop attempting entirely when the dependency is clearly failing

```text
Request -> Timeout (5s) -> Retry (1 attempt) -> Circuit Breaker (if open, reject immediately)
```

## Bulkhead vs Circuit Breaker

- **Circuit breaker** stops calling a failing dependency entirely
- **Bulkhead** isolates failures to a resource pool so one failing dependency cannot drain resources from healthy ones

They are complementary. Use bulkheads to isolate resource pools and circuit breakers to stop calling clearly failing dependencies.

## Implementation

Common libraries:

- **Hystrix** (Netflix, legacy) -- the original circuit breaker library
- **Resilience4j** -- lightweight, Java, successor to Hystrix
- **Polly** (.NET) -- resilience and fault handling
- **golang-circuit-breaker** -- Go implementations
- **Istio/Envoy** -- service mesh with built-in circuit breaking

## Mid/Senior Interview Questions and Answers

### 1. How do circuit breakers prevent cascading failures?

**Answer:** When a dependency fails repeatedly, the circuit breaker opens and
stops sending requests. This prevents the failing service from consuming
resources (threads, connections, memory) in the caller.

After a timeout, the circuit breaker enters half-open state and allows a test
request. If it succeeds, the circuit closes and normal operation resumes. If it
fails, the circuit opens again.

### 2. When would you use a circuit breaker vs just timeouts and retries?

**Answer:** Timeouts and retries handle individual transient failures. Circuit
breakers handle sustained failures. Without a circuit breaker, retries against
a clearly failing dependency waste resources and delay recovery.

A circuit breaker detects a pattern of failures and stops sending requests
entirely, giving the failing service time to recover. It is the difference
between retrying a failing call and recognizing that the dependency is down.

### 3. How do you test circuit breakers?

**Answer:** Use fault injection to simulate dependency failures (return errors,
add latency, drop connections). Verify that the circuit opens after the failure
threshold, rejects requests in open state, transitions to half-open after the
timeout, and closes after successful half-open requests.

Chaos engineering tools (Chaos Monkey, Litmus) can test circuit breakers in
staging or production by injecting real failures into dependencies.
