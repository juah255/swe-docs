# NextJS

Next.js routing, data fetching, and deployment notes.

## Mid/Senior Interview Questions and Answers

### 1. How do server-rendered and client-rendered UI differ?

**Answer:** Server-rendered UI is generated on the server before being sent to
the browser, improving initial load and SEO for many pages. Client-rendered UI
loads JavaScript and renders more of the experience in the browser.

Senior design balances SEO, interactivity, caching, data freshness, bundle size,
and deployment model.

### 2. Where should data fetching happen in a Next.js app?

**Answer:** Fetch data as close as possible to where it is needed while keeping
security and caching clear. Server-side data fetching is appropriate for secrets,
private data, and database access. Client-side fetching fits highly interactive
or user-triggered data.

Do not expose server credentials or privileged APIs to browser code.

### 3. How do you think about caching in Next.js?

**Answer:** Caching can happen at several layers: fetch caching, route output,
CDN, browser cache, database cache, and application cache.

The hard part is invalidation. Define which data can be static, which needs
revalidation, and which must always be dynamic.

### 4. What production issues commonly appear in Next.js apps?

**Answer:** Common issues include oversized client bundles, hydration
mismatches, accidental server-only code in client components, slow data
fetching, unclear cache behavior, and environment variable leaks.

Use bundle analysis, logs, tracing, and clear server/client boundaries.
