# Fundamentals and Rendering

React components describe what the interface should look like for the current
props, state, and context. React decides when to call those components and when
the host environment needs an actual update.

## Components and JSX

A function component returns React nodes:

```tsx
type GreetingProps = {
  name: string;
};

export function Greeting({ name }: GreetingProps) {
  return <h1>Hello, {name}</h1>;
}
```

Component names begin with an uppercase letter so JSX distinguishes them from
host elements such as `<button>`. JSX is syntax transformed by the build tool
into calls understood by the React runtime; it is not an HTML string.

Expressions inside `{}` can calculate values, select elements, and map arrays.
Keep statements and substantial logic outside the returned JSX.

## Render and Commit

A UI update has distinct phases:

1. Something triggers a render, such as the initial root or a state update.
2. React calls components to calculate the next tree.
3. React commits the required changes to the DOM.
4. The browser paints, and Effects run according to their timing.

A component rendering does not imply that every DOM node beneath it changes.
React compares the new result with the prior one and applies the necessary host
updates during commit.

## Rendering Must Be Pure

Given the same props, state, and context, a render should return the same result.
Do not mutate existing values, start requests, set timers, write storage, or
change the DOM during render.

```tsx
// Bad: mutates a prop during render.
function SortedUsers({ users }: { users: User[] }) {
  users.sort(byName);
  return <UserList users={users} />;
}

// Better: calculates from an independent copy.
function SortedUsers({ users }: { users: readonly User[] }) {
  const sortedUsers = [...users].sort(byName);
  return <UserList users={sortedUsers} />;
}
```

Pure rendering lets React pause, restart, or repeat work safely.

## State Is a Snapshot

Each render receives a snapshot of state. Calling a setter queues another
render; it does not change the value captured by the current event handler:

```tsx
function Counter() {
  const [count, setCount] = useState(0);

  function incrementThreeTimes() {
    setCount((current) => current + 1);
    setCount((current) => current + 1);
    setCount((current) => current + 1);
  }

  return <button onClick={incrementThreeTimes}>{count}</button>;
}
```

Functional updaters are required when the next value depends on queued previous
updates. React batches updates where appropriate to avoid unnecessary renders.

## Events

Event handlers belong to interactions such as clicks, typing, and submissions:

```tsx
function SaveButton({ save }: { save: () => Promise<void> }) {
  async function handleClick() {
    await save();
  }

  return <button onClick={handleClick}>Save</button>;
}
```

Pass the function rather than calling it during render: `onClick={handleClick}`,
not `onClick={handleClick()}`.

React events follow DOM concepts, but event prop names use camel case. Use the
event's propagation controls intentionally; avoid stopping propagation by
default because it can break parent behavior and analytics.

## Conditional Rendering

Use ordinary JavaScript:

```tsx
if (status === "loading") return <Loading />;
if (status === "error") return <ErrorMessage />;

return isAdmin ? <AdminPanel /> : <UserPanel />;
```

Returning `null` renders nothing. Be careful with `condition && <Element />`
when `condition` can be `0`, because React can render the zero.

## Lists and Keys

Keys identify sibling elements between renders:

```tsx
<ul>
  {users.map((user) => (
    <UserRow key={user.id} user={user} />
  ))}
</ul>
```

Use stable IDs from the data. Array indexes are safe only when the list is truly
static and never reorders, inserts, or deletes. Random keys force remounting and
discard local state on every render.

Keys are scoped to the immediate array and are not passed as a normal prop.

## State Identity

React associates state with a component's position and identity in the rendered
tree. Changing a key or component type at a position resets that subtree's
state. This is useful for deliberately resetting a form:

```tsx
<ProfileForm key={selectedUserID} userID={selectedUserID} />
```

Do not define component functions inside another component. A new component
type is created on each render, which can reset state unexpectedly.

## Strict Mode

Strict Mode enables development-only checks that help reveal impure rendering
and missing Effect cleanup. React may call render logic and setup-cleanup cycles
more than once in development. Code should be correct under this behavior rather
than using flags to suppress it.

Strict Mode does not add the duplicate production behavior; it exposes code
that was unsafe to repeat.

## Client Roots

A browser-only application creates a root and renders into it:

```tsx
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
```

Server-rendered HTML must be hydrated rather than replaced with a new client
root. Frameworks normally manage root creation and hydration.
