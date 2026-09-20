# Data Fetching, Actions, and Suspense

Remote data is owned by a server and has a different lifecycle from local UI
state. A robust design coordinates request start time, caching, revalidation,
loading, errors, cancellation, mutations, and stale results.

## Prefer an Architecture-Level Data API

The best request is often started by the router or framework before the route
component renders. This avoids parent-child request waterfalls and can support
server rendering, streaming, caching, and prefetching.

Choose one primary strategy:

- framework route loaders or Server Components;
- a dedicated client-side server-state cache;
- a small client-only request hook for simple applications;
- an external store when data arrives through a subscription.

Do not combine several caches without defining ownership and invalidation.

## Server State Is Not UI State

A server-state layer typically needs:

- a stable key for each query;
- stale and retention policies;
- request deduplication;
- cancellation on abandoned work;
- retry rules based on error type;
- invalidation after mutations;
- background refresh and focus/reconnect policies;
- optimistic update and rollback behavior.

Copying query results into component state creates a second source of truth
unless the copy is an intentional editable draft.

## Avoid Request Waterfalls

A waterfall occurs when a parent fetch completes before a child can discover
and start its own request. Start independent work together at the route or
server boundary, preload during navigation, or fetch in parallel.

Request waterfalls increase latency even when every individual endpoint is
fast.

## Suspense

`Suspense` displays a fallback while a compatible child source is not ready:

```tsx
<Suspense fallback={<OrderDetailsSkeleton />}>
  <OrderDetails orderID={orderID} />
</Suspense>
```

Suspense placement defines the reveal sequence. Boundaries should match a
meaningful loading experience rather than wrapping every component.

Suspense does not detect arbitrary fetching started in an Effect. Use a
Suspense-enabled framework, router, or cache. Lazy component loading is also a
supported Suspense source.

## Error Boundaries

An Error Boundary catches errors thrown while rendering a descendant and shows
a fallback. It does not generally catch event-handler errors, arbitrary async
callbacks, server-side errors for the same boundary, or errors inside the
boundary itself.

Place boundaries around recoverable product areas and route segments. Provide a
retry or navigation path when appropriate, and report unexpected failures with
component and route context.

Function components do not directly implement the class error-boundary lifecycle
methods; applications commonly use a small class boundary or a framework or
library abstraction.

## Transitions

A Transition marks a state update as non-urgent so urgent interaction can remain
responsive:

```tsx
const [isPending, startTransition] = useTransition();

function selectTab(tab: Tab) {
  startTransition(() => setSelectedTab(tab));
}
```

Transitions do not delay the work from being scheduled and do not replace
debouncing or request cancellation. They help React prioritize rendering and
avoid unnecessarily replacing already visible content with a Suspense fallback.

Use `useDeferredValue` when a derived subtree may lag behind an urgent value,
such as a search input. Show a visual stale state so users understand the lag.

## Actions

An Action is an async transition used for data mutation and pending UI. Action
integration is strongest in frameworks and React-aware form APIs.

`useActionState` associates returned state and pending status with an action:

```tsx
type SaveState = { error: string | null };

async function saveProfile(
  previous: SaveState,
  formData: FormData,
): Promise<SaveState> {
  try {
    await updateProfile(formData);
    return { error: null };
  } catch (error: unknown) {
    return { error: toPublicMessage(error) };
  }
}

function ProfileForm() {
  const [state, formAction, isPending] = useActionState(
    saveProfile,
    { error: null },
  );

  return (
    <form action={formAction}>
      <input name="displayName" required />
      <button disabled={isPending}>Save</button>
      {state.error && <p role="alert">{state.error}</p>}
    </form>
  );
}
```

When a framework turns an action into server execution, treat it as a public
server endpoint: authenticate, authorize, validate, protect against abuse, and
avoid trusting hidden fields.

## Optimistic UI

`useOptimistic` can show an expected result immediately while an Action runs.
Use it only when the likely outcome and rollback behavior are clear.

An optimistic update needs:

- a stable identity for temporary items;
- a policy for concurrent changes;
- rollback or reconciliation on failure;
- accessible pending and error feedback;
- server-side idempotency where duplicate submission is possible.

Never imply irreversible success, such as a completed payment, before the server
confirms it.

## Mutation Checklist

- Disable or safely deduplicate duplicate submissions.
- Keep validation errors distinct from unexpected failures.
- Invalidate or update every affected query.
- Preserve server authority when reconciling optimistic data.
- Carry authentication, authorization, and idempotency on the server.
- Announce pending, success, and failure states accessibly.
