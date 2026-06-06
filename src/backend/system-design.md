# System Design

## Steps for Answering System Design Questions

1. Requirements: functional and non-functional
2. Capacity estimation
3. API design / high-level design
4. Data model
5. High-level architecture
6. Detailed design: component deep-dive
7. Bottlenecks and trade-offs

## Functional Requirements

**Functional requirements** describe **what the system must do**.

Questions to ask:

- What features are required?
- What are the key user actions?
- What are the expected data objects and their critical fields?
- What exactly is a `post`, `order`, or `ride` in this system?

## Non-Functional Requirements

**Non-functional requirements** describe **how well the system should do it**.

Areas to clarify:

- Scale: DAU, MAU, requests per second
- Latency: acceptable response time
- Availability: `99.9%` vs. `99.99%`
- Consistency: strong vs. eventual
- Durability: whether some data loss is tolerable

Detailed questions:

- How many DAU / MAU are expected?
- What are the requests per second for key operations?
- How much data will be stored per day or per year?
- What latency is acceptable for the main user flows?
- Are there hard SLAs for any API?
- What uptime is expected?
- Is downtime worse than data loss, or the reverse?
- How will QPS or data volume grow over the next 1 to 3 years?
- Are workloads spiky, such as flash sales or live events?
- Where is strong consistency required?
- Are ordering or idempotency requirements important?
- Is the data sensitive, such as PII or financial data?
- Are there compliance constraints such as GDPR or HIPAA?
- How important are observability, rollbacks, and feature toggles?

Also ask:

- Is the system read-heavy or write-heavy?
- Is it latency-sensitive or throughput-sensitive?
- What does failure look like, and is degraded service acceptable?

## Critical Path

The **critical path** is the sequence of dependent operations that determines the minimum latency of a request. Any delay on this path directly increases end-to-end response time.

### Example: e-commerce checkout

```text
Place order -> Check inventory -> Reserve item -> Authorize payment -> Write order DB record -> Return confirmation
```

### When do we need to identify the critical path?

- When optimizing latency
- When deciding what to scale first under load
- When checking whether an SLA is achievable
- When planning redundancy for failure-prone components
- When deciding what can move off the synchronous request path

Interview rule:

> If removing a component from the flow does not change user-facing latency, it is not on the critical path.

## SLA

SLA stands for **Service Level Agreement**.

In simple terms, it is a **promise the system makes about behavior**, usually to users or business clients.

## Design a Rate Limiter

Use this section to document **common rate-limiter designs and trade-offs**.

## Microservices

**Microservices** is an architectural style where an application is built as a collection of small, independent, loosely coupled services. Each service owns a specific business capability and usually its own data.

These services communicate over the network and can be **developed, deployed, and scaled independently**.

### Microservice example

In an e-commerce system:

- Product service manages products
- User service handles accounts and login
- Payment service processes payments
- Order service tracks orders

### Common communication methods

- REST APIs
- gRPC
- Message queues such as RabbitMQ or Kafka
- Event streams
- Shared messaging systems

### What is gRPC?

**gRPC** is a high-performance communication framework developed by Google. It allows services to communicate efficiently by using Protocol Buffers instead of JSON payloads.

## Serverless Architecture

**Serverless architecture** is a way to run backend code where the cloud provider manages the servers and your code runs only when triggered.
