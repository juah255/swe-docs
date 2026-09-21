# Caching and Revalidation

Caching is a data-consistency policy, not merely a performance switch. Define
who may share an entry, how stale it may be, what invalidates it, and how the
deployment coordinates invalidation.

Next.js currently supports two App Router caching approaches. Do not combine
their mental models accidentally.

## Ordinary App Router Caching

Without Cache Components, server `fetch` requests are not persistently cached by
default. Opt in explicitly:

```ts
const response = await fetch(PRODUCTS_URL, {
  cache: "force-cache",
  next: {
    revalidate: 3_600,
    tags: ["products"],
  },
});
```

- `cache: "no-store"` fetches from the source for each request.
- `cache: "force-cache"` uses the persistent Data Cache.
- `next.revalidate` sets a maximum lifetime in seconds.
- `next.tags` associates cached work with invalidation tags.

Avoid conflicting options such as `no-store` with a positive revalidation
interval.

## Cache Components

Cache Components is enabled in configuration:

```ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  cacheComponents: true,
};

export default nextConfig;
```

Use `"use cache"` inside an async function or component to cache its output:

```ts
import { cacheLife, cacheTag } from "next/cache";
import "server-only";

export async function listProducts() {
  "use cache";
  cacheLife("hours");
  cacheTag("products");

  return database.product.findMany();
}
```

Arguments and captured serializable inputs contribute to the cache key. Keep the
function's dependencies explicit and do not read request-time cookies or headers
inside a shared cached scope. Read them outside and pass only a safe value when
sharing is intended.

## Partial Prerendering

With Cache Components, cached work can form a static shell while uncached
request-time regions stream through Suspense. This combines fast reusable output
with dynamic content on one route.

Design the shell around data that is safe to share. Personalized or
authorization-sensitive content belongs in a dynamic region or an intentionally
private cache, never in a public shared entry.

## Time-Based Freshness

`cacheLife` describes stale, revalidation, and expiration windows through a
profile or custom values. Choose them from business tolerance:

- documentation and CMS pages may tolerate longer stale windows;
- inventory or pricing needs a short policy or event invalidation;
- permissions and account balances may need request-time reads;
- content with reliable webhooks can use long lifetimes plus on-demand
  invalidation.

Do not select a profile only because it makes a benchmark faster.

## Tag Invalidation

Tag data by domain identity and collection:

```ts
export async function getProduct(productID: string) {
  "use cache";
  cacheTag("products", `product:${productID}`);
  return database.product.findUnique({ where: { id: productID } });
}
```

Use precise tags so one update does not invalidate an entire application.

## `revalidateTag` and `updateTag`

- `revalidateTag(tag, "max")` marks matching data stale and permits stale-while-
  revalidate behavior. It works in Server Actions and Route Handlers.
- `updateTag(tag)` immediately expires matching data for read-your-own-writes
  behavior. It is limited to Server Actions.

Use background revalidation for shared content that may remain briefly stale.
Use immediate expiration when the mutating user must see the confirmed write on
the next render.

## Path Invalidation

`revalidatePath` invalidates cached work associated with a page or layout path.
It is useful when the route is the clearest invalidation unit, but tags are often
more precise and reusable across several routes.

Cache invalidation does not authorize a mutation and does not make a database
transaction atomic.

## Private and User-Specific Data

Never cache user-specific results under a key shared by other users. Include
stable identity or tenant scope only through supported private caching and
carefully reviewed keys.

Do not place access tokens, full session objects, or secrets into cache keys or
logs. Authorization should occur before returning cached sensitive data, or the
cache should store only data proven safe to share.

## Development Surprises

Development mode includes caches that improve hot reload behavior and can make
an uncached fetch appear stale until navigation or a full reload. A hard refresh
and browser developer settings can also change request cache headers.

Verify caching in a production build. Development observations are not a
reliable production cache specification.

## Multi-Instance Deployment

Self-hosted replicas need a shared cache or coordination strategy. Invalidating
one process's local cache does not automatically update another process.

Plan for:

- shared tag invalidation;
- cache handler compatibility;
- rollout across builds with different cached formats;
- regional consistency expectations;
- failure behavior when the cache is unavailable.

## Cache Review Checklist

- Is the entry public, tenant-scoped, user-scoped, or request-only?
- Which API opts it into caching?
- What is its maximum acceptable staleness?
- Which mutation or webhook invalidates it?
- Does invalidation work across replicas and regions?
- Can a permission or identity change expose stale private data?
- Has behavior been tested in the production deployment mode?
