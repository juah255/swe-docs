# JavaScript

JavaScript is used heavily in frontend applications and backend services through
Node.js. Mid-level and senior interviews usually focus on execution model,
asynchronous behavior, runtime performance, language pitfalls, and production
Node.js patterns.

## Questions and Answers

### 1. How does the JavaScript event loop work?

**Answer:** JavaScript runs user code on a single main thread, but asynchronous
work is coordinated through the runtime and event loop.

The event loop processes tasks such as timers, I/O callbacks, and UI events.
Promises use the microtask queue, which runs before the next macrotask.

In practice:

- `Promise.then`, `catch`, `finally`, and `queueMicrotask` are microtasks;
- `setTimeout`, `setInterval`, and many I/O callbacks are macrotasks;
- long synchronous work blocks the event loop.

### 2. What is the difference between `var`, `let`, and `const`?

**Answer:** `var` is function-scoped and hoisted with an initial value of
`undefined`. `let` and `const` are block-scoped and are hoisted but stay in the
temporal dead zone until declared.

Use `const` by default, `let` when reassignment is needed, and avoid `var` in
modern code.

`const` prevents reassignment of the binding, not mutation of the object:

```js
const user = { name: "Ann" };
user.name = "Lisa"; // allowed
```

### 3. How does `async`/`await` work?

**Answer:** `async` functions always return a promise. `await` pauses execution
inside the async function until the promise settles, then resumes through the
microtask queue.

Use `try/catch` for errors:

```js
try {
  const user = await getUser(id);
} catch (error) {
  logger.error(error);
}
```

Avoid unnecessary sequential awaits when operations can run in parallel. Use
`Promise.all` when all operations must succeed, and `Promise.allSettled` when
partial failure is acceptable.

### 4. What are closures, and where can they cause problems?

**Answer:** A closure is created when a function remembers variables from its
outer scope after that outer function has finished executing.

Closures are useful for callbacks, function factories, and encapsulation. They
can cause memory issues if they accidentally retain large objects or request
state longer than needed.

In backend services, be careful with closures stored in long-lived caches,
timers, event listeners, or global arrays.

### 5. How does `this` work in JavaScript?

**Answer:** The value of `this` depends on how a function is called.

Common rules:

- method call: `this` is the object before the dot;
- plain function call: `this` is `undefined` in strict mode;
- constructor call with `new`: `this` is the new object;
- `call`, `apply`, and `bind` set `this` explicitly;
- arrow functions capture `this` from the outer scope.

This is why arrow functions are useful for callbacks, but they should not be
used as object methods when dynamic `this` is required.

### 6. What is prototypal inheritance?

**Answer:** JavaScript objects can inherit properties from another object
through the prototype chain. Classes are syntax over prototype-based behavior.

When a property is accessed, JavaScript checks the object first. If not found,
it walks up the prototype chain.

Senior-level concern: mutating shared prototypes can affect all instances.
Prefer clear class definitions, composition, or factory functions depending on
the design.

### 7. How do Node.js streams and backpressure work?

**Answer:** Streams process data in chunks instead of loading everything into
memory. They are useful for files, network responses, uploads, and large
payloads.

Backpressure happens when the consumer is slower than the producer. Node streams
signal this so producers can slow down instead of filling memory.

Use `pipeline` from `stream/promises` because it handles errors and cleanup more
safely than manually wiring events.

### 8. When should you use worker threads or clustering in Node.js?

**Answer:** Node.js is strong for I/O-heavy workloads, but CPU-heavy work blocks
the event loop.

Use worker threads for CPU-heavy tasks such as image processing, encryption,
compression, or large JSON transformations. Use clustering or multiple
processes to utilize multiple CPU cores for HTTP servers.

Do not use worker threads to hide slow database queries. Fix the query,
indexing, pooling, or external dependency instead.

### 9. What is the difference between CommonJS and ES modules?

**Answer:** CommonJS uses `require` and `module.exports`. ES modules use
`import` and `export`.

Key differences:

- ES modules are statically analyzable;
- CommonJS loads modules synchronously;
- ES modules support top-level `await`;
- interop between the two can have edge cases.

In new Node.js projects, ES modules are common, but many packages and older
systems still use CommonJS.

### 10. What are common JavaScript production pitfalls?

**Answer:** Common pitfalls include:

- blocking the event loop with heavy synchronous work;
- unhandled promise rejections;
- missing timeouts on HTTP calls;
- memory leaks from global caches or listeners;
- unsafe object merging that allows prototype pollution;
- relying on implicit type coercion in critical logic.

Production JavaScript should use structured logging, input validation, timeouts,
and monitoring for event loop lag.
