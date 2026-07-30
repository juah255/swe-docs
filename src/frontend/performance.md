# Frontend Performance

## Core Web Vitals

- **LCP (Largest Contentful Paint):** Loading performance. Target < 2.5s. Largest visible element.
- **FID (First Input Delay) / INP (Interaction to Next Paint):** Interactivity. Target < 100ms / < 200ms.
- **CLS (Cumulative Layout Shift):** Visual stability. Target < 0.1.
- **TTFB (Time to First Byte):** Server response time. Target < 800ms.

## Bundle Optimization

- Code splitting at route level so users only load what they need.
- Tree shaking removes unused exports. Requires ESM imports and side-effect-free packaging.
- Compress images with modern formats (WebP, AVIF). Use responsive image sizes with `srcset`.
- Dynamic imports for heavy components not needed on first paint.
- Analyze bundles with tools like `webpack-bundle-analyzer` or `vite inspect`.

## Rendering Performance

- Avoid unnecessary re-renders. `React.memo`, `useMemo`, `useCallback` for expensive computations.
- Virtualize long lists with libraries like `react-window` or `tanstack-virtual`.
- Debounce or throttle scroll, resize, and input handlers.
- Use `content-visibility: auto` in CSS to skip off-screen rendering.
- Prefer CSS animations over JavaScript for 60fps compositor-only animations.

## Loading Patterns

- **Lazy loading:** Defer off-screen images and iframes with `loading="lazy"`.
- **Route-based splitting:** Each route loads its own bundle.
- **Progressive enhancement:** Core content renders immediately, enhancements load after.
- **Resource hints:** `preload`, `preconnect`, `prefetch`, `dns-prefetch` for critical resources.

## Mid/Senior Interview Questions and Answers

### 1. How do you improve frontend performance?

**Answer:** Measure first with browser DevTools, Lighthouse, and real-user monitoring. Common improvements: reduce JavaScript with code splitting, lazy-load routes and images, optimize bundles, avoid unnecessary re-renders, virtualize long lists, use modern image formats, and cache API responses. Target user-facing metrics (LCP, FID/INP, CLS), not just load time.

### 2. What is the difference between `preload`, `prefetch`, and `preconnect`?

**Answer:** `preload` fetches a critical resource early (font, hero image). `prefetch` fetches a resource likely needed for a future navigation. `preconnect` establishes an early connection to an origin. Preload is high priority; prefetch is low priority.

### 3. How do you measure real-user performance?

**Answer:** Use the Web Vitals API (`PerformanceObserver`), RUM services (Datadog RUM, New Relic, Cloudflare Browser Insights), and analytics providers. Collect LCP, FID/INP, CLS, TTFB, and custom metrics. Segment by device, connection type, and geographic region to identify real bottlenecks.

### 4. What causes layout shifts and how do you prevent them?

**Answer:** Layout shifts happen when elements move after initial render. Common causes: images/ads without dimensions, dynamically injected content, web fonts causing FOIT/FOUT, and late-loading embeds. Fix by setting explicit dimensions, reserving space for dynamic content, using font-display, and avoiding inserting content above existing elements.

### 5. When should you use server-side rendering over client-side rendering?

**Answer:** SSR improves LCP and SEO for content-heavy pages, especially on slow connections. CSR is better for highly interactive applications where server round-trips would delay interactivity. Next.js and similar frameworks let you mix both per-route.
