# Frontend Testing

## Testing Pyramid for Frontend

- **Unit tests:** Test individual functions, hooks, and utilities in isolation. Fast, high coverage.
- **Component tests:** Test a component's rendering and behavior with mocked props and child components.
- **Integration tests:** Test how multiple components work together, often with real state and context.
- **E2E tests:** Test complete user flows in a real browser. Slow but high confidence.

## Tools

- **Vitest / Jest:** Test runner and assertion library. Vitest is faster and integrates with Vite.
- **React Testing Library:** Tests components from the user's perspective — queries by accessible roles, labels, text.
- **Playwright / Cypress:** E2E testing. Playwright supports multiple browsers and mobile emulation.
- **Storybook + Chromatic:** Visual regression testing for UI components.

## What to Test

- User interactions (click, type, submit) produce the expected output.
- Edge cases: empty states, error states, loading states, long content.
- Accessibility: critical paths work with keyboard and screen readers.
- Behavior under different viewport sizes and locales.

## What Not to Test

- Internal implementation details (state values, private methods).
- Exact CSS values unless critical for layout correctness.
- Third-party libraries (test your integration, not their internals).
- Snapshot tests for large components (brittle, low signal).

## Mid/Senior Interview Questions and Answers

### 1. Which tests should run on every pull request?

**Answer:** Unit and component tests should run on every PR — they are fast and catch most regressions. Integration tests for critical paths. E2E tests can run on the main branch or a nightly schedule since they are slow and flaky. Run linting and type checking in parallel.

### 2. How do you test asynchronous behavior in frontend code?

**Answer:** Use `waitFor`, `findBy*` queries, and `act` from Testing Library. Mock API calls with `msw` (Mock Service Worker) to control responses and simulate loading, error, and empty states. Avoid arbitrary timeouts — use assertions that wait for expected elements to appear.

### 3. What is the difference between a mock, a stub, and a spy?

**Answer:** A mock replaces a function and asserts how it was called. A stub replaces a function with a fixed return value. A spy wraps a function and records calls without changing behavior. In frontend testing, mocks are common for API calls and modules.

### 4. How do you test component behavior without testing implementation details?

**Answer:** Query elements by accessible roles, labels, and text (Testing Library philosophy). Test what the user sees and interacts with, not internal state or prop values. Avoid testing `useState` values directly — test the rendered output and behavior when the user clicks or types.
