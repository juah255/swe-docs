# Software Architecture Questions

## What is software architecture?

**Software architecture** is the set of high-level decisions that shape a
system: which components exist, how they communicate, where data lives, and
which quality attributes the system must uphold. These are the decisions that
are expensive to change later.

## Architecture vs Design vs System Design

- **Architecture**: structure and qualities of the whole system.
- **System Design**: how the architecture meets scale and reliability targets.
- **Design**: internal structure of a module or class.

A useful test: if changing a decision means coordinating teams, migrations,
or downtime, it is architectural.

## Monolith vs Microservices

- **Monolith**: one deployable, one database. Simple, strongly consistent,
  cheap to start.
- **Microservices**: many services, each owning its data. Independent
  scaling and deployment at the cost of distributed-system complexity.

Default to a modular monolith. Extract services when a specific boundary
justifies the operational cost.

## What is layered architecture?

Code is organized into layers (presentation, application, domain,
infrastructure) with dependencies pointing downward. Simple and familiar;
domain logic often leaks into upper layers unless discipline is enforced.

## What is hexagonal architecture?

The domain sits in the center and depends only on **ports** (interfaces).
Outer **adapters** implement those ports for HTTP, databases, and queues. It
makes the core independent of frameworks and easy to test.

## What is clean architecture?

A refinement of hexagonal with explicit entity, use case, and adapter layers.
Dependencies always point inward toward the domain, so business logic is
insulated from framework churn.

## What is event-driven architecture?

Components communicate by producing and consuming events on a broker.
Producers do not know their consumers, which enables loose coupling and
fan-out at the cost of eventual consistency and harder tracing.

## What is CQRS?

**Command Query Responsibility Segregation** separates the write model from
the read model. Useful when read and write patterns diverge sharply, at the
cost of maintaining two models and accepting eventual consistency on reads.

## What is event sourcing?

State is stored as an ordered log of events; current state is rebuilt by
replay. Provides an audit history and time-travel debugging, but complicates
schema evolution and querying.

## What is a bounded context?

A boundary within which a domain term has one clear meaning and one model.
The same word (`customer`, `product`) can mean different things in different
contexts. Bounded contexts are the natural seams for services and teams.

## What is an aggregate?

A cluster of entities and value objects treated as one unit for changes, with
a single **aggregate root** as the only entry point. It enforces business
invariants inside a transaction. Keep aggregates small.

## Entity vs Value Object

- **Entity**: has identity that persists over time (`Order #42`).
- **Value Object**: defined by its attributes, immutable, no identity
  (`Money(100, "USD")`).

## What are quality attributes?

Non-functional qualities the system must uphold: performance, scalability,
availability, reliability, maintainability, security, testability,
portability, observability. Each has a cost and often trades against others.

## Availability vs Reliability

- **Availability**: is the system up and responding?
- **Reliability**: is it responding correctly?

A system can be highly available but unreliable, which is worse than a clean
outage.

## What is the difference between coupling and cohesion?

- **Coupling**: how tightly modules depend on each other. Aim low.
- **Cohesion**: how related the responsibilities inside a module are. Aim
  high.

High cohesion within, low coupling between, is the durable rule.

## What is separation of concerns?

Each module addresses one concern. Business rules, persistence, transport,
and presentation should not be tangled together, so each can change
independently.

## What is dependency inversion at the architectural level?

High-level policy (the domain) depends on abstractions, not on concrete
infrastructure. The database, HTTP framework, and queue implementation all
sit at the edge and can change without disturbing the core.

## What is an anticorruption layer?

A translation layer between two bounded contexts (often between your system
and a legacy or third-party system) so changes on one side do not leak into
the other's model.

## What is the difference between architectural and design patterns?

- **Architectural patterns** describe the whole system's structure
  (layered, hexagonal, event-driven, microservices).
- **Design patterns** describe small-scale solutions inside a component
  (Strategy, Factory, Observer).

## Why prefer a modular monolith to microservices early?

A modular monolith has clean internal boundaries but a single deployment. You
get cohesion, testability, and simple operations. If a boundary later proves
itself with independent scaling, ownership, or deployment needs, you can
extract it into a service — from a known-good starting point.

## What is an architecture decision record (ADR)?

A short document capturing an architectural decision, its context, the
options considered, and the trade-offs accepted. ADRs make reasoning
durable so future engineers can revisit decisions with the same information.

## Mid/Senior Interview Questions and Answers

### 1. How do you approach a "design this system" question at the architecture level?

**Answer:** Start by clarifying the business goal, users, and quality
attributes: latency targets, availability, consistency needs, scale profile.
Only then sketch bounded contexts and their communication, decide sync vs
async between them, and place the data. Justify each choice against the
qualities you named up front.

Skipping the requirements step produces architecture that solves the wrong
problem — the classic senior-level mistake to avoid.

### 2. What is architectural debt and how do you address it?

**Answer:** Architectural debt is the gap between the boundaries the system
needs today and the boundaries it actually has. It shows up as changes that
touch too many modules, incidents that cross service lines, and teams that
block each other. Unlike code debt, you cannot refactor it inside a single
pull request.

Address it incrementally: identify the highest-friction seam, invest in a
migration path, and pay it down while shipping features. Big-bang rewrites
almost always fail.

### 3. When would you rewrite versus refactor?

**Answer:** Refactor when the boundaries are roughly right but the code inside
them is messy. Rewrite only when the architecture itself is fundamentally
misaligned with the current business — wrong data ownership, wrong
communication model, wrong tenancy — and no amount of internal cleanup will
fix that.

Even then, prefer the **strangler fig** pattern: build the new architecture
alongside the old, migrate slice by slice, and retire the old system when
nothing depends on it.

### 4. How do you document architecture without it going stale?

**Answer:** Keep the durable parts small and closest to reality: a context
diagram, per-service READMEs owned by the team, and architecture decision
records for each significant decision. Anything more detailed will drift.

The senior habit is to document why, not how — the reasoning that will help
future engineers judge whether a decision still applies, even after the code
has changed.

### 5. What is the biggest mistake engineers make when choosing an architecture?

**Answer:** Copying the architecture of a much larger company without their
scale, team size, or operational maturity. Microservices, event sourcing, and
CQRS are appropriate answers to real problems; adopting them prophylactically
adds cost without benefit.

The senior answer is boring on purpose: match the architecture to the current
domain, team, and quality targets, and accept that you will change it as
those change.
