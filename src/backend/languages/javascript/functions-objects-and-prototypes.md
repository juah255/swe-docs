# Functions, Objects, and Prototypes

Functions are first-class values in JavaScript, and objects inherit behavior
through prototypes. Classes provide familiar syntax, but their methods still
use the prototype system underneath.

## Function Forms

Function declarations are available throughout their scope:

```js
function normalizeEmail(email) {
  return email.trim().toLowerCase();
}
```

Function expressions and arrow functions are values assigned during execution:

```js
const byCreatedAt = (left, right) => left.createdAt - right.createdAt;
```

Arrow functions capture `this` from their surrounding scope and do not have
their own `arguments` object. That makes them useful for callbacks, but not as a
universal replacement for methods that need a dynamic receiver.

## Closures

A closure keeps access to variables from the lexical scope where a function was
created:

```js
function createRateChecker(maximum) {
  let used = 0;

  return function consume(amount = 1) {
    if (used + amount > maximum) return false;
    used += amount;
    return true;
  };
}
```

Closures support factories, callbacks, encapsulation, and dependency injection.
A long-lived closure also keeps captured objects reachable, so avoid retaining
large request payloads through timers, listeners, or global callback registries.

Closures created in a loop with `let` receive a binding for each iteration.
Legacy loops using `var` share one function-scoped binding.

## How `this` Is Chosen

For regular functions, `this` depends on the call site:

- `object.method()` uses `object` as the receiver;
- a plain strict-mode function call uses `undefined`;
- `new Constructor()` uses the newly created object;
- `call`, `apply`, and `bind` specify a receiver;
- an arrow function uses `this` from its enclosing scope.

Passing a method as a callback can lose its receiver:

```js
const handler = service.handle; // Detached method
await handler(request);         // `this` is no longer `service`
```

Prefer methods that do not depend unnecessarily on `this`, wrap the call in an
arrow function, or bind the method deliberately.

## Prototype Lookup

When a property is not found directly on an object, JavaScript follows its
prototype chain until the property is found or the chain ends at `null`.

```js
const accountBehavior = {
  describe() {
    return `${this.id}:${this.status}`;
  },
};

const account = Object.create(accountBehavior);
account.id = "A-12";
account.status = "active";
```

Use `Object.hasOwn(object, key)` when logic must distinguish an object's own
property from an inherited one.

Never merge untrusted keys into ordinary objects without validation. Special
keys can lead to prototype pollution in unsafe merge code.

## Classes

Class syntax organizes constructors, prototype methods, static methods, private
fields, and inheritance:

```js
class Account {
  #balance;

  constructor(id, balance) {
    this.id = id;
    this.#balance = balance;
  }

  debit(amount) {
    if (amount > this.#balance) {
      throw new RangeError("insufficient funds");
    }
    this.#balance -= amount;
  }
}
```

Private fields are enforced by the language. Underscore-prefixed properties are
only a naming convention.

Avoid deep inheritance trees. They make state and method resolution harder to
follow and couple subclasses to implementation details.

## Composition

Composition assembles behavior from smaller dependencies:

```js
function createUserService({ users, mailer, clock }) {
  return {
    async register(input) {
      const user = await users.insert({ ...input, createdAt: clock.now() });
      await mailer.sendWelcome(user.email);
      return user;
    },
  };
}
```

This factory makes dependencies visible and easy to replace in tests. Classes
are still useful when instances own state or invariants; use the form that makes
the lifecycle clearest.

## Property Descriptors

Object properties have flags such as `writable`, `enumerable`, and
`configurable`, and may be data properties or getter/setter accessors. Most
application code does not manipulate descriptors directly, but libraries,
frameworks, and decorators may rely on them.

Getters should be fast and free of surprising side effects because property
access looks like ordinary data access.

## Practical Rules

- Use closures for small, intentional state—not accidental object retention.
- Treat `this` as a call-site rule for regular functions.
- Prefer composition over deep inheritance.
- Check ownership when accepting dynamic object keys.
- Keep constructors and property access free from hidden I/O.
