# Domain-Driven Design

**Domain-Driven Design** (`DDD`) is an approach to building software where the
structure of the code closely mirrors the structure of the business domain.
The team, the code, and the conversations all use the same vocabulary.

DDD is most useful when the domain is complex. For simple CRUD, most of DDD is
overhead.

## Ubiquitous Language

Developers, product, and domain experts agree on the meaning of each business
term and use it everywhere: code, database, APIs, docs, and meetings.

If the business says "customer" and code says `user`, `account`, and
`profile` for the same concept, that mismatch will produce bugs and confusion.

## Bounded Contexts

A **bounded context** is a boundary within which a term has one clear meaning.
The same word can mean different things in different contexts.

Example: in an e-commerce system, `Product` in the **Catalog** context
(pricing, images, description) is a different model from `Product` in the
**Inventory** context (stock levels, warehouses, reorder point).

```text
+------------------+   +-------------------+   +-----------------+
|   Catalog        |   |    Inventory      |   |    Shipping     |
|   Product        |   |    Product        |   |    Package      |
|   Price, Media   |   |    Stock, Warehouse|  |    Weight, Route|
+------------------+   +-------------------+   +-----------------+
```

Bounded contexts are the natural seams for microservices, teams, and
databases.

## Building Blocks

### Entity

An object with a distinct identity that persists over time. Two entities with
the same fields but different IDs are different.

```text
Order #42 and Order #43 are different orders,
even if they contain the same items.
```

### Value Object

An object defined only by its attributes, with no identity. Value objects are
immutable and safely shareable.

```text
Money(100, "USD")
Address("15 Rue Cler", "Paris")
```

Two `Money(100, "USD")` values are interchangeable.

### Aggregate

A cluster of entities and value objects treated as a single unit for changes.
Each aggregate has one **aggregate root** — the only entry point for
modification — and enforces its own invariants.

```text
Order (root)
  ├── OrderLine (entity)
  ├── OrderLine (entity)
  └── ShippingAddress (value object)
```

Rules:

- Load and save the aggregate as a whole.
- External code changes the aggregate only through the root.
- Transactions do not span aggregates.

### Repository

An abstraction for loading and saving aggregates. The domain depends on the
`OrderRepository` interface; a SQL, NoSQL, or in-memory implementation lives
in infrastructure.

### Domain Service

Business behavior that does not naturally belong to a single entity or value
object. Example: a `PricingService` that combines catalog rules, promotions,
and taxes.

### Domain Event

Something meaningful that happened in the domain, expressed in past tense:
`OrderPlaced`, `PaymentFailed`, `StockDepleted`. Events let other parts of the
system react without the origin knowing about them.

## Strategic Design

Strategic design is DDD at the system level: identifying contexts and how they
relate.

- **Context map**: a diagram of every bounded context and the relationships
  between them.
- **Anticorruption layer** (`ACL`): a translation layer between contexts so
  changes in one do not force changes in the other. Common when integrating
  with a legacy system.
- **Shared kernel**: a small shared model used by multiple contexts. Powerful
  but risky, since changes affect every consumer.
- **Published language**: a stable, documented format (e.g. an event schema)
  used to communicate between contexts.

## Tactical Design

Tactical design is DDD inside a single context: entities, value objects,
aggregates, services, repositories, and events. It is where the code actually
lives.

## When DDD Helps

- The domain has non-trivial rules that change often.
- Business experts and engineers need to collaborate closely.
- The system will live for years and cross many teams.
- Bounded contexts naturally suggest service or team boundaries.

## When DDD Is Overkill

- Simple CRUD with no meaningful invariants.
- Prototypes and short-lived tools.
- Small systems built by one or two engineers.

Using aggregates and repositories for a to-do list adds ceremony without
value.

## Common Mistakes

- Anemic domain models: entities that are just data bags with no behavior.
- Aggregates that span the entire schema, killing performance.
- Ignoring the ubiquitous language and letting technical terms leak into
  business conversations.
- Applying DDD tactically without doing the strategic work first.
- Treating every table as an aggregate.

## Mid/Senior Interview Questions and Answers

### 1. What is a bounded context and why does it matter?

**Answer:** A bounded context is the scope within which a domain term has one
consistent meaning and one model. It matters because business words like
`customer`, `order`, or `product` almost always mean subtly different things
in different parts of the business, and forcing them into a shared model
produces bloated, brittle code.

Bounded contexts are also the natural seams for teams, databases, and
services. Getting them right is the single highest-leverage DDD decision.

### 2. What is an aggregate and how do you choose its boundary?

**Answer:** An aggregate is a cluster of entities and value objects that must
change together to preserve business invariants, with one root as the only
entry point. The boundary is chosen so that a single transaction can enforce
all rules inside it, and rules across aggregates are handled asynchronously.

Choose small aggregates. Large aggregates lock too much data, hurt
concurrency, and pull unrelated concepts together. If two things do not need
to be consistent inside one transaction, they belong in separate aggregates.

### 3. What is an anemic domain model and why avoid it?

**Answer:** An anemic model has entities that are pure data containers, with
all behavior in service classes. The result looks object-oriented but reads
like procedural code, and business rules end up scattered across many
services.

The fix is to put behavior on the entity or aggregate that owns the data, so
invariants are enforced at the source. Services should coordinate use cases,
not replace domain logic.

### 4. When would you not use DDD?

**Answer:** When the domain is thin. Straightforward CRUD, admin panels,
scripts, and short-lived tools do not benefit from aggregates, repositories,
and events. The overhead is real and the payoff — protecting complex
invariants and enabling long-term evolution — never materializes.

Reach for DDD when the business rules are complex, likely to keep changing,
and worth talking about with domain experts in a shared language.

### 5. How does DDD relate to microservices?

**Answer:** Bounded contexts are natural microservice boundaries: each context
owns its model and its data, and communicates with others through explicit
contracts or events. Splitting services without first understanding the
domain almost always produces the wrong boundaries.

DDD does not require microservices, though. A well-modeled modular monolith
with clean bounded contexts is often a better place to start, and services
can be extracted later along boundaries that have already proved themselves.
