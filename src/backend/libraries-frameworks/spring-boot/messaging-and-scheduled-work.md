# Messaging and Scheduled Work

Messaging decouples producers from consumers in time and deployment. It also
introduces duplicate delivery, ordering, schema evolution, poison messages,
consumer lag, and operational dependencies.

## Message Design

A useful event envelope commonly contains:

- a stable event ID and type;
- schema version;
- occurrence time;
- correlation and causation IDs;
- tenant or partition key where applicable;
- the minimum data required by consumers.

Do not publish JPA entities or Java serialization as a long-lived contract. Use
an explicit JSON, Avro, or Protobuf schema and evolve it compatibly.

## Producer Consistency

Writing database state and publishing a message are two separate operations. If
one succeeds and the other fails, the system diverges. The transactional outbox
pattern writes both domain state and an outbox record in one database
transaction, then a relay publishes the record.

Publishing from an after-commit callback avoids pre-commit visibility but can
still lose a message if the process dies after commit. Choose the reliability
pattern from the business requirement.

## Consumer Semantics

Assume at-least-once delivery unless the complete system proves otherwise.
Consumers should be idempotent:

```java
@Transactional
public void handle(OrderPaid event) {
    if (processedEvents.existsById(event.id())) {
        return;
    }

    fulfillOrder(event.orderId());
    processedEvents.save(new ProcessedEvent(event.id()));
}
```

The deduplication record and business write must share a transaction to close
the race. An external side effect may require the destination's idempotency key
or another outbox.

## Retries and Dead Letters

Retry transient failures with bounded exponential backoff and jitter. Validation
errors, unsupported schemas, and missing permanent data usually need a dead
letter or quarantine flow rather than infinite retry.

Record why a message failed, alert on age and repeated attempts, and provide a
safe replay process. A dead-letter queue is not resolved merely because messages
have moved out of the main queue.

## Ordering and Concurrency

Global ordering limits throughput and is rarely necessary. Partition by an
entity or tenant key when per-key ordering matters. Even then, retries and
consumer rebalances can reveal assumptions, so reject invalid state transitions
safely.

Size listener concurrency against downstream database and service capacity.
Increasing consumers without increasing connection budgets can make lag worse.

## Scheduled Work

`@Scheduled` is suitable for simple in-process schedules:

```java
@Scheduled(cron = "0 */5 * * * *", zone = "UTC")
public void expireReservations() {
    reservationExpiry.expireBatch();
}
```

In a multi-replica deployment, each replica may run the schedule. Use a
distributed lock, leader election, platform scheduler, or queue when only one
execution is allowed. The operation should still be idempotent because locks and
leases can fail.

Make timezone explicit, batch large datasets, record last successful completion,
and handle missed schedules. Use Quartz, Spring Batch, or an external workflow
system when jobs need durable state, restartability, complex calendars, or
multi-step orchestration.

## Observability

Track publish failures, send latency, consumer lag, queue depth, oldest message
age, processing duration, retries, dead-letter count, and handler outcome. Carry
trace or correlation context without putting credentials or sensitive payloads
in headers.

