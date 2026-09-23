# Caching and Performance

Performance work starts with measurement. Record request latency, query counts,
slow SQL, cache effectiveness, external-call latency, error rate, and worker
saturation before choosing an optimization.

## Query Efficiency

Database access is often the first bottleneck in a Django application:

- remove N+1 queries with measured relationship loading;
- select only needed rows and paginate large collections;
- add indexes that match real filters, joins, and ordering;
- use annotations or database expressions for appropriate aggregation;
- inspect plans with `QuerySet.explain()`;
- keep transactions short and monitor lock waits;
- avoid loading a whole queryset merely to count or check existence.

Query count is not the only measure. One giant join or prefetch can use more time
and memory than a few focused queries.

## Cache Levels

Django provides several cache interfaces:

| Level | Suitable for | Main risk |
| --- | --- | --- |
| Per-site | Mostly public sites with uniform responses | Caching private variants |
| Per-view | Stable, independently cacheable endpoints | Incomplete cache key |
| Template fragment | Expensive page fragments | Stale fragment invalidation |
| Low-level API | Domain results and computed values | Key and lifecycle complexity |

```python
from django.core.cache import cache


def get_product_summary(product_id):
    key = f"product-summary:v3:{product_id}"
    summary = cache.get(key)
    if summary is None:
        summary = build_product_summary(product_id)
        cache.set(key, summary, timeout=300)
    return summary
```

A cache key must include every dimension that changes the response: tenant,
user, locale, permissions, feature version, or input parameters as appropriate.
Never let one user's private data be served under another user's key.

## Invalidation and Stampedes

Every cache entry needs an ownership and invalidation story. Common strategies
include short time-to-live values, explicit deletion after writes, and versioned
keys. Use `transaction.on_commit()` for invalidation that depends on a successful
write.

When a popular key expires, many workers can recompute it simultaneously. Reduce
this stampede with locking, stale-while-revalidate behavior, jittered expiry, or
request coalescing. The exact mechanism depends on the cache backend.

## HTTP Caching

Use `Cache-Control`, `Vary`, `ETag`, and `Last-Modified` to let browsers and CDNs
reuse safe responses. Shared caches must not store personalized content unless
the key and response directives safely separate every variant. Cookies and
authorization headers deserve special attention.

## Connections and Workers

Capacity depends on the whole system:

- application process and thread counts;
- database connection limits and pooling;
- cache and external-service connection pools;
- memory per worker;
- synchronous versus asynchronous workload;
- request and upstream timeouts.

More workers can make performance worse by exhausting database connections or
increasing contention. Load test a production-like stack and size each pool from
an explicit budget.

## Static and Media Assets

Run `collectstatic` during build or deployment and serve static assets through a
web server, CDN, or suitable storage integration. Treat user-uploaded media as a
separate data lifecycle: it needs access control, scanning or validation,
backups, retention, and safe content headers.

