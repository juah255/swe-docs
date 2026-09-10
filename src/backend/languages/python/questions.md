# Python Questions

These questions review the language and runtime concepts that matter most in
backend systems.

## 1. What is the GIL, and how does it affect concurrency?

**Answer:** In the normal CPython runtime, the Global Interpreter Lock lets only
one thread in a process execute Python bytecode at a time. Threads can still
overlap I/O because many blocking operations release the lock, but they usually
do not make CPU-bound Python bytecode run in parallel. Use processes or suitable
native libraries for CPU parallelism.

The GIL does not make application-level shared state safe. Multi-step updates
can still interleave and require synchronization.

## 2. When should you use threads, processes, or `asyncio`?

**Answer:** Use threads to overlap blocking I/O from synchronous libraries,
processes for substantial CPU-bound Python work, and `asyncio` for many
concurrent I/O operations when the complete call path uses async-compatible
libraries.

Bound concurrency in all three models so the application cannot overwhelm
memory or downstream dependencies.

## 3. What is the difference between an iterable, iterator, and generator?

**Answer:** An iterable can return an iterator. An iterator returns one value at
a time through `next()` and is usually consumed once. A generator is a compact
way to create an iterator, commonly with `yield`.

Generators are useful for streaming and large datasets because they produce
values lazily, but the underlying data source must also support incremental
reading for the memory benefit to be real.

## 4. Why are mutable default arguments dangerous?

**Answer:** Default argument values are evaluated once when the function is
defined. If a list or dictionary default is mutated, later calls see the same
object. Use `None` as the default and create a new object inside the function.

## 5. What is the difference between `is` and `==`?

**Answer:** `is` compares object identity; `==` compares values using the
object's equality behavior. Use `is` for singletons such as `None` and `==` for
ordinary value comparison.

## 6. What are decorators, and what can go wrong with them?

**Answer:** A decorator replaces a function or class with a wrapped version.
Backend applications use them for logging, authorization, caching, retries, and
transactions.

Use `functools.wraps` to preserve metadata. Keep ordering, sync-versus-async
behavior, exception handling, and hidden side effects in mind when composing
decorators.

## 7. What problem do context managers solve?

**Answer:** Context managers pair setup with guaranteed cleanup around a `with`
block. They are suited to files, locks, connections, transactions, temporary
resources, and tracing spans. Cleanup runs even when the body raises an
exception.

## 8. How does CPython manage memory?

**Answer:** CPython primarily uses reference counting and supplements it with a
collector for unreachable reference cycles. Memory problems usually come from
objects that are still reachable through caches, globals, callbacks, queues, or
running tasks—not from the absence of garbage collection.

## 9. What are the typical costs of `list`, `dict`, and `set`?

**Answer:** List indexing and amortized append are typically `O(1)`, while
insertion near the front is `O(n)`. Dictionary lookup, insertion, and deletion
are typically `O(1)` on average. Set membership is also typically `O(1)` on
average, compared with `O(n)` membership for a list.

Real performance also depends on hashing, allocation, object size, and access
patterns.

## 10. What do type hints guarantee at runtime?

**Answer:** By default, nothing. Type hints are metadata used by static checkers,
IDEs, and frameworks. Untrusted input still needs runtime parsing and validation
at HTTP, queue, configuration, and persistence boundaries.

## 11. When would you use a `Protocol`?

**Answer:** Use a protocol when code depends on a small behavior rather than a
specific implementation. Any object with compatible members satisfies the
protocol for static typing, which reduces coupling and makes test doubles
straightforward.

## 12. How should a Python service be tested?

**Answer:** Use fast unit tests for business behavior, integration tests for
database and service adapters, and a small number of end-to-end tests for
critical flows. Tests should be independent, deterministic, and responsible for
cleaning up external state.

Mocks are most useful at nondeterministic boundaries. Over-mocking internal
calls makes refactoring needlessly difficult.

## 13. Why can an `async def` function still block a server?

**Answer:** `async def` changes how a function can suspend; it does not make its
operations non-blocking. A synchronous database call, `time.sleep()`, large file
operation, or CPU-heavy loop blocks the event-loop thread until it returns.

## 14. What matters when sizing Python web workers?

**Answer:** Consider CPU, memory per process, I/O wait time, expected
concurrency, connection pools, dependency limits, and latency targets. Every
worker has its own heap, pools, and caches, so adding workers can exhaust memory
or database connections even when CPU is available.

Validate the configuration with production-like load tests and saturation
metrics.

## 15. How should `match`/`case` constants be written?

**Answer:** A bare name in a pattern is normally a capture pattern. Use a
qualified name, such as `EventType.USER_CREATED`, when comparing with a constant.
Guards can handle conditions that do not fit naturally into the pattern.

## 16. What makes a Python service production-ready?

**Answer:** It needs finite timeouts, bounded pools and concurrency, runtime
input validation, structured logging, metrics, secure configuration, graceful
shutdown, reproducible builds, dependency management, and tested failure paths.
The process and deployment model are part of the application design.
