# State, Reducers, and Context

State represents information that changes over time and affects rendering.
Reliable React applications distinguish local UI state, URL state, server-owned
data, and long-lived external application state instead of placing everything
in one store.

## Choose the State Owner

Keep state in the lowest component that owns all interactions requiring it.

- Keep an open menu or input draft local.
- Lift state when sibling components must coordinate.
- Put shareable navigation state in the URL.
- Treat API data as server state with caching and revalidation needs.
- Use an external store only for state truly shared outside a manageable React
  subtree or synchronized with another system.

Duplicating the same fact in several state variables creates synchronization
bugs. Store the minimal source of truth and derive the rest during render.

## Updating Objects and Arrays

Replace state rather than mutating an existing object:

```tsx
setProfile((current) => ({
  ...current,
  address: {
    ...current.address,
    city: nextCity,
  },
}));
```

For arrays, use operations that produce a new array, such as `map`, `filter`,
and spread. Copying only the outer array does not make its nested objects
independent.

## Do Not Store Derived Values

```tsx
// Prefer deriving this during render.
const visibleUsers = users.filter((user) => user.name.includes(query));
```

Storing `visibleUsers` separately requires an Effect or coordinated setters to
keep it synchronized. Memoize the calculation only if profiling shows it is
expensive or stable identity is needed for an optimization.

## State Shape

Group values that change together and separate values that change independently.
Use unions for mutually exclusive states:

```tsx
type LoadState<Data> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: Data }
  | { status: "error"; message: string };
```

This is safer than independent `loading`, `error`, and optional `data` fields
that can represent contradictory combinations.

## Reducers

Use a reducer when a component has related transitions that are easier to name
and test centrally:

```tsx
type State = { quantity: number };
type Action =
  | { type: "increment" }
  | { type: "decrement" }
  | { type: "set"; quantity: number };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "increment":
      return { quantity: state.quantity + 1 };
    case "decrement":
      return { quantity: Math.max(0, state.quantity - 1) };
    case "set":
      return { quantity: Math.max(0, action.quantity) };
  }
}
```

Reducers must be pure. They centralize transitions; they do not automatically
make state global or asynchronous.

## Context

Context passes a value to descendants without threading it through every
intermediate prop:

```tsx
type Session = { userID: string; roles: readonly string[] };

const SessionContext = createContext<Session | null>(null);

function useSession(): Session {
  const session = useContext(SessionContext);
  if (session === null) throw new Error("SessionProvider is missing");
  return session;
}
```

Good uses include theme, locale, session display data, and a reducer API shared
within one feature. Context is dependency injection through the component tree,
not automatically a complete state-management solution.

## Context Performance

When a provider value changes, consumers reading that context can render again.
Avoid one giant context containing unrelated, frequently changing fields.

Useful strategies:

- split contexts by responsibility and update frequency;
- keep state near the consuming subtree;
- pass stable primitive values when possible;
- separate state from dispatch when it benefits consumers;
- measure before adding memoization or selector libraries.

## External Stores

Use `useSyncExternalStore` when subscribing to state owned outside React, such
as a custom store or browser API. It coordinates snapshots with concurrent
rendering and server rendering better than a hand-written Effect subscription.

A state library may add selectors, devtools, persistence, normalized entities,
or event-driven patterns. Choose one for a concrete application need, not
because the project contains more than a few components.

## URL and Server State

Filters, pagination, tabs, and selected IDs often belong in the URL when users
should bookmark, share, refresh, or navigate through them.

Server state remains owned by the backend. Client caches need loading, stale,
error, invalidation, deduplication, and mutation policies. Copying cached server
data into general UI state usually creates two sources of truth.

## State Checklist

- Is this value needed for rendering?
- Can it be calculated from props or other state?
- Which smallest subtree needs to own it?
- Should it survive refresh or be shareable through the URL?
- Is it actually remote server state?
- Does a reducer make transitions clearer?
- Is context scoped narrowly enough for its update rate?
