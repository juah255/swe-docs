# Components and Composition

Good component boundaries make state ownership, reuse, accessibility, and
loading behavior clear. Split by cohesive responsibility rather than by an
arbitrary line count or every visible DOM element.

## Props Are Inputs

Props flow from parent to child and should be treated as immutable:

```tsx
type UserCardProps = {
  user: Readonly<UserSummary>;
  onSelect: (userID: string) => void;
};

function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <article>
      <h2>{user.name}</h2>
      <button onClick={() => onSelect(user.id)}>Open profile</button>
    </article>
  );
}
```

If a child needs a change, it calls a provided callback or updates state it
owns. Mutating props can corrupt another component's snapshot and defeats
memoization assumptions.

## Prefer Composition

Use `children` when a component supplies structure around arbitrary content:

```tsx
type PanelProps = {
  title: string;
  children: React.ReactNode;
};

function Panel({ title, children }: PanelProps) {
  const headingID = useId();

  return (
    <section aria-labelledby={headingID}>
      <h2 id={headingID}>{title}</h2>
      {children}
    </section>
  );
}
```

For named regions, accept explicit node props such as `header`, `sidebar`, and
`footer`. This is often clearer than many booleans controlling internal layout.

## Component Boundaries

Create a component when it provides one or more of these:

- a cohesive UI responsibility;
- state or Effect ownership;
- an accessibility abstraction;
- reuse with a stable, understandable API;
- an error, loading, or code-splitting boundary;
- isolation of expensive rendering.

Avoid splitting a simple flow into layers of pass-through components. Extract
when the new boundary improves ownership or comprehension.

## Controlled Component APIs

A controlled component receives its current value and emits requested changes:

```tsx
type ToggleProps = {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
};

function Toggle({ checked, onCheckedChange }: ToggleProps) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      onClick={() => onCheckedChange(!checked)}
    >
      Notifications
    </button>
  );
}
```

Controlled APIs let parents coordinate state. An uncontrolled variant can own
state and accept an initial value. Do not switch between controlled and
uncontrolled behavior during a component's lifetime.

## Avoid Boolean Prop Explosion

Several booleans can create invalid combinations:

```tsx
// Hard to reason about combinations.
<Banner success warning compact dismissible />
```

Prefer an explicit variant or separate components:

```tsx
type BannerProps = {
  tone: "success" | "warning" | "danger";
  density?: "normal" | "compact";
};
```

Use discriminated unions when different variants require different props.

## Domain Components and Primitives

- A **primitive** captures reusable interaction and accessibility, such as a
  dialog, field, or menu.
- A **domain component** represents a product concept, such as an order summary
  or subscription status.
- A **route component** coordinates page data, boundaries, and navigation.

Keep backend payloads from spreading directly through every presentational
component. Map them into UI-facing view models when that clarifies formatting,
permissions, or missing values.

## Keys and Extraction

The key belongs where the array is created:

```tsx
{orders.map((order) => (
  <OrderRow key={order.id} order={order} />
))}
```

Putting a key on the root element inside `OrderRow` does not identify the
sibling component to its parent.

## TypeScript Props

Prefer narrow prop contracts and real browser element types:

```tsx
type ButtonProps = React.ComponentPropsWithoutRef<"button"> & {
  tone?: "primary" | "secondary";
};
```

Forward valid native props when building a primitive, but do not blindly spread
untrusted objects onto DOM elements. Explicit application components are often
safer with a smaller named API.

Use `React.ReactNode` for content that React may render. Use an element type or
component type only when the prop must specifically be a component or element.

## Custom Hooks Are Not Components

A custom hook extracts reusable stateful logic; it does not share one state
instance between callers. Each call owns its own state and Effects.

Use a component to reuse UI and a hook to reuse behavior. Keep hooks focused on
one responsibility and return an API that hides internal coordination.

## Boundary Checklist

- Can the component be understood from its props and local code?
- Is state held by the nearest common owner that needs it?
- Does the API prevent invalid prop combinations?
- Is accessible interaction built into the abstraction?
- Are loading and error boundaries placed around meaningful user experiences?
- Would composition be clearer than another configuration flag?
