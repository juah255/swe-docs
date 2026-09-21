# Data Fetching and Streaming

Server Components can load data directly from its source. This avoids exposing
credentials to the browser and avoids an internal HTTP round trip through the
same Next.js application.

## Fetch on the Server by Default

```tsx
import "server-only";

export default async function OrdersPage() {
  const orders = await database.order.findMany({
    select: { id: true, number: true, totalMinor: true },
  });

  return <OrderList orders={orders} />;
}
```

Server Components may call a database, service SDK, filesystem, or external API.
Keep authorization inside the data function so every caller receives the same
protection.

Do not call your own Route Handler from a Server Component. At build time no
server may be listening, and at runtime this adds serialization and an extra
network hop. Share the underlying server-only function instead.

## Validate External Data

TypeScript types do not validate API responses. Check status, content type,
shape, and bounds before using untrusted data:

```ts
export async function getCatalog(signal?: AbortSignal): Promise<Catalog> {
  const response = await fetch(CATALOG_URL, { signal, cache: "no-store" });
  if (!response.ok) {
    throw new CatalogUnavailableError(response.status);
  }

  return catalogSchema.parse(await response.json());
}
```

Return narrow DTOs rather than passing an entire database row or third-party
payload into the UI.

## Start Independent Work Together

Sequential awaits create a waterfall:

```tsx
const userPromise = getUser();
const ordersPromise = getOrders();

const [user, orders] = await Promise.all([userPromise, ordersPromise]);
```

Parallelize only independent operations. If one query determines the next or
both must share a transaction, sequential execution is correct.

For nested components, start work before the component is rendered when a
preload pattern can reduce discovery time. Keep preload functions idempotent and
ensure their errors are observed by the eventual consumer.

## Request Deduplication

Identical server `fetch` work can be deduplicated during rendering. For database
or other non-`fetch` functions, React's request-scoped `cache` can memoize a
function result within one server render:

```ts
import { cache } from "react";
import "server-only";

export const getCurrentUser = cache(async () => {
  const session = await verifySession();
  return database.user.findUnique({ where: { id: session.userID } });
});
```

React `cache` deduplication is not a persistent freshness cache. Do not confuse
it with Next.js Data Cache or Cache Components.

## Streaming With Route Loading UI

`loading.tsx` creates an automatic Suspense boundary for its segment:

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return <DashboardSkeleton />;
}
```

The shared layout can render immediately while the segment streams later. Keep
skeleton dimensions close to final content to reduce layout shift.

## Granular Suspense Boundaries

Use explicit boundaries when independent regions should reveal separately:

```tsx
export default function DashboardPage() {
  return (
    <main>
      <Suspense fallback={<RevenueSkeleton />}>
        <Revenue />
      </Suspense>
      <Suspense fallback={<RecentOrdersSkeleton />}>
        <RecentOrders />
      </Suspense>
    </main>
  );
}
```

Boundary placement is a product decision. Too broad hides useful content; too
granular produces a noisy sequence of placeholders.

## Expected and Unexpected Errors

Represent expected outcomes explicitly:

- use `notFound()` when a resource does not exist;
- use `redirect()` when navigation is the intended result;
- return validation or business errors from actions for inline display;
- throw unexpected failures so the nearest `error.tsx` boundary can handle
  them.

Do not catch `redirect()` or `notFound()` inside a broad `try/catch`; they use
framework control flow. Limit catch blocks to the operation whose error you
intend to translate.

## Client-Side Data

Client fetching is appropriate for:

- frequent polling or live updates;
- data dependent on browser-only APIs;
- user-triggered views not needed for initial server output;
- client caches shared across highly interactive components.

Use a server-state library or a well-defined hook for caching, cancellation,
deduplication, focus refresh, and mutation invalidation. Avoid copying the
result into another global store without a clear ownership need.

## Request-Time APIs

Cookies, headers, search parameters, and other request-bound values make output
depend on the incoming request. Read them only where required and pass narrow
values downward.

Under Cache Components, request-specific work creates dynamic regions that need
an appropriate Suspense boundary unless it uses an explicitly supported private
cache strategy.

## Data Checklist

- Fetch directly from the source in Server Components.
- Authorize inside the data access layer.
- Validate external responses at runtime.
- Parallelize independent operations and stream slow regions.
- Distinguish render-pass deduplication from persistent caching.
- Use client fetching only for client-owned timing or browser capabilities.
- Apply deadlines and cancellation to backend dependencies.
