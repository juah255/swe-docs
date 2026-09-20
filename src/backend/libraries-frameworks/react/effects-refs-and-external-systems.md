# Effects, Refs, and External Systems

Effects synchronize rendered React state with systems React does not control,
such as browser APIs, network connections, media players, maps, timers, and
third-party widgets. They are an escape hatch, not the default tool for moving
data around a component tree.

## When an Effect Is Appropriate

Use an Effect when a component's presence or reactive values require an
external system to be connected or updated:

```tsx
function ChatRoom({ roomID }: { roomID: string }) {
  useEffect(() => {
    const connection = createConnection(roomID);
    connection.connect();

    return () => connection.disconnect();
  }, [roomID]);

  return <Chat roomID={roomID} />;
}
```

Setup and cleanup form one synchronization cycle. When `roomID` changes, React
cleans up the old connection before setting up the new one.

## You Might Not Need an Effect

Do not use an Effect to:

- derive display data from props or state;
- handle a user interaction that belongs in an event handler;
- reset a subtree when a key can express identity;
- notify a parent when the child can call a callback in the same event;
- chain local state updates that can be one reducer transition;
- perform framework-supported route data loading.

These patterns introduce an extra render with stale state and create dependency
problems.

```tsx
// Avoid synchronizing derived state.
const [fullName, setFullName] = useState("");
useEffect(() => setFullName(`${firstName} ${lastName}`), [firstName, lastName]);

// Derive during render instead.
const fullName = `${firstName} ${lastName}`;
```

## Dependencies Are Descriptive

Every reactive value read by an Effect belongs in its dependency list. The list
describes the code; it is not a manual schedule to tune until the Effect runs at
the desired times.

If a dependency causes unwanted reruns:

- move interaction-specific work to an event handler;
- move an object or function inside the Effect;
- extract non-reactive constants outside the component;
- use a functional state updater when only the prior value is needed;
- split unrelated synchronization into separate Effects.

Do not disable the hook dependency linter to hide an unstable design.

## Cleanup

Cleanup should undo setup:

- unsubscribe listeners;
- disconnect sockets;
- clear timers;
- abort requests;
- release imperative widgets;
- ignore obsolete async results when the underlying API cannot cancel.

In development Strict Mode, React runs an extra setup-cleanup cycle to reveal
missing cleanup. The correct fix is symmetric cleanup, not a ref that prevents
the second setup.

## Data Fetching in Effects

Fetching in an Effect is valid for client-only synchronization, but it requires
handling cancellation, race conditions, loading, errors, caching, and repeated
requests:

```tsx
useEffect(() => {
  const controller = new AbortController();

  void loadUser(userID, { signal: controller.signal })
    .then(setUser)
    .catch((error: unknown) => {
      if (!controller.signal.aborted) setError(toMessage(error));
    });

  return () => controller.abort();
}, [userID]);
```

Prefer framework data APIs or a dedicated server-state cache when they can
start work before rendering and coordinate deduplication and revalidation.

## Refs

A ref stores a mutable value across renders without causing a render when it
changes:

```tsx
const inputRef = useRef<HTMLInputElement>(null);

function focusInput() {
  inputRef.current?.focus();
}

return <input ref={inputRef} />;
```

Use refs for DOM nodes, timer IDs, imperative library instances, and values that
do not affect rendering. If the UI should update when a value changes, it belongs
in state instead.

Avoid reading or writing `ref.current` during rendering except for predictable
initialization. Mutable reads make render output depend on hidden state.

## Imperative Handles

Expose the smallest imperative API a parent needs rather than an entire internal
DOM structure. `useImperativeHandle` can provide methods such as `focus()` or
`reset()`. Prefer declarative props when state can describe the result.

## Layout Effects

`useLayoutEffect` runs before the browser repaints after a commit. It is useful
for measuring layout and synchronously adjusting visual position when a normal
Effect would visibly flicker.

It blocks paint, so prefer `useEffect` unless pre-paint measurement is required.
Browser-only layout logic also needs care in server-rendered applications.

## Custom Hooks

A custom hook packages a synchronization policy behind a focused API:

```tsx
function useOnlineStatus(): boolean {
  return useSyncExternalStore(
    subscribeToOnlineStatus,
    getOnlineStatus,
    getServerOnlineStatus,
  );
}
```

Hooks must follow the Rules of Hooks: call them at the top level of components
or other hooks. Keep the hooks lint rules enabled.

## Effect Review Checklist

- Which external system is being synchronized?
- Does setup have complete cleanup?
- Are all reactive dependencies declared?
- Could this be calculated during render?
- Was it caused by a specific event instead?
- Can a framework or external-store hook own the lifecycle more safely?
