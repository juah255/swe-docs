# Language Fundamentals

Python is dynamically typed: names are not locked to one type, but every value
has a type at runtime. Understanding how names refer to objects explains many
behaviors that otherwise look surprising.

## Names, Objects, and Assignment

Assignment binds a name to an object. It does not copy the object.

```py
first = {"roles": ["reader"]}
second = first
second["roles"].append("editor")

assert first == {"roles": ["reader", "editor"]}
```

Both names refer to the same dictionary. Create an independent object when
shared mutation is not intended. A shallow copy duplicates only the outer
container; use a deep copy only when nested objects must also be copied and the
performance cost is justified.

## Mutable and Immutable Values

Common immutable types include `int`, `float`, `bool`, `str`, `bytes`, `tuple`,
and `frozenset`. Common mutable types include `list`, `dict`, `set`, and most
user-defined objects.

Immutability is useful for stable values and hashable keys. A tuple is hashable
only when all its elements are hashable.

Avoid mutable default arguments because the default object is created once,
when the function is defined:

```py
def add_tag(tag: str, tags: list[str] | None = None) -> list[str]:
    result = [] if tags is None else tags
    result.append(tag)
    return result
```

## Equality and Identity

- `==` asks whether two values are equivalent.
- `is` asks whether two references point to the same object.

Use identity for singletons such as `None`:

```py
if user is None:
    raise LookupError("user not found")
```

Do not use `is` to compare strings or numbers. Interpreter optimizations may
reuse some objects, but that is not a semantic guarantee.

## Truthiness

`None`, `False`, numeric zero, and empty containers are false in a Boolean
context. Most other values are true.

Be precise when empty and missing mean different things:

```py
if result is None:
    # No result was produced.
    ...
elif not result:
    # A result exists, but it is empty.
    ...
```

## Scope and Name Resolution

Python resolves a name using the **LEGB** order:

1. Local scope
2. Enclosing function scopes
3. Global module scope
4. Built-in scope

Use `nonlocal` to rebind a name in an enclosing function and `global` to rebind
a module-level name. Both should be used sparingly; explicit state passed
through objects or function parameters is generally easier to test.

## Comprehensions

Comprehensions are concise tools for simple transformations and filters:

```py
active_emails = {
    user.email.lower()
    for user in users
    if user.is_active
}
```

Prefer a regular loop when the expression contains multiple conditions, side
effects, or complex error handling. Readability matters more than saving lines.

## Exceptions

Catch the narrowest exception that the current layer can handle meaningfully:

```py
try:
    port = int(raw_port)
except ValueError as exc:
    raise ConfigurationError("PORT must be an integer") from exc
```

Important practices:

- preserve the original cause with `raise ... from exc`;
- avoid a bare `except`, which also catches shutdown-related exceptions;
- do not use exceptions for ordinary branching in a hot path;
- translate low-level exceptions at architectural boundaries;
- put unconditional cleanup in `finally` or a context manager.

## Structural Pattern Matching

`match`/`case` can express parsing rules clearly when inputs have distinct
shapes:

```py
from enum import StrEnum


class EventType(StrEnum):
    USER_CREATED = "user_created"
    ORDER_CREATED = "order_created"


def route_event(event: object) -> tuple[str, int]:
    match event:
        case {"type": EventType.USER_CREATED, "user_id": int(user_id)}:
            return ("user", user_id)
        case {"type": EventType.ORDER_CREATED, "order_id": int(order_id)}:
            return ("order", order_id)
        case _:
            raise ValueError("unsupported event")
```

A bare name in a pattern captures a value; it does not compare against a
constant. Qualified names such as `EventType.USER_CREATED` make constant
matching explicit. Pattern matching improves code only when it describes the
input better than a short `if`/`elif` chain.

## Practical Rules

- Make state ownership and mutation explicit.
- Use `is None` for absence and `==` for value comparison.
- Keep comprehensions simple and side-effect free.
- Raise exceptions with actionable context.
- Prefer clear control flow over clever syntax.
