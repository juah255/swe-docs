# Frontend

Frontend-focused notes, guides, and implementation references.

## Mid/Senior Interview Questions and Answers

### 1. How do you design frontend state management?

**Answer:** Start by separating local UI state, shared client state, and server
state. Local state belongs close to the component. Shared UI state may need
context or a store. Server state should usually be handled with a data-fetching
cache that understands loading, errors, invalidation, and retries.

Senior frontend design avoids putting every value into one global store.

### 2. How do you improve frontend performance?

**Answer:** Measure first with browser performance tools, real-user monitoring,
and bundle analysis. Common improvements include reducing JavaScript size,
lazy-loading routes, optimizing images, avoiding unnecessary re-renders, using
virtualized lists, and caching API responses.

Performance work should target user-facing metrics such as interaction latency,
largest contentful paint, and route transition time.

### 3. What accessibility concerns should every frontend engineer understand?

**Answer:** Semantic HTML, keyboard navigation, focus management, color
contrast, labels, ARIA only when needed, visible error messages, and screen
reader behavior.

Accessibility is not a final polish step. It affects component choice, layout,
forms, modals, navigation, and testing.

### 4. How do frontend and backend contracts stay reliable?

**Answer:** Use typed API clients, schema validation, contract tests, generated
types, stable error formats, and versioned API changes.

Frontend code should not rely on undocumented response shapes or status-code
behavior. Backend changes should be compatible with deployed clients.

### 5. What are common frontend security risks?

**Answer:** Common risks include XSS, unsafe HTML rendering, token exposure,
CSRF in cookie-based flows, dependency vulnerabilities, leaking secrets into
client bundles, and overly permissive CORS assumptions.

Never put server secrets in frontend environment variables that are bundled into
browser code.
