# Unions and Narrowing

Union types model alternatives. Narrowing uses runtime checks and control flow
to determine which alternative is present before code accesses its members.

## Basic Narrowing

TypeScript recognizes checks such as:

- `typeof value === "string"`;
- `value instanceof Date`;
- `"property" in value`;
- equality comparisons;
- truthiness checks;
- discriminant-property checks;
- user-defined type predicates.

```ts
function format(value: string | number): string {
  if (typeof value === "string") {
    return value.trim();
  }

  return value.toFixed(2);
}
```

Narrowing follows control flow, including early returns and thrown exceptions.

## Null and Truthiness

With strict null checks, `null` and `undefined` must be handled explicitly:

```ts
function displayName(user: User | null): string {
  if (user === null) return "anonymous";
  return user.name;
}
```

Truthiness narrowing can accidentally remove valid values such as `0`, `false`,
or an empty string. Use a nullish check when those values are meaningful.

## Discriminated Unions

A shared literal property lets the compiler distinguish states:

```ts
type PaymentResult =
  | { status: "approved"; transactionId: string }
  | { status: "declined"; reason: string }
  | { status: "pending"; pollAfterMs: number };

function describe(result: PaymentResult): string {
  switch (result.status) {
    case "approved":
      return `approved:${result.transactionId}`;
    case "declined":
      return `declined:${result.reason}`;
    case "pending":
      return `pending:${result.pollAfterMs}`;
  }
}
```

Each variant contains only the fields valid for that state. This makes invalid
combinations harder to represent than one object with many optional fields.

## Exhaustiveness

An exhaustiveness helper turns an unhandled variant into a compiler error:

```ts
function assertNever(value: never): never {
  throw new Error(`unexpected variant: ${JSON.stringify(value)}`);
}

function statusCode(result: PaymentResult): number {
  switch (result.status) {
    case "approved":
      return 200;
    case "declined":
      return 422;
    case "pending":
      return 202;
    default:
      return assertNever(result);
  }
}
```

Adding a union member now identifies switches that need a policy for the new
case. The runtime throw also protects against unvalidated external input.

## Type Predicates

A predicate return type tells the compiler what a successful check proves:

```ts
function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.length > 0;
}
```

The compiler trusts this declaration. An incomplete predicate creates false
confidence, so keep custom guards small and test them with invalid inputs.

For complex external structures, prefer a schema validator that checks every
required field and produces useful error details.

## Assertion Functions

An assertion function throws unless a condition is true and narrows afterward:

```ts
function assertAuthenticated(
  request: RequestContext,
): asserts request is AuthenticatedRequestContext {
  if (request.user === undefined) {
    throw new AuthenticationError();
  }
}
```

Use assertion functions when failure should stop execution. Use predicates when
the caller should choose between branches.

## Literal Unions and Enums

Literal unions are simple choices when values already exist as strings or
numbers at runtime:

```ts
type Role = "admin" | "editor" | "viewer";
```

An `enum` creates a runtime object and can be useful when that object is part of
the design or when interoperating with generated code. String enums are usually
more predictable across logs and APIs than numeric enums.

Do not assume either form validates external strings. Parsing is still required.

## The `in` Operator

`"id" in value` checks own and inherited properties. First establish that a
value is a non-null object, and validate the property's value as well:

```ts
function hasStringId(value: unknown): value is { id: string } {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    typeof value.id === "string"
  );
}
```

Checking only that a key exists is not sufficient runtime validation.

## Narrowing Pitfalls

- using truthiness when `0`, `false`, or `""` is valid;
- writing a predicate that checks fewer fields than it claims;
- mutating a narrowed object through another reference;
- narrowing external input once and then retaining it while another owner can
  change it;
- replacing a missing check with a non-null assertion;
- handling a union with a default branch that hides new variants.

Good unions represent real business alternatives, and good narrowing is backed
by checks that are true at runtime.
