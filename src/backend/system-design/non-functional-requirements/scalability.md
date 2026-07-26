# Scalability

**Scalability** is a system's ability to handle increased load by adding resources. A scalable design keeps latency and reliability acceptable as traffic, data, and users grow.

## Vertical vs Horizontal Scaling

- **Vertical scaling (scale up)** -- add more CPU, RAM, or disk to a single machine. Simple, but has a hard ceiling and a single point of failure.
- **Horizontal scaling (scale out)** -- add more machines and distribute load. Nearly unbounded, but requires statelessness, load balancing, and a strategy for distributed state.

| | Vertical | Horizontal |
| --- | --- | --- |
| Complexity | Low | High |
| Ceiling | Hardware limit | Effectively unbounded |
| Fault tolerance | Single point of failure | Survives node loss |
| Cost curve | Steep at the top end | More linear |

The usual answer at scale is horizontal, made possible by keeping application servers **stateless** so any node can serve any request.

## Scaling Reads vs Writes

- **Read scaling** -- add read replicas, caching, CDNs. Most systems are read-heavy.
- **Write scaling** -- sharding, partitioning, write-ahead logs, message queues. Harder than read scaling.
- **Storage scaling** -- sharding across nodes, tiered storage (hot/cold), archival policies.

## Key Insight

Most real systems use a combination of techniques:

- Caching for hot data
- Replicas for read throughput
- Shards for write throughput and storage
- Queues for async processing

No single technique solves all scaling problems. The right combination depends on the workload.

## Levers

- Horizontal scaling with stateless services
- Load balancing across instances
- Database read replicas and sharding
- Caching layers (Redis, CDN)
- Message queues for async processing
- Autoscaling based on metrics

## Trade-offs

- Scalable architectures are more complex
- Horizontal scaling requires statelessness, which complicates session management
- Sharding introduces cross-shard query complexity
- Eventual consistency is often the cost of scale

## Mid/Senior Interview Questions and Answers

### 1. When do you choose horizontal over vertical scaling?

**Answer:** Vertical scaling is fine for early stages and simple, until you hit a
hardware ceiling or need fault tolerance. Horizontal scaling is the answer for
high traffic and availability, since you can add commodity nodes and survive
individual failures.

The prerequisite is statelessness on the app tier and a strategy for state
(caches, replicas, shards), which is the real work in scaling out.

### 2. How do you handle a sudden 10x traffic spike?

**Answer:** Absorb it with autoscaling on stateless tiers, aggressive caching and
CDN offload for reads, and queues to buffer writes so the backend drains at a
safe rate. Rate limiting and load shedding protect the core when capacity is
exceeded.

Prepare ahead for known spikes (flash sales) with pre-scaling and warm caches.
For unknown spikes, the queue plus shedding combination keeps the system alive
even if some requests are delayed or rejected.
