# Performance

**Performance** measures how efficiently the system uses resources to handle work. The two primary dimensions are **latency** (how long a request takes) and **throughput** (how many requests the system handles per unit time).

## Techniques

- **Cache** -- store frequently accessed data in fast storage
- **CDN** -- serve static assets from edge locations close to users
- **Compression** -- reduce payload size (gzip, brotli)
- **HTTP/2** -- multiplexing, header compression, server push
- **Indexes** -- speed up database queries at the cost of write performance

## Latency

**Latency** is the time from request initiation to response completion. It is measured at percentiles, not averages.

- **p50 (median)** -- half of requests are faster than this
- **p95** -- 95% of requests are faster than this
- **p99** -- 99% of requests are faster (this is what users complain about)
- **p99.9** -- tail latency, often driven by GC pauses, cold caches, or noisy neighbors

Why percentiles matter more than averages:

- An average of 100ms could hide 99% of requests at 50ms and 1% at 5 seconds
- Users experience the tail, not the average
- SLAs are usually expressed in p99 or p99.9

### Latency Budgets

| System Type | Typical p99 Target |
|---|---|
| Interactive APIs | < 200-500ms |
| Search and recommendations | < 1 second |
| Real-time (chat, gaming) | < 100ms |
| Background jobs | Minutes to hours |

### Factors Affecting Latency

- Network round trips (each adds 0.5-150ms depending on distance)
- Database queries (index hits vs full table scans)
- Serialization and deserialization
- External service calls (payment providers, email services)
- Garbage collection pauses
- Cold starts (serverless functions, cache misses)

## Throughput

**Throughput** is the number of operations the system can handle per unit time, usually measured in requests per second (RPS/QPS) or transactions per second (TPS).

Throughput and latency are related but distinct. You can improve throughput (more workers, parallelism) while latency stays the same. Conversely, adding work per request increases latency without necessarily improving throughput.

## Latency vs Throughput

| | Latency | Throughput |
|---|---|---|
| Measures | Time per request | Requests per unit time |
| Optimized by | Faster code, caching, fewer round trips | More workers, parallelism, batching |
| Measured at | Percentiles (p50, p99) | Rate (QPS, TPS) |
| Trade-off | Batch size: larger batches improve throughput but increase latency |

## Resource Efficiency

- **CPU utilization** -- high utilization without saturation is ideal
- **Memory usage** -- avoid leaks, use connection pooling
- **Network I/O** -- minimize round trips, batch requests, compress payloads
- **Disk I/O** -- use SSDs for random reads, sequential writes for logs

## Levers

- Caching (in-memory, CDN, application-level)
- Async processing and batching
- Efficient data structures and algorithms
- Appropriate database indexes
- Colocation of data and compute
- Connection pooling and keep-alive

## Trade-offs

- Caching hurts freshness
- Async processing hurts consistency
- Heavy indexing hurts write speed
- Larger batch sizes improve throughput but increase per-request latency

## Mid/Senior Interview Questions and Answers

### 1. How do you determine if a latency target is achievable?

**Answer:** Map the critical path and estimate the time for each step:
network round trips, database queries, external service calls, serialization,
and business logic.

If the sum of component latencies exceeds the p99 budget, you need to
parallelize independent steps, add caching, use faster storage, or move
computation closer to the user. Always leave margin for tail latency.

### 2. Why is p99 more important than average latency?

**Answer:** Average latency hides the tail. An average of 100ms could mean
99% of requests are fast but 1% take 5 seconds. Users experience individual
requests, not averages.

p99 (or p99.9) represents the worst experience most users will have. SLAs are
typically written in terms of p99 or p99.9 to ensure the tail is bounded.

### 3. How do you optimize for both latency and throughput?

**Answer:** They sometimes conflict. Larger batch sizes improve throughput but
increase per-request latency. More parallelism improves throughput but can
increase resource contention and tail latency.

The approach depends on the workload: optimize latency for user-facing paths
(caching, fewer round trips, connection pooling) and throughput for background
paths (batching, async processing, parallel workers).
