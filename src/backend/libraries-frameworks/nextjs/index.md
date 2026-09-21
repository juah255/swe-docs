# Next.js

Next.js is a React framework for building web applications across the server
and browser. It provides file-system routing, Server and Client Components,
data loading, mutations, streaming, caching, metadata, asset optimization,
server endpoints, and several deployment modes.

This section focuses on the App Router, the current architecture for new work.
The Pages Router remains supported and is covered for maintenance and migration.

## Why Next.js Works Well

- Routes, layouts, loading UI, errors, metadata, and endpoints follow explicit
  file conventions.
- Server Components keep data access and non-interactive dependencies out of
  browser bundles.
- Client Components add interaction at deliberate boundaries.
- Streaming and Suspense can progressively reveal slow route regions.
- Server Functions integrate form mutations with refreshed UI and cache
  invalidation.
- Static rendering, dynamic rendering, and cached output can coexist within one
  application.
- Image, font, script, and route optimizations are integrated into the build.

The main complexity is understanding execution location and cache behavior.
Every route should make server/client boundaries, freshness, authorization, and
deployment assumptions visible.

## Topics

- [Project Structure and App Router](project-structure-and-app-router.md) —
  application layout, special files, colocated code, runtime boundaries, and
  configuration.
- [Routing, Layouts, and Navigation](routing-layouts-and-navigation.md) — static
  and dynamic segments, layouts, route groups, links, URL state, and advanced
  routing.
- [Server and Client Components](server-and-client-components.md) — execution
  environments, composition, serialization, providers, and bundle boundaries.
- [Data Fetching and Streaming](data-fetching-and-streaming.md) — server data,
  parallel loading, preloading, Suspense, client data, errors, and cancellation.
- [Caching and Revalidation](caching-and-revalidation.md) — explicit `fetch`
  caching, Cache Components, cache lifetimes, tags, paths, and personalization.
- [Mutations, Forms, and Server Functions](mutations-forms-and-server-functions.md)
  — Actions, validation, authorization, pending state, optimistic UI, and cache
  updates.
- [Route Handlers, Proxy, and BFF](route-handlers-proxy-and-bff.md) — HTTP
  endpoints, webhooks, browser-facing APIs, request interception, and limits.
- [Authentication and Security](authentication-and-security.md) — sessions,
  authorization, data access layers, DTOs, CSRF, secrets, and safe caching.
- [Performance, Metadata, and Assets](performance-metadata-and-assets.md) —
  bundles, images, fonts, scripts, metadata, Core Web Vitals, and SEO.
- [Testing and Observability](testing-and-observability.md) — unit, component,
  integration, end-to-end, instrumentation, errors, logs, and tracing.
- [Deployment and Production](deployment-and-production.md) — managed hosting,
  Node.js, containers, static export, multi-instance caching, and rollout.
- [Pages Router and Migration](pages-router-and-migration.md) — legacy data
  APIs, router differences, coexistence, and incremental migration.
- [Next.js Questions](questions.md) — concise mid- and senior-level interview
  questions and answers.

## Core Vocabulary

| Term | Meaning |
| --- | --- |
| **Route segment** | One folder in the `app` route hierarchy. |
| **Server Component** | A component rendered in the server environment and omitted from the client JavaScript graph. |
| **Client Component** | A component within a `"use client"` module graph that can use browser APIs, state, Effects, and event handlers. |
| **RSC payload** | The serialized React Server Component result used to update the client tree. |
| **Prerendering** | Producing route output ahead of a request, normally during the build or cache generation. |
| **Hydration** | Attaching React behavior to server-generated HTML for Client Components. |
| **Server Function** | An async function marked for server execution and callable through a framework-managed request. |
| **Proxy** | Request-boundary logic in `proxy.ts` that can redirect, rewrite, modify headers, or respond before routing completes. |

## Suggested Learning Path

1. Learn App Router files, nested layouts, and navigation.
2. Understand Server and Client Component boundaries before adding data access.
3. Build uncached data flows and Suspense loading UI.
4. Add caching only with an explicit freshness and invalidation policy.
5. Implement mutations with server-side validation and authorization.
6. Add Route Handlers, Proxy, and client state only for concrete needs.
7. Test the production build in the intended deployment model.

Review [React](../react/index.md) and [TypeScript](../../languages/typescript/index.md)
before treating Next.js conventions as substitutes for language and component
fundamentals.

## Official References

- [Next.js App Router documentation](https://nextjs.org/docs/app)
- [App Router getting started](https://nextjs.org/docs/app/getting-started)
- [Production checklist](https://nextjs.org/docs/app/guides/production-checklist)
- [Upgrade guides](https://nextjs.org/docs/app/guides/upgrading)
