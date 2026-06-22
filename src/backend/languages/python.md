# Python

Python is widely used for backend APIs, automation, data processing, machine
learning systems, and scripting. Mid-level and senior interviews usually focus
on runtime behavior, concurrency, typing, memory, packaging, testing, and
production service design.

## Questions and Answers

### 1. What is the Global Interpreter Lock (`GIL`)?

**Answer:** The `GIL` is a lock in CPython that allows only one thread to
execute Python bytecode at a time.

CPython uses the `GIL` to simplify memory management and protect interpreter
internals while Python objects are being accessed or modified. The `GIL` is
process-local: each Python process has its own interpreter state and its own
`GIL`.

Impact:

- threads can help with I/O-bound work;
- threads usually do not speed up CPU-bound Python code;
- multiprocessing or native extensions can use multiple CPU cores more
  effectively.

The `GIL` does not mean Python cannot handle concurrent I/O. It means CPU-bound
parallelism needs different design choices.

| Workload | Good choice | Why |
| --- | --- | --- |
| Blocking I/O | Threads | The `GIL` is released during many I/O waits. |
| High-concurrency I/O | `asyncio` | Many waits can overlap in one event loop. |
| CPU-bound Python code | Processes | Each process has its own `GIL` and can run on another core. |
| CPU-heavy native code | Native extensions | Libraries such as NumPy can release the `GIL` during heavy work. |

### 2. When should you use threads, processes, or `asyncio`?

**Answer:**

- Use threads for blocking I/O when libraries do not support async.
- Use processes for CPU-bound work that needs parallel execution.
- Use `asyncio` for high-concurrency I/O with async-compatible libraries.

In backend APIs, `asyncio` works well for many simultaneous network calls, but a
single blocking database driver or CPU-heavy function can still block the event
loop.

### 3. What are generators, and why are they useful?

**Answer:** A generator produces values lazily using `yield`. It does not build
the full result in memory at once.

Generators are useful for:

- streaming files;
- processing large query results;
- pipelines;
- pagination;
- memory-efficient transformations.

Example:

```py
def read_ids(rows):
    for row in rows:
        yield row["id"]
```

### 4. What are decorators?

**Answer:** A decorator is a callable that takes another function or class and
returns a modified version of it.

Common backend uses:

- authentication checks;
- caching;
- logging;
- tracing;
- retries;
- rate limiting.

Use `functools.wraps` when writing function decorators so metadata such as the
function name and docstring is preserved.

### 5. What are context managers?

**Answer:** A context manager manages setup and cleanup around a block of code,
usually with the `with` statement.

Examples:

- closing files;
- database transactions;
- locks;
- temporary resources.

```py
with open("data.txt") as file:
    content = file.read()
```

For backend work, context managers help make resource cleanup explicit and
reliable.

### 6. How does Python manage memory?

**Answer:** CPython primarily uses reference counting. When an object's
reference count reaches zero, it can be freed. CPython also has a cyclic garbage
collector for reference cycles.

Common memory concerns:

- keeping large objects in global caches;
- reference cycles involving objects with cleanup behavior;
- loading entire files or query results into memory;
- accidental retention through closures.

Use profiling tools before optimizing memory manually.

### 7. What are the performance characteristics of `list`, `dict`, and `set`?

**Answer:** A `list` is dynamic array-like storage. Index access and append are
usually `O(1)`, while inserting or deleting near the front is `O(n)`.

A `dict` is a hash table. Lookup, insert, and delete are usually `O(1)` on
average.

A `set` is also hash-based and is useful for membership checks and removing
duplicates.

Senior-level detail: performance depends on hashing, object size, memory
pressure, and access patterns.

### 8. How should Python type hints be used?

**Answer:** Type hints document expected types and allow tools such as mypy,
pyright, and IDEs to catch mistakes before runtime.

Use type hints for:

- public functions;
- service boundaries;
- data models;
- complex return values;
- reusable libraries.

Type hints are not runtime validation by default. Validate external input with
tools such as Pydantic, dataclasses with validation, Marshmallow, or framework
request validators.

### 9. How do you structure testing in Python?

**Answer:** Use unit tests for isolated logic, integration tests for database or
service boundaries, and end-to-end tests for critical flows.

Common tools:

- `pytest`;
- fixtures for setup;
- mocks for external services;
- factories for test data;
- coverage tools for visibility.

Good tests should avoid depending on test order and should clean up external
state such as database rows, files, and queues.

### 10. What matters for production Python web services?

**Answer:** Production Python services need clear process, I/O, and resource
management.

Important areas:

- use a proper ASGI or WSGI server setup;
- configure worker count based on workload;
- set timeouts for HTTP clients and database calls;
- use connection pooling;
- avoid blocking the async event loop;
- validate input at boundaries;
- log structured events;
- monitor latency, errors, memory, and worker restarts.

Most Python backend performance issues come from blocking I/O, inefficient
queries, large in-memory data handling, or too few worker processes.
