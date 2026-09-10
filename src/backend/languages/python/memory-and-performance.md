# Memory and Performance

Performance work begins with measurement. Python services are often limited by
database queries or network calls rather than language execution, so optimize
the largest verified bottleneck instead of guessing from syntax.

## CPython Memory Management

CPython primarily uses **reference counting**. An object is usually reclaimed
when its reference count reaches zero. A cyclic garbage collector supplements
this mechanism by detecting unreachable reference cycles.

```py
parent.children.append(child)
child.parent = parent
```

The objects above form a cycle. That is not automatically a leak: the cyclic
collector can reclaim most unreachable cycles. Memory remains in use when some
live reference still reaches the objects.

## Common Retention Problems

- unbounded dictionaries or caches;
- global lists containing request or event data;
- closures and callbacks that capture large objects;
- tasks, futures, and exception tracebacks kept after completion;
- reading complete files or result sets when streaming would work;
- queues whose producers consistently outpace consumers.

The process's resident memory may not fall immediately after Python frees
objects. The allocator can keep memory available for reuse, and fragmentation
may prevent pages from being returned to the operating system.

## Collection Characteristics

These are typical average-case costs, not guarantees for every input:

| Operation | Typical cost | Note |
| --- | --- | --- |
| `items[index]` on a list | `O(1)` | Lists provide random access. |
| `items.append(value)` | Amortized `O(1)` | A resize occasionally copies elements. |
| Insert/delete near list front | `O(n)` | Later elements must move. |
| `key in mapping` | Average `O(1)` | Dictionaries use hashing. |
| `value in values_set` | Average `O(1)` | Sets are designed for membership checks. |
| `value in values_list` | `O(n)` | The list may need a full scan. |
| `deque.appendleft(value)` | `O(1)` | Prefer a deque for both-ended queues. |

Big O alone is not enough. Hashing cost, allocation, cache locality, object
size, and access patterns matter in real services.

## Lazy Processing

Generators and iterators reduce peak memory when data can be processed one item
at a time:

```py
total = sum(invoice.amount for invoice in invoice_stream)
```

Laziness changes lifetime and failure behavior. Errors may occur during
iteration rather than when the generator is created, and the source resource
must remain open until iteration finishes.

## Measure at the Right Level

Useful measurements include:

- request latency percentiles and throughput;
- database query counts and timings;
- external-call latency and timeout rates;
- CPU time and event-loop lag;
- allocation hot spots and retained memory;
- queue depth, pool saturation, and worker utilization.

Use representative data and production-like traffic. A microbenchmark is
useful for comparing two isolated implementations but cannot predict full
service behavior.

## A Practical Optimization Order

1. Remove unnecessary network and database round trips.
2. Fix query plans and prevent accidental N+1 queries.
3. Bound payloads, queues, caches, and result sets.
4. Replace an inefficient algorithm or data structure.
5. Batch work where it reduces repeated overhead without harming latency.
6. Profile CPU and allocations before changing low-level code.
7. Move a verified hot path to a specialized library, process, or service only
   when the added complexity is justified.

## Caching Carefully

A cache exchanges memory and consistency for speed. Define:

- a maximum size;
- an eviction policy;
- an expiration policy;
- how stale data is handled;
- whether entries are isolated by user or tenant;
- metrics for hit rate and memory use.

An unbounded in-process cache is a memory leak with a friendly name. Remember
that every server worker normally has its own cache, so memory usage multiplies
with the worker count.

## Optimization Pitfalls

- choosing async code for a CPU bottleneck;
- adding threads without bounding downstream concurrency;
- loading all ORM rows before filtering or aggregating;
- repeatedly serializing large objects between processes;
- optimizing a tiny function while slow queries dominate latency;
- relying on `gc.collect()` instead of removing unwanted references.

Keep changes evidence-driven, benchmark the result, and preserve clear code
unless the performance benefit is meaningful.
