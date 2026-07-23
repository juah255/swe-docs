# Architectural Styles

An **architectural style** is a proven way of organizing components and their
interactions. No style is universally best; each optimizes for a different set
of qualities and pays for it elsewhere.

## Layered Architecture

Also called **n-tier**. Code is organized into layers with a strict dependency
direction, typically top-down.

```text
Presentation  (controllers, UI)
     |
Application   (use cases, orchestration)
     |
Domain        (business rules)
     |
Infrastructure (DB, HTTP clients, queues)
```

- **Strengths**: simple, familiar, easy for new engineers to navigate.
- **Weaknesses**: business logic often leaks into upper layers; the domain
  ends up depending on the database framework.
- **Use when**: small to medium applications with a straightforward domain.

## Hexagonal Architecture (Ports and Adapters)

The domain sits in the center. It exposes **ports** (interfaces) and outer
**adapters** implement them for HTTP, databases, queues, and external APIs.

```text
        HTTP adapter        CLI adapter
              \               /
               \             /
                +----Domain----+
               /             \
              /               \
        SQL adapter       Queue adapter
```

- **Strengths**: domain is independent of frameworks and I/O; easy to test with
  fake adapters.
- **Weaknesses**: more indirection; overkill for CRUD.
- **Use when**: business rules are non-trivial and you want long-term
  testability and framework independence.

## Onion Architecture

A close cousin of hexagonal. Concentric layers surround a domain core, and
dependencies always point **inward**.

```text
+---------------------------------------+
|   Infrastructure (DB, HTTP, queues)   |
|   +-------------------------------+   |
|   |   Application (use cases)     |   |
|   |   +-----------------------+   |   |
|   |   |   Domain Services     |   |   |
|   |   |   +---------------+   |   |   |
|   |   |   |    Domain     |   |   |   |
|   |   |   |    Model      |   |   |   |
|   |   |   +---------------+   |   |   |
|   |   +-----------------------+   |   |
|   +-------------------------------+   |
+---------------------------------------+
```

- **Strengths**: strong isolation of the domain; infrastructure is
  interchangeable; very testable.
- **Weaknesses**: more indirection than layered; similar cost profile to
  hexagonal and clean.
- **Use when**: the domain deserves protection from framework and I/O
  churn.

Onion, hexagonal, and clean architecture are variations of the same idea:
**the domain in the center, dependencies pointing inward**. Teams often
blend them and call the result whatever fits their vocabulary.

## Clean Architecture

A refinement of hexagonal with explicit **use case** and **entity** layers.
Dependencies always point inward toward the domain.

```text
Frameworks & Drivers (outermost)
  Interface Adapters
    Application (use cases)
      Entities (innermost, pure domain)
```

- **Strengths**: strong separation, testable core, resistant to framework
  churn.
- **Weaknesses**: many files and mappings; risks abstraction for its own sake.
- **Use when**: long-lived systems where the domain is the crown jewel.

## MVC (Model-View-Controller)

An older but still widespread pattern for organizing user-facing applications.

- **Model**: data and business rules.
- **View**: renders data for the user.
- **Controller**: receives input, coordinates the model, and picks a view.

```text
Request -> Controller -> Model -> Controller -> View -> Response
```

- **Strengths**: familiar, well-supported by frameworks (Rails, Spring MVC,
  Laravel, ASP.NET), clear separation for web apps.
- **Weaknesses**: "model" often becomes a dumping ground; controllers grow
  fat; not enough structure for complex domains.
- **Use when**: server-rendered web apps or APIs where the domain is not
  deep.

### MVC Variants

| Pattern | Where the logic lives | Common in |
| --- | --- | --- |
| **MVC** | Controller coordinates model and view | Rails, Spring MVC |
| **MVP** (Model-View-Presenter) | Presenter mediates all view logic | Legacy desktop, Android |
| **MVVM** (Model-View-ViewModel) | ViewModel exposes state via bindings | WPF, Vue, Knockout |

For backend APIs, **MVC without the V** is the typical layout: a controller
receives HTTP, calls a service, returns JSON. Views live in the frontend.

## Event-Driven Architecture

Components communicate by producing and consuming **events** on a broker
(Kafka, RabbitMQ, SNS/SQS). Producers do not know the consumers.

```text
Order Service -> "OrderPlaced" event -> [Inventory, Billing, Email]
```

- **Strengths**: loose coupling, natural async processing, easy to add new
  consumers.
- **Weaknesses**: harder to trace end-to-end; eventual consistency; needs
  schema management, idempotency, and dead-letter handling.
- **Use when**: multiple independent reactions to a domain event, spiky loads,
  or bridging services.

## CQRS (Command Query Responsibility Segregation)

Separate the **write model** (commands that change state) from the **read
model** (queries optimized for display).

```text
Command side               Query side
-----------                ----------
POST /orders  -> writes -> events -> projections -> GET /orders
```

- **Strengths**: read and write can scale and evolve independently; complex
  reporting stops distorting the write model.
- **Weaknesses**: two models to maintain; reads are eventually consistent.
- **Use when**: read and write patterns diverge sharply, or you already use
  event sourcing.

## Event Sourcing

State is stored as an ordered **log of events** rather than the current row.
The current state is rebuilt by replaying events.

- **Strengths**: perfect audit history, natural time-travel debugging, aligns
  well with CQRS.
- **Weaknesses**: schema evolution of events is painful; queries need
  projections; not a fit for simple CRUD.
- **Use when**: audit and history matter (finance, medical, workflow engines).

## Microservices

**Microservices:** It is a software architectural style where the backend application is split into multiple independent services, and each service can be developed, deployed, and scaled independently.

