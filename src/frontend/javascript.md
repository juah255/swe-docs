# JavaScript

## Event Loop

JavaScript is single-threaded with a concurrency model based on an event loop. The call stack executes functions. Macrotasks (setTimeout, I/O, UI rendering) and microtasks (Promise callbacks, queueMicrotask) are queued. After each macrotask, all pending microtasks run before the next render.

## Closures

A closure is a function that retains access to its outer scope even after the outer function has returned. Used for data privacy, factory functions, and maintaining state in callbacks.

## Promises and Async/Await

- **Promise:** Represents a future value. States: pending, fulfilled, rejected.
- **Async/await:** Syntactic sugar over Promises. An async function returns a Promise; await pauses execution until the Promise settles.
- Error handling: `try/catch` with async/await, `.catch()` with Promises.

## Prototypes and Inheritance

JavaScript uses prototypal inheritance. Each object has an internal `[[Prototype]]` link to another object. Classes (ES6) are syntactic sugar over prototype chains.

## Modules (ESM vs CommonJS)

- **ESM:** `import`/`export`, static analysis, tree-shakeable, works in browsers and Node.
- **CommonJS:** `require()`/`module.exports`, dynamic loading, Node.js default before ESM.
- ESM is the modern standard for new projects.

## DOM Manipulation

- `document.querySelector`, `element.addEventListener`, `element.textContent`, `element.classList`.
- Minimize DOM access. Batch reads before writes. Use document fragments for bulk inserts.

## Mid/Senior Interview Questions and Answers

### 1. How does the event loop handle async operations?

**Answer:** The event loop processes the call stack synchronously. Async operations are delegated to the runtime (browser or Node). When the async operation completes, its callback is queued as a task. The event loop picks up tasks when the call stack is empty. Microtasks (Promise callbacks) run between each macrotask, before rendering.

### 2. What is the difference between `var`, `let`, and `const`?

**Answer:** `var` is function-scoped, hoisted, and can be redeclared. `let` and `const` are block-scoped, hoisted but not initialized (temporal dead zone). `const` prevents reassignment, not mutation. Prefer `const` by default, `let` when reassignment is needed, never `var`.

### 3. How do closures affect memory?

**Answer:** Closures keep outer scope variables alive as long as the closure exists. This can cause memory leaks if closures are held longer than needed (e.g., in event listeners that are never removed). The leak is not the closure itself but the unintended reference retention.

### 4. What is the difference between `==` and `===`?

**Answer:** `===` is strict equality — no type coercion. `==` coerces types before comparison. Always use `===` unless type coercion is explicitly intended. The only common use case for `==` is `x == null` to check both `null` and `undefined`.

### 5. How do you deep clone an object?

**Answer:** `structuredClone()` is the modern standard — handles Date, Map, Set, ArrayBuffer, and circular references. `JSON.parse(JSON.stringify(obj))` is a common fallback but drops functions, undefined, symbols, and special types. Spread and `Object.assign()` do shallow copies only.

### 6. What is debouncing and throttling and when do you use each?

**Answer:** Debouncing delays execution until a pause in events (search input, autocomplete). Throttling limits execution to once per interval (scroll, resize handlers). Both prevent excessive function calls. Debounce resets on each call; throttle does not.
