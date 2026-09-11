# Performance and Memory

Node.js performs well for I/O-heavy services when callbacks remain short and
concurrency stays bounded. Measure full request paths before optimizing: slow
queries, external calls, serialization, and resource contention often matter
more than individual JavaScript expressions.

## Event-Loop Health

All requests handled by one event-loop thread compete for the same JavaScript
execution time. A long synchronous task delays unrelated timers, I/O callbacks,
and promise continuations.

Common event-loop blockers include:

- large JSON parsing or serialization;
- expensive regular expressions;
- synchronous filesystem and cryptographic APIs;
- compression, image processing, and document conversion;
- loops over unexpectedly large collections;
- excessive microtask or `process.nextTick()` scheduling.

Monitor event-loop delay together with CPU usage and request latency. High delay
with high CPU points toward synchronous work; low CPU can instead indicate
container throttling or runtime pauses.

## CPU-Bound Work

`async`/`await` does not move computation to another thread. For substantial
CPU-heavy JavaScript, consider:

- worker threads within the process;
- a separate worker process;
- a durable job queue for restart-safe work;
- a specialized native or external service when justified.

Worker threads share a process but run JavaScript in separate isolates. Passing
large values normally adds cloning or transfer cost, so batch enough work to
justify the overhead. Bound the number of workers and queued jobs.

## Garbage Collection

The JavaScript engine reclaims objects that are no longer reachable. Modern
collectors use generations and several phases to keep common collections short,
but garbage collection still consumes CPU and can pause application execution.

A memory leak is usually unintended reachability rather than a broken collector.
Common sources include:

- unbounded maps, arrays, and caches;
- event listeners that are never removed;
- timers and subscriptions that outlive their owner;
- closures retaining request data;
- unresolved promises and abandoned tasks;
- buffered streams and queues without backpressure.

## Event Listeners

Listeners create a reference from the emitter to the callback and everything
the callback captures. Remove listeners when their owner is disposed, or use an
abort signal or one-time listener when appropriate.

Increasing the listener-warning threshold does not fix a leak. First determine
why ownership is unclear or listeners accumulate.

## Caches

Every cache needs a maximum size, expiration policy, and observability. Define
how stale data, invalidation, and tenant isolation work.

In-process caches are duplicated across worker processes and replicas. They may
be inconsistent and their total memory use equals much more than one cache's
configured size.

## Streams and Large Values

Use streams or incremental parsers for large files and payloads. Buffering a
large request several times—for parsing, validation, transformation, and
logging—multiplies peak memory.

Apply size limits before buffering. A stream still needs backpressure and
cleanup on error or client disconnect.

## Profiling Workflow

1. Define the failing service-level measure: latency, throughput, CPU, memory,
   or queue time.
2. Reproduce with representative data and concurrency.
3. Separate application time from database and external-call time.
4. Use CPU profiles, heap snapshots, allocation sampling, and event-loop
   metrics to find the dominant cause.
5. Change one meaningful bottleneck.
6. repeat the same measurement and watch for regressions elsewhere.

Heap snapshots can contain credentials and user data. Capture and store them as
sensitive production artifacts.

## A Practical Optimization Order

1. Remove unnecessary network and database round trips.
2. Fix query plans and accidental N+1 access.
3. Bound requests, queues, pools, caches, and fan-out.
4. Stream or paginate large values.
5. Replace an inefficient algorithm or data structure.
6. Profile CPU and memory before low-level changes.
7. Add worker or process parallelism only for measured CPU work.

Performance changes should keep failure and cancellation behavior correct. A
faster happy path is not an improvement if it creates unbounded resource use.
