# Rate Limiting

**Rate limiting** restricts how many requests a client can make within a time window. It protects services from abuse, brute-force attacks, and traffic spikes.

## Why Rate Limiting Is Needed

- Prevent brute-force and credential stuffing attacks
- Mitigate denial-of-service (DoS) and distributed denial-of-service (DDoS)
- Protect against API abuse and scraping
- Ensure fair usage across clients
- Prevent a single client from overwhelming shared resources

## Where to Place the Rate Limiter

- **API Gateway** -- centralized, most common in production
- **Middleware in each service** -- distributed, harder to coordinate
- **Dedicated sidecar** -- per-service proxy with rate limit logic
- **Client-side** -- easily bypassed, not reliable for security

Most production systems use the **API gateway** as the primary enforcement point.

## Algorithms

### Fixed Window

```text
Count requests in fixed time buckets (e.g., per minute)
If count > limit, reject
```

- Simple to implement
- Burst problem: 100 requests at 11:59:59 and 100 at 12:00:00 = 200 in 1 second

### Sliding Window Log

```text
Store timestamp of each request in a sorted set
Remove entries older than the window
If count within window > limit, reject
```

- Accurate but memory-intensive (stores every timestamp)

### Sliding Window Counter

```text
Weighted sum of previous window count and current window count
```

- Approximation of sliding window log
- Memory efficient and smooths burst across windows

### Token Bucket

```text
Bucket holds N tokens
Each request consumes 1 token
Tokens are refilled at a fixed rate
If bucket is empty, reject
```

- Allows controlled bursts (up to bucket size)
- Smooth rate limiting
- Most widely used in practice

### Leaky Bucket

```text
Requests enter a queue (bucket)
Processed at a fixed rate
If queue is full, reject
```

- Smooths traffic to a constant output rate
- Good for protecting downstream services

## Distributed Rate Limiting

- Use **Redis** as the central counter store
- Atomic operations: `INCR` + `EXPIRE` for fixed window, Lua scripts for token bucket
- For multi-region: use local rate limiting with async sync, or accept slightly relaxed limits

## Rate Limit Response

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 30
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1640995200
```

## Failure Mode

- If Redis is down, **fail open** (allow requests) or **fail closed** (reject)
- Fail open is usually preferred -- availability over strict rate limiting
- Alert on Redis failures and monitor rate limit bypasses

## Mid/Senior Interview Questions and Answers

### 1. Which rate limiting algorithm would you pick and why?

**Answer:** Token bucket is a strong default because it enforces an average rate
while permitting short bursts, which matches real client behavior, and it is
cheap to implement with a counter and timestamp. Leaky bucket is better when you
need a strictly constant outflow to a fragile downstream.

For distributed enforcement, back the counters with a shared store like Redis and
accept small inaccuracies, or use a sliding window log when accuracy matters more
than memory.

### 2. How do you design rate limiting for a distributed API?

**Answer:** Use a centralized store (Redis, Memcached) to track request counts
across all API instances. Implement sliding window or token bucket algorithms
in middleware.

Consider per-user, per-IP, and per-API-key limits. Return `429 Too Many
Requests` with a `Retry-After` header. For critical endpoints, add additional
limits regardless of the general rate limit.

### 3. What are the trade-offs of fail-open vs fail-closed?

**Answer:** Fail-open means the system allows all traffic when the rate limiter
is unavailable. This prioritizes availability but exposes the system to abuse.

Fail-closed means the system rejects traffic when the rate limiter is
unavailable. This prioritizes safety but can cause a total outage for all
users.

Most systems prefer fail-open with alerting, because a brief period of
unlimited traffic is usually less harmful than a complete outage.
