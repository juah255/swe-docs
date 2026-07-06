# React

React patterns, component guidance, and state management notes.

## Core Concepts

### What is React?

React is a library for building user interfaces from composable components. It
uses a virtual DOM diffing algorithm to update the real DOM efficiently and a
declarative model where the UI is expressed as a function of state.

React only handles the view layer. Routing, data fetching, forms, and styling
are provided by ecosystem libraries or meta-frameworks such as Next.js and
Remix.

### Components and JSX

Components are functions that return JSX. JSX is syntactic sugar for
`React.createElement` and compiles down to plain function calls.

```tsx
type Props = { name: string };

function Greeting({ name }: Props) {
  return <h1>Hello, {name}</h1>;
}
```

Class components still work but are legacy — modern React is written with
function components and hooks.

### Props and Children

Props flow one way, from parent to child. `children` is a special prop for
composing content passed between tags.

```tsx
function Card({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section>
      <h2>{title}</h2>
      {children}
    </section>
  );
}
```

Prefer composition over configuration through many boolean props.

### State with `useState` and `useReducer`

`useState` stores local state and returns a setter that triggers a re-render.

```tsx
const [count, setCount] = useState(0);
```

`useReducer` centralizes complex state transitions into a pure reducer
function, useful when updates depend on the previous state or span multiple
fields.

State updates are batched and asynchronous — always compute new state from the
previous state when it matters:

```tsx
setCount((prev) => prev + 1);
```

### Effects with `useEffect`

`useEffect` runs side effects after render — subscriptions, DOM measurements,
data syncing. The dependency array controls when it re-runs, and the cleanup
function undoes work before the next run or on unmount.

```tsx
useEffect(() => {
  const controller = new AbortController();
  fetch(`/api/users/${id}`, { signal: controller.signal })
    .then((r) => r.json())
    .then(setUser);
  return () => controller.abort();
}, [id]);
```

Effects should not be used for data derivation — compute it during render or
with `useMemo` instead.

### Context

Context passes data through the tree without prop drilling. It is best for
low-frequency, app-wide values (theme, current user, locale).

```tsx
const ThemeContext = createContext<"light" | "dark">("light");

function App() {
  return (
    <ThemeContext.Provider value="dark">
      <Page />
    </ThemeContext.Provider>
  );
}
```

Every consumer re-renders when the context value changes, so avoid putting
frequently changing state into a single wide context.

### Refs

`useRef` stores a mutable value that persists across renders without
triggering re-renders. It is commonly used for DOM access and holding
imperative handles.

```tsx
const inputRef = useRef<HTMLInputElement>(null);
useEffect(() => inputRef.current?.focus(), []);
```

### Memoization

`useMemo`, `useCallback`, and `React.memo` skip unnecessary work when
dependencies are unchanged.

```tsx
const filtered = useMemo(
  () => items.filter((i) => i.active),
  [items],
);

const onSelect = useCallback((id: string) => setSelected(id), []);
```

Memoize only when there is a measurable win. Premature memoization adds
complexity without value.

### Custom Hooks

A custom hook is a function starting with `use` that composes other hooks. It
is the primary reuse mechanism for stateful logic.

```tsx
function useDebounced<T>(value: T, delay = 300) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(id);
  }, [value, delay]);
  return debounced;
}
```

### Lists and Keys

Keys tell React which items changed between renders. Use stable, unique IDs —
not array indexes when the list can reorder or grow.

```tsx
{users.map((u) => <UserRow key={u.id} user={u} />)}
```

### Forms: Controlled vs Uncontrolled

Controlled components store input value in React state; uncontrolled
components let the DOM own the value and read it via refs.

Libraries such as React Hook Form and TanStack Form manage validation,
touched/dirty state, and performance for large forms.

### Data Fetching and Server State

Server state (data owned by an API) has different needs than UI state:
caching, revalidation, deduplication, retries. Libraries such as TanStack
Query, SWR, RTK Query, and Apollo Client handle this well.

Meta-frameworks like Next.js App Router move data fetching into React Server
Components, streaming HTML to the client with less JavaScript.

### Error Boundaries and Suspense

Error boundaries catch render-time errors in a subtree and show a fallback UI.
`Suspense` lets a subtree render a fallback while lazy components or async
data resolve.

```tsx
<Suspense fallback={<Spinner />}>
  <UserProfile />
</Suspense>
```

### Concurrent Features

React 18+ introduces concurrent rendering. `useTransition` marks non-urgent
updates so the UI stays responsive, and `useDeferredValue` yields a lagged
copy of a value for expensive downstream work.

```tsx
const [isPending, startTransition] = useTransition();
startTransition(() => setQuery(input));
```

### Rules of Hooks

- Call hooks at the top level, not inside conditions, loops, or nested
  functions.
- Call hooks only from React functions (components or other hooks).

The linter plugin `eslint-plugin-react-hooks` enforces both rules and
dependency-array correctness.

## Mid/Senior Interview Questions and Answers

### 1. How do you decide component boundaries in React?

**Answer:** Split components around cohesive UI responsibility, reusable
behavior, and state ownership. A component should be easy to understand without
knowing the entire page.

Avoid splitting only by visual fragments if it creates excessive prop drilling
or hides important flow.

### 2. What state should be local, lifted, or external?

**Answer:** Keep state local when only one component needs it. Lift state when
siblings must coordinate. Use external state or server-state tools when data is
shared widely, cached, synchronized with APIs, or updated from multiple places.

Senior React design separates UI state from server state.

### 3. Why do unnecessary re-renders happen?

**Answer:** Re-renders happen when state, props, or context values change.
Unstable object and function references can also cause memoized children to
render again.

Optimize only after measuring. Common fixes include better component boundaries,
stable keys, memoization, and avoiding overly broad context updates.

### 4. What are common React production concerns?

**Answer:** Common concerns include bundle size, accessibility, hydration
issues, stale state, error boundaries, slow lists, form complexity, and insecure
rendering of untrusted HTML.

Production React should include performance measurement, accessibility checks,
and clear data-fetching patterns.
