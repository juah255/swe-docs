# Non-Functional Requirements

**Non-functional requirements (NFRs)** define how well a system performs, not what it does. They shape architecture more than features do because they determine scale, latency budgets, consistency models, and operational cost.

In system design interviews, NFRs are where the hard trade-offs live. Two systems with identical features but different NFRs look completely different.

## Categories

- [Scalability](scalability.md): handling growing load by adding resources
- [Availability](availability.md): the system is operational and reachable
- [Reliability](reliability.md): the system performs its intended function correctly
- [Performance](performance.md): latency, throughput, and resource efficiency
- [Security](security.md): protecting data, systems, and users from threats
- [Maintainability](maintainability.md): ease of modification, debugging, and evolution

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

## Trade-offs Between Attributes

Improving one attribute usually costs another. Common trade-offs:

| Improve | Often costs |
| --- | --- |
| Availability | Consistency (CAP) |
| Latency | Freshness (caching) or cost (more capacity) |
| Consistency | Availability under partition |
| Security | Developer velocity and UX friction |
| Maintainability | Short-term speed |
| Scalability | Complexity and eventual consistency |

There is no universally right answer. The architecture should name the
qualities that matter, the level required for each, and the trade-offs it
accepts.

## Setting Targets

Vague goals ("fast", "reliable") are not actionable. Useful targets look like:

- `p95` API latency under `200ms`.
- `99.95%` monthly availability.
- Recover from a full region outage within `15 minutes`.
- Zero data loss for financial transactions; up to `5 minutes` acceptable for
  analytics.

Targets should come from the business and drive architectural decisions, not
be inferred after the fact.

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

### 3. How do you prioritize NFRs when they conflict?

**Answer:** Tie NFRs to business impact. If data loss would cause legal
liability, durability and consistency come first. If downtime costs revenue
per minute, availability is the priority. If users churn on slow responses,
latency wins.

State the prioritization out loud and design for the most critical NFRs first.
Secondary NFRs can often be addressed incrementally.

### 4. How do you handle NFRs in a microservices architecture?

**Answer:** Each service may have different NFRs. A payment service needs
strong consistency and high availability. A recommendation service can tolerate
eventual consistency and slightly higher latency.

Define NFRs per service, not just for the system as a whole. Use service-level
objectives (SLOs) per service, and design inter-service communication
(synchronous vs async, retries, circuit breakers) based on each service's
requirements.
