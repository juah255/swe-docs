# Typing and Data Models

Python remains dynamically typed at runtime, but type hints let static analysis
tools verify contracts before deployment. Good annotations document intent,
improve refactoring, and expose vague boundaries in an application.

## What Type Hints Do

Annotations are metadata. Python does not normally reject a wrong argument at
runtime:

```py
def find_user(user_id: int) -> User | None:
    ...
```

Tools such as mypy, Pyright, and IDEs can report incompatible calls. Runtime
validation is a separate concern and is especially important for HTTP payloads,
environment variables, queue messages, and database results.

## Type the Boundaries First

Prioritize annotations for:

- public functions and reusable libraries;
- service and repository interfaces;
- request and response models;
- configuration objects;
- callbacks and complex return values.

Local variables with obvious types rarely need annotations.

## Collections and Optional Values

Use precise collection interfaces based on what a function needs:

```py
from collections.abc import Iterable, Mapping


def select_names(
    user_ids: Iterable[int],
    users: Mapping[int, User],
) -> list[str]:
    return [users[user_id].name for user_id in user_ids if user_id in users]
```

Accepting `Iterable` and `Mapping` is more flexible than requiring `list` and
`dict`. Return a concrete type when callers benefit from knowing the behavior.

`User | None` means the value may be absent. Handle that case explicitly before
using it.

## Type Aliases and New Types

A type alias gives a complex type a readable name. `NewType` distinguishes
values that share the same runtime representation:

```py
from typing import NewType, TypeAlias

UserId = NewType("UserId", int)
Headers: TypeAlias = dict[str, str]
```

Static checkers can then prevent an `OrderId` from being passed where a
`UserId` is expected, even if both are integers at runtime.

## Protocols and Structural Typing

A `Protocol` describes behavior without requiring inheritance:

```py
from typing import Protocol


class UserStore(Protocol):
    def get(self, user_id: int) -> User | None: ...


def load_profile(store: UserStore, user_id: int) -> Profile:
    user = store.get(user_id)
    if user is None:
        raise LookupError(user_id)
    return Profile.from_user(user)
```

Any object with a compatible `get` method satisfies the protocol for static
typing. This keeps application code loosely coupled and makes test doubles
simple.

## Generics

Generics preserve relationships between input and output types:

```py
from collections.abc import Sequence
from typing import TypeVar

T = TypeVar("T")


def first(items: Sequence[T]) -> T:
    if not items:
        raise ValueError("items cannot be empty")
    return items[0]
```

Avoid reaching for `Any` whenever a type is inconvenient. `Any` disables useful
checking and can spread through a codebase. Use `object` when a value may truly
be anything but must be narrowed before use.

## Dataclasses and Domain Models

Dataclasses remove boilerplate for internal value objects:

```py
from dataclasses import dataclass
from decimal import Decimal


@dataclass(frozen=True, slots=True)
class Money:
    amount: Decimal
    currency: str

    def __post_init__(self) -> None:
        if self.amount < 0:
            raise ValueError("amount cannot be negative")
```

- `frozen=True` prevents normal attribute reassignment.
- `slots=True` prevents an instance dictionary and can reduce memory use.
- `__post_init__` can enforce invariants, though complex creation logic may be
  clearer in a factory function.

Do not use one model for every layer. An external request, a domain entity, and
a database row have different responsibilities and may deserve different
types.

## Runtime Validation

Validate untrusted data at the boundary with a deliberate schema or parser.
Pydantic, framework serializers, or explicit conversion functions can turn
untrusted input into typed application values.

After validation, internal code should be able to rely on the model's
invariants. Revalidating the same data in every function adds noise without
improving safety.

## Practical Rules

- Run a type checker in continuous integration.
- Avoid annotations that are broader than the actual contract.
- Prefer protocols for small consumer-owned interfaces.
- Keep runtime validation at external boundaries.
- Treat `cast()` as an assertion to the checker, not as conversion or
  validation.
