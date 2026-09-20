# React Questions

These questions review React concepts relevant to mid-level and senior frontend
and full-stack engineers.

## 1. What happens during render and commit?

**Answer:** During render, React calls components to calculate the next UI tree.
Rendering must be pure and may be repeated. During commit, React applies the
necessary host changes, such as DOM updates. A component render does not imply
that every descendant DOM node changes.

## 2. How do you choose component boundaries?

**Answer:** Split around cohesive responsibility, state and Effect ownership,
reusable accessible interaction, loading or error boundaries, and measured
render isolation. Avoid extracting every visual fragment or creating layers of
components that only pass props through unchanged.

## 3. What state should be local, lifted, placed in context, or external?

**Answer:** Keep state local to the smallest subtree that needs it. Lift it to a
common owner when siblings coordinate. Use context for a value or dependency
needed across a subtree. Use an external store for state genuinely owned outside
React or shared beyond a practical component boundary. Keep server data in a
server-state layer and shareable navigation state in the URL.

## 4. Why should state not be mutated?

**Answer:** React treats state as a snapshot. Mutation changes an existing
snapshot without telling React and can corrupt prior renders, memoization, and
concurrent work. Replace objects and arrays with new values through the setter
or reducer.

## 5. When should you use a reducer?

**Answer:** Use a reducer when several related state transitions are easier to
name, test, and centralize. Reducers are pure and local unless their state and
dispatch are deliberately provided through context.

## 6. What is an Effect for?

**Answer:** An Effect synchronizes rendered state with an external system after
commit, such as a subscription, browser API, timer, network connection, or
imperative widget. Deriving values and handling direct user interactions usually
do not require an Effect.

## 7. Why must Effect dependencies be complete?

**Answer:** The dependency list describes every reactive value the Effect reads.
Omitting one lets the synchronization use stale props or state. If complete
dependencies cause unwanted reruns, restructure ownership or the Effect rather
than suppressing the linter.

## 8. Why do Effects run an extra setup-cleanup cycle in Strict Mode?

**Answer:** Development Strict Mode stresses synchronization to reveal missing
cleanup and hidden assumptions that setup occurs only once. Correct Effects can
be stopped and started again without breaking. The extra cycle is not the normal
production behavior.

## 9. What is the difference between state and a ref?

**Answer:** Updating state schedules a render because the value affects UI.
Updating a ref does not render; refs hold DOM nodes, timer IDs, imperative
instances, or other mutable information outside the visual result.

## 10. Why are stable keys important?

**Answer:** Keys identify sibling elements across renders so React preserves the
correct state and DOM. Use stable data IDs. Index keys break identity when a
list changes order, and random keys force remounting every time.

## 11. What does Suspense do?

**Answer:** Suspense shows a fallback while a compatible child source is not
ready and coordinates progressive reveal. It works with lazy code and integrated
framework, router, or cache data sources; it does not automatically detect an
ordinary fetch started in an Effect.

## 12. What does an Error Boundary catch?

**Answer:** It catches descendant render and lifecycle errors and displays a
fallback. It does not generally catch event-handler errors, arbitrary async
callbacks, server-side errors for that same client boundary, or an error thrown
inside the boundary itself.

## 13. How do Server Components differ from SSR?

**Answer:** Server Components keep selected component execution and dependencies
outside the client bundle and send rendered output through a framework protocol.
SSR produces initial HTML. They can work together: a framework may render Server
Components, produce HTML, and hydrate only interactive Client Components.

## 14. What causes hydration mismatches?

**Answer:** The initial client render differs from the server HTML, often because
render reads time, randomness, locale, browser-only APIs, different data, or
invalid markup. Treat mismatches as bugs and make the initial render
deterministic rather than broadly suppressing warnings.

## 15. When should you memoize?

**Answer:** Memoize after profiling shows repeated expensive rendering or a
stable identity is required for an optimization. `memo`, `useMemo`, and
`useCallback` add comparison and dependency complexity. React Compiler can
automate much memoization when configured, but it does not replace measurement
or pure components.

## 16. How should React data fetching be designed?

**Answer:** Prefer route or framework loading, Server Components, or a dedicated
server-state cache so requests can start early and share caching, cancellation,
revalidation, and error policy. Avoid copying query data into a second general
state store or creating parent-child request waterfalls.

## 17. How do controlled and uncontrolled inputs differ?

**Answer:** A controlled input receives its current value from React state and
emits changes. An uncontrolled input keeps its current value in the DOM and can
be read through `FormData` or a ref. Choose based on interaction needs and do
not switch modes during the input's lifetime.

## 18. What makes a React application production-ready?

**Answer:** It needs accessible semantic UI, authoritative backend security,
safe HTML and URL handling, deliberate data and rendering architecture, error
and loading boundaries, measured bundle and runtime performance, behavior-
focused tests, protected source maps, observability, compatible caching, and a
deployment strategy that preserves referenced assets and supports rollback.
