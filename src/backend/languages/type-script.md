# TypeScript

TypeScript adds static typing on top of JavaScript. Mid-level and senior
interviews usually focus on type modeling, narrowing, generics, strictness,
runtime validation, and designing maintainable APIs.

## Questions and Answers

### 1. What problem does TypeScript solve?

**Answer:** TypeScript catches many type-related mistakes before runtime. It
improves refactoring, editor tooling, API contracts, and large-codebase
maintainability.

TypeScript does not make JavaScript safe at runtime. It only checks code during
development and compilation. Runtime inputs still need validation.

### 2. What is the difference between `type` and `interface`?

**Answer:** Both can describe object shapes.

Use `interface` when defining object contracts that may be extended or merged.
Use `type` for unions, intersections, primitives, tuples, mapped types, and
more complex type expressions.

Example:

```ts
interface User {
  id: string;
  name: string;
}

type UserId = string;
type ApiResult = Success | Failure;
```

In many codebases, either is acceptable for simple object shapes. Consistency is
more important than personal preference.

### 3. What is structural typing?

**Answer:** TypeScript uses structural typing. This means compatibility is based
on the shape of a value, not the declared name of its type.

If an object has the required fields, it can be assigned to that type.

This is different from nominal typing languages where two types with the same
shape are not automatically compatible.

Senior-level pitfall: structural typing can accidentally allow values that look
compatible but have different domain meaning. Branded types can help for IDs and
other sensitive values.

### 4. What are union and intersection types?

**Answer:** A union means a value can be one of several types:

```ts
type Status = "pending" | "paid" | "failed";
```

An intersection combines multiple types:

```ts
type AdminUser = User & { role: "admin" };
```

Discriminated unions are especially useful for modeling states:

```ts
type Result =
  | { ok: true; data: User }
  | { ok: false; error: string };
```

They make invalid states harder to represent.

### 5. What is the difference between `any`, `unknown`, and `never`?

**Answer:**

- `any` disables type checking for a value.
- `unknown` represents an unknown value that must be narrowed before use.
- `never` represents a value that should never occur.

Prefer `unknown` over `any` for untrusted input because it forces validation.
Use `never` for exhaustiveness checks in discriminated unions.

### 6. How do generics improve API design?

**Answer:** Generics allow functions, classes, and types to work with many
types while preserving type information.

Example:

```ts
function first<T>(items: T[]): T | undefined {
  return items[0];
}
```

Good generics express a real relationship between inputs and outputs. Avoid
adding generic parameters that do not constrain or return anything meaningful.

### 7. What are type guards and narrowing?

**Answer:** Narrowing is the process of reducing a broad type to a more specific
type through checks.

Common narrowing techniques:

- `typeof`;
- `instanceof`;
- `in`;
- equality checks;
- custom type guard functions.

Example:

```ts
function isUser(value: unknown): value is User {
  return typeof value === "object" && value !== null && "id" in value;
}
```

Type guards are important when handling API input, JSON, or third-party data.

### 8. Why is `strict` mode important?

**Answer:** `strict` mode enables stronger type checking and catches more bugs.
It includes checks such as `strictNullChecks`, `noImplicitAny`, and stricter
function type rules.

For production TypeScript projects, `strict` mode is usually worth enabling. If
turning it on in an old project is too expensive, migrate gradually by directory
or package.

### 9. Why do TypeScript projects still need runtime validation?

**Answer:** TypeScript types disappear after compilation. Data from HTTP
requests, databases, queues, files, and environment variables can still be
wrong at runtime.

Use runtime validation for external input. Common tools include Zod, Yup,
Valibot, class-validator, and JSON Schema validators.

Good production practice is to validate at boundaries and use trusted typed
objects inside the application.

### 10. What are common senior-level TypeScript pitfalls?

**Answer:** Common pitfalls include:

- overusing `any`;
- creating complex types that nobody can maintain;
- trusting generated or external types without validation;
- using non-null assertions to silence real null bugs;
- weakening compiler options for convenience;
- mixing domain models and transport DTOs without clear boundaries.

Good TypeScript should make invalid states harder to represent while staying
readable for the team.
