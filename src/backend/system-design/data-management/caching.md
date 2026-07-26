# Caching

**Caching** stores frequently accessed data in fast storage to cut latency and offload backends. Caches exist at many layers and are one of the most effective ways to improve read performance.

## Cache Layers

| Layer | Example | Use Case |
|---|---|---|
| **Client cache** | Browser cache, app memory | Reduce round trips for static assets |
| **CDN** | CloudFront, Cloudflare | Serve static and cacheable content from edge |
| **Application cache** | Redis, Memcached | Store hot data close to the application |
| **Database cache** | Query cache, buffer pool | Reduce disk I/O for repeated queries |

## Cache Strategies

| Strategy | How It Works | Best For |
|---|---|---|
| **Cache-aside** | App checks cache, on miss reads DB and populates cache | General read-heavy workloads |
| **Read-through** | Cache library loads from DB on miss transparently | Simpler app code |
| **Write-through** | Writes go to cache and DB synchronously | Strong cache freshness |
| **Write-back** | Writes go to cache, flushed to DB later | Write-heavy, tolerates some loss |

## Cache Invalidation

Keeping caches correct is famously hard. Common approaches:

- **TTL (expiration)** -- entries expire after a set time. Simple, allows bounded staleness.
- **Explicit invalidation** -- delete or update the key on write.
- **Versioning** -- include a version or hash in the key so stale entries are never read.

### Cache Problems

- **Cache stampede** -- many misses hitting the DB at once. Mitigate with request coalescing and jittered TTLs.
- **Hot keys** -- one key dominating traffic. Mitigate with key replication and local caching.
- **Thundering herd** -- many clients waiting for the same cache miss. Use a lock or lease to serialize populates.

## When to Use Caching

- Read-heavy workloads (reads >> writes)
- Data that can tolerate slight staleness
- Expensive computations or queries that are repeated
- Static or semi-static content (CDN caching)

## When NOT to Use Caching

- Data that must always be fresh (financial balances, inventory counts)
- Write-heavy workloads with little read benefit
- Data that changes constantly and cannot be partitioned by hot/cold

## Mid/Senior Interview Questions and Answers

### 1. What makes cache invalidation hard?

**Answer:** The cache and source of truth can diverge whenever data changes, and
there is no perfect signal that a cached entry is stale. TTLs give bounded
staleness but waste freshness or serve stale data; explicit invalidation is
precise but easy to miss on some write paths.

You also have to handle stampedes and hot keys. Most teams combine short
jittered TTLs with explicit invalidation on critical writes, accepting bounded
staleness elsewhere.

### 2. When do you choose Redis over Memcached?

**Answer:** Redis supports richer data structures (strings, hashes, lists, sets,
sorted sets, streams), persistence, replication, pub/sub, and Lua scripting.
Memcached is simpler, multithreaded, and slightly faster for pure key-value
caching at scale.

Choose Redis when you need more than simple caching (queues, leaderboards,
session stores). Choose Memcached when you need simple, fast, distributed
caching with minimal operational complexity.

### 3. How do you prevent cache stampedes?

**Answer:** Use request coalescing (only one goroutine/thread populates the
cache for a given key, others wait), jittered TTLs (add random variation to
expiration to prevent synchronized expirations), and stale-while-revalidate
(serve stale data while refreshing in the background).

For critical keys, pre-warm the cache during off-peak hours and set long TTLs
with background refresh.
