# Performance, Metadata, and Assets

Next.js can optimize routing, code, images, fonts, and scripts, but architecture
still determines most performance. Measure production behavior across server
latency, cache hits, browser bundles, hydration, and assets.

## Rendering and Data Performance

Start with the largest latency sources:

1. remove sequential server data waterfalls;
2. cache only reusable work with a freshness policy;
3. stream slow independent regions behind Suspense;
4. keep interactive client boundaries small;
5. avoid fetching the application's own Route Handlers from the server;
6. set backend timeouts and profile database queries.

Static rendering is not automatically correct for personalized data, and
dynamic rendering is not automatically slow. Choose based on freshness,
identity, and infrastructure.

## Client Bundle Boundaries

`"use client"` pulls the module and its transitive imports into the client
graph. Keep large formatting libraries, database types, server SDKs, and
non-interactive layout outside client entry points.

Watch for barrel files that mix server and client exports. Importing one client
utility through a broad index can pull an unexpected graph into the bundle.

Analyze route bundles after adding editors, charts, maps, date libraries, or
analytics. Load large client-only features dynamically when the user may not
need them immediately.

## Links and Prefetching

`Link` supports client navigation and route prefetching. Prefetching improves
navigation but can generate substantial requests on pages with many links or
expensive dynamic routes.

Measure actual navigation and origin load. Disable or delay prefetch only for a
demonstrated cost, since doing so trades background work for navigation latency.

## Images

Use the Image component when its optimization model fits:

```tsx
import Image from "next/image";

<Image
  src={product.imageURL}
  alt={product.imageAlt}
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, 50vw"
/>;
```

Provide dimensions or a controlled fill container to prevent layout shift. Use
accurate `sizes` for responsive images; otherwise the browser may download a
larger resource than needed.

Restrict remote image sources with narrow patterns. An overly broad image proxy
can be abused to fetch arbitrary origins or consume optimization capacity.

## Fonts

The font module self-hosts font files and can reduce layout shift and external
requests. Load only required families, styles, weights, and character subsets.

Define fonts in stable modules rather than recreating font configuration in
several route components.

## Third-Party Scripts

Use the Script component to choose loading strategy deliberately. A tag manager,
support widget, A/B platform, or embedded player can dominate main-thread and
privacy cost.

Load third-party code only on routes that need it, delay non-critical scripts,
and maintain a Content Security Policy and consent policy where required.

## Static Metadata

Export typed metadata from a Server Component layout or page:

```tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Products",
  description: "Browse the product catalog.",
};
```

Set `metadataBase` in the root layout when relative URL fields need a canonical
origin.

## Dynamic Metadata

`generateMetadata` can load route-specific values:

```tsx
export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const post = await getPost(slug);

  return {
    title: post.title,
    description: post.summary,
  };
}
```

Deduplicate the data function when both metadata and the page need the same
record. Metadata APIs are server-only.

For dynamic routes, metadata may stream separately for supported user agents.
Search and social crawlers with limited streaming behavior receive blocking
metadata according to framework detection and configuration.

## Metadata Files

File conventions can define:

- favicon and application icons;
- Open Graph and social images;
- `robots.txt`;
- `sitemap.xml`;
- web application manifest.

Generate large sitemaps in chunks when the catalog exceeds search-engine and
response limits. Do not expose private or unapproved URLs through a sitemap.

## Core Web Vitals

Measure field performance by route and release. Lab tools are useful for
diagnosis but do not replace real-user data.

Track server response, largest content paint, layout shifts, input
responsiveness, JavaScript errors, and chunk failures together. A regression may
come from backend latency, client code, images, fonts, or a third-party script.

## Performance Checklist

- Server data starts early and independent work runs in parallel.
- Cache policies match freshness and privacy.
- Client boundaries and route bundles are measured.
- Images have dimensions, responsive sizes, and restricted origins.
- Fonts and scripts include only needed variants and routes.
- Every route has intentional title, description, canonical, and social data.
- Field performance and backend traces can be correlated by release.
