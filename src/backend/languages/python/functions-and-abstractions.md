# Functions and Pythonic Abstractions

Python treats functions as values. They can be passed as arguments, returned
from other functions, stored in objects, and decorated. Iterators and context
managers build on the same small-protocol approach.

## Function Parameters

Python supports positional-only, positional-or-keyword, and keyword-only
parameters:

```py
def create_user(
    email: str,
    /,
    *,
    send_welcome_email: bool = True,
) -> int:
    ...
```

The `/` makes `email` positional-only, while `*` makes the remaining parameter
keyword-only. Keyword-only options make Boolean flags and configuration-heavy
calls easier to understand.

Use `*args` for extra positional arguments and `**kwargs` for extra keyword
arguments, but do not use them to hide an unclear interface.

## First-Class Functions and Closures

A closure remembers names from the enclosing scope:

```py
from collections.abc import Callable


def minimum_length(size: int) -> Callable[[str], bool]:
    def validate(value: str) -> bool:
        return len(value) >= size

    return validate
```

Closures are useful for callbacks and small factories. Be careful when a
long-lived closure captures request objects, large collections, or mutable loop
variables, because those objects remain reachable.

## Decorators

A decorator receives a function or class and returns a replacement. Common
backend uses include authorization, caching, tracing, metrics, retries, and
transaction handling.

```py
from collections.abc import Callable
from functools import wraps
from time import perf_counter
from typing import ParamSpec, TypeVar

P = ParamSpec("P")
R = TypeVar("R")


def timed(function: Callable[P, R]) -> Callable[P, R]:
    @wraps(function)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        started = perf_counter()
        try:
            return function(*args, **kwargs)
        finally:
            duration = perf_counter() - started
            print(f"{function.__name__} took {duration:.3f}s")

    return wrapper
```

`functools.wraps` preserves the original name, docstring, annotations, and
introspection metadata. A decorator should keep behavior unsurprising; ordering
also matters when several decorators wrap the same function.

## Iterables and Iterators

An **iterable** can produce an iterator through `iter()`. An **iterator**
produces one item at a time through `next()` and raises `StopIteration` when
exhausted.

Lists are reusable iterables. Most iterators are single-use:

```py
iterator = iter([10, 20])
assert next(iterator) == 10
assert list(iterator) == [20]
assert list(iterator) == []
```

This distinction matters when an API accepts a stream: iterating once to log or
validate it may consume it before the real operation begins.

## Generators

A function containing `yield` returns a generator. Values are produced lazily,
so the complete result does not need to fit in memory.

```py
from collections.abc import Iterable, Iterator


def active_ids(rows: Iterable[dict[str, object]]) -> Iterator[int]:
    for row in rows:
        if row.get("active") is True:
            yield int(row["id"])
```

Generators work well for file streaming, large query results, pagination, and
transformation pipelines. They do not make the underlying source efficient by
themselves: a database driver may still fetch all rows before iteration.

## Context Managers

A context manager guarantees paired setup and cleanup through `with`:

```py
with database.transaction():
    account.debit(amount)
    ledger.record(account.id, amount)
```

Class-based context managers implement `__enter__` and `__exit__`. Generator-
based context managers can use `contextlib.contextmanager`:

```py
from collections.abc import Iterator
from contextlib import contextmanager


@contextmanager
def managed_connection(pool: object) -> Iterator[object]:
    connection = pool.acquire()
    try:
        yield connection
    finally:
        pool.release(connection)
```

Context managers are appropriate for files, connections, locks, transactions,
temporary resources, and tracing spans. Async resources use `async with` and
the asynchronous context manager protocol.

## Choosing the Abstraction

| Need | Prefer |
| --- | --- |
| Transform one input into one output | Function |
| Preserve a small amount of private state | Closure or callable object |
| Apply cross-cutting behavior | Decorator |
| Produce a lazy sequence | Generator or iterator |
| Guarantee setup and cleanup | Context manager |

Choose the simplest abstraction that makes ownership, lifetime, and failure
behavior obvious.
