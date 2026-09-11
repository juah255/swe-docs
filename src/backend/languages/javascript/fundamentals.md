# Language Fundamentals

JavaScript is dynamically typed: variables can refer to values of different
types over their lifetime, while each value has a runtime type. Backend code is
safer when conversions and missing-value behavior are deliberate.

## Primitive and Object Values

JavaScript has these primitive value types:

- `string`
- `number`
- `bigint`
- `boolean`
- `undefined`
- `symbol`
- `null`

Everything else is an object, including arrays, functions, maps, sets, and
dates. Primitives behave like immutable values. Objects are mutable and are
assigned by reference:

```js
const original = { roles: ["reader"] };
const shared = original;

shared.roles.push("editor");
console.log(original.roles); // ["reader", "editor"]
```

Spread syntax makes a shallow copy, so nested objects remain shared. Use an
explicit deep-copy strategy only when the data supports it and independent
ownership is required.

## `const`, `let`, and `var`

- `const` creates a block-scoped binding that cannot be reassigned.
- `let` creates a block-scoped binding that can be reassigned.
- `var` is function-scoped and has legacy hoisting behavior.

Use `const` by default and `let` when reassignment communicates real state
change. Avoid `var` in modern code.

`const` protects the binding, not the object:

```js
const user = { name: "Ann" };
user.name = "Lisa"; // Allowed
// user = anotherUser; // TypeError
```

Declarations made with `let` and `const` are in the **temporal dead zone** from
the beginning of their scope until execution reaches the declaration.

## Equality and Coercion

Use strict equality by default:

- `===` compares without coercing operands to another type.
- `!==` is the corresponding inequality operator.
- `==` and `!=` apply conversion rules that can produce surprising results.

Convert explicitly at input boundaries:

```js
const port = Number.parseInt(process.env.PORT ?? "3000", 10);

if (!Number.isInteger(port) || port <= 0) {
  throw new Error("PORT must be a positive integer");
}
```

`Number.isNaN(value)` checks for the numeric `NaN` value without the coercion
performed by the global `isNaN()` function.

## Missing Values

`undefined` usually means a value was not supplied or a property is absent.
`null` is commonly used as an explicit empty value. A codebase should define
how it uses each at API and persistence boundaries.

The nullish coalescing operator falls back only for `null` or `undefined`:

```js
const limit = request.limit ?? 25;
```

Unlike `request.limit || 25`, this preserves meaningful values such as `0` and
an empty string.

Optional chaining stops a property access or call when the value on its left is
nullish:

```js
const city = account.profile?.address?.city;
```

Use it for genuinely optional data, not to hide a missing invariant that should
raise an error.

## Truthiness

The false-like values are `false`, `0`, `-0`, `0n`, `NaN`, `""`, `null`, and
`undefined`. All objects are truthy, including empty arrays and empty objects.

Be precise when empty, zero, false, and missing carry different meanings.

## Destructuring and Spread

Destructuring extracts values by name or position:

```js
const { id, email, role = "reader" } = user;
const [first, ...remaining] = jobs;
```

Object spread is useful for small immutable-style updates:

```js
const updated = { ...user, role: "editor" };
```

Both destructuring defaults and spread work at one level. A default runs only
for `undefined`, and spread does not recursively clone nested values.

## Collections

- Use `Array` for ordered values and indexed access.
- Use `Map` for key-value data when keys are not limited to strings and symbols
  or when map-specific operations improve clarity.
- Use `Set` for uniqueness and frequent membership checks.
- Use plain objects for records with a known set of string-keyed fields.

Do not use `Array.prototype.map()` only for side effects; use `for...of` or
`forEach()` when no transformed array is needed.

## Practical Rules

- Prefer `const`, strict equality, and explicit conversion.
- Distinguish missing values from valid false-like values.
- Remember that object copies made with spread are shallow.
- Validate external input before business logic uses it.
- Choose readable control flow over dense operator chains.
