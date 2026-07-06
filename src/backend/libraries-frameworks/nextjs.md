# NextJS

Next.js routing, data fetching, and deployment notes.

## Core Concepts

### What is Next.js?

Next.js is a React meta-framework built by Vercel. It adds routing, data
fetching, rendering strategies, bundling, image and font optimization, and
production deployment on top of React.

A Next.js app can render in several modes on a per-route basis: static
generation, server-side rendering, streaming server components, and pure
client rendering.

### App Router vs Pages Router

Next.js currently ships two routers:

- **App Router** (`app/`) — the modern default. Uses React Server Components,
  nested layouts, streaming, and colocated data fetching. Recommended for new
  projects.
- **Pages Router** (`pages/`) — the original file-based router. Uses
  `getServerSideProps`, `getStaticProps`, and `getStaticPaths` for data
  fetching.

Both can coexist during migrations.

### File-based Routing

Files inside `app/` map to URLs. Special filenames define behavior:

- `page.tsx` — the route's UI.
- `layout.tsx` — shared UI wrapping the route and its children.
- `loading.tsx` — Suspense fallback for the segment.
- `error.tsx` — error boundary for the segment.
- `not-found.tsx` — 404 UI.
- `route.ts` — HTTP route handler (API endpoint).

Dynamic segments use square brackets: `app/users/[id]/page.tsx`. Catch-all
segments use `[...slug]`, and optional catch-alls use `[[...slug]]`.

### Server and Client Components

App Router components are **server components** by default. They run only on
the server, can be `async`, can access secrets and databases, and ship no
JavaScript to the client.

Client components opt in with `"use client"` at the top of the file. They run
in the browser and can use state, effects, and browser APIs.

```tsx
// app/users/page.tsx (server component)
export default async function UsersPage() {
  const users = await db.user.findMany();
  return <UserList users={users} />;
}
```

```tsx
// components/user-list.tsx
"use client";
import { useState } from "react";
export function UserList({ users }: { users: User[] }) {
  const [query, setQuery] = useState("");
  // ...
}
```

Only pass serializable data across the boundary — no functions, class
instances, or Date objects without conversion.

### Data Fetching

In server components, `fetch` is extended with caching semantics:

```tsx
const res = await fetch("https://api.example.com/posts", {
  next: { revalidate: 60, tags: ["posts"] },
});
```

- `cache: "force-cache"` (default) — cache indefinitely until revalidated.
- `cache: "no-store"` — always fetch fresh.
- `next: { revalidate: N }` — ISR-style time-based revalidation.
- `next: { tags: [...] }` — enable tag-based invalidation via
  `revalidateTag()`.

Databases can be queried directly from server components; there is no need
for an internal `/api` route.

### Route Handlers

`route.ts` files define HTTP endpoints using the Web Request/Response API:

```ts
export async function GET(request: Request) {
  const users = await db.user.findMany();
  return Response.json(users);
}

export async function POST(request: Request) {
  const body = await request.json();
  return Response.json(await db.user.create({ data: body }), { status: 201 });
}
```

They replace the old `pages/api/*` handlers.

### Server Actions

Server Actions are async functions marked `"use server"` that can be called
directly from client components. They handle form submissions and mutations
without a hand-written API route.

```tsx
// app/actions.ts
"use server";
export async function createPost(formData: FormData) {
  await db.post.create({ data: { title: formData.get("title") as string } });
  revalidateTag("posts");
}

// app/new/page.tsx
import { createPost } from "../actions";
export default function NewPost() {
  return (
    <form action={createPost}>
      <input name="title" />
      <button type="submit">Create</button>
    </form>
  );
}
```

Actions always run on the server, even when triggered from the client.

### Rendering Strategies

Per route, Next.js supports:

- **Static (SSG)** — HTML built at build time.
- **ISR** — static HTML with periodic revalidation.
- **SSR** — rendered per request on the server.
- **Streaming SSR** — server components streamed with `<Suspense>` fallbacks.
- **CSR** — client component rendered in the browser.

Reading a dynamic API (cookies, headers, search params) opts a route into
dynamic rendering automatically.

### Caching Layers

App Router has multiple cache layers that interact:

- **Request memoization** — dedupes identical `fetch` calls within one render.
- **Data Cache** — persistent cache for `fetch` results across requests.
- **Full Route Cache** — cached rendered HTML/RSC payload.
- **Router Cache** — in-memory client-side cache of visited routes.

Invalidate with `revalidatePath()`, `revalidateTag()`, or by using `no-store`.

### Layouts, Templates, and Metadata

Layouts persist across navigations and preserve state; templates re-mount on
navigation. Both nest along the URL segments.

Metadata is exported statically or generated dynamically:

```tsx
export const metadata: Metadata = { title: "Users" };

export async function generateMetadata({ params }): Promise<Metadata> {
  const user = await getUser(params.id);
  return { title: user.name };
}
```

### Middleware

`middleware.ts` at the project root runs on the Edge before a request reaches
a route. It is commonly used for auth checks, redirects, A/B tests, and
rewrites.

```ts
export function middleware(req: NextRequest) {
  if (!req.cookies.get("session")) {
    return NextResponse.redirect(new URL("/login", req.url));
  }
}
export const config = { matcher: ["/dashboard/:path*"] };
```

Middleware runs on the Edge runtime, which does not support all Node APIs.

### Images, Fonts, and Scripts

Next.js ships built-in optimizations:

- `next/image` — automatic resizing, lazy loading, and modern formats.
- `next/font` — self-hosted, zero-layout-shift fonts.
- `next/script` — controlled loading strategies for third-party scripts.

### Environment Variables

Variables in `.env.local` are server-only by default. Only variables prefixed
with `NEXT_PUBLIC_` are exposed to the browser bundle.

Never put secrets behind `NEXT_PUBLIC_` — anything with that prefix ends up
in client JavaScript.

### Deployment

Vercel is the first-class target, but Next.js runs anywhere Node runs. Output
modes control this:

- Default (Serverless / Node) — hybrid static + server functions.
- `output: "standalone"` — self-contained Node server for Docker.
- `output: "export"` — fully static export (no server features).

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
