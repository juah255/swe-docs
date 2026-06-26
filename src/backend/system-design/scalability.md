# Scalability

**Scalability** is a system's ability to handle increased load by adding
resources. A scalable design keeps latency and reliability acceptable as
traffic, data, and users grow. The techniques below stack: caching, replication,
and sharding together carry most real systems.

## Vertical vs Horizontal Scaling

- **Vertical scaling (scale up)**: add more CPU, RAM, or disk to a single
  machine. Simple, but has a hard ceiling and a single point of failure.
- **Horizontal scaling (scale out)**: add more machines and distribute load.
  Nearly unbounded, but requires statelessness, load balancing, and a strategy
  for distributed state.

| | Vertical | Horizontal |
| --- | --- | --- |
| Complexity | Low | High |
| Ceiling | Hardware limit | Effectively unbounded |
| Fault tolerance | Single point of failure | Survives node loss |
| Cost curve | Steep at the top end | More linear |

The usual answer at scale is horizontal, made possible by keeping application
servers **stateless** so any node can serve any request.

## Load Balancing

A **load balancer** distributes requests across multiple servers, improving
throughput and availability. It also performs health checks and removes
unhealthy nodes from rotation.

Common algorithms:

- **Round robin**: rotate through servers in order.
- **Least connections**: send to the server with the fewest active requests.
- **Weighted**: bias toward more powerful nodes.
- **Consistent hashing**: map a key to a node so the same key lands on the same
  node, minimizing reshuffling when nodes change.

Load balancing happens at **L4** (transport, by IP/port) or **L7**
(application, by HTTP path/headers).

## Caching

Caching stores frequently accessed data in fast storage to cut latency and
offload backends. Caches exist at many layers:

- **Client cache**: browser or app memory.
- **CDN**: edge servers close to users for static and cacheable content.
- **Application cache**: in-memory stores like Redis or Memcached.
- **Database cache**: query and buffer caches inside the database.

### Cache strategies

| Strategy | How it works | Best for |
| --- | --- | --- |
| **Cache-aside** | App checks cache, on miss reads DB and populates cache | General read-heavy workloads |
| **Read-through** | Cache library loads from DB on miss transparently | Simpler app code |
| **Write-through** | Writes go to cache and DB synchronously | Strong cache freshness |
| **Write-back** | Writes go to cache, flushed to DB later | Write-heavy, tolerates some loss |

### Cache invalidation

Keeping caches correct is famously hard. Common approaches:

- **TTL (expiration)**: entries expire after a set time. Simple, allows bounded
  staleness.
- **Explicit invalidation**: delete or update the key on write.
- **Versioning**: include a version or hash in the key so stale entries are
  never read.

Watch for **cache stampede** (many misses hitting the DB at once) and **hot
keys** (one key dominating traffic). Mitigate with request coalescing, jittered
TTLs, and key replication.

## Database Replication

**Replication** copies data across multiple database nodes for read scaling and
fault tolerance.

- **Primary-replica (leader-follower)**: writes go to the primary, reads can be
  served by replicas. Replication lag means replicas may be slightly stale.
- **Multi-primary**: multiple write nodes, which adds conflict resolution
  complexity.

Replication boosts read throughput and availability but introduces eventual
consistency on the read path unless you read from the primary.

## Sharding / Partitioning

**Sharding** splits data across multiple nodes so no single machine holds
everything. It scales writes and storage, which replication alone cannot.

- **Horizontal partitioning**: split rows across shards (e.g. users `A–M` vs
  `N–Z`).
- **Vertical partitioning**: split columns or tables by access pattern.

Sharding strategies:

- **Range-based**: partition by key ranges. Simple, but risks hotspots.
- **Hash-based**: hash the key to pick a shard. Even distribution, but range
  queries get harder.
- **Consistent hashing**: minimizes data movement when shards are added or
  removed.

Trade-offs: cross-shard joins and transactions become expensive, and choosing a
good **shard key** is critical to avoid hotspots.

