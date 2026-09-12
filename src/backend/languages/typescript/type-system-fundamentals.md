# Type System Fundamentals

TypeScript analyzes JavaScript code before it runs. Its types help tools reason
about possible values, but they do not exist as enforcement objects in the
generated JavaScript.

## Inference and Annotations

The compiler infers local types well:

```ts
const retryLimit = 3; // Inferred as the literal type 3
let attempts = 0;     // Inferred as number

function double(value: number): number {
  return value * 2;
}
```

Use inference for obvious local values. Add explicit types at exported
functions, service boundaries, public class members, and places where the
contract is more important than the implementation.

An explicit return type prevents an implementation change from silently
changing a public API.

## Common Types

TypeScript represents JavaScript primitives with lowercase types such as
`string`, `number`, `bigint`, `boolean`, `symbol`, `null`, and `undefined`.

Avoid the boxed types `String`, `Number`, and `Boolean` in application
interfaces. They describe wrapper objects rather than ordinary primitive
values.

```ts
const ids: string[] = ["user-1", "user-2"];
const roles: ReadonlySet<string> = new Set(["reader"]);
const headers: Record<string, string> = { accept: "application/json" };
```

## Object Types

Object types describe required and optional properties:

```ts
type User = {
  readonly id: string;
  name: string;
  phone?: string;
};
```

With the default optional-property behavior, `phone?: string` means the
property may be absent. A project can enable stricter optional-property checks
to distinguish absence from an explicitly assigned `undefined`.

`readonly` prevents mutation through that reference during type checking. It
does not freeze the runtime object, and it is shallow unless nested values are
also readonly.

## Arrays and Tuples

An array has a variable length and one element type. A tuple describes a fixed
sequence of positions:

```ts
type Coordinate = readonly [latitude: number, longitude: number];

function locate(): Coordinate {
  return [23.8103, 90.4125];
}
```

Use tuples for small positional contracts whose order is obvious. Prefer an
object when field names make the call site easier to understand.

## `any`, `unknown`, and `never`

- `any` opts out of type checking and allows unsafe operations to spread.
- `unknown` accepts any value but requires narrowing before use.
- `never` represents a value that cannot occur.

```ts
function stringify(value: unknown): string {
  if (typeof value === "string") return value;
  if (typeof value === "number") return value.toString();
  throw new TypeError("value must be a string or number");
}
```

Use `unknown` for caught errors, parsed JSON, messages, and other untrusted
values. Use `any` only at a deliberately isolated compatibility boundary.

## `void` and `undefined`

`undefined` is a value and a type. A function returning `void` tells callers not
to depend on its result; it is not always the same contract as returning only
`undefined`.

Callbacks typed to return `void` may still return a value that the caller
ignores. This makes common callbacks ergonomic but means `void` should not be
read as a runtime guarantee.

## Literal Types

`const` declarations and `as const` can preserve exact literal values:

```ts
const methods = ["GET", "POST"] as const;
type HttpMethod = (typeof methods)[number]; // "GET" | "POST"
```

`as const` makes properties deeply readonly for the literal expression and
narrows values to literals. It does not freeze the object at runtime.

The `satisfies` operator checks compatibility without replacing the expression's
inferred type:

```ts
type RouteName = "health" | "users";

const routes = {
  health: "/health",
  users: "/users",
} satisfies Record<RouteName, `/${string}`>;
```

## Function Types

Function signatures make callback contracts explicit:

```ts
type Clock = () => Date;
type Mapper<Input, Output> = (value: Input) => Output;

function mapOne<Input, Output>(
  value: Input,
  mapper: Mapper<Input, Output>,
): Output {
  return mapper(value);
}
```

Optional and default parameters should model runtime behavior accurately.
Avoid broad overloads when a union parameter and union result are clearer.

## Type Erasure

Interfaces, type aliases, generic parameters, and most annotations are removed
from emitted JavaScript. Code cannot use a type alias with `instanceof`, and a
successful compilation does not prove that an HTTP body matches its declared
type.

This principle shapes backend TypeScript: use types for compile-time contracts
and executable parsers for runtime trust boundaries.
