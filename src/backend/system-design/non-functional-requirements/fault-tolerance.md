# Fault Tolerance

**Fault tolerance** is the system's ability to continue operating correctly when one or more components fail. A fault-tolerant system does not require every component to be working in order to serve requests.

Fault tolerance is related to but distinct from availability and reliability. Availability means the system is up. Reliability means it is correct. Fault tolerance means it keeps working despite failures.

## Techniques

- **Replication** -- duplicate data or services so a failure does not lose capacity or data
- **Circuit Breaker** -- stop calling a failing dependency to prevent cascading failures
- **Retry** -- attempt transient failures again with backoff
- **Queue** -- buffer work so a temporary downstream failure does not block producers

## How Fault Tolerance Differs

| | What it answers | Example |
| --- | --- | --- |
| **Availability** | Is the system reachable? | `99.99%` uptime |
| **Reliability** | Is the output correct? | No silent data corruption |
| **Fault tolerance** | Does it keep working despite failures? | Survives a node or AZ loss |

## Design Principles

- Assume every component will fail
- No single point of failure on the critical path
- Isolate failures to prevent cascading
- Degrade gracefully rather than fail entirely
- Test failures regularly (chaos engineering)

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between fault tolerance and high availability?

**Answer:** High availability focuses on minimizing downtime -- the system is reachable and responsive. Fault tolerance focuses on continuing correct operation despite component failures.

A system can be highly available but not fault-tolerant: if a primary database fails and the replica takes over with a brief blip, availability is maintained but writes may be lost. Fault tolerance requires that no single failure causes data loss or incorrect behavior.

### 2. How do you design for fault tolerance in a distributed system?

**Answer:** Replicate state across failure domains (nodes, AZs, regions). Use circuit breakers and retries with backoff to handle transient failures. Buffer work in durable queues so a downstream outage does not block upstream producers. Isolate failures with bulkheads so one bad component cannot drain resources from healthy ones.

Test fault tolerance with chaos engineering -- kill nodes, inject latency, and partition networks to verify the system degrades gracefully rather than catastrophically.

### 3. When is fault tolerance not worth the cost?

**Answer:** When the impact of a failure is low and recovery is fast. A batch analytics pipeline that can restart from the last checkpoint does not need the same fault tolerance as a payment system.

Every layer of fault tolerance adds cost: replication, extra infrastructure, operational complexity, and testing burden. Apply it where failures have real business impact -- the critical path, not every component.
