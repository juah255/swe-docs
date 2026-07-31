# Microservices

**Microservices** is an architectural style where an application is built as a collection of small, independent, loosely coupled services. Each service owns a specific business capability and usually its own data. Services communicate over the network and can be **developed, deployed, and scaled independently**.

Microservices solve organizational and scaling problems, not technical ones for their own sake. They trade in-process simplicity for distributed-system complexity, so adopt them only when the benefits justify that cost.

## Monolith vs Microservices

| | Monolith | Microservices |
| --- | --- | --- |
| Deployment | One unit | Independent per service |
| Scaling | Whole app together | Per service |
| Data | Shared database | Database per service |
| Failure blast radius | Whole app | Isolated to a service |
| Operational overhead | Low | High |
| Best for | Small teams, early products | Large orgs, independent scaling |

A monolith is often the right starting point. A **modular monolith** with clean internal boundaries captures much of the structure benefit without the distributed cost, and makes a later split easier.

## Service Boundaries

Good boundaries follow **business capabilities**, not technical layers. Each service should own a cohesive domain (often a **bounded context** in domain-driven design terms) and minimize chatty cross-service calls.

Signs of bad boundaries:

- Two services always deploy together.
- A single user action fans out into many synchronous service calls.
- Services share a database table directly.

### Microservice example

In an e-commerce system:

- Product service manages products
- User service handles accounts and login
- Payment service processes payments
- Order service tracks orders

## Communication

Services communicate **synchronously** (caller waits) or **asynchronously** (fire-and-forget via a broker). Prefer async for anything not on the critical path.

- **REST**: ubiquitous, human-readable, easy to debug. Higher overhead.
- **gRPC**: high-performance RPC using Protocol Buffers over HTTP/2. Compact, fast, strongly typed; ideal for internal service-to-service calls.
- **Message queues** (RabbitMQ, SQS): decouple producer and consumer, smooth spikes, enable retries. Good for task/work distribution.
- **Event streaming** (Kafka): durable, replayable event logs for many consumers; the backbone of event-driven architectures.

### What is gRPC?

**gRPC** is a high-performance communication framework developed by Google. It lets services communicate efficiently using Protocol Buffers instead of JSON payloads, with generated client and server stubs and HTTP/2 features like multiplexing and streaming.

### Synchronous vs asynchronous

```text
Sync (REST/gRPC): Order service -> calls Payment service -> waits for response
Async (Kafka):    Order service -> publishes OrderPlaced event -> consumers react
```

Async communication improves resilience and decoupling but adds eventual consistency and harder debugging.

## Data Ownership / Database per Service

Each service should own its data and expose it only through its API. **Sharing a database** between services recreates tight coupling and defeats the point of microservices.

Consequences:

- No cross-service joins. Data is composed at the API layer or via events.
- Each service can pick the database that fits its access pattern (polyglot persistence).
- Keeping data consistent across services needs explicit patterns rather than a single ACID transaction.

## Saga Pattern

A **saga** manages a transaction that spans multiple services without a distributed lock. It is a sequence of local transactions; if one step fails, **compensating transactions** undo the prior steps.

Two styles:

- **Choreography**: services react to each other's events. Decentralized, but the overall flow is harder to follow.
- **Orchestration**: a central orchestrator tells each service what to do and handles failures. Clearer control, but the orchestrator is a focal point.

```text
Order saga (orchestrated):
1. Reserve inventory
2. Charge payment
3. If payment fails -> release inventory (compensation)
```

## Serverless

**Serverless** (functions-as-a-service) runs backend code where the cloud provider manages servers and your code runs only when triggered. You pay per invocation and scaling is automatic.

Good fits:

- Event-driven workloads and glue logic
- Spiky or unpredictable traffic
- Scheduled jobs and lightweight APIs

Weak fits:

- Long-running jobs
- Latency-sensitive paths hurt by **cold starts**
- Heavy local state or deep runtime control needs

## Mid/Senior Interview Questions and Answers

### 1. How do you decide between monolith and microservices?

**Answer:** A monolith is often better for small teams, early products, and
strongly coupled domains. Microservices help when independent scaling,
deployment, ownership, or fault isolation justifies the distributed-system
complexity they introduce.

Microservices add network failures, data consistency problems, observability
needs, deployment coordination, and operational overhead. A modular monolith is
frequently the pragmatic middle ground until those pressures appear.

### 2. How do you maintain data consistency across services?

**Answer:** Drop the idea of a single distributed ACID transaction. Use the saga
pattern with local transactions and compensating actions, and rely on events to
propagate state changes, accepting eventual consistency between services.

Make operations idempotent and use the outbox pattern to publish events
reliably alongside local writes, so a crash never leaves data and events out of
sync.

### 3. When would you choose gRPC over REST?

**Answer:**
**Use gRPC when:**

- High performance and low latency are important.
- Communication is between internal microservices.
- You need streaming (client, server, or bidirectional).
- You want efficient binary serialization with Protocol Buffers.

**Use REST when:**

- Building public APIs.
- Supporting web browsers or third-party clients.
- You prefer simple, human-readable JSON APIs.
- Ease of debugging and compatibility are more important than maximum performance.

**Common practice:** REST for client-to-server communication, gRPC for service-to-service communication.

### 4. How do you evolve a monolith toward microservices?

**Answer:** Do not rewrite. Start by enforcing clean module boundaries inside the
monolith, then peel off the highest-value service first, usually one with
distinct scaling needs or a clear bounded context. Give it its own data and an
API, and route to it incrementally (the strangler-fig pattern).

Measure whether the split actually reduced coupling or deployment pain. If it
did not, stop; not every domain benefits from being a separate service.

### 5. When is serverless a good fit?

**Answer:** Serverless fits event-driven workloads, spiky traffic, scheduled
jobs, lightweight APIs, and teams that benefit from managed scaling and
pay-per-use billing.

It is less ideal for long-running jobs, low-latency workloads sensitive to cold
starts, heavy local state, or systems needing deep runtime control.
