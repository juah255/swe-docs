# Pages Router and Migration

The Pages Router remains useful in existing applications. The App Router changes
component execution, data loading, layouts, errors, metadata, and caching, so a
migration should move coherent routes rather than mechanically rename files.

## Pages Router Fundamentals

Routes live under `pages`:

```text
pages/
├── _app.tsx
├── _document.tsx
├── index.tsx
├── products/
│   ├── index.tsx
│   └── [slug].tsx
└── api/
    └── products.ts
```

- `_app.tsx` wraps every page and owns global client providers and styles.
- `_document.tsx` customizes the server-rendered document shell.
- API Routes expose server endpoints under `pages/api`.
- `_error.tsx`, `404.tsx`, and `500.tsx` define legacy error pages.

Pages are ordinary React components rendered through the Pages Router model;
they are not Server Components.

## Legacy Data APIs

| API | Behavior |
| --- | --- |
| `getStaticProps` | Loads data during static generation and may enable time-based regeneration. |
| `getStaticPaths` | Declares or controls dynamic paths generated statically. |
| `getServerSideProps` | Loads request-specific data for every server request. |
| Client fetch | Loads or refreshes data after browser rendering. |

These functions return serializable props. Keep secrets and privileged work
inside them or server modules, not in the page's browser bundle.

## Conceptual Mapping

| Pages Router | App Router |
| --- | --- |
| `_app.tsx` and page wrappers | Nested `layout.tsx` and Client providers |
| `_document.tsx` | Root layout document elements and Metadata APIs |
| `getStaticProps` | Cached/prerendered Server Component data |
| `getStaticPaths` | `generateStaticParams` |
| `getServerSideProps` | Dynamic Server Component data |
| API Routes | Route Handlers |
| `next/head` | Static or generated Metadata APIs |
| `next/router` | `next/navigation` hooks in Client Components |
| custom loading state | `loading.tsx` and Suspense |
| error pages | `error.tsx`, `global-error.tsx`, and `not-found.tsx` |

The mapping is conceptual, not a direct text replacement. Server Components and
cache semantics change where code executes and which values may cross into the
browser.

## Incremental Migration

The `app` and `pages` directories can coexist. Migrate one route group at a time:

1. upgrade Next.js and resolve deprecations first;
2. move reusable domain and data code out of page files;
3. create the root App Router layout;
4. migrate one route and its loading, errors, metadata, and endpoints;
5. verify navigation, bundle size, caching, authorization, and SEO;
6. remove the old route only after production validation.

Navigation between router systems can require a full-page transition and does
not share every layout or state assumption. Test cross-router links explicitly.

## Move Providers Deliberately

Do not copy all `_app` providers into one root Client Component. Determine which
routes need each provider and render it as deep as possible.

Global CSS can move to the root layout. Per-feature client state may belong in a
route layout, while server data should remain in Server Components rather than a
client provider.

## Convert Data Loading

Move request-independent data functions into server-only modules. Call them from
Server Components and define caching explicitly.

Do not keep `getServerSideProps` architecture by replacing it with a page that
fetches its own Route Handler. Direct server data access is simpler and faster.

Review serialization. App Router client props still cross a boundary even when
the calling syntax looks like ordinary component composition.

## Router API Differences

App Router navigation hooks come from `next/navigation` and are client-only.
Search and path hooks have different responsibilities from the Pages Router
router object.

Prefer page `params` and `searchParams` props for server data loading. Current
route props and request-time APIs are asynchronous, so migrate call sites to
`await` them rather than relying on old synchronous behavior.

## Caching Changes

Do not assume the caching behavior of an older Next.js release. In the current
ordinary App Router model, `fetch` is not persistently cached unless it opts in.
Cache Components adds a separate explicit `"use cache"` model when enabled.

Write route-specific freshness tests during migration. A page that previously
used static generation can accidentally become request-rendered, and a private
route can become dangerously reusable if cached without identity review.

## Proxy Migration

The historical `middleware.ts` convention is deprecated and renamed to
`proxy.ts`. Use the official codemod as a starting point, then review matchers,
runtime assumptions, authentication behavior, and performance.

Proxy should remain a fast request boundary, not become a replacement for the
authorization checks formerly inside server data functions.

## Migration Checklist

- Upgrade and run official codemods in small reviewed steps.
- Move business and data access logic out of router-specific files.
- Keep Client Component boundaries narrow.
- Replace head and document behavior with Metadata and layouts.
- Define cache behavior instead of relying on historical defaults.
- Rebuild authorization beside App Router data access.
- Test direct loads, client navigation, refresh, errors, and status codes.
- Compare client bundles and production performance before removing old routes.
