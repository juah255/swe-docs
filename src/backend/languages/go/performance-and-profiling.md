# Performance and Profiling

Optimize measured bottlenecks, not code that merely looks expensive. Backend
latency often comes from database access, network calls, locks, or queueing long
before language-level instruction speed matters.

## Start With Service-Level Evidence

Define the problem before selecting a tool:

- response-time percentiles;
- throughput and error rate;
- CPU or memory saturation;
- goroutine and queue growth;
- garbage-collection cost;
- lock contention;
- dependency and database latency.

Use production-like request sizes and concurrency. A faster microbenchmark does
not guarantee better whole-service performance.

## Benchmarks

Go benchmarks live in test files:

```go
func BenchmarkEncodeOrder(b *testing.B) {
    order := newBenchmarkOrder()
    b.ReportAllocs()

    for b.Loop() {
        if _, err := EncodeOrder(order); err != nil {
            b.Fatal(err)
        }
    }
}
```

Run a benchmark several times and compare statistically rather than trusting
one noisy result. Keep setup outside the timed region or use the benchmark
timer controls where setup must happen per case.

Benchmark realistic values. Compiler optimization and dead-code elimination
can make artificial work disappear if its result is never observable.

## CPU Profiles

A CPU profile samples where running goroutines spend processor time. It helps
find expensive parsing, encoding, algorithms, compression, hashing, and lock
paths.

Inspect cumulative cost as well as flat function cost. A small wrapper may
appear cheap itself while calling most of the expensive work underneath.

## Heap and Allocation Profiles

- An **in-use heap** profile shows memory retained at the sample time.
- An **allocation** profile shows cumulative allocation activity.

Use retained memory to investigate leaks and total allocation to reduce garbage-
collector pressure. They answer different questions.

Heap profiles can contain user data and secrets. Protect them as sensitive
production artifacts.

## Goroutine and Blocking Profiles

A goroutine profile reveals stacks of live goroutines and is useful for leaks,
deadlocks, and stuck I/O. Block and mutex profiles show time waiting on channel
operations and locks.

Collect profiles during the problem when possible. A profile after traffic has
stopped may miss the queue, contention, or blocked state that caused the
incident.

## Runtime Tracing

A runtime trace shows scheduling, goroutine transitions, network blocking,
garbage collection, and processor utilization over a time window. It is useful
when aggregate CPU profiles cannot explain latency or concurrency behavior.

Traces can be large and add overhead. Capture a short, representative interval
and restrict access to the result.

## Allocations and Escape Analysis

Allocation reduction can lower garbage-collection work, but stack versus heap
placement is a compiler decision. Use compiler diagnostics and benchmarks to
verify a suspected escape.

Common improvements after measurement include:

- preallocating a slice with a realistic capacity;
- reusing a buffer within a clear owner;
- streaming instead of building a large result;
- avoiding repeated string and byte conversions;
- reducing interface or closure use in a proven hot path;
- batching work to remove repeated setup and network overhead.

Do not replace clear APIs with pointer-heavy code solely to guess at allocation
behavior.

## Concurrency Is Not Free

More goroutines can increase throughput for waiting work, but beyond downstream
capacity they increase queueing, memory, scheduling, and contention.

For CPU-bound work, start near available CPU parallelism and measure. For I/O-
bound work, size concurrency around latency, connection pools, rate limits, and
the dependency's safe capacity.

## A Practical Optimization Order

1. Remove unnecessary database and network round trips.
2. Fix query plans and accidental N+1 access.
3. Bound fan-out, queues, caches, and result sizes.
4. Stream, paginate, or batch large work.
5. Choose a better algorithm or data structure.
6. Profile CPU, allocation, locks, and goroutines.
7. Tune low-level allocation and concurrency only with benchmark evidence.

Re-run correctness tests, race detection, and the original performance
measurement after every meaningful change.
