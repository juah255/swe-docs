# Message Queues

A **message queue** is a broker that decouples producers from consumers, enabling asynchronous processing, smoothing traffic spikes, and improving system resilience.

## Why Use Message Queues

- **Decoupling** -- producers and consumers operate independently
- **Async processing** -- move non-critical work off the request path (emails, notifications, analytics)
- **Traffic smoothing** -- absorb spikes and let consumers drain at a safe rate
- **Retry and resilience** -- failed messages can be retried without losing data
- **Scalability** -- add consumers independently to scale processing

## Queue vs Event Streaming

| | Message Queue | Event Streaming |
|---|---|---|
| Pattern | Task consumed once, then removed | Durable log many consumers read independently |
| Retention | Until consumed | Time-based or size-based retention |
| Replay | No | Yes (replay from any offset) |
| Consumers | Competing consumers (one processes each message) | Independent consumer groups |
| Example | RabbitMQ, SQS, Redis Streams | Kafka, Kinesis, Pulsar |

## When to Use a Queue

- Sending emails or SMS (slow, unreliable external service)
- Image/video processing after upload
- Analytics event collection
- Order processing, payment reconciliation
- Any work that does not need to be on the synchronous request path

## When NOT to Use a Queue

- When the client needs an immediate response (synchronous flow)
- When ordering across the entire system is required (queues complicate ordering)
- When the overhead of queue infrastructure is not justified (simple apps)

## Dead-Letter Queues (DLQ)

A DLQ collects messages that failed processing after max retries:

- Prevents poison messages from blocking the queue
- Allows manual inspection and reprocessing
- Alerts on DLQ depth indicate systemic issues

## Delivery Guarantees

| Guarantee | Meaning | How |
|---|---|---|
| **At-most-once** | Message may be lost, never duplicated | Fire and forget, no ack |
| **At-least-once** | Message may be duplicated, never lost | Ack after processing, retry on failure |
| **Exactly-once** | Message processed exactly once | Complex: idempotent consumers + transactional outbox |

Most systems use **at-least-once** with idempotent consumers. Exactly-once is expensive and usually unnecessary.

## Patterns

### Outbox Pattern

Write the event to an outbox table in the same database transaction as the business data. A separate process polls the outbox and publishes to the queue. This guarantees at-least-once delivery without dual-write problems.

### Competing Consumers

Multiple consumers read from the same queue. Each message is processed by exactly one consumer. This scales processing horizontally.

### Fan-Out

One message is delivered to multiple consumers or queues. Used when one event triggers multiple downstream actions (e.g., order placed -> send email, update inventory, charge payment).

## Mid/Senior Interview Questions and Answers

### 1. When would you choose a message queue over synchronous communication?

**Answer:** Use a queue when the producer does not need an immediate result from
the consumer, when the consumer is slow or unreliable, or when you need to
absorb traffic spikes without overwhelming backends.

Synchronous calls are simpler and provide immediate feedback. Queues add
asyncrony, which improves resilience and scalability but introduces eventual
consistency and harder debugging.

### 2. What is the difference between at-least-once and exactly-once delivery?

**Answer:** At-least-once guarantees no message loss but may deliver duplicates.
The consumer must be idempotent to handle retries safely.

Exactly-once guarantees each message is processed once, but it requires
distributed transactions, idempotent producers, and transactional outbox
patterns. It is complex and expensive. Most systems use at-least-once with
idempotent consumers as a pragmatic choice.

### 3. What is the outbox pattern and why does it matter?

**Answer:** The outbox pattern writes events to an outbox table in the same
database transaction as the business data. A separate process polls the outbox
and publishes to the message queue.

This solves the dual-write problem: you cannot atomically write to a database
and publish to a queue. The outbox ensures that if the business data is
committed, the event will eventually be published, providing at-least-once
delivery without data loss.
