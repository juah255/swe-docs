# Requirements

Gathering requirements is the first and most important step of any system
design. Getting them wrong means designing the wrong system efficiently.
Requirements split into two categories: **functional** (what the system does)
and **non-functional** (how well it does it).

## Functional Requirements

**Functional requirements** describe **what the system must do**: the features,
user actions, and core entities.

Questions to ask:

- What features are required?
- What are the key user actions?
- What are the expected data objects and their critical fields?
- What exactly is a `post`, `order`, or `ride` in this system?

Keep the list tight. In an interview, agree on a small set of core features
first and treat the rest as out of scope until time allows.

## Non-Functional Requirements

**Non-functional requirements** describe **how well the system should do it**.
These shape the architecture far more than feature lists do, because they
dictate scale, latency budgets, and consistency choices.

Areas to clarify:

- **Scale**: DAU, MAU, requests per second
- **Latency**: acceptable response time, usually expressed as p50 / p99
- **Availability**: `99.9%` vs `99.99%`
- **Consistency**: strong vs eventual
- **Durability**: whether any data loss is tolerable
- **Compliance**: PII, financial data, GDPR, HIPAA

### Clarifying questions

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

### Availability tiers

Each extra nine cuts allowed downtime by roughly `10x`, which directly raises
cost and complexity. Pin down the tier early.

| Availability | Downtime per year | Downtime per month |
| --- | --- | --- |
| `99%` | ~3.65 days | ~7.3 hours |
| `99.9%` | ~8.77 hours | ~43.8 minutes |
| `99.99%` | ~52.6 minutes | ~4.4 minutes |
| `99.999%` | ~5.26 minutes | ~26 seconds |

### Consistency vs durability

- **Consistency** is about whether reads see the latest write. **Strong
  consistency** guarantees they do; **eventual consistency** allows a lag.
- **Durability** is about whether committed data survives failures. A system can
  be highly durable yet only eventually consistent.

## Read-Heavy vs Write-Heavy

Knowing the read/write ratio drives most architectural decisions.

- **Read-heavy** (e.g. news feed, product catalog): lean on caching, read
  replicas, and CDNs. Reads dominate, so optimize the read path.
- **Write-heavy** (e.g. metrics ingestion, chat, logging): focus on write
  throughput with partitioning, append-only storage, batching, and queues.

Also ask:

- Is the system latency-sensitive or throughput-sensitive?
- What does failure look like, and is degraded service acceptable?

## Capacity Estimation Basics

Rough back-of-the-envelope math shows whether a design is feasible and what to
scale. You are not aiming for precision, only the right order of magnitude.

Useful steps:

1. Convert users to QPS. A common heuristic:

```text
QPS = (DAU * actions per user per day) / 86400 seconds
```

2. Estimate peak QPS as `2x` to `10x` average for spiky traffic.
3. Estimate storage from object size times write rate times retention.
4. Estimate bandwidth from payload size times QPS.

Handy numbers to memorize:

| Quantity | Value |
| --- | --- |
| Seconds per day | ~86,400 (≈ `10^5`) |
| 1 million writes/day | ~12 writes/second average |
| L1 cache reference | ~1 ns |
| Memory reference | ~100 ns |
| SSD random read | ~100 µs |
| Round trip within a datacenter | ~0.5 ms |
| Round trip across regions | ~50–150 ms |

## Mid/Senior Interview Questions and Answers

### 1. Why are non-functional requirements more important than feature lists?

**Answer:** Non-functional requirements determine the architecture. Scale,
latency budgets, consistency, and availability decide whether you need caching,
sharding, replication, or queues. Two systems with identical features but
different scale and consistency needs look completely different.

Senior engineers spend most of the clarification phase here, because this is
where the hard trade-offs and the real cost live.

### 2. How do you do capacity estimation without exact numbers?

**Answer:** Use back-of-the-envelope math. Convert DAU and per-user activity
into average QPS, multiply by a peak factor for spikes, then derive storage and
bandwidth from object size and retention. Round aggressively to powers of ten.

The point is feasibility and identifying the dominant cost or bottleneck, not
precision. State your assumptions so the interviewer can correct the inputs.

### 3. How do you decide between strong and eventual consistency?

**Answer:** Tie it to business rules. Money movement, inventory reservation, and
unique-username checks usually need strong consistency. Feeds, counts, likes,
and analytics tolerate eventual consistency and benefit from the extra
availability and performance.

Often the answer is mixed: strong consistency on a few critical writes, eventual
consistency everywhere else to keep the system fast and available.

### 4. What clarifying questions matter most for a read-heavy system?

**Answer:** Confirm the read/write ratio, acceptable staleness, and hot-key
behavior. If reads dominate and slight staleness is fine, caching, CDNs, and
read replicas do most of the heavy lifting.

Then ask about cache invalidation needs and traffic spikes, since those decide
how aggressive the caching layer can safely be.

### 5. How do availability tiers affect your design?

**Answer:** Each additional nine roughly cuts allowed downtime tenfold and
forces redundancy, multi-AZ or multi-region deployment, automated failover, and
careful dependency management. Cost and operational burden climb sharply.

Confirm the target tier before designing, because `99.9%` and `99.999%` lead to
very different architectures and budgets.
