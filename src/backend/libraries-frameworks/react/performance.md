# Performance

React performance includes network delivery, JavaScript execution, rendering,
layout, paint, and data latency. A render that takes one millisecond cannot fix
a slow API, a large client bundle, or an unoptimized image.

## Measure First

Use production builds and representative devices, data, and network conditions.
Measure:

- user-centric web performance metrics;
- route and resource waterfalls;
- JavaScript bundle size and execution time;
- React commits with the Profiler;
- long tasks and input responsiveness;
- layout shifts and image loading;
- server response and data-fetch latency.

Development mode adds checks and different optimization behavior, so it is not
a reliable performance benchmark.

## State Placement

State updates render the component that owns the state and, by default, its
descendant tree. Keep rapidly changing state near the components that display
it.

Composition can isolate updates naturally:

```tsx
function Page({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button onClick={() => setOpen((value) => !value)}>Toggle menu</button>
      {open && <Menu />}
      {children}
    </>
  );
}
```

Passing stable children can prevent unrelated expensive content from being
recreated by the state-owning component.

## Remove Cascading Effects

Effects that set derived state cause an extra render and often form chains.
Calculate during render or combine related transitions in one event or reducer.

Also remove unnecessary Effects that continually recreate subscriptions or
write global state. Correct dependencies and stable ownership improve both
performance and correctness.

## Context Scope

A frequently changing provider can render many consumers. Split unrelated
contexts, move providers nearer their use, and avoid passing a new object when
its meaningful fields did not change.

Measure before introducing selector layers. A small subtree may be faster and
clearer without them.

## Memoization

`memo`, `useMemo`, and `useCallback` are performance tools, not correctness
tools.

- `memo` can skip a child render when its props are unchanged.
- `useMemo` can cache a calculation or stabilize a derived value.
- `useCallback` can stabilize a function reference.

They add comparison work and dependency complexity. A single always-new object
or function prop can defeat memoization. Use profiling to identify expensive,
repeated renders before adding it.

## React Compiler

React Compiler is a build-time optimizer that can automatically memoize
components and calculations based on React's rules. It must be configured and
validated as part of the build; the React runtime does not enable it merely by
being upgraded.

For compiler-enabled new code, rely on its analysis by default and use manual
memoization for cases requiring precise identity control. For an existing
codebase, adopt incrementally and test before removing established manual
memoization.

Code still needs pure rendering and valid hook usage for safe optimization.

## Large Lists

For hundreds or thousands of visible rows:

- paginate or incrementally load server data;
- virtualize when only a viewport-sized window is needed;
- use stable keys;
- avoid expensive work in every row render;
- keep row props narrow;
- preserve focus and screen-reader usability when virtualizing.

Virtualization is not automatically appropriate for small lists, printed
content, browser find, or accessibility-sensitive layouts.

## Code Splitting

Split code at routes and large features so users do not download every screen
up front:

```tsx
const AdminPanel = lazy(() => import("./AdminPanel"));

<Suspense fallback={<AdminPanelSkeleton />}>
  <AdminPanel />
</Suspense>
```

Avoid excessive tiny chunks that add request and coordination overhead.
Preload likely next routes or features based on the router and product flow.

## Assets and Third-Party Code

Images, fonts, analytics, editors, and support widgets often dominate page
cost. Resize images, use appropriate formats, reserve layout space, subset
fonts, and load third-party code deliberately.

Track bundle changes in CI and assign ownership to large dependencies. Importing
one helper can pull in an unexpected module graph depending on package and build
configuration.

## Transitions and Deferred Values

Transitions can keep urgent input responsive while a heavier update renders.
Deferred values allow a non-urgent subtree to lag behind an input.

These tools prioritize rendering; they do not make computation cheaper. Reduce
the work, virtualize it, move it off the main thread, or process it on the server
when priority alone is insufficient.

## Performance Checklist

1. Measure a real user-facing problem in a production build.
2. Separate network, server, JavaScript, render, and paint time.
3. Fix waterfalls, bundle weight, and oversized assets.
4. Colocate state and remove unnecessary Effects.
5. Profile expensive commits and list rendering.
6. Add memoization or compiler optimization with evidence.
7. Re-measure the same scenario and watch accessibility regressions.
