# React

React patterns, component guidance, and state management notes.

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
