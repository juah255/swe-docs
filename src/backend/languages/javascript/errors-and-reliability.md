# Errors and Reliability

Reliable JavaScript services give every failure an owner. Errors should preserve
useful context, cross asynchronous boundaries predictably, and become safe
responses or process-level actions at deliberate boundaries.

## Throw `Error` Objects

Throw an `Error` or subclass instead of a string or arbitrary object:

```js
class UserNotFoundError extends Error {
  constructor(userId, options) {
    super(`user ${userId} was not found`, options);
    this.name = "UserNotFoundError";
    this.userId = userId;
  }
}
```

Error objects provide a message, stack, and consistent inspection behavior.
Machine-readable fields such as a stable error code are more reliable than
parsing message text.

## Preserve the Cause

Add context without discarding the underlying failure:

```js
try {
  return await repository.findById(userId);
} catch (error) {
  throw new UserLoadError(userId, { cause: error });
}
```

Log the error once at the boundary that has request, job, or process context.
Logging and rethrowing at every layer creates duplicates without adding useful
information.

## Error Boundaries

An HTTP error boundary should:

1. map known domain and validation failures to stable status codes;
2. return a safe public response without stack traces or secrets;
3. record the full internal error with request and trace identifiers;
4. avoid sending a second response if streaming already began.

Background consumers need a similar boundary that decides whether to
acknowledge, retry, delay, or dead-letter a message.

## Expected and Unexpected Failures

Expected operational failures include timeouts, unavailable dependencies,
invalid input, and missing records. Code should handle them through defined
policies.

Unexpected failures indicate a broken invariant or programming error. A process
may be in an unknown state after an uncaught exception. Record the failure,
drain work where safe, and let a supervisor replace the process instead of
silently continuing.

Global exception and rejection handlers are last-resort process boundaries, not
a substitute for local ownership of promises.

## Timeouts and Cancellation

Every external operation needs a finite timeout. The timeout should cancel the
real operation when supported, not merely stop awaiting its result.

Propagate an `AbortSignal` or request deadline through application and adapter
layers. Cleanup belongs in `finally` blocks:

```js
const client = await pool.connect();

try {
  return await runTransaction(client, command);
} finally {
  client.release();
}
```

## Retries

Retry only transient failures and only when repeating the operation is safe.
Use a small attempt limit, exponential backoff, jitter, and a total deadline.

Do not retry:

- invalid input or authorization failures;
- deterministic application errors;
- a non-idempotent write without an idempotency strategy;
- an operation after the caller's deadline has expired.

Retries at several layers multiply attempts and can turn a dependency outage
into a traffic storm.

## Idempotency

An idempotent operation produces the same intended effect when repeated. For
commands such as payment or order creation, accept a unique idempotency key and
store the outcome atomically with the state change.

Message consumers should expect duplicate delivery. Use stable event IDs,
unique constraints, transactional state transitions, or an inbox pattern to
make duplicate handling safe.

## Resource Cleanup

Use `finally`, stream pipelines, abort signals, and resource-owning helpers to
release:

- database connections and transactions;
- file descriptors and streams;
- timers and event listeners;
- locks and leases;
- tracing spans and telemetry buffers.

Cleanup must work on success, rejection, timeout, cancellation, and client
disconnect.

## Error-Handling Pitfalls

- catching an error and returning a successful-looking value;
- wrapping without retaining the cause;
- exposing internal messages or stacks to clients;
- retrying every rejection indiscriminately;
- forgetting to await or return a promise;
- continuing after an unrecoverable process-level failure;
- logging tokens, credentials, request bodies, or personal data with an error.
