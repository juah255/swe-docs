# Redis

## Core Concepts

### What is Redis?

Redis is an in-memory key-value data store. It supports strings, hashes, lists,
sets, sorted sets, streams, and more. It is single-threaded with non-blocking
I/O and delivers sub-millisecond latency.

### Data Structures and Use Cases

- **Strings:** Cache values, counters, simple locks.
- **Hashes:** Store objects (user sessions, profiles) with field-level access.
- **Lists:** Message queues (LPUSH/BRPOP), recent activity feeds.
- **Sets:** Unique items, tags, membership checks (SINTER, SUNION).
- **Sorted Sets:** Leaderboards, delayed jobs, priority queues (ZRANGE, ZADD).
- **Streams:** Event logs, pub/sub with consumer groups.
- **HyperLogLog:** Approximate cardinality counting.

### Uses Beyond Caching

- **Session store:** Store user sessions with automatic TTL expiry.
- **Rate limiting:** Sliding window counters with INCR and EXPIRE.
- **Pub/Sub:** Real-time messaging between services.
- **Distributed locks:** Redlock algorithm for cross-service coordination.
- **Queues:** LPUSH/BRPOP for simple task queues.
- **Geospatial:** Store and query locations (GEODIST, GEORADIUS).
- **Counting:** Atomic increments for page views, metrics (INCR).

### Cache-Aside Pattern

The most common caching strategy for backend services.

```text
Read path:
  1. App checks cache (Redis GET)
  2. Cache hit → return cached value
  3. Cache miss → read from DB
  4. Write result to cache (Redis SET with TTL)
  5. Return value

Write path:
  1. Update the database
  2. Invalidate the cache (Redis DEL)
  3. Next read triggers a cache miss and repopulates
```

```python
import redis
import json

r = redis.Redis(host="localhost", port=6379, decode_responses=True)

def get_user(user_id: int) -> dict:
    cache_key = f"user:{user_id}"

    # Check cache first
    cached = r.get(cache_key)
    if cached:
        return json.loads(cached)

    # Cache miss: read from DB
    user = db.query(User).get(user_id)
    if user:
        r.set(cache_key, json.dumps(user.to_dict()), ex=300)  # TTL 5 min
    return user.to_dict()

def update_user(user_id: int, data: dict) -> dict:
    user = db.query(User).get(user_id)
    user.update(data)
    db.commit()

    # Invalidate cache so next read repopulates
    r.delete(f"user:{user_id}")
    return user.to_dict()
```

### When Redis Caching Helps

Redis is most effective for repeated reads of hot data: user sessions, product
catalogs, frequently queried rows, or expensive computed results. Each cache
hit avoids a database round trip.

- Cache reads that repeat; keep the database as the source of truth
- Set a TTL so stale data expires, and invalidate on writes
- Do not cache data that changes on every request or writes
- An in-memory cache is bounded by memory and eviction policy, not by database
  query speed

### TTL and Expiration

TTL prevents stale data and manages memory. Choose TTL based on how stale data
can tolerate being: short (30s–5min) for fast-changing data, long (1hr–24hr)
for stable data. Use EX, PX, EXAT, or PTAT options with SET.

### Persistence Options

- **RDB:** Periodic snapshots. Fast restart, may lose recent writes.
- **AOF:** Append-only file. More durable, larger files, slower restart.
- **Hybrid:** AOF rewrite + RDB snapshots for balanced durability.

### Pub/Sub vs Streams

Pub/Sub is fire-and-forget messaging. No persistence, no consumer groups. Use
Streams for durable, ordered events with consumer groups and acknowledgment.

## Mid/Senior Interview Questions and Answers

### 1. What are the trade-offs of storing sessions in Redis vs a database?

**Answer:** Redis gives sub-millisecond reads, built-in TTL expiry, and simple
atomic operations. A relational database gives ACID guarantees, joins, and
richer queries but is slower for high-frequency session lookups.

For high-traffic services, Redis is usually the better fit for sessions. Pair it
with a durable store (database or replicated Redis) if session loss is
unacceptable.

### 2. How would you implement rate limiting with Redis?

**Answer:** Use a sliding window or fixed window counter with INCR and EXPIRE.

```python
def is_rate_limited(user_id: str, limit: int = 100, window: int = 60) -> bool:
    key = f"rate:{user_id}"
    current = r.incr(key)
    if current == 1:
        r.expire(key, window)
    return current > limit
```

For distributed rate limiting across multiple app instances, use Redis Lua
scripts to make the check-and-increment atomic. For stricter sliding windows,
use sorted sets with timestamp scores and ZREMRANGEBYSCORE to trim old entries.

### 3. What happens when Redis runs out of memory?

**Answer:** Redis evicts keys based on the configured eviction policy
(maxmemory-policy). Common policies: `allkeys-lru`, `volatile-lru`,
`noeviction`, `allkeys-random`. With `noeviction`, write commands return errors.

Monitor memory usage, set maxmemory, and choose a policy that matches your
workload. For caches, `allkeys-lru` is usually appropriate. For durable data,
`noeviction` with alerts is safer.
