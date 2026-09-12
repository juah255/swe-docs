# Generics and Type Transformations

Generics describe relationships between types without discarding information.
Mapped, conditional, and template literal types transform existing contracts so
related APIs can stay consistent.

## Generic Functions

A generic parameter should connect meaningful parts of a signature:

```ts
function first<Item>(items: readonly Item[]): Item | undefined {
  return items[0];
}
```

The output depends on the input element type. A generic used only once often
adds no value; a concrete type or `unknown` may express the contract better.

Prefer descriptive parameter names such as `Item`, `Entity`, or `Result` when a
signature has several generic types.

## Constraints

Constraints describe the minimum behavior a generic operation requires:

```ts
function indexById<Entity extends { id: string }>(
  entities: readonly Entity[],
): Map<string, Entity> {
  return new Map(entities.map((entity) => [entity.id, entity]));
}
```

The return type preserves every additional property of `Entity`. Avoid a broad
constraint when the implementation needs only one or two members.

## Key Relationships

`keyof` and indexed access types connect property names with values:

```ts
function getProperty<ObjectType, Key extends keyof ObjectType>(
  object: ObjectType,
  key: Key,
): ObjectType[Key] {
  return object[key];
}
```

This is safer than returning a union of all possible property values or using
`any`.

## Standard Utility Types

Common utilities include:

| Utility | Purpose |
| --- | --- |
| `Partial<T>` | Makes every property optional. |
| `Required<T>` | Makes every property required. |
| `Readonly<T>` | Makes every property readonly at the first level. |
| `Pick<T, K>` | Keeps selected keys. |
| `Omit<T, K>` | Removes selected keys. |
| `Record<K, V>` | Maps a key union to one value type. |
| `Parameters<T>` | Extracts a function's parameter tuple. |
| `ReturnType<T>` | Extracts a function's return type. |
| `Awaited<T>` | Recursively unwraps promise-like values. |
| `NonNullable<T>` | Removes `null` and `undefined`. |

Use transformations when the derived contract truly changes with its source.
For public request and domain models, separate named types may better document
different semantics even when their fields currently overlap.

## Mapped Types

A mapped type iterates over keys:

```ts
type NullableFields<Value> = {
  [Key in keyof Value]: Value[Key] | null;
};

type Mutable<Value> = {
  -readonly [Key in keyof Value]: Value[Key];
};
```

Mapped types can add or remove `readonly` and optional modifiers, remap keys,
and compose with conditional types.

## Conditional Types

A conditional type selects a type based on assignability:

```ts
type ElementOf<Value> = Value extends readonly (infer Item)[] ? Item : never;

type User = ElementOf<readonly User[]>;
```

When the checked value is a naked type parameter, conditional types distribute
over unions. Wrap each side in a single-element tuple when distribution is not
desired:

```ts
type IsNever<Value> = [Value] extends [never] ? true : false;
```

`infer` introduces a type variable inside the matching branch and is useful for
extracting part of a larger type.

## Template Literal Types

Template literal types describe patterned strings:

```ts
type HttpMethod = "GET" | "POST" | "PATCH";
type ApiRoute = `/api/${string}`;
type HandlerName<Event extends string> = `on${Capitalize<Event>}`;
```

They work well for small, finite naming conventions. Very large unions can slow
the compiler and produce unreadable diagnostics. Runtime route and event values
still need validation.

## Generic Defaults

Defaults reduce noise when one type is most common:

```ts
type ApiResponse<Data, Meta = undefined> = {
  data: Data;
  meta: Meta;
};
```

Required generic parameters must come before optional parameters. Do not use a
default merely to hide an unresolved type design.

## Variance and Callbacks

Variance describes how compatibility of parameterized types follows
compatibility of their type arguments. Function parameters and mutable
containers are where unsafe assumptions most often appear.

Prefer `readonly` inputs when a function only reads them. This permits more
callers and prevents the implementation from inserting an incompatible value.
Keep strict function checking enabled so callback parameter mistakes remain
visible.

## Avoiding Type-Level Overengineering

- Prefer standard utility types over custom equivalents.
- Name intermediate transformations when diagnostics become unreadable.
- Do not derive every external DTO from a domain entity automatically.
- Keep recursive and distributive types bounded.
- Test public advanced types with positive and negative compile-time examples.
- Replace a clever type with a small runtime function when the function is
  clearer and validation is needed anyway.

A useful advanced type makes application code simpler. If every caller needs an
assertion to satisfy it, the abstraction is working against the codebase.
