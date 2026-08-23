# Asynchronous Processing

Asynchronous processing separates work from the request that initiated it. The
request can return before all processing finishes, while workers handle the
remaining work through queues, event streams, or scheduled jobs.

This is different from `async`/`await`. Async I/O improves concurrency inside a
process. Asynchronous processing moves work across time or process boundaries.

## Why Process Work Asynchronously?

Use asynchronous processing when work is:

- Too slow for the request-response path
- Retryable after a temporary failure
- CPU- or memory-intensive
- Triggered by an event rather than a direct request
- Suitable for batching or scheduling
- Able to finish after the user receives a response

Examples include sending email, generating reports, processing uploads,
delivering webhooks, synchronizing external systems, and updating search
indexes.

Do not move work to a queue only to hide poor performance. Operations that must
complete before a response is truthful should remain synchronous or use a
clearly documented pending state.

## Basic Architecture

```text
Client -> API -> database
             -> broker -> worker -> dependency
                          |
                          -> result/status store
```

The API validates the request, records necessary state, publishes a message,
and returns. A worker consumes the message and performs the job.

## Background Tasks vs. Durable Jobs

An in-process background task runs in the API process after the response. It is
simple but can be lost during a crash or deployment and competes with requests
for CPU and memory.

A durable job is written to a broker or database and handled by separate
workers. It supports independent scaling, retries, scheduling, and operational
visibility.

Use in-process tasks only for small, non-critical work. Use a durable queue when
the work must eventually happen or may need recovery.

## Queues and Event Streams

A **task queue** usually distributes each job to one worker. Examples include
RabbitMQ, Amazon SQS, Redis-backed queues, and cloud task services.

An **event stream** stores an ordered log that multiple consumer groups can
read independently. Examples include Kafka, Pulsar, and Kinesis.

Choose a queue for commands such as `generate_report`. Choose an event stream
when multiple consumers need facts such as `order_paid` and replay is useful.

## Delivery Guarantees

Common delivery models are:

- **At-most-once:** a message may be lost but is not redelivered
- **At-least-once:** a message is retried but may be processed more than once
- **Effectively-once:** duplicates may arrive, but application design prevents
  duplicate effects

True end-to-end exactly-once processing is rarely available across a broker,
database, and external services. Most reliable systems use at-least-once
delivery with idempotent consumers.

## Idempotent Consumers

A handler is idempotent when processing the same message repeatedly produces the
same intended outcome.

Strategies include:

- Store processed message IDs under a unique constraint
- Use a business idempotency key
- Make state transitions conditional
- Use database upserts carefully
- Check the current state before applying an operation
- Pass idempotency keys to external APIs that support them

```sql
INSERT INTO processed_messages (consumer, message_id)
VALUES ('billing', 'msg_123')
ON CONFLICT DO NOTHING;
```

The marker and business update should normally commit in the same database
transaction.

## Acknowledgments and Visibility Timeouts

A consumer acknowledges a message after successful processing. If it crashes
before acknowledgment, the broker makes the message available again.

Some brokers use a visibility timeout. The timeout must exceed normal job
duration or be extended while long jobs run; otherwise another worker may
receive the same job before the first worker finishes.

## Retries

Retry temporary failures such as timeouts, rate limits, or short dependency
outages. Do not retry permanent failures such as invalid input without changing
the message.

Use exponential backoff with jitter:

```text
delay = min(max_delay, base * 2^attempt) + random_jitter
```

Retries must be bounded. An unhealthy dependency combined with aggressive
retries can create a retry storm and extend an outage.

## Dead-Letter Queues

Messages that repeatedly fail should move to a dead-letter queue. Operators need
tools to inspect the error, correct the underlying problem, and replay or discard
the message safely.

A DLQ is not a substitute for monitoring. Alert on its growth and record why
each message was moved there.

## Ordering

Global ordering limits throughput and is often unnecessary. Many systems need
ordering only for one entity, such as all events for the same account.

Partition messages by a stable key such as `account_id`. Messages for the same
key then reach the same ordered partition, while unrelated keys process in
parallel.

Even with ordered delivery, consumers should reject stale state transitions or
use sequence numbers because retries and producers can still create surprises.

## Transactional Outbox

A database write and message publication cannot normally share one atomic
transaction. If the application commits the database write and crashes before
publishing, downstream consumers never learn about the change.

The transactional outbox pattern writes the business data and an outbox row in
the same transaction:

```text
Database transaction:
  1. Update order to paid
  2. Insert order_paid into outbox

Publisher:
  3. Read unpublished outbox rows
  4. Publish messages
  5. Mark rows as published
```

Publishing may still happen more than once, so consumers remain idempotent.

## Job State and API Design

For long-running work, return `202 Accepted` with a job resource:

```http
HTTP/1.1 202 Accepted
Location: /jobs/job_123

{"id": "job_123", "status": "queued"}
```

Useful states include `queued`, `running`, `succeeded`, `failed`, and
`cancelled`. Store progress only when it is meaningful. Define result retention,
cancellation semantics, and whether failed jobs can be retried by users.

Clients can poll the job resource or receive completion through WebSockets,
server-sent events, or a webhook.

## Concurrency and Backpressure

Workers must not consume faster than dependencies can handle. Control pressure
with:

- Bounded worker concurrency
- Broker prefetch limits
- Separate queues and worker pools for different workloads
- Per-tenant or per-dependency limits
- Rate limiting and circuit breakers
- Queue admission limits

Queue depth, oldest-message age, and processing latency show whether the system
is keeping up. Autoscaling only helps until a database or external API becomes
the bottleneck.

## Scheduled and Periodic Jobs

Schedulers enqueue work at a future time or on a recurring schedule. In a
distributed deployment, ensure only one logical scheduler owns each schedule or
use a system designed for leader election and deduplication.

Periodic jobs should still be idempotent. A scheduler can run twice during
failover, daylight-saving changes, clock drift, or deployment overlap.

## Payload Design

Messages should include a unique ID, event type, schema version, timestamp,
correlation ID, and the minimum data needed by consumers.

Avoid large payloads and secrets. Store large files in object storage and send a
reference. Decide whether an event contains a snapshot or only an entity ID;
fetching current state can produce results different from the state at event
time.

## Observability

Track:

- Queue depth and oldest message age
- Enqueue-to-start delay
- Processing duration and success rate
- Retry and dead-letter counts
- Worker utilization and crashes
- End-to-end correlation IDs

Log message IDs and job IDs, but avoid sensitive payloads. Distributed traces
should connect the originating request, message publication, and worker span.

## Mid/Senior Interview Questions and Answers

### 1. Why must queue consumers be idempotent?

**Answer:** A worker can complete its database update and crash before
acknowledging the message. The broker then redelivers it. Idempotency ensures the
retry does not charge twice, send conflicting updates, or corrupt state.

### 2. What problem does the transactional outbox solve?

**Answer:** It prevents a successful database transaction from being separated
from the event that announces it. Business data and an outbox record commit
together, then a publisher reliably sends the event later.

### 3. How do you handle a growing queue backlog?

**Answer:** Check oldest-message age, failure rate, worker capacity, and
dependency latency. Scale consumers only when the downstream systems have
capacity. Apply backpressure, isolate slow job types, reduce retry pressure, and
degrade non-critical producers when necessary.

### 4. When would you use a queue instead of an event stream?

**Answer:** Use a queue to distribute commands where one worker should perform
each job. Use an event stream when multiple independent consumers need the same
event history, ordering by partition matters, or replay is required.
