# Quality Attributes

**Quality attributes** — often called the "-ilities" — are the non-functional
qualities a system must uphold. They cannot be added at the end; they are
shaped by architectural decisions.

Every quality attribute has a cost, and improving one often hurts another. The
job of architecture is to state which qualities matter, at what level, and
what you are willing to trade for them.

## Performance

How fast the system responds and how much work it does per unit time.

- **Latency**: time to handle a single request. Usually measured as `p50`,
  `p95`, `p99`.
- **Throughput**: requests handled per second.

Levers: caching, async processing, batching, efficient data structures,
appropriate indexes, colocation of data and compute.

Trade-offs: caching hurts freshness; async hurts consistency; heavy indexing
hurts write speed.

## Scalability

The ability to handle more load by adding resources without redesign.

- **Vertical**: bigger machines. Simple, capped.
- **Horizontal**: more machines. Requires stateless services, distributed
  state, and load balancing.

Trade-offs: scalable architectures are more complex and often eventually
consistent. See [System Design → Scalability](../system-design/scalability.md).

## Availability

The fraction of time the system is usable. Usually expressed as nines.

| Level | Downtime per year | Notes |
| --- | --- | --- |
| `99%` | ~3.65 days | Basic |
| `99.9%` | ~8.77 hours | Common target |
| `99.99%` | ~52 minutes | Requires redundancy |
| `99.999%` | ~5 minutes | Very expensive |

Levers: redundancy at every layer, health checks, automated failover, retries
with backoff, circuit breakers, graceful degradation.

Trade-offs: higher availability means more infrastructure cost and, under CAP,
often weaker consistency during partitions.

## Reliability

The system behaves correctly under expected and unexpected conditions.
Availability answers "is it up?"; reliability answers "is it correct?".

Levers: idempotency, retries with dead-letter queues, database constraints,
exactly-once semantics where possible, chaos testing.

## Maintainability

How cheaply engineers can understand, change, and safely extend the system.

Levers: clear boundaries, tests, documentation, consistent conventions, small
modules, explicit dependencies, observability.

Trade-offs: highly maintainable code often has more indirection than the
shortest possible implementation.

## Security

Confidentiality, integrity, and availability of data and operations.

Levers: authentication, authorization, encryption in transit and at rest,
least privilege, input validation, secret management, audit logging, regular
patching.

Security is a cross-cutting concern that must be baked into every layer, not
bolted on.

## Testability

How easy it is to verify behavior automatically.

Levers: pure functions, dependency injection, small units, deterministic
behavior, clean separation of I/O from logic. A hard-to-test module is almost
always a badly designed module.

## Portability

How easily the system moves between environments — cloud providers, operating
systems, runtimes.

Levers: containerization, standard interfaces, avoiding vendor-specific
features where reasonable.

Trade-offs: portable systems often pay a complexity or performance cost for
avoiding proprietary features.

## Observability

The ability to understand what the system is doing from outside: logs,
metrics, and traces.

- **Logs**: discrete events with context.
- **Metrics**: numeric measurements over time.
- **Traces**: request paths across services.

Observability is a first-class quality attribute in distributed systems.
Without it, everything else is guesswork.

## Cost

Not always listed as an attribute, but every design choice has a cost profile:
infrastructure, licenses, on-call load, engineer time. A "cheaper" system that
requires constant firefighting is not actually cheap.

## Trade-offs Between Attributes

Improving one attribute usually costs another. Common trade-offs:

| Improve | Often costs |
| --- | --- |
| Availability | Consistency (CAP) |
| Latency | Freshness (caching) or cost (more capacity) |
| Consistency | Availability under partition |
| Security | Developer velocity and UX friction |
| Maintainability | Short-term speed |
| Portability | Ability to use best-of-breed cloud features |

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

### 1. How do you decide which quality attributes matter?

**Answer:** Start from the business. A payment system prioritizes reliability,
security, and consistency; a social feed prioritizes availability and
latency; an internal admin tool prioritizes maintainability and cost. Ask what
failure looks like and what users will actually notice, then translate that
into targets.

Explicit targets — latency percentiles, availability nines, recovery times —
are the difference between an architecture that is optimized and one that
just hopes.

### 2. Why can you not maximize every quality attribute?

**Answer:** They trade against each other. Higher availability under a
partition means weaker consistency. More caching means more staleness.
Stronger security friction slows delivery. Adding portability limits use of
the best cloud primitives.

A senior architect names the trade-offs on purpose: which attributes are hard
constraints, which are targets, and which are explicitly deprioritized.

### 3. What is the difference between availability and reliability?

**Answer:** Availability is whether the system responds; reliability is
whether it responds correctly. A service can be highly available but
unreliable — for example, always returning quickly but silently dropping
messages. Availability without reliability is worse than a clear outage,
because it hides failure.

Real systems need both, plus observability to detect gaps between them.

### 4. How do you approach performance targets?

**Answer:** Express targets as percentiles, not averages. `p50` looks fine on
almost every broken system; user experience is defined by `p95` and `p99`.
Measure end-to-end from the user's perspective, then break the budget down
across the components on the critical path.

Optimizing without a target is guesswork. Optimizing off the critical path is
wasted work.

### 5. How do you build security into architecture rather than adding it later?

**Answer:** Treat security as a cross-cutting quality attribute from day one:
identity and authorization model, tenant isolation, encryption in transit and
at rest, secret management, and audit logging. Choose defaults that fail
closed — deny by default, require explicit access, and validate at every
boundary.

Retrofitting security is expensive because it forces changes to data models,
API contracts, and infrastructure at once, often under incident pressure.
