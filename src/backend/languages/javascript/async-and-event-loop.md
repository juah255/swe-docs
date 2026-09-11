# Promises, Async/Await, and the Event Loop

JavaScript runs application callbacks on one main thread by default. Node.js can
still handle many concurrent operations because the runtime and operating system
perform I/O while the event loop schedules callbacks that are ready to continue.

## Run-to-Completion

Each callback runs until it returns. The event loop cannot interrupt a long
synchronous loop to run a timer or complete another request.

```js
setTimeout(() => console.log("timer"), 0);

for (let index = 0; index < 1_000_000_000; index += 1) {
  // The timer cannot run while this loop owns the thread.
}
```

A zero-millisecond timer means "not before this delay"; it does not mean
"immediately."

## Tasks and Microtasks

Timers, I/O callbacks, and other runtime events enter task queues associated
with event-loop phases. Promise reactions and `queueMicrotask()` schedule
microtasks.

After the current JavaScript callback finishes, queued microtasks run before the
event loop proceeds to later task callbacks. Continuously adding microtasks can
therefore delay timers and I/O.

Node.js also has `process.nextTick()`, whose queue is handled with special
priority. Use it sparingly; recursive scheduling can starve the event loop.

## Promises

A promise is pending, fulfilled, or rejected. `then`, `catch`, and `finally`
return new promises, which allows composition:

```js
return loadUser(userId)
  .then((user) => loadPermissions(user))
  .catch((error) => {
    throw new UserLoadError(userId, { cause: error });
  });
```

Returning or throwing inside a handler settles the promise returned by that
handler. Forgetting to return a nested promise can let an outer operation finish
too early.

## `async` and `await`

An `async` function always returns a promise. `await` suspends that function
until the awaited value settles; it does not block the operating-system thread.

```js
async function loadDashboard(userId) {
  const [profile, orders] = await Promise.all([
    fetchProfile(userId),
    fetchRecentOrders(userId),
  ]);

  return { profile, orders };
}
```

Use concurrent execution only for independent operations. Sequential awaits are
correct when a result feeds the next operation, ordering is required, or a
transaction cannot perform the operations simultaneously.

## Promise Combinators

| Method | Result |
| --- | --- |
| `Promise.all()` | Fulfills with all values or rejects when one input rejects. |
| `Promise.allSettled()` | Waits for every input and reports each outcome. |
| `Promise.any()` | Fulfills with the first successful value; rejects if all fail. |
| `Promise.race()` | Settles with the first input to settle. |

Rejecting `Promise.all()` does not automatically cancel work that already
started. Use an abort signal or API-specific cancellation when abandoned work
should stop.

## Cancellation and Deadlines

JavaScript promises do not have universal built-in cancellation. Many web and
Node.js APIs accept an `AbortSignal`:

```js
async function loadJson(url, { timeoutMs = 2_000 } = {}) {
  const signal = AbortSignal.timeout(timeoutMs);
  const response = await fetch(url, { signal });

  if (!response.ok) {
    throw new Error(`upstream returned ${response.status}`);
  }

  return response.json();
}
```

Propagate cancellation into database and HTTP operations when supported. A
timeout that merely rejects a wrapper promise while the underlying operation
continues does not release the resource.

## Bounded Concurrency

Starting one promise per item can exhaust sockets, memory, connection pools, or
an external service:

```js
await Promise.all(records.map(processRecord)); // Unbounded for a large array
```

Use a worker queue or concurrency limiter. Set the bound according to downstream
capacity and measure queue delay as well as execution time.

## Handling Rejections

Await a promise, return it to an owner, or attach an intentional rejection
handler. "Fire-and-forget" work needs explicit lifecycle and error reporting;
otherwise its failures can become unhandled rejections and deployment can stop
it midway.

Use a durable job queue for work that must survive process restarts or requires
retries.

## Common Mistakes

- using `forEach(async () => ...)` and assuming the outer code waits;
- awaiting independent operations one after another;
- launching an unbounded number of promises;
- forgetting to return a promise from a callback;
- mixing callbacks and promises without a single error owner;
- assuming `await` moves CPU-heavy code off the main thread;
- implementing a timeout without cancelling the underlying operation.
