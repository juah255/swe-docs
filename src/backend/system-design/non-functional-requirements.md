# Non-Functional Requirements

**Non-functional requirements (NFRs)** define how well a system performs, not what it does. They shape architecture more than features do because they determine scale, latency budgets, consistency models, and operational cost.

In system design interviews, NFRs are where the hard trade-offs live. Two systems with identical features but different NFRs look completely different.

## Categories of Non-Functional Requirements

### Scalability

**Scalability** is the system's ability to handle growing load by adding resources.

- **Vertical scaling (scale up)** -- adding more CPU, RAM, or disk to a single machine
- **Horizontal scaling (scale out)** -- adding more machines to distribute load

Questions to clarify:

- What is the expected DAU, MAU, and requests per second?
- How will traffic grow over 1-3 years?
- Is the workload spiky (flash sales, live events) or steady?
- Is the system read-heavy or write-heavy?

Scalability decisions cascade into almost every other architectural choice: database selection, caching strategy, service boundaries, and deployment topology.

### Availability

**Availability** is the fraction of time the system is operational and reachable.

| Availability | Downtime per year | Downtime per month |
|---|---|---|
| `99%` | ~3.65 days | ~7.3 hours |
| `99.9%` | ~8.77 hours | ~43.8 minutes |
| `99.99%` | ~52.6 minutes | ~4.4 minutes |
| `99.999%` | ~5.26 minutes | ~26 seconds |

Key considerations:

- Each extra nine roughly cuts allowed downtime by `10x`
- Higher availability requires redundancy at every layer (compute, network, storage)
- Multi-AZ deployment is usually sufficient for `99.99%`; multi-region for `99.999%`
- Dependencies (databases, third-party APIs, DNS) are the most common availability bottlenecks
- Degrade gracefully -- serve cached or partial results when backends fail

Related terms:

- **MTBF (Mean Time Between Failures)** -- average time between system failures
- **MTTR (Mean Time To Repair)** -- average time to restore service after failure
- **High availability** = maximizing MTBF and minimizing MTTR

### Latency

**Latency** is how long a request takes to complete, usually measured as percentiles.

- **p50 (median)** -- half of requests are faster than this
- **p95** -- 95% of requests are faster than this
- **p99** -- 99% of requests are faster (this is what users complain about)
- **p99.9** -- tail latency, often driven by GC pauses, cold caches, or noisy neighbors

Why percentiles matter more than averages:

- An average of 100ms could hide 99% of requests at 50ms and 1% at 5 seconds
- Users experience the tail, not the average
- SLAs are usually expressed in p99 or p99.9

Latency budgets:

- Interactive APIs: p99 under 200-500ms
- Search and recommendations: p99 under 1 second
- Background jobs: minutes to hours is acceptable
- Real-time systems (chat, gaming): p99 under 100ms

Factors that affect latency:

- Network round trips (each adds 0.5-150ms depending on distance)
- Database queries (index hits vs full table scans)
- Serialization and deserialization
- External service calls (payment providers, email services)
- Garbage collection pauses
- Cold starts (serverless functions, cache misses)

### Consistency

**Consistency** determines whether reads reflect the most recent write.

**Strong consistency:**

- Every read returns the most recent write
- Required for: financial transactions, inventory counts, unique constraint checks
- Cost: higher latency (must coordinate across replicas), lower availability during partitions
- Achieved via: synchronous replication, consensus protocols (Raft, Paxos), single-leader databases

**Eventual consistency:**

- Reads may return stale data temporarily, but converge to the latest write eventually
- Acceptable for: feeds, counts, likes, analytics, non-critical displays
- Benefit: higher availability, lower latency, simpler scaling
- Requires: idempotent operations, conflict resolution strategies

**Causal consistency:**

- Operations that are causally related are seen in order
- Concurrent operations may be seen in different order
- A middle ground between strong and eventual consistency

**Read-your-writes consistency:**

- A user always sees their own writes immediately
- Other users may see stale data temporarily
- Useful for user-facing applications where users expect to see their own changes

### Durability

**Durability** guarantees that committed data survives system failures.

- Durability is not the same as consistency -- a system can be durable but eventually consistent
- Achieved via: write-ahead logs (WAL), replication, backups, distributed storage
- Durability requirements drive storage choices: local SSD vs distributed replication vs cross-region backup

Questions to clarify:

- Is any data loss tolerable, or must every committed write survive?
- How quickly must data be recoverable?
- Are point-in-time recovery and backups required?

### Fault Tolerance

**Fault tolerance** is the system's ability to continue operating when components fail.

- Redundancy at every layer (multiple instances, replicas, regions)
- Automatic failover and health checks
- Circuit breakers to prevent cascading failures
- Bulkheads to isolate failing components from healthy ones
- Timeouts and retries with exponential backoff

Failure modes to consider:

