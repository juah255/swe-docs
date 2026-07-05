# TypeScript

TypeScript adds static typing on top of JavaScript. Mid-level and senior
interviews usually focus on type modeling, narrowing, generics, strictness,
runtime validation, and designing maintainable APIs.

## Core Concepts

### What is TypeScript?

TypeScript is a superset of JavaScript that adds a static type system. It
compiles down to plain JavaScript, so types exist only at development and build
time and are erased at runtime.

The compiler (`tsc`) checks types, and tools like `ts-node`, `tsx`, `esbuild`,
and `swc` are commonly used to run or transpile TypeScript directly during
development.

### Type Annotations and Inference

Types can be declared explicitly, but the compiler infers them whenever
possible.

```ts
const count = 42;              // inferred as number
let name: string = "Alice";    // explicit
function double(n: number) {   // return type inferred as number
  return n * 2;
}
```

Idiomatic TypeScript relies on inference for local values and adds explicit
annotations at function signatures and public API boundaries.

### Object Shapes, Arrays, and Tuples

```ts
type User = { id: string; name: string };
const ids: string[] = ["a", "b"];
const point: [number, number] = [10, 20];
```

`readonly` prevents mutation at the type level:

```ts
type Config = { readonly host: string };
const items: readonly string[] = [];
```

### Enums and Literal Types

Literal union types are usually preferred over `enum` because they are simpler,
tree-shakeable, and do not emit runtime code.

```ts
type Role = "admin" | "editor" | "viewer";
```

`const enum` is an exception that inlines values at compile time, but many
teams disable it for portability reasons.

### Generics

Generics let you write reusable code that preserves type information.

```ts
function identity<T>(value: T): T {
  return value;
}

interface ApiResponse<T> {
  data: T;
  error?: string;
}
```

Constraints narrow what types are allowed:

```ts
function getId<T extends { id: string }>(item: T): string {
  return item.id;
}
```

### Utility Types

The standard library ships utility types for common transformations.

- `Partial<T>` — all properties optional.
- `Required<T>` — all properties required.
- `Readonly<T>` — all properties readonly.
- `Pick<T, K>` — subset of keys.
- `Omit<T, K>` — everything except the given keys.
- `Record<K, V>` — object with keyed values.
- `Awaited<T>` — unwraps a `Promise`.
- `ReturnType<T>` — the return type of a function.

They compose well and reduce the need for hand-written mapped types.

### Type Narrowing

The compiler narrows types inside branches based on control-flow checks.

```ts
function format(value: string | number) {
  if (typeof value === "string") {
    return value.toUpperCase();
  }
  return value.toFixed(2);
}
```

Discriminated unions with a shared literal field enable exhaustive narrowing
that the compiler can check with a `never` fallthrough.

### Modules and `tsconfig.json`

TypeScript uses ES modules by default. `tsconfig.json` controls compilation
behavior — the most impactful options are:

- `strict` — enables the recommended strictness bundle.
- `target` and `module` — output JavaScript version and module format.
- `moduleResolution` — how imports are resolved (`node`, `bundler`, `nodenext`).
- `paths` and `baseUrl` — path aliases for cleaner imports.
- `noUncheckedIndexedAccess` — treats array/object index access as possibly
  `undefined`.

### Declaration Files

`.d.ts` files describe the shape of JavaScript code without implementation.
They ship with libraries or live in `@types/*` packages on npm and are what
enables typed autocomplete for untyped JavaScript dependencies.

### Classes and Access Modifiers

TypeScript extends JavaScript classes with `public`, `private`, `protected`,
`readonly`, and parameter properties.

```ts
class UserService {
  constructor(
    private readonly db: Database,
    protected logger: Logger,
  ) {}

  public findById(id: string) {
    return this.db.users.find(id);
  }
}
```

The `#` prefix (`#field`) provides true runtime private fields at the ES level,
while `private` is a compile-time-only check.

### Abstract Classes and Interfaces

Abstract classes define a partial implementation that subclasses must complete.
Interfaces define a contract with no implementation and support declaration
merging.

```ts
abstract class Shape {
  abstract area(): number;
  describe() {
    return `area=${this.area()}`;
  }
}

interface Repository<T> {
  find(id: string): Promise<T | null>;
  save(item: T): Promise<void>;
}
```

### Decorators

Decorators are functions that annotate and modify classes, methods, properties,
accessors, or parameters. They are widely used by NestJS, TypeORM, and
`class-validator`.

```ts
function Log(target: any, key: string, descriptor: PropertyDescriptor) {
  const original = descriptor.value;
  descriptor.value = function (...args: any[]) {
    console.log(`${key} called with`, args);
    return original.apply(this, args);
  };
}

class OrderService {
  @Log
  create(orderId: string) {
    // ...
  }
}
```

Two decorator systems exist:

- **Legacy (experimental) decorators** — enabled with `experimentalDecorators`
  and `emitDecoratorMetadata`. Required by NestJS, Angular, and TypeORM.
- **Stage 3 / ECMAScript decorators** — the standardized form supported by
  modern TypeScript. Different signature and no `reflect-metadata` support.

Most existing frameworks still target the legacy decorators, so projects
usually pick one system and stay consistent.

### Type Assertions and Non-null Assertion

`as` reinterprets a value's type without runtime checks. Use it sparingly and
only when you have external knowledge the compiler lacks.

```ts
const el = document.getElementById("root") as HTMLDivElement;
const value = input!.trim(); // non-null assertion
```

`as unknown as T` is a double assertion used as an escape hatch, and it should
be treated as a code smell.

### Mapped and Conditional Types

Mapped types build new object types by iterating over keys, and conditional
types branch on a type relationship.

```ts
type Nullable<T> = { [K in keyof T]: T[K] | null };
type NonNullableFields<T> = { [K in keyof T]: NonNullable<T[K]> };

type IsArray<T> = T extends unknown[] ? true : false;
type ElementOf<T> = T extends (infer U)[] ? U : never;
```

`infer` extracts a type inside a conditional branch and powers utility types
like `ReturnType` and `Awaited`.

### Template Literal Types

Template literal types compose string literal types the same way template
literals compose strings.

```ts
type HttpMethod = "GET" | "POST";
type Route = `/${string}`;
type EventName = `on${Capitalize<string>}`;
```

They are useful for typing routing, event names, or CSS keys where the string
follows a pattern.

### Namespaces

`namespace` was TypeScript's original module system before ES modules
stabilized. Modern code should use ES modules; namespaces mainly appear in
legacy code and ambient type declarations.

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
