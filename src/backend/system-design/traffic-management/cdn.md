# CDN

A **Content Delivery Network (CDN)** caches and serves content from edge locations close to users, reducing latency and offloading origin servers.

## How It Works

```text
User -> CDN Edge (nearest location) -> cache hit? -> return cached response
                                           |
                                      cache miss -> CDN Edge -> Origin Server
```

1. DNS resolves the request to the nearest edge location
2. Edge checks its cache for the requested content
3. **Cache hit**: serve directly from edge (low latency, no origin load)
4. **Cache miss**: fetch from origin, cache at edge, then serve

## CDN vs Application Caching

| | CDN | Application Cache (Redis) |
|---|---|---|
| **What it caches** | Static/semi-static HTTP responses | Application-level computed data |
| **Where it lives** | Edge, close to users | Same region as the app |
| **Invalidation** | TTL, purge API, versioned URLs | Programmatic (delete, TTL) |
| **Best for** | Static assets, media, API responses with stable shape | Sessions, counters, hot database rows, complex queries |

CDN and application caching are complementary. CDN handles the edge; application caching handles the origin.

## What to Cache

- **Static assets** -- JS, CSS, images, fonts, downloads
- **API responses** -- GET endpoints with stable or slowly-changing data
- **Media files** -- video, audio, large downloads
- **HTML pages** -- for sites with mostly static content

**Do not cache**: auth-gated content, user-specific data, real-time data, mutating endpoints.

## Cache-Control and TTL

HTTP headers tell the CDN how long to cache:

| Header | Meaning |
|---|---|
| `Cache-Control: max-age=3600` | Cache for `3600` seconds |
| `Cache-Control: no-cache` | Must revalidate with origin before serving |
| `Cache-Control: no-store` | Never cache |
| `Cache-Control: s-maxage=86400` | CDN-specific max age (overrides `max-age` for CDN) |
| `ETag` / `If-None-Match` | Origin validates if cached version is still fresh |
| `Last-Modified` / `If-Modified-Since` | Conditional fetch: return `304` if unchanged |

## Cache Invalidation

When content changes before TTL expires:

- **Purge API** -- CDN providers offer instant purge by URL or tag (CloudFront invalidation, Cloudflare purge)
- **Versioned URLs** -- `style.v2.css` instead of `style.css` (cache-busting)
- **Short TTL** -- trade origin load for freshness
- **Surrogate keys** -- tag cached objects and purge by tag

## CDN Architecture

### Push vs Pull

- **Pull CDN** -- CDN fetches from origin on cache miss. Simple origin setup, cold misses are slow.
- **Push CDN** -- origin pushes content to CDN. Faster first-hit, but origin must manage distribution.

Most CDNs are pull-based.

### Origin Shield

```text
User -> Edge -> Origin Shield -> Origin
```

An intermediate cache layer between edge and origin. Reduces origin load by deduplicating requests across edge locations. Useful when origin is expensive or rate-limited.

### Signed URLs and Private Content

For paid or private content:

- **Signed URLs** -- CDN generates a time-limited URL with a cryptographic signature
- **Signed cookies** -- grant access to a path pattern for a duration
- **Token authentication** -- origin validates a token before CDN serves content

## CDN Providers

| Provider | Key Feature |
|---|---|
| **CloudFront** (AWS) | Deep integration with AWS services |
| **Cloudflare** | Free tier, DDoS protection, Workers at edge |
| **Fastly** | Real-time purge, VCL/Compute@Edge |
| **Akamai** | Largest network, enterprise features |
| **GCP Cloud CDN** | Integrated with GCP load balancers |

## Performance Impact

- Reduces latency by serving from edge (`10-100ms` vs `100-300ms` from origin)
- Absorbs traffic spikes (CDN handles scale, origin stays stable)
- Reduces bandwidth cost (CDN pays for egress, origin serves fewer requests)

## Mid/Senior Interview Questions and Answers

### 1. When should you use a CDN vs application-level caching?

**Answer:** Use a CDN for static or semi-static HTTP content that benefits from edge proximity: images, CSS, JS, API responses with stable data. Use application-level caching (Redis, Memcached) for computed data, sessions, hot database rows, and anything requiring programmatic invalidation.

They are complementary. A typical setup uses CDN at the edge and Redis at the origin, with different TTLs and invalidation strategies.

### 2. How do you handle cache invalidation on a CDN?

**Answer:** Prefer short TTLs with versioned URLs for static assets (`app.v3.js`). For dynamic content that must update quickly, use the CDN's purge API with surrogate keys or path patterns. For real-time requirements, set `Cache-Control: no-cache` and let the CDN revalidate with the origin on every request.

The classic trade-off: aggressive caching improves performance but delays updates; frequent invalidation improves freshness but increases origin load.

### 3. How does a CDN affect your system design in an interview?

**Answer:** A CDN absorbs read traffic for cacheable content, which reduces origin load and improves latency globally. It should appear in your high-level diagram for any system serving static assets, media downloads, or cacheable API responses.

Call it out explicitly: CDN handles static reads, application handles dynamic logic, and the origin rarely sees hot-path traffic. This simplifies the capacity story and improves availability since the CDN keeps serving even if the origin is temporarily down.
