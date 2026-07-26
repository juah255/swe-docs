# System Design Questions

A quick reference of common system design questions and concise answers. Use it
to review the vocabulary before an interview; the deeper treatment lives in
[Non-Functional Requirements](non-functional-requirements/index.md),
[Traffic Management](traffic-management/load-balancing.md),
[Data Management](data-management/caching.md), and
[Microservices](../software-architecture/microservices.md).

## What is latency vs throughput?

- **Latency** is the time to handle a single request.
- **Throughput** is how many requests the system handles per unit time.

You can improve throughput (more workers) while latency stays the same, and vice
versa. Measure latency at percentiles (p50, p99), not averages.

## What is the difference between horizontal and vertical scaling?

- **Vertical**: a bigger machine. Simple, capped, single point of failure.
- **Horizontal**: more machines. Unbounded, fault-tolerant, but needs
  statelessness and load balancing.

## What is a load balancer?

A component that distributes incoming requests across multiple servers, runs
health checks, and removes unhealthy nodes. It enables horizontal scaling and
improves availability. Works at L4 (transport) or L7 (application).

## What is caching and where does it live?

Storing frequently accessed data in fast storage to cut latency and offload
backends. It lives at the client, CDN, application (Redis/Memcached), and
database layers. The hard part is invalidation: keeping cached data consistent
with the source of truth.

## What is the CAP theorem?

During a network partition, a distributed system can guarantee only two of:
**Consistency**, **Availability**, **Partition tolerance**. Since partitions are
unavoidable, the real choice is **CP** (consistent, may reject requests) vs
**AP** (available, may serve stale data).

## What is the difference between SQL and NoSQL?

- **SQL**: relational, structured schema, ACID transactions, strong consistency,
  good for complex queries and joins.
- **NoSQL**: flexible schema, horizontal scaling, often eventual consistency,
  good for high write volume and simple access patterns.

Choose by access pattern and consistency needs, not popularity.

## What is database sharding?

Splitting data across multiple nodes so no single machine holds everything. It
scales writes and storage. The shard key choice is critical to avoid hotspots,
and cross-shard joins and transactions become expensive.

## What is replication?

Copying data across nodes for read scaling and fault tolerance. In
primary-replica setups, writes go to the primary and reads can hit replicas,
which may lag slightly behind (eventual consistency on reads).

## What is the difference between strong and eventual consistency?

- **Strong**: every read reflects the latest write.
- **Eventual**: replicas converge over time; reads may be temporarily stale.

Strong consistency costs availability and latency. Use it only where the
business rule demands it, such as payments or inventory.

## What is idempotency and why does it matter?

An operation is **idempotent** if doing it multiple times has the same effect as
doing it once. It is essential for safe retries in distributed systems, where
network failures cause duplicate requests. Implement with idempotency keys or
deduplication.

## What is a message queue and when do you use it?

A broker that decouples producers from consumers, smooths traffic spikes, and
enables retries and async processing. Use it to move non-critical work off the
request path, such as sending emails or generating reports.

## What is the difference between a message queue and event streaming?

- **Message queue** (RabbitMQ, SQS): a task is consumed once, then removed.
- **Event streaming** (Kafka): a durable, replayable log many consumers can read
  independently, retained over time.

## How do you handle a single point of failure?

Add redundancy: multiple instances behind a load balancer, replicated databases,
multi-AZ or multi-region deployment, and automated failover. The goal is no
single component whose failure takes down the system.

## Mid/Senior Interview Questions and Answers

### 1. How do you approach an unfamiliar system design question?

**Answer:** Clarify requirements first, both functional and non-functional, then
estimate scale, sketch APIs and a data model, draw a high-level architecture,
and deep-dive on the hardest one or two components. Narrate your reasoning and
confirm assumptions as you go.

The interviewer grades structure and prioritization more than a perfect answer.
Driving the conversation and surfacing trade-offs is the signal they want.

### 2. How do you identify the bottleneck in a design?

**Answer:** Follow the critical path and find the component with the least
headroom: a single-writer database, a hot cache key, a synchronous external
call, or a saturated network link. Back it with rough capacity math to confirm
where load concentrates.

Then apply the matching fix: caching, read replicas, sharding, async processing,
or moving work off the request path. Re-check that the fix does not just shift
the bottleneck elsewhere.

### 3. How do you make a system resilient to failures?

**Answer:** Assume every dependency can fail. Use redundancy and failover,
timeouts and retries with backoff, circuit breakers, bulkheads to isolate
failures, and graceful degradation so a partial outage does not cascade.

Make retried operations idempotent, and design so that a non-critical dependency
failing (say, recommendations) never breaks the core flow (checkout).

### 4. How do you handle a sudden 10x traffic spike?

**Answer:** Absorb it with autoscaling on stateless tiers, aggressive caching and
CDN offload for reads, and queues to buffer writes so the backend drains at a
safe rate. Rate limiting and load shedding protect the core when capacity is
exceeded.

Prepare ahead for known spikes (flash sales) with pre-scaling and warm caches.
For unknown spikes, the queue plus shedding combination keeps the system alive
even if some requests are delayed or rejected.

### 5. How do you evolve a monolith toward microservices?

**Answer:** Do not rewrite. Start by enforcing clean module boundaries inside the
monolith, then peel off the highest-value service first, usually one with
distinct scaling needs or a clear bounded context. Give it its own data and an
API, and route to it incrementally (the strangler-fig pattern).

Measure whether the split actually reduced coupling or deployment pain. If it
did not, stop; not every domain benefits from being a separate service.
