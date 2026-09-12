# Async Code and Error Handling

TypeScript describes asynchronous contracts, but JavaScript and Node.js still
determine their runtime scheduling, cancellation, and failure behavior. Types
should make ownership clear without pretending that a promise can fail only in
declared ways.

## Promise Return Types

An `async` function returns a promise even when it returns a plain value:

```ts
async function findUser(id: UserId): Promise<User | null> {
  return repository.findById(id);
}
```

Annotate exported async return types. This prevents a refactor from accidentally
changing a public contract and makes missing branches visible.

Do not wrap an existing promise in `new Promise()` without a real adaptation
need. The promise constructor pattern can lose errors or settle at the wrong
time when implemented incorrectly.

## Concurrent Operations

Tuple inference preserves the individual results of `Promise.all()`:

```ts
const [profile, orders] = await Promise.all([
  loadProfile(userId),
  loadOrders(userId),
]);
```

Run only independent operations concurrently. For a large input collection,
use a typed concurrency limiter or worker queue instead of starting every
promise at once.

`Promise.allSettled()` returns a discriminated union whose `status` narrows each
outcome to its `value` or `reason`.

## Cancellation

Pass an `AbortSignal` through API boundaries that support cancellation:

```ts
type LoadOptions = {
  signal?: AbortSignal;
};

async function loadUser(
  id: UserId,
  { signal }: LoadOptions = {},
): Promise<User> {
  const response = await fetch(`/users/${id}`, { signal });
  return parseUser(await response.json());
}
```

A rejected timeout wrapper does not necessarily stop the underlying database or
HTTP operation. Cancellation must reach the resource-owning adapter.

## Caught Errors Are Unknown

JavaScript permits throwing any value. Treat a caught value as `unknown` and
narrow it:

```ts
try {
  await publish(event);
} catch (error: unknown) {
  if (error instanceof PublishError) {
    logger.warn({ error, eventId: event.id }, "publish failed");
    throw error;
  }

  throw new PublishError("unexpected publisher failure", { cause: error });
}
```

Avoid annotating caught values as `any`. Preserve the original `cause` when
adding context.

## Custom Error Classes

Custom classes provide runtime identity and structured fields:

```ts
class EntityNotFoundError extends Error {
  readonly code = "ENTITY_NOT_FOUND";

  constructor(
    readonly entity: string,
    readonly id: string,
    options?: ErrorOptions,
  ) {
    super(`${entity} ${id} was not found`, options);
    this.name = "EntityNotFoundError";
  }
}
```

Map known errors at HTTP or job boundaries. Do not expose internal messages,
stack traces, or database details to clients.

## Result Types

Expected business outcomes can be modeled as a discriminated union:

```ts
type TransferResult =
  | { ok: true; transfer: Transfer }
  | { ok: false; reason: "insufficient_funds" | "account_locked" };
```

Use result types when callers should handle ordinary alternatives explicitly.
Use exceptions for failures that interrupt the expected flow, such as an
unavailable dependency or broken invariant. Mixing both is fine when the
boundary between expected and exceptional outcomes is clear.

## Floating Promises

Every promise should be awaited, returned, combined, or deliberately owned by a
background supervisor. A floating promise can reject after the request finishes
and lose its error context.

Linters can report unhandled promises, but fire-and-forget work still needs a
runtime lifecycle, rejection policy, and shutdown behavior. Use a durable queue
for important work that must survive process restarts.

## Async Callback Pitfalls

An `async` callback passed where a `void` return is expected can produce a
promise that the caller ignores. Event emitters and array iteration methods are
common examples.

```ts
// This does not wait for handlers.
items.forEach(async (item) => processItem(item));
```

Use `for...of` for sequential work or `map()` plus a promise combinator and
concurrency bound for parallel work.

## Reliability Rules

- Give every promise an owner.
- Type exported async return values explicitly.
- Treat caught errors and external values as `unknown`.
- Propagate cancellation to resource-owning adapters.
- Distinguish expected result variants from exceptional failures.
- Bound concurrency according to downstream capacity.
