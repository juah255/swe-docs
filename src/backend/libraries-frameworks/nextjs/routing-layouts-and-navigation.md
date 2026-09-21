# Routing, Layouts, and Navigation

The App Router derives URL structure and UI nesting from folders. Routing design
also determines state preservation, loading boundaries, data ownership, and
navigation performance.

## Static and Nested Routes

```text
app/
├── page.tsx                 -> /
├── about/page.tsx           -> /about
└── dashboard/
    ├── layout.tsx           -> wraps dashboard children
    ├── page.tsx             -> /dashboard
    └── settings/page.tsx    -> /dashboard/settings
```

Layouts nest according to the folder hierarchy. They preserve state and remain
interactive across navigation within their subtree. A template looks similar
but creates a new instance for each navigation and resets descendant state.

## Dynamic Segments

- `[slug]` captures one segment.
- `[...slug]` captures one or more segments.
- `[[...slug]]` captures zero or more segments.

Current App Router route props are asynchronous:

```tsx
export default async function OrderPage({
  params,
}: {
  params: Promise<{ orderID: string }>;
}) {
  const { orderID } = await params;
  const order = await getOrder(orderID);

  if (!order) notFound();
  return <OrderDetails order={order} />;
}
```

Generated `PageProps` and `LayoutProps` helpers can provide route-aware types
after Next.js type generation.

## Static Parameters

`generateStaticParams` tells the build which dynamic values to prerender:

```tsx
export async function generateStaticParams() {
  const posts = await listPublishedPosts();
  return posts.map((post) => ({ slug: post.slug }));
}
```

Do not generate an unbounded catalog at build time. Prerender high-value routes
and let the chosen cache or runtime policy handle the rest.

## Search Parameters

Page components receive an asynchronous `searchParams` prop. Use it when query
parameters affect server data loading:

```tsx
export default async function ProductsPage({
  searchParams,
}: {
  searchParams: Promise<{ page?: string; query?: string }>;
}) {
  const filters = await searchParams;
  return <Products filters={parseFilters(filters)} />;
}
```

Client Components can use navigation hooks when query state is client-facing.
Put shareable filters, sorting, and pagination in the URL rather than duplicating
them in a global store.

## Links and Navigation

Use `Link` for internal navigation:

```tsx
import Link from "next/link";

<Link href={`/orders/${order.id}`}>View order</Link>;
```

Next.js can prefetch linked routes and perform client navigation while
preserving shared layouts. Prefetching consumes bandwidth and server capacity,
so inspect its impact for very large link collections or costly dynamic routes.

Use router navigation from a Client Component only when navigation follows an
imperative interaction. Prefer `redirect` in server code and normal links for
ordinary destinations.

## Route Groups

Parentheses organize segments without changing the URL:

```text
app/(marketing)/about/page.tsx -> /about
app/(app)/dashboard/page.tsx   -> /dashboard
```

Groups can apply different layouts to routes at the same URL depth. Multiple
root layouts can cause a full document navigation between groups, so choose
them intentionally.

## Parallel Routes

Named slots such as `@analytics` let a layout render several independently
navigated subtrees. Each slot should provide a `default.tsx` fallback for cases
where a hard reload cannot recover its active child from navigation history.

Parallel routes fit dashboards, split views, and conditional panels. They add
URL and fallback complexity, so do not use them only to place components side by
side.

## Intercepting Routes

Intercepting routes can show one route within another layout during client
navigation—for example, opening a photo as a modal while keeping a direct URL
that renders the full photo page on refresh.

Provide a complete direct-navigation experience, accessible dialog behavior,
back-button semantics, and a clear close destination.

## Loading, Errors, and Not Found

- `loading.tsx` creates a Suspense boundary around the segment.
- `error.tsx` catches uncaught descendant errors and must be a Client Component.
- `not-found.tsx` renders when `notFound()` is called.

Place boundaries according to recoverable user experiences. A segment-level
spinner should not hide stable navigation, and an error fallback should offer a
retry or safe destination when possible.

If streaming has already begun, an HTTP status can no longer be changed. Check
critical existence or authorization before a boundary suspends when the exact
status code matters.

## Navigation Checklist

- URLs represent shareable application state.
- Links remain real links with expected browser behavior.
- Dynamic parameters and search values are validated.
- Layouts preserve only state that should persist.
- Loading, error, and not-found UI match route ownership.
- Advanced slots and intercepts work on refresh and back navigation.
- Focus, document title, and status feedback remain accessible.
