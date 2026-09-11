# JavaScript Questions

These questions review JavaScript and Node.js concepts that matter in backend
systems.

## 1. How does the JavaScript event loop work?

**Answer:** JavaScript callbacks run on one main thread by default. Node.js and
the operating system coordinate timers and I/O, then the event loop schedules
callbacks when they are ready. Each callback runs to completion, so long
synchronous work delays every other callback on that thread.

Promise reactions run as microtasks after the current callback and before later
task callbacks.

## 2. What is the difference between `var`, `let`, and `const`?

**Answer:** `var` is function-scoped and has legacy hoisting behavior. `let` and
`const` are block-scoped and remain in the temporal dead zone until their
declaration executes. A `const` binding cannot be reassigned, but the object it
refers to may still be mutable.

Use `const` by default, `let` for intentional reassignment, and avoid `var` in
modern code.

## 3. How does `async`/`await` work?

**Answer:** An `async` function always returns a promise. `await` suspends that
function until a value settles and schedules its continuation through the
promise microtask mechanism. It does not block the operating-system thread, but
CPU-heavy code before or after the `await` still blocks the JavaScript thread.

## 4. When should you use `Promise.all()` versus `Promise.allSettled()`?

**Answer:** Use `Promise.all()` when every independent operation must succeed.
Use `Promise.allSettled()` when all outcomes are needed and partial failure is
part of the design. Neither method automatically cancels operations already in
progress; pass abort signals when abandoned work should stop.

## 5. What is a closure, and how can it cause a memory leak?

**Answer:** A closure is a function with access to its lexical environment. It
can retain captured objects as long as the function remains reachable. A timer,
listener, cache, or callback registry can therefore keep a large request object
alive accidentally.

## 6. How is `this` determined?

**Answer:** For a regular function, `this` depends on the call site: a method
call uses its receiver, `new` uses the new instance, and `call`, `apply`, or
`bind` can specify it. Arrow functions capture `this` from their surrounding
scope.

Passing a method as a callback detaches it from its original receiver unless it
is wrapped or bound.

## 7. What is prototypal inheritance?

**Answer:** When an object does not have a requested property, JavaScript looks
up its prototype chain. Classes provide syntax for constructors and prototype
methods but do not replace this lookup model. Mutating shared prototypes can
affect many objects and is dangerous with untrusted keys.

## 8. What is the difference between `==` and `===`?

**Answer:** `===` compares operands without type coercion. `==` first applies a
set of conversion rules. Use strict equality by default and make conversions
explicit at input boundaries.

## 9. What is the difference between `||` and `??` for defaults?

**Answer:** `||` uses its right side for any false-like left value, including
`0`, `false`, and an empty string. `??` uses the fallback only for `null` or
`undefined`. Use `??` when false-like values are valid data.

## 10. How do Node.js streams and backpressure work?

**Answer:** Streams process data in chunks. Backpressure signals that a consumer
cannot accept more data at the current rate, allowing the producer to slow down
instead of growing memory indefinitely. `pipeline()` coordinates flow, errors,
and teardown more safely than manually wiring events.

## 11. When should you use worker threads or multiple processes?

**Answer:** Use worker threads for substantial CPU-heavy JavaScript when sharing
a process is useful. Use multiple processes or replicas for CPU utilization and
failure isolation across server instances. Both add communication and memory
cost, so they should not be used to hide slow database or network operations.

## 12. What is the difference between CommonJS and ES modules?

**Answer:** CommonJS uses `require()` and `module.exports`; ES modules use
`import` and `export`. ES modules are statically analyzable and support top-level
`await`. Interoperability has edge cases, so new services should choose one
primary module system and test legacy boundaries.

## 13. Why does `forEach(async () => ...)` often cause bugs?

**Answer:** `forEach()` ignores the promises returned by its callback, so the
outer function does not wait and cannot naturally collect rejections. Use
`for...of` with `await` for sequential work or `map()` plus an appropriate
promise combinator and concurrency bound for concurrent work.

## 14. How should errors cross application layers?

**Answer:** Lower layers should preserve the original error while adding useful
context. A request or job boundary maps known failures to stable outcomes, logs
unexpected errors once with operation context, and hides internal details from
clients.

## 15. What causes memory leaks in Node.js services?

**Answer:** Leaks usually come from objects that remain reachable through
unbounded caches, listeners, timers, closures, pending work, buffered streams,
or queues. Heap snapshots and allocation profiles help locate the retaining
path; forcing garbage collection does not fix unwanted references.

## 16. Why can an async Node.js service still become unresponsive?

**Answer:** Large synchronous computations, parsing, compression, regular
expressions, or synchronous runtime APIs block the event-loop thread. Unbounded
microtasks can also starve later work. Monitor event-loop delay and move
substantial CPU work to bounded workers or processes.

## 17. How should outgoing calls be protected?

**Answer:** Apply finite timeouts, cancellation, bounded pools, and carefully
limited retries with backoff and jitter. Retry only transient failures when the
operation is idempotent or protected by an idempotency key.

## 18. What makes a Node.js service production-ready?

**Answer:** It needs runtime input validation, bounded concurrency and pools,
timeouts and cancellation, safe error boundaries, structured logs, metrics,
supported dependencies, security controls, health signals, reproducible builds,
and tested graceful shutdown.
