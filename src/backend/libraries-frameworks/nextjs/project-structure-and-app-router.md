# Project Structure and App Router

The App Router maps folders under `app` to route segments. Only special files
make a segment publicly accessible; other modules can be colocated safely beside
them.

## A Practical Layout

```text
project/
├── app/
│   ├── (marketing)/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── dashboard/
│   │   ├── loading.tsx
│   │   ├── error.tsx
│   │   └── page.tsx
│   ├── api/
│   │   └── webhooks/
│   │       └── route.ts
│   ├── layout.tsx
│   ├── not-found.tsx
│   └── global-error.tsx
├── components/
├── lib/
│   ├── dal/
│   ├── validation/
│   └── database.ts
├── public/
├── instrumentation.ts
├── next.config.ts
├── package.json
└── tsconfig.json
```

A `src` directory may wrap `app`, components, and library code when the team
wants configuration separated from source. Choose one layout and keep imports
consistent.

## Important File Conventions

| File | Responsibility |
| --- | --- |
| `page.tsx` | Public UI for a route segment. |
| `layout.tsx` | Shared UI that persists across child navigation. |
| `template.tsx` | Shared UI that receives a fresh instance on navigation. |
| `loading.tsx` | Suspense fallback for the segment. |
| `error.tsx` | Client error boundary for uncaught errors in the segment. |
| `global-error.tsx` | Fallback replacing the root layout after a root-level failure. |
| `not-found.tsx` | UI rendered by `notFound()` or unmatched routes in its scope. |
| `forbidden.tsx` / `unauthorized.tsx` | Optional authorization-status UI when the corresponding feature and APIs are used. |
| `route.ts` | HTTP Route Handler using Web `Request` and `Response`. |
| `default.tsx` | Fallback for an unmatched parallel-route slot. |

Special metadata files cover icons, sitemaps, robots rules, manifests, and
social images.

## Root Layout

The root layout defines the document shell:

```tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: {
    default: "Acme",
    template: "%s | Acme",
  },
  description: "Acme customer portal",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

Keep the root layout stable. Put feature-specific providers and scripts nearer
the routes that need them so unrelated pages do not inherit client JavaScript.

## Colocation and Private Folders

Files under `app` are not routes unless a `page` or `route` convention exposes
them. Components, tests, styles, and data functions can be colocated with a
segment.

Prefix a folder with `_` when it should be excluded from routing explicitly.
Route groups in parentheses organize routes without adding a URL segment.

Choose between global feature folders and route colocation based on ownership:

- colocate code used by one segment;
- place reusable primitives in a shared component package;
- keep server-only data and authorization functions behind an explicit `lib`
  or data-access boundary;
- prevent imports from reaching into another feature's private folders.

## Server-Only and Client-Only Code

Use server-only modules for database clients, secrets, privileged SDKs, and the
data access layer. Importing a server-only marker can make accidental use from a
Client Component fail during the build.

Use client-only modules for code that requires the browser. Prefer explicit
environment boundaries over checks such as `typeof window` scattered through
render logic.

## Configuration Files

- `next.config.ts` controls framework build and runtime options.
- `tsconfig.json` controls TypeScript and generated Next.js types.
- environment files supply local values but should not contain committed
  secrets.
- `instrumentation.ts` initializes server observability.
- `proxy.ts` handles request-boundary rewriting or redirects when needed.

Keep configuration typed, reviewed, and minimal. An option copied from an old
version can silently change caching, bundling, or runtime behavior.

## Environment Variables

Environment variables are server-only unless their name uses the public client
prefix. Public values are inlined into browser bundles during the build and are
not secrets.

Parse and validate server configuration at startup or first controlled access:

```ts
import "server-only";

const databaseURL = process.env.DATABASE_URL;
if (!databaseURL) throw new Error("DATABASE_URL is required");

export const env = { databaseURL };
```

Build-time inlining means one client bundle cannot receive a different public
value merely because its container environment changed after the build.

## Project Structure Rules

- Organize around feature and runtime ownership, not generic `utils` folders.
- Keep Client Component boundaries small.
- Centralize authorization near data access.
- Avoid database connections and side effects during arbitrary module import.
- Do not expose a route accidentally by adding `page.tsx` or `route.ts` to an
  organizational folder.
- Test the built application, not only the development server.