- Single server failure
- Database primary failure
- Network partition between regions
- Third-party service outage
- Disk or storage failure
- DNS resolution failure

### Security

**Security** requirements constrain how data is protected, transmitted, and accessed.

- Encryption in transit (TLS) and at rest
- Authentication and authorization mechanisms
- Data classification and access control
- Audit logging for sensitive operations
- Compliance with regulations (GDPR, HIPAA, PCI DSS)

### Compliance and Regulatory

Some systems must meet legal or industry requirements:

- **GDPR** -- right to deletion, data portability, consent management
- **HIPAA** -- healthcare data protection, audit trails, encryption
- **PCI DSS** -- payment card data handling, network segmentation, logging
- **SOC 2** -- controls for security, availability, processing integrity, confidentiality, privacy
- **FedRAMP** -- government cloud security requirements

### Maintainability

**Maintainability** is how easy it is to modify, debug, and evolve the system.

- Clean code architecture and separation of concerns
- Comprehensive logging, metrics, and tracing
- Feature flags and gradual rollouts
- CI/CD pipelines and automated testing
- Documentation and runbooks

### Cost

Every architectural decision has a cost implication:

- Infrastructure cost (compute, storage, network, managed services)
- Operational cost (monitoring, incident response, on-call)
- Development cost (complexity, time to build, hiring)
- Opportunity cost (what you cannot build because resources are spent here)

Cost often conflicts with other NFRs. Higher availability, stronger consistency, and lower latency all cost more. The right design balances cost against business requirements.

## How NFRs Drive Architecture

| NFR | Architectural Impact |
|---|---|
| High read throughput | Caching, CDNs, read replicas |
| High write throughput | Write-ahead logs, partitioning, message queues |
| Low latency | In-memory caches, connection pooling, edge computing |
| Strong consistency | Single-leader DB, synchronous replication, distributed transactions |
| Eventual consistency | Multi-leader or leaderless replication, async replication |
| High availability | Multi-AZ/region, load balancing, failover, circuit breakers |
| Strict compliance | Encryption, access controls, audit logging, data residency |
| Cost sensitivity | Managed services, serverless, spot instances, right-sizing |

## NFR Prioritization in Interviews

Not all NFRs matter equally for every problem. Prioritize based on the domain:

- **Social media feed**: scalability, availability, eventual consistency, low cost
- **Banking system**: strong consistency, durability, security, compliance
- **Real-time gaming**: low latency, fault tolerance, availability
- **Healthcare platform**: compliance (HIPAA), durability, security, availability
- **E-commerce checkout**: strong consistency (inventory), availability, low latency

State your prioritization out loud in an interview. The interviewer wants to see that you can identify which NFRs matter most and design accordingly.

## Mid/Senior Interview Questions and Answers

### 1. Why are non-functional requirements more important than feature lists in system design?

**Answer:** NFRs determine the architecture. Scale, latency, consistency, and
availability decide whether you need caching, sharding, replication, queues,
or multi-region deployment. Two systems with identical features but different
NFRs look completely different.

Senior engineers spend most of the clarification phase on NFRs because this is
where the hard trade-offs and real cost live.

### 2. How do you trade off consistency and availability?

**Answer:** The CAP theorem states that during a network partition, a
distributed system must choose between consistency and availability.

In practice, most systems choose eventual consistency for most operations
(availability and performance) and strong consistency only for critical paths
(money movement, inventory, unique constraints). State your choice explicitly
and justify it with the business requirements.

### 3. How do you determine if a latency target is achievable?

**Answer:** Map the critical path and estimate the time for each step:
network round trips, database queries, external service calls, serialization,
and business logic.

If the sum of component latencies exceeds the p99 budget, you need to
parallelize independent steps, add caching, use faster storage, or move
computation closer to the user. Always leave margin for tail latency.

### 4. What is the difference between scalability and availability?

**Answer:** Scalability is the ability to handle growing load by adding
resources. Availability is the ability to stay operational despite failures.

A system can be highly scalable but have low availability (scales well under
normal conditions but fails entirely when a component goes down). A system can
be highly available but not scalable (handles failures gracefully but cannot
grow beyond a fixed capacity). You need both.

### 5. How do you prioritize NFRs when they conflict?

**Answer:** Tie NFRs to business impact. If data loss would cause legal
liability, durability and consistency come first. If downtime costs revenue
per minute, availability is the priority. If users churn on slow responses,
latency wins.

State the prioritization out loud and design for the most critical NFRs first.
Secondary NFRs can often be addressed incrementally.

### 6. How do you handle NFRs in a microservices architecture?

**Answer:** Each service may have different NFRs. A payment service needs
strong consistency and high availability. A recommendation service can tolerate
eventual consistency and slightly higher latency.

Define NFRs per service, not just for the system as a whole. Use service-level
objectives (SLOs) per service, and design inter-service communication
(synchronous vs async, retries, circuit breakers) based on each service's
requirements.