## CAP Theorem

The **CAP theorem** states that a distributed system can guarantee only two of
three properties during a network partition:

- **Consistency**: every read sees the latest write.
- **Availability**: every request gets a non-error response.
- **Partition tolerance**: the system keeps working despite dropped or delayed
  messages between nodes.

Because network partitions are unavoidable, real systems choose between **CP**
(reject requests to stay consistent) and **AP** (stay available, allow stale
reads) when a partition occurs.

```text
CP example: a system that refuses writes during a partition to avoid divergence
AP example: a system that serves possibly-stale reads and reconciles later
```

## Consistency Models

- **Strong consistency**: reads always reflect the most recent write.
- **Eventual consistency**: replicas converge over time; reads may be stale.
- **Read-your-writes**: a user always sees their own most recent write.
- **Monotonic reads**: a user never sees data move backwards in time.

Pick the weakest model that still satisfies the business rule, since weaker
models generally allow higher availability and performance.

## Rate Limiting Algorithms

Rate limiting protects a service from overload and abuse by capping requests per
client over time. To design one, define the **key** (user, IP, route, plan), the
**limit**, the **window**, the rejection behavior, and the **storage backend**
(often Redis for distributed counters).

| Algorithm | How it works | Burst handling | Memory | Notes |
| --- | --- | --- | --- | --- |
| **Fixed window** | Count requests per fixed interval | Allows bursts at window edges | Low | Simple, but edge spikes |
| **Sliding window** | Weighted/log-based count over a rolling window | Smooth | Higher | More accurate, more cost |
| **Token bucket** | Tokens refill at a fixed rate; each request spends one | Allows controlled bursts | Low | Common default |
| **Leaky bucket** | Requests queue and drain at a fixed rate | Smooths output | Low | Enforces steady rate |

Token bucket is the common production default because it allows short bursts
while enforcing an average rate. Leaky bucket is preferred when you need a
strictly smooth, constant outflow.

## Mid/Senior Interview Questions and Answers

### 1. When do you choose horizontal over vertical scaling?

**Answer:** Vertical scaling is fine for early stages and simple, until you hit a
hardware ceiling or need fault tolerance. Horizontal scaling is the answer for
high traffic and availability, since you can add commodity nodes and survive
individual failures.

The prerequisite is statelessness on the app tier and a strategy for state
(caches, replicas, shards), which is the real work in scaling out.

### 2. Why does replication not solve write scaling?

**Answer:** Primary-replica replication scales reads by adding read-only copies,
but all writes still funnel through a single primary. Once write throughput or
data size exceeds one node, you need sharding to split writes and storage across
multiple nodes.

Replication and sharding are complementary: shard for write/storage scale,
replicate each shard for read scale and fault tolerance.

### 3. What makes cache invalidation hard?

**Answer:** The cache and source of truth can diverge whenever data changes, and
there is no perfect signal that a cached entry is stale. TTLs give bounded
staleness but waste freshness or serve stale data; explicit invalidation is
precise but easy to miss on some write paths.

You also have to handle stampedes and hot keys. Most teams combine short
jittered TTLs with explicit invalidation on critical writes, accepting bounded
staleness elsewhere.

### 4. How does CAP guide a real design?

**Answer:** Partitions are inevitable, so the real choice is how to behave during
one: stay consistent and reject some requests (CP), or stay available and serve
possibly stale data (AP). Tie that choice to the business rule for each data set.

A payment ledger leans CP; a social feed or product view count leans AP. Many
systems mix both, applying strong consistency only to the few critical writes.

### 5. Which rate limiting algorithm would you pick and why?

**Answer:** Token bucket is a strong default because it enforces an average rate
while permitting short bursts, which matches real client behavior, and it is
cheap to implement with a counter and timestamp. Leaky bucket is better when you
need a strictly constant outflow to a fragile downstream.

For distributed enforcement, back the counters with a shared store like Redis and
accept small inaccuracies, or use a sliding window log when accuracy matters more
than memory.
