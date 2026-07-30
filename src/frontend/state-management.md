# State Management

## Types of State

- **Local state:** Data owned by a single component (`useState`).
- **Shared UI state:** Data needed by multiple components (theme, sidebar open).
- **Server state:** Data from the backend, with loading, error, invalidation concerns.
- **URL state:** Current route, query params, filters.
- **Form state:** Field values, validation, submission status.

## Local State

`useState` for simple values. `useReducer` for complex state logic with multiple transitions. Keep state as close as possible to where it is used.

## Context

React Context provides a way to pass data through the component tree without prop drilling. Best for low-frequency, mostly-read state (theme, locale, auth status). Not a replacement for a store — frequent updates cause subtree re-renders.

## Server State

Use a dedicated library (TanStack Query, SWR, Apollo Client) that handles caching, background refetching, optimistic updates, pagination, and cache invalidation. Avoid storing server data in a global store — it duplicates state and misses cache semantics.

## Global Stores (Redux, Zustand, Pinia)

- **Redux:** Predictable state container with actions, reducers, middleware. Strong devtools and ecosystem. Verbose.
- **Zustand:** Minimal API. No boilerplate. Good for medium-scale shared state.
- **Pinia:** Vue's official store. Similar to Vuex but simpler.

Use a global store only for truly shared client state (cart, user preferences, multi-step wizard). Most state can be local, server-cached, or context-based.

## Mid/Senior Interview Questions and Answers

### 1. How do you design frontend state management?

**Answer:** Separate local UI state, shared client state, and server state. Local state belongs close to the component. Shared UI state may need context or a store. Server state should be handled with a data-fetching cache that understands loading, errors, invalidation, and retries. Avoid putting every value into one global store.

### 2. When would you use Context vs a dedicated state library?

**Answer:** Context is fine for low-frequency, mostly-read state (theme, locale). It causes re-renders on every update and is not optimized for frequent changes. Use a state library (Zustand, Redux) when state changes often, multiple components consume independent slices, or you need middleware (logging, persistence).

### 3. How do you handle stale server state?

**Answer:** Use a library with built-in cache invalidation (TanStack Query, SWR). Key strategies: background refetch on mount, stale-while-revalidate, optimistic updates, cache invalidation on mutation, and refetch on window focus. Manual state management of server data inevitably leads to stale UI.

### 4. What is the difference between controlled and uncontrolled components?

**Answer:** Controlled components have their state managed by React — the component value is tied to state and only changes through `setState`. Uncontrolled components manage their own state via the DOM ref. Controlled gives React full control; uncontrolled is simpler for non-critical inputs.

### 5. What is prop drilling and how do you solve it?

**Answer:** Prop drilling is passing data through many intermediate components that do not use it. Solutions: Context for shared state, composition (lifting content up, passing it down as children), or a state library for truly global state. Composition is often cleaner than context.