The system is a set of small, independently deployable services, each owning
its data.

- **Strengths**: independent deployment, scaling, and team ownership; fault
  isolation.
- **Weaknesses**: distributed-system complexity — network failures, eventual
  consistency, observability overhead.
- **Use when**: the domain has clear bounded contexts, teams need
  independence, or parts of the system have very different scale profiles.

See also [System Design → Microservices](../system-design/microservices.md).

## Monolith

**Monolith:** It is a software architectural style where the entire application is built as a single unit and all of its components are developed, deployed, and scaled together.

A single deployable that contains the whole application, usually against a
single database.

- **Strengths**: simplest to build, deploy, test, and reason about; strong
  consistency by default; one place to look during incidents.
- **Weaknesses**: scaling is all-or-nothing; a bad module can slow the whole
  system; large teams step on each other.
- **Use when**: small teams, early products, or any system where microservices
  cannot be justified. Most companies should start here.

## Modular Monolith

A monolith with **explicit internal module boundaries**. Modules are enforced
in code (packages, namespaces, or build modules), communicate through
well-defined interfaces, and often own their own tables — but everything ships
as one process.

```text
+-------------------------------------------------+
|                    Monolith                     |
|                                                 |
|  +-----------+  +-----------+  +-----------+    |
|  |  Orders   |  |  Billing  |  | Shipping  |    |
|  |           |  |           |  |           |    |
|  |  API      |  |  API      |  |  API      |    |
|  |  Domain   |  |  Domain   |  |  Domain   |    |
|  |  DB tables|  |  DB tables|  |  DB tables|    |
|  +-----------+  +-----------+  +-----------+    |
|                                                 |
+-------------------------------------------------+
```

- **Strengths**: microservice-like separation without the operational cost;
  in-process calls stay fast and consistent; ready to be extracted into
  services later.
- **Weaknesses**: requires discipline — nothing at runtime stops a module from
  reaching into another's internals.
- **Use when**: you want clean domain boundaries and expect to grow, but do
  not want to pay for a distributed system yet. This is the sensible default
  for most systems that outgrow a plain monolith.

Modular monolith is often the honest answer when someone asks about
microservices. It captures most of the design benefit at a fraction of the
operational cost.

## Serverless

Business logic runs as short-lived functions triggered by events, with the
platform managing servers, scaling, and idle cost.

- **Strengths**: no server management, granular billing, effortless scale-out.
- **Weaknesses**: cold starts, vendor lock-in, limited runtime, harder local
  development.
- **Use when**: spiky or event-driven workloads, glue code, cron jobs, and
  lightweight APIs.

## Comparison

| Style | Coupling | Complexity | Best for |
| --- | --- | --- | --- |
| Layered | Medium | Low | Standard CRUD applications |
| MVC | Medium | Low | Server-rendered web apps and simple APIs |
| Hexagonal | Low | Medium | Rich domain, long-lived core |
| Onion | Low | Medium | Same as hexagonal, concentric framing |
| Clean | Very low | Medium-High | Framework-independent core |
| Event-driven | Very low | High | Async workflows, fan-out |
| CQRS | Low | High | Divergent read/write needs |
| Event sourcing | Low | Very high | Audit-heavy domains |
| Microservices | Very low | Very high | Independent teams and scaling |
| Monolith | High | Low | Small teams, early products |
| Modular monolith | Medium | Low-Medium | Most systems past the earliest stage |
| Serverless | Low | Medium | Event-driven, spiky workloads |

## Mid/Senior Interview Questions and Answers

### 1. How do you choose an architectural style?

**Answer:** Start from the domain, the team, and the qualities that matter
most. A small team shipping a straightforward product should default to a
modular monolith. Reach for hexagonal or clean when the domain is complex and
long-lived. Reach for events, CQRS, or microservices only when a concrete
problem — team independence, scale profile, integration surface — justifies the
cost.

The wrong question is "what style is best." The right question is "which
change do we need to make cheap, and which are we willing to pay for later?"

### 2. When is hexagonal architecture worth its cost?

**Answer:** When the domain has meaningful rules and you expect the
infrastructure around it to change: databases swapped, HTTP replaced with
messaging, or the same use cases exposed through different channels.

For pure CRUD, ports and adapters mostly add ceremony. The value shows up when
you can run domain tests without any framework and swap infrastructure without
rewriting business logic.

### 3. What are the real costs of microservices?

**Answer:** Network calls fail; every service boundary becomes an availability
and latency multiplier. Data ownership and cross-service consistency require
sagas or eventual consistency. Observability, deployment coordination, schema
management, and on-call load all grow.

Microservices are worth it when independent scaling, deployment, and ownership
outweigh those costs. If the answer is unclear, keep a modular monolith and
extract services when a boundary proves itself.

### 4. What problems does event-driven architecture actually solve?

**Answer:** It decouples producers from consumers and lets independent
reactions to a business event evolve separately. It handles spiky load through
buffering and enables fan-out to many consumers without changing the producer.

It introduces its own problems: eventual consistency, out-of-order and
duplicate delivery, schema evolution, and end-to-end tracing. It is a fit when
those trade-offs are worth the decoupling, not as a default.

### 5. When would you use CQRS and event sourcing?

**Answer:** Use CQRS when read and write shapes diverge sharply — for example,
a write model that enforces invariants and a read model optimized for
dashboards or search. Use event sourcing when the history itself is valuable,
such as ledgers, workflows, or auditable state.

Both add real complexity: multiple models, projections, event schema
migration. They are powerful in the right domain and expensive in the wrong
one.
