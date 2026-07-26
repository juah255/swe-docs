# Availability

**Availability** is the fraction of time the system is operational and reachable. It is usually expressed as a percentage of uptime over a year.

## Techniques

- **Health Checks** -- detect and remove failed instances
- **Failover** -- automated switch to a standby when primary goes down
- **Replication** -- copy data across nodes for redundancy
- **Multi-AZ** -- deploy across availability zones for zone-level failure tolerance
- **Load Balancer** -- distributes traffic and removes unhealthy nodes

## Availability Tiers

Each extra nine cuts allowed downtime by roughly `10x`, which directly raises cost and complexity.

| Availability | Downtime per year | Downtime per month |
|---|---|---|
| `99%` | ~3.65 days | ~7.3 hours |
| `99.9%` | ~8.77 hours | ~43.8 minutes |
| `99.99%` | ~52.6 minutes | ~4.4 minutes |
| `99.999%` | ~5.26 minutes | ~26 seconds |

## Key Concepts

- **MTBF (Mean Time Between Failures)** -- average time between system failures
- **MTTR (Mean Time To Repair)** -- average time to restore service after failure
- **High availability** = maximizing MTBF and minimizing MTTR

## How to Achieve High Availability

- **Redundancy** at every layer (compute, network, storage)
- **Multi-AZ deployment** for `99.99%`; **multi-region** for `99.999%`
- **Load balancing** to distribute traffic and remove unhealthy nodes
- **Automated failover** when a primary node goes down
- **Health checks** to detect and remove failed instances
- **Graceful degradation** -- serve cached or partial results when backends fail
- **Dependencies** are the most common availability bottleneck (databases, third-party APIs, DNS)

## Availability vs Cost

Higher availability requires:

- More infrastructure (redundant instances, databases, regions)
- More operational complexity (monitoring, failover, testing)
- More engineering time (chaos engineering, game days)

Pin down the target tier before designing, because `99.9%` and `99.999%` lead to very different architectures and budgets.

## Levers

- Redundancy at every layer (compute, network, storage)
- Health checks and automated failover
- Retries with exponential backoff
- Circuit breakers and graceful degradation
- Multi-AZ and multi-region deployment
- Load balancing to distribute traffic

## Trade-offs

- Higher availability means more infrastructure cost
- Under CAP, higher availability often means weaker consistency during partitions
- Redundancy adds operational complexity (monitoring, failover testing)

## Mid/Senior Interview Questions and Answers

### 1. How do availability tiers affect your design?

**Answer:** Each additional nine roughly cuts allowed downtime tenfold and
forces redundancy, multi-AZ or multi-region deployment, automated failover, and
careful dependency management. Cost and operational burden climb sharply.

Confirm the target tier before designing, because `99.9%` and `99.999%` lead to
very different architectures and budgets.

### 2. What are the most common causes of downtime?

**Answer:** Dependency failures (databases, third-party APIs, DNS), deployment
bugs, configuration changes, resource exhaustion (memory, disk, connections),
network partitions, and human error.

The best defenses are redundancy, automated failover, graceful degradation, and
thorough testing of failure scenarios.

### 3. How do you handle graceful degradation?

**Answer:** When a non-critical dependency fails, continue serving the core
functionality. For example, if the recommendation service is down, serve the
catalog without recommendations. If the payment service is degraded, queue
orders for later processing.

Design every external dependency with a fallback path. The system should never
fail entirely because one component is slow or unavailable.
