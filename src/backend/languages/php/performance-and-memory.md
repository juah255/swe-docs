# Performance and Memory

Measure before optimizing. For web services, database queries, remote calls,
serialization, framework boot, and cache misses often dominate language-level
operations.

## OPcache and JIT

OPcache stores compiled PHP bytecode in shared memory so workers do not parse and
compile every file on each request. Enable and size it for production, monitor
its memory and restart behavior, and use an intentional deployment strategy for
timestamp validation or cache resets.

PHP's JIT can help selected CPU-heavy workloads, but many web applications are
I/O-bound and see little benefit. Benchmark the actual application; JIT does not
fix slow SQL, network latency, or an inefficient object graph.

## Profiling

Use an application performance monitor, sampling profiler, request profiler,
database slow-query log, and targeted benchmarks. Measure:

- wall time and CPU time;
- memory peak and allocations;
- database query count and duration;
- cache hit ratio;
- remote-call latency and retries;
- FPM queue depth and worker saturation;
- tail percentiles, not only averages.

A microbenchmark must warm up appropriately, avoid measuring setup by accident,
and represent the production PHP build. Treat results as evidence for one narrow
question.

## Copy-on-Write Values

PHP arrays and strings are generally copied lazily. Assigning an array can share
storage until one copy is changed, at which point a real copy may be required.
Passing a large array by value is therefore not automatically a full copy, but
mutating it can create a large allocation.

References can avoid some copies but introduce aliasing and often make code less
predictable. Choose streaming, smaller value shapes, or a better data model
before adding references as an optimization.

## Large Data Sets

Avoid loading an unbounded result into a PHP array. Use database pagination,
cursors, generators, and chunked work. Be aware that a database driver may buffer
all rows even when PHP code yields one at a time.

Release references between batches in long-running workers and clear ORM entity
managers or identity maps according to the library's guidance. Track memory over
many jobs, not only one iteration.

## Database and Cache Behavior

Eliminate N+1 queries, fetch only required fields, add indexes based on real
plans, and keep transactions short. Size each process pool against the database
connection budget; more FPM workers can reduce reliability if each can open a
connection.

Cache stable, expensive results with a complete key, bounded lifetime, and clear
invalidation owner. Include tenant, locale, permission scope, and version when
they change the result. Protect hot keys from stampedes with locking, jitter, or
stale-while-revalidate behavior.

## Autoloading and Bootstrap

Build an optimized Composer autoloader for production. Cache compiled container,
route, annotation, attribute, or template metadata when the framework supports
it. Do not run dependency resolution, development discovery, or schema changes
on every request.

An authoritative class map can improve negative lookups but may break runtime
class generation. Test it with the production framework and plugins.

## FPM Capacity

FPM pool settings determine how many PHP requests run concurrently and how idle
workers are managed. Size the pool from measured memory per worker, latency,
CPU, database capacity, and traffic behavior.

Monitor queueing and rejection. Raising the worker count without downstream
capacity can increase memory use, lock contention, and tail latency.

