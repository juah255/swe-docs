# Architectural Principles

Architectural principles are heuristics that keep large systems changeable.
They complement class-level principles like SOLID by focusing on how modules
and services fit together.

## Separation of Concerns

Each module should address **one concern**. Business rules, persistence,
transport, and presentation should not be tangled in the same code.

Bad:

```text
OrderController parses HTTP, validates input, runs pricing, writes to the DB,
and formats the response.
```

Better: split into controller, validator, use case, repository, and response
mapper. Each has one reason to change.

## Cohesion and Coupling

- **Cohesion**: how closely related the responsibilities inside a module are.
  High cohesion is good.
- **Coupling**: how tightly modules depend on each other. Low coupling is good.

Aim for **high cohesion within a module, low coupling between modules**. A
module you can describe in one sentence is usually cohesive. A module you can
delete or replace without a chain reaction is loosely coupled.

## Dependency Direction

Dependencies should point **from unstable, changeable code toward stable,
policy code**. In practice: from I/O and frameworks toward the domain, not the
other way around.

```text
HTTP controller -> Use case -> Domain
     ^                ^          |
     |                |          v
Framework         (depends on abstractions, not concrete DB)
```

This is the core idea behind hexagonal and clean architecture and behind the
**Dependency Inversion Principle** at the class level.

## Encapsulation of Change

Group things that change together, and separate things that change for
different reasons. If tax rules and shipping rules change on different
schedules, they should not live in the same module.

## Explicit Boundaries

Every boundary — module, service, or team — should have an explicit contract:
inputs, outputs, ownership, and failure modes. Implicit boundaries turn into
shared mutable state and cross-team incidents.

## Reversibility

Prefer decisions you can undo. Two-way doors (a library choice, an internal
file layout) can be revisited cheaply. One-way doors (public API contracts,
data models, authentication schemes) deserve much more thought.

## Fail Fast, Fail Safe

Fail fast at boundaries: validate input, reject malformed requests
immediately, and surface configuration errors at startup. Fail safe in the
runtime: contain failures, degrade gracefully, and never let one module take
down the whole system.

## Least Knowledge (Law of Demeter)

A module should talk only to its direct collaborators. Deep chains like
`order.getCustomer().getAddress().getCity()` couple you to the entire object
graph and break when anything in the chain changes.

## Design for Observability

Every non-trivial component should emit **logs, metrics, and traces** that let
operators answer: is it up, is it fast enough, is it correct? Observability
that is bolted on after an incident is always incomplete.

## Design for Failure

Assume every dependency will fail eventually: network calls time out,
databases lose connections, queues back up. Bake in timeouts, retries with
backoff, circuit breakers, idempotency, and graceful degradation.

## Principles vs Rules

These are heuristics, not laws. Every one of them has cases where the opposite
is right — for example, tight coupling inside a hot path is sometimes the
correct choice. Senior engineers apply principles with judgment and can
explain the trade-off when they break one.

## Mid/Senior Interview Questions and Answers

### 1. How do cohesion and coupling actually guide your work?

**Answer:** They guide where to draw module boundaries. If two pieces of code
change together every time the business changes, they belong in the same
module (high cohesion). If a module cannot be modified without editing many
others, it is too coupled and the boundary is in the wrong place.

The senior habit is to look at the last few months of pull requests: modules
that always change together should be merged, and modules that touch every
feature should be split.

### 2. Why does dependency direction matter?

**Answer:** Dependencies constrain change. If the domain depends on the ORM,
you cannot change the ORM without changing the domain. If the domain depends
only on interfaces, you can swap the ORM behind a repository adapter.

Pointing dependencies inward — toward stable policy, away from unstable I/O —
lets the business logic live longer than any specific framework or database.

### 3. What does "fail fast" mean at an architectural level?

**Answer:** Detect broken input, missing configuration, and invalid state at
the earliest boundary and stop there. A service should refuse to start with a
missing secret, reject a malformed request at the edge, and validate
invariants at the domain layer rather than deep inside persistence.

The alternative — silently continuing with bad data — turns a clear failure
into a subtle one that only surfaces later as data corruption.

### 4. How do you decide which decisions to reverse-proof?

**Answer:** Ask which decisions become expensive to undo: data models, event
schemas, tenant isolation model, authentication scheme, and public API
contracts. Invest in getting those right and record the reasoning. For
everything else — library choice, folder layout, internal implementation —
prefer the simplest thing that works and expect to change it.

The senior instinct is to identify one-way doors early and treat them with
proportionally more care.

### 5. When is it right to break these principles?

**Answer:** When the cost of following them exceeds the value. Extreme
performance sensitivity may justify tight coupling; a tiny script does not
need layered architecture; a prototype should not be over-abstracted.

The point is to break principles on purpose, with a stated reason and a plan
to revisit, rather than by drift.
