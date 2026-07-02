# Software Architecture

**Software architecture** is the set of high-level decisions that shape a
system: its major components, how they communicate, where state lives, and
which qualities the system must uphold. Good architecture makes some changes
easy and consciously accepts that others will be hard.

Architecture is not the same as design. **Design** decides how a class or
module is built; **architecture** decides which modules exist, who owns which
data, and how they interact.

## What Architecture Decides

- **Component boundaries**: which modules or services exist and what each owns.
- **Communication style**: synchronous calls, async messages, events, or a mix.
- **Data ownership**: which component is the source of truth for each piece of
  data.
- **Cross-cutting concerns**: authentication, logging, tracing, error handling,
  configuration.
- **Quality attributes**: performance, availability, security, scalability,
  maintainability, and their trade-offs.

## Architecture vs Design vs System Design

| Level | Concern | Example question |
| --- | --- | --- |
| **Architecture** | Structure and qualities of the whole system | Should this be one service or three? |
| **System Design** | How the architecture meets scale and reliability targets | How do we handle `100k` writes per second? |
| **Design** | Internal structure of a module or class | How do I model `Order` status transitions? |

## Subtopics

- **Architectural Styles**: layered, MVC, hexagonal, onion, clean, modular
  monolith, event-driven, CQRS, microservices, and where each fits.
- **Building Blocks**: the components most systems are made of — controller,
  service, repository, entity, DTO, middleware, and how they fit together.
- **Principles**: separation of concerns, dependency direction, cohesion and
  coupling, boundaries.
- **Domain-Driven Design**: modeling around the business domain with
  aggregates, bounded contexts, and a ubiquitous language.
- **Quality Attributes**: the "-ilities" architecture must reason about
  explicitly.
- **Questions**: reference Q&A for common architecture interview topics.

## Why Architecture Matters

- Changing architecture is far more expensive than changing code.
- Architectural choices constrain team structure, deployment, and testing.
- Most system failures at scale are architectural (wrong boundaries, wrong
  ownership) rather than algorithmic.

Senior engineers make architecture decisions **reversible where possible** and
**explicit where not**, and record the reasoning so future changes are informed.

## Common Mistakes

- Choosing microservices before the domain is understood.
- Copying an architecture from a much larger company.
- Optimizing for scale the system will never reach.
- Confusing framework structure with architecture.
- Skipping cross-cutting concerns until they become incidents.

## Mid/Senior Interview Questions and Answers

### 1. How do you tell architecture from design?

**Answer:** Architecture is about decisions that are expensive to change:
component boundaries, data ownership, sync vs async communication, and
cross-cutting concerns. Design is about decisions inside those boundaries: class
shape, method contracts, error handling in one module.

A quick test: if changing the decision means coordinating multiple teams,
migrations, or downtime, it is architectural. If one engineer can change it in a
pull request, it is design.

### 2. What does "good architecture" actually mean?

**Answer:** Good architecture makes the changes the business is likely to need
cheap, and states clearly which changes will be expensive. It aligns with team
structure, matches the domain, and reasons explicitly about quality attributes
like availability, latency, and security.

It is not about using the latest style. A boring monolith with clean boundaries
often beats a fashionable microservice mesh that no one can debug.

### 3. How do you evaluate an existing architecture?

**Answer:** Look at where changes actually hurt: which pull requests touch many
modules, which incidents cross service boundaries, which teams block each other.
Compare that to the intended boundaries. Gaps between the two are the real
architectural debt.

Also review data ownership, deployment coupling, failure modes, observability,
and how new engineers describe the system after a month. Their mental model
reveals whether the architecture communicates itself.

### 4. When is it worth investing in architecture up front?

**Answer:** Invest early in the decisions that are hard to reverse: data
ownership, service boundaries, authentication and authorization model, event
schemas, and multi-tenant isolation. Delay decisions that are cheap to change,
like specific libraries, internal file layout, or one endpoint's response shape.

The senior habit is to identify which decisions are one-way doors and get those
right, while keeping two-way doors flexible.
