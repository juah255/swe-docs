# Next.js Questions

These questions review current App Router concepts relevant to mid-level and
senior full-stack engineers.

## 1. What does Next.js add to React?

**Answer:** Next.js adds file-system routing, server rendering, Server Component
orchestration, data and mutation conventions, streaming, caching, metadata,
asset optimization, server endpoints, and deployment integration. React still
provides the component and UI model.

## 2. How do the App Router and Pages Router differ?

**Answer:** The App Router uses Server Components, nested layouts, Suspense,
Route Handlers, Server Functions, and colocated route conventions. The Pages
Router uses page components, `_app`, `_document`, data functions such as
`getServerSideProps`, and API Routes. They can coexist during migration but have
different execution and caching models.

## 3. When should a component be a Server Component?

**Answer:** Use the server default for data access, secrets, large server-only
dependencies, cacheable output, and non-interactive markup. Use a Client
Component only when state, event handlers, Effects, browser APIs, or client
context are required.

## 4. What does `"use client"` do?

**Answer:** It marks a module as a client entry point. That module and its
transitive imports enter the client graph. It does not mean the component only
renders in the browser; Client Components can still contribute to server-
generated initial HTML and then hydrate.

## 5. What can cross from a Server Component to a Client Component?

**Answer:** Props must follow React's serialization contract. Prefer narrow
plain DTOs and explicit representations for dates, decimals, large integers,
and domain objects. Never pass secrets, database clients, requests, or privileged
server objects.

## 6. Where should data fetching happen?

**Answer:** Fetch initial and privileged data directly in Server Components or
server-only data functions. Use client fetching for polling, browser-dependent
data, or user-triggered views that need a client cache. Avoid calling the same
application's Route Handler from a Server Component.

## 7. How do you prevent server data waterfalls?

**Answer:** Start independent promises together, fetch at the route boundary,
preload predictable work, deduplicate shared reads, and place independent slow
regions behind Suspense so they can stream separately.

## 8. What is the current default caching behavior for server `fetch`?

**Answer:** In the ordinary current App Router model, `fetch` is not persistently
cached by default. Opt in with `force-cache` or a positive revalidation policy.
When Cache Components is enabled, `"use cache"`, `cacheLife`, and `cacheTag`
provide a different explicit model.

## 9. How does React `cache` differ from Next.js persistent caching?

**Answer:** React `cache` commonly deduplicates a server function during one
render request. Next.js Data Cache or Cache Components can reuse work across
requests according to freshness and invalidation rules. Request deduplication
does not make data persistently cached.

## 10. How do `revalidateTag`, `updateTag`, and `revalidatePath` differ?

**Answer:** `revalidateTag` supports stale-while-revalidate tag invalidation.
`updateTag` immediately expires a tag for read-your-own-writes and is limited to
Server Actions. `revalidatePath` invalidates route-associated cached work. Tags
are usually more precise when the same data appears on several routes.

## 11. What is Partial Prerendering?

**Answer:** With Cache Components, reusable cached regions can form a static
shell while request-time regions stream through Suspense. It combines fast
prerendered output and dynamic content within one route, provided private data
does not enter shared cached regions.

## 12. Why are Server Actions not automatically secure?

**Answer:** They are remotely callable server entry points. The client controls
arguments, form fields, and invocation timing. Every action must authenticate,
authorize the resource, validate input, enforce transaction and idempotency
rules, and return safe errors.

## 13. When should you use a Route Handler instead of a Server Action?

**Answer:** Use a Server Action for UI mutations integrated with React forms and
updated rendering. Use a Route Handler for a public HTTP contract needed by
webhooks, mobile clients, external consumers, file responses, OAuth callbacks,
or browser code requiring an explicit endpoint.

## 14. What is Proxy, and what should it not do?

**Answer:** `proxy.ts` runs at the request boundary and can rewrite, redirect,
modify headers, or respond. Use it for fast request-dependent policy. It should
not perform slow data loading or serve as the only authorization layer. The old
`middleware.ts` name is deprecated.

## 15. Where should authorization happen?

**Answer:** Authorize as close as possible to every protected read and write,
normally in a server-only data access layer, action, or Route Handler. Layout and
Proxy checks are useful for experience and early redirects but are insufficient
as the only enforcement.

## 16. What causes hydration mismatches in Next.js?

**Answer:** The first client render differs from server HTML, often because
rendering reads time, randomness, locale, browser APIs, inconsistent data, or
invalid markup. Keep initial output deterministic and treat mismatch warnings as
bugs rather than broadly suppressing them.

## 17. How do you reduce client JavaScript?

**Answer:** Keep `"use client"` boundaries near interactive leaves, avoid broad
client providers, keep server-only dependencies out of shared barrels, load
large optional client features dynamically, and analyze route bundles in a
production build.

## 18. What must be coordinated in a multi-instance self-hosted deployment?

**Answer:** Coordinate persistent cache and tag invalidation, Server Action
encryption keys, build and asset IDs, old chunk availability, runtime
configuration, database migration compatibility, observability, and graceful
rollout. Module memory and local disk are not shared state.

## 19. Why should async Server Components often be tested end to end?

**Answer:** Their behavior depends on the framework renderer, server/client
boundary, streaming, cache, navigation, and hydration. Unit tools may not model
all of that accurately. Keep pure logic unit tested, then verify representative
async route behavior through a production-like application.

## 20. What makes a Next.js application production-ready?

**Answer:** It needs explicit server/client and cache boundaries, secure data
access, validated Actions and handlers, accessible loading and errors, optimized
bundles and assets, production-mode tests, instrumentation, compatible database
migrations, coordinated distributed caching, protected configuration, health
signals, and a tested rollback strategy.
