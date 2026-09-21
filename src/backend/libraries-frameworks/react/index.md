# React

React is a library for building user interfaces from components. It provides a
declarative rendering model, local state, composition, and primitives for
coordinating synchronous and asynchronous UI. Routing, data loading, validation,
styling, and deployment architecture are supplied by the surrounding platform
or framework.

React can power a client-rendered application, enhance server-rendered HTML, or
participate in a framework architecture with streaming and Server Components.
Choose that architecture before selecting state and data-fetching patterns.

## Why React Works Well

- Components combine markup and behavior around cohesive UI responsibilities.
- One-way data flow makes updates easier to trace.
- State and reducer primitives cover local interaction without requiring a
  global store.
- The ecosystem supports browsers, native platforms, server rendering, testing,
  accessibility, and developer tooling.
- Framework integrations can coordinate routing, server data, mutations,
  streaming, and code splitting.

The main risks are unclear state ownership, unnecessary Effects, accidental
client-side waterfalls, oversized bundles, inaccessible custom controls, and
trusting client code with server-side security decisions.

## Topics

- [Fundamentals and Rendering](fundamentals-and-rendering.md) — JSX, pure
  rendering, render and commit, events, Strict Mode, and state snapshots.
- [Components and Composition](components-and-composition.md) — props,
  `children`, keys, controlled component APIs, TypeScript, and boundaries.
- [State, Reducers, and Context](state-reducers-and-context.md) — state
  ownership, immutable updates, reducers, context, and external stores.
- [Effects, Refs, and External Systems](effects-refs-and-external-systems.md) —
  synchronization, dependencies, cleanup, refs, layout effects, and hooks.
- [Data Fetching, Actions, and Suspense](data-fetching-actions-and-suspense.md) —
  server state, loading boundaries, transitions, Actions, and optimistic UI.
- [Forms and Validation](forms-and-validation.md) — controlled and uncontrolled
  fields, accessible validation, submission, and server errors.
- [Routing and Rendering Architectures](routing-and-rendering-architectures.md)
  — CSR, SSR, static rendering, streaming, hydration, and Server Components.
- [Testing and Accessibility](testing-and-accessibility.md) — behavior-focused
  tests, semantic HTML, keyboard access, focus, and end-to-end coverage.
- [Performance](performance.md) — measurement, render cost, state placement,
  code splitting, lists, memoization, and React Compiler.
- [Security and Production](security-and-production.md) — XSS, authentication,
  CSRF, secrets, error reporting, observability, and deployment checks.
- [React Questions](questions.md) — concise mid- and senior-level interview
  questions and answers.

## Core Vocabulary

| Term | Meaning |
| --- | --- |
| **Component** | A function or class that describes part of the UI. Function components are standard for new code. |
| **Element** | An immutable description of what should be rendered. JSX creates element descriptions. |
| **Render** | React calls components to calculate the next UI description. Rendering must be pure. |
| **Commit** | React applies the required changes to the host environment, such as the browser DOM. |
| **Hook** | A function that lets a component use React capabilities such as state, context, refs, and Effects. |
| **Effect** | Logic caused by rendering that synchronizes with an external system after commit. |
| **Hydration** | React attaches behavior to compatible HTML that was already rendered on the server. |
| **Server Component** | A component rendered in a framework-managed server environment and not shipped as client component code. |

## Suggested Learning Path

1. Learn JSX, pure rendering, props, events, and state snapshots.
2. Practice component composition and local state ownership.
3. Add reducers and context only when interaction spans a larger subtree.
4. Learn when an Effect is needed and how cleanup mirrors setup.
5. Choose a routing and data architecture, then design loading and error
   boundaries.
6. Test behavior and accessibility before optimizing measured bottlenecks.

React assumes strong JavaScript knowledge. Review [JavaScript](../../languages/javascript/index.md)
and [TypeScript](../../languages/typescript/index.md) as needed, then continue to
[Next.js](../nextjs/index.md) for one full-stack React framework.

## Official References

- [React Learn](https://react.dev/learn)
- [React API reference](https://react.dev/reference/react)
- [React DOM reference](https://react.dev/reference/react-dom)
- [React Server Components](https://react.dev/reference/rsc/server-components)
