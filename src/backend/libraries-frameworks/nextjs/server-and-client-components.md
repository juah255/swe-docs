# Server and Client Components

App Router layouts and pages are Server Components by default. Client Components
are introduced with the `"use client"` boundary when browser interactivity is
required.

## Choose by Capability

Use a Server Component for:

- database and filesystem access;
- private service credentials;
- large server-only dependencies;
- data loading near the source;
- cacheable or request-rendered output;
- non-interactive markup.

Use a Client Component for:

- state and event handlers;
- Effects and custom client hooks;
- browser APIs such as storage and geolocation;
- client context providers;
- imperative third-party browser widgets.

Do not add `"use client"` merely because a Server Component renders a Client
Component. Server Components can import and render client entry points.

## The Client Boundary

`"use client"` marks a module and its transitive imports as part of the client
module graph:

```tsx
// app/orders/order-filter.tsx
"use client";

import { useState } from "react";

export function OrderFilter({ orders }: { orders: readonly OrderSummary[] }) {
  const [query, setQuery] = useState("");
  const visible = orders.filter((order) => order.number.includes(query));

  return <>{/* interactive filter UI */}</>;
}
```

Place the boundary at interactive leaves. Marking a high-level layout as client
code can pull broad dependencies and UI into the browser bundle.

## Server Rendering Flow

On the server, Next.js produces:

- an RSC payload describing Server Component results and Client Component
  references;
- HTML for the initial visual response.

On first load, the browser displays the HTML, uses the RSC payload to reconcile
the tree, and hydrates Client Components. On later navigation, it can fetch an
updated RSC payload and preserve shared client state.

## Passing Props Across the Boundary

Props from Server to Client Components must follow React's serialization
contract. Prefer plain, intentional DTOs:

```tsx
const summary = {
  id: order.id,
  totalMinor: order.totalMinor.toString(),
  createdAt: order.createdAt.toISOString(),
};

return <OrderSummaryCard order={summary} />;
```

Do not pass database clients, request objects, arbitrary class instances, or
secrets. Dates, large integers, decimals, maps, and domain objects deserve an
explicit wire representation even when a serializer supports some of them.

## Composition

A Server Component can pass rendered server content as a child to a Client
Component:

```tsx
export default function Page() {
  return (
    <ClientModal>
      <ServerOrderDetails />
    </ClientModal>
  );
}
```

This preserves the server-rendered content while letting the client wrapper own
interaction. A Client Component cannot import a Server Component directly into
its client graph.

## Providers

React context is unavailable inside Server Components, but a Client Component
provider can wrap server-rendered children:

```tsx
"use client";

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  return <ThemeContext.Provider value="dark">{children}</ThemeContext.Provider>;
}
```

Render providers as deep as their consumers allow. Wrapping the entire document
in a broad client provider reduces how much work can remain static and server-
only.

## Third-Party Client Components

A package may use state or browser APIs without declaring a compatible client
entry point. Wrap it in a small local Client Component rather than marking a
large page or layout as client code.

Check package support for server rendering. Some browser libraries execute DOM
access at import time and must be loaded only within a client boundary or
dynamically when appropriate.

## Preventing Environment Leaks

Mark privileged modules as server-only. Keep database and secret-bearing code
under a data access layer that Client Components cannot import.

Only environment variables with the public prefix are intended for browser
bundles. Treat every public variable and serialized prop as visible to users.

## Common Mistakes

- adding `"use client"` to fix an unrelated type or rendering error;
- importing server data utilities through a shared barrel file used by clients;
- passing full database rows to interactive components;
- placing every provider in the root layout;
- assuming a Server Component is automatically cached;
- assuming hidden UI protects an unauthorized operation;
- reading browser-only values during server render and causing hydration drift.

## Boundary Checklist

- Does this component actually require a browser capability?
- Can interactivity move into a smaller child?
- Are cross-boundary props minimal and serializable?
- Are secrets and privileged dependencies marked server-only?
- Does authorization happen near data access, not only in UI?
- Is client bundle impact visible in analysis?
