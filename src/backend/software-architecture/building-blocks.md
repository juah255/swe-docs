# Building Blocks

Most backend applications, regardless of style, are assembled from the same
handful of components. Knowing their responsibilities — and where each stops
— keeps modules cohesive and easy to test.

## Request Lifecycle

A typical HTTP request flows through these components in order:

```text
Client
  |
  v
Router  --->  Middleware  --->  Controller
                                    |
                                    v
                                Service (use case)
                                    |
                                    v
                                Repository
                                    |
                                    v
                                Database / External API
```

The response travels back up the same path, often through a **DTO** or
serializer at the controller boundary.

## Router

The **router** maps an HTTP method and path to a handler.

```text
GET  /orders/:id     -> OrderController.show
POST /orders         -> OrderController.create
```

Responsibilities:

- Match method and path.
- Extract path and query parameters.
- Delegate to the right controller method.

The router should not contain business logic. If it grows conditions, they
belong in middleware or controllers.

## Middleware

**Middleware** is code that runs before or after the controller and handles
cross-cutting concerns.

Common middleware:

- Authentication (verify token, load user).
- Authorization (check permissions).
- Request logging and tracing.
- Rate limiting.
- CORS and security headers.
- Request body parsing.
- Error handling and response shaping.

Middleware runs in a pipeline; each step can short-circuit the request
(e.g. an unauthorized user gets a `401` and never reaches the controller).

```text
[log] -> [auth] -> [rate limit] -> [controller] -> [error handler]
```

## Controller

The **controller** is the entry point for a specific use case at the HTTP
layer. It translates between the transport (HTTP) and the application.

Responsibilities:

- Parse and validate input (usually into a DTO).
- Call the appropriate service.
- Map the result to a response DTO and HTTP status.
- Handle errors at the transport layer.

Controllers should be **thin**. Anti-patterns:

- Querying the database directly.
- Enforcing business rules.
- Chaining calls to several services when a single use case would do.

```text
class OrderController:
    def create(request):
        dto = CreateOrderDto.from(request.body)
        order = order_service.place_order(dto, request.user)
        return 201, OrderResponseDto.from(order)
```

## Service

The **service** (also called **application service** or **use case**)
implements one business operation. It orchestrates domain objects and
repositories to fulfill an intent.

Responsibilities:

- Coordinate the steps of a single use case.
- Enforce authorization at the business level.
- Manage transactions.
- Call domain methods and repositories.
- Publish domain events.

A service is not the domain itself — the domain lives in entities and value
objects. The service coordinates them.

```text
class OrderService:
    def place_order(dto, user):
        cart = cart_repo.find_active(user.id)
        order = Order.from_cart(cart, dto.shipping_address)
        order_repo.save(order)
        event_bus.publish(OrderPlaced(order.id))
        return order
```

Anti-patterns:

- **Anemic service**: only forwards to the repository, adding no value.
- **Fat service**: hundreds of lines mixing authorization, validation,
  domain rules, and persistence. Split into smaller use cases.

## Repository

The **repository** abstracts data access. The rest of the application asks
the repository for aggregates without knowing whether they come from
PostgreSQL, Mongo, an HTTP API, or a fake in tests.

Responsibilities:

- Load and save aggregates.
- Translate between domain objects and storage rows.
- Encapsulate query complexity behind meaningful methods.

```text
class OrderRepository:
    def find(id): ...
    def save(order): ...
    def find_pending_for(user_id): ...
```

Anti-patterns:

- Exposing raw SQL or ORM query builders to callers.
- Repository methods that return unrelated joins.
- One giant `Repository` shared across every domain.

The repository interface belongs to the domain. The implementation belongs
to the infrastructure layer.

## Model / Entity

The **model** — or **entity** in DDD vocabulary — represents a domain
concept: `Order`, `User`, `Invoice`. It carries both data **and** behavior.

Responsibilities:

- Hold the state of a domain concept.
- Enforce invariants (`Order.pay()` refuses if already paid).
- Expose meaningful methods, not just getters and setters.

A "model" that has only fields and getters is an **anemic model**. The
behavior ends up scattered across services, which weakens the whole design.

## Value Object

A **value object** is defined only by its attributes and is immutable:
`Money(100, "USD")`, `EmailAddress("a@b.com")`, `DateRange(from, to)`.

Two value objects with the same attributes are interchangeable. They are the
cheapest way to make code express intent (`Money` beats a bare `float`).

## DTO (Data Transfer Object)

A **DTO** carries data across a boundary — usually between the transport
layer and the application, or between services. It has no behavior.

Two common flavors:

- **Request DTO**: parsed from the HTTP body or query, validated at the
  edge.
- **Response DTO**: shaped for the client, hiding internal fields.

```text
CreateOrderDto  -> input DTO
OrderResponseDto -> output DTO
```

Why not return the entity directly? Because leaking internal fields (e.g.
`user.password_hash`) or coupling the API shape to the database schema is a
common source of bugs and security issues.

## Mapper / Serializer

A **mapper** converts between DTOs and domain objects. In simple systems it
lives in the controller; in larger systems it becomes its own module.

Anti-pattern: putting mapping logic inside the entity, which couples the
domain to transport concerns.

## Use Case / Interactor

In clean and hexagonal architecture, a **use case** is a dedicated class per
business operation: `PlaceOrder`, `CancelOrder`, `RefundPayment`. It plays
the same role as a service method, but each use case is its own class with
one `execute()` method.

- **Strengths**: single responsibility, easy to test, easy to compose.
- **Weaknesses**: many small files; can feel ceremonial for simple CRUD.

Choose between "services with methods" and "one class per use case" based on
the domain's complexity and the team's preference. Both are valid.

## Domain Event

A **domain event** is a message expressing that something meaningful
happened: `OrderPlaced`, `PaymentFailed`. Events are named in past tense and
carry the minimal data other components need to react.

- Emitted by the domain or the service that completes the use case.
- Consumed by listeners in the same process (in-memory bus) or by other
  services (message broker).

Events let side effects — email, analytics, downstream updates — evolve
without touching the origin.

## Configuration

**Configuration** — connection strings, feature flags, external URLs — is not
code. It should be:

- Loaded from environment variables or a secret manager.
- Validated at startup (fail fast).
- Accessible through a typed config object, not scattered `getenv()` calls.

## Cross-Cutting: Logging, Metrics, Tracing

These are not layers, they run through every layer:

- **Logging**: structured events with correlation IDs.
- **Metrics**: counters, gauges, histograms for latency and throughput.
- **Tracing**: request paths across services and modules.

Wire them in through middleware and small helpers rather than sprinkling
`log()` calls in the domain.

## How the Pieces Fit

A typical layout for a single use case:

```text
Controller
   \-- calls Service
           \-- uses Repository to load aggregate (Entity)
           \-- calls methods on the aggregate to change state
           \-- uses Repository to save it
           \-- publishes a Domain Event
   \-- maps result to a Response DTO
```

Each component has one job. If a change forces edits to all of them, the
boundaries are probably right. If it forces edits to only one, even better.

## Common Mistakes

- **Fat controllers** that query the database and enforce business rules.
- **Anemic services** that only forward to the repository.
- **Anemic models** with only getters and setters, no behavior.
- **Leaky repositories** that expose ORM types to the rest of the app.
- **Skipping DTOs** and returning ORM entities straight to the client.
- Reaching from a controller into another module's repository, bypassing its
  service.
- Treating middleware as a place to hide business logic.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between a controller and a service?

**Answer:** A controller belongs to the transport layer. Its job is to parse
and validate HTTP input, call the right use case, and shape the response. A
service belongs to the application layer. Its job is to run one business
operation, coordinating domain objects and repositories.

The test is portability: if you had to add a CLI or a gRPC entry point
tomorrow, the service should not have to change; only new controllers would
be added on top.

### 2. Why is the repository pattern useful?

**Answer:** It gives the domain a stable interface for loading and saving
aggregates without knowing the storage technology. Business logic depends on
`OrderRepository`, not on the ORM. That makes the domain testable with fakes
and lets you swap PostgreSQL for something else without rewriting business
rules.

The trade-off is a layer of indirection. It pays for itself when the domain
is non-trivial or the storage is likely to change; for pure CRUD, calling
the ORM directly is often fine.

### 3. What is an anemic domain model and how do you fix it?

**Answer:** An anemic model has entities with only fields and getters, while
all behavior lives in services. The code looks object-oriented but reads
procedurally, and business rules spread across many places.

The fix is to move behavior onto the entity or aggregate that owns the
state. `Order.cancel()` decides whether the order can be canceled and
records the change; the service just orchestrates loading, calling
`cancel()`, and saving. Invariants stay where the data is.

### 4. When would you use DTOs versus returning entities directly?

**Answer:** Use DTOs at every external boundary — HTTP responses, message
payloads, cross-service calls. They let the API shape evolve independently
from the database, and they prevent accidentally leaking internal fields
like password hashes, soft-delete flags, or audit columns.

For small internal helpers where the entity and the payload are naturally
identical, adding a DTO is ceremony. The senior rule is: DTOs at boundaries,
entities inside the domain.

### 5. How thin should a controller be?

**Answer:** Thin enough that reading it tells you what the endpoint does but
not how the business rule works. A controller parses input into a DTO,
delegates to a service, and maps the result to a response. Anything more —
database queries, permission checks beyond authentication, business
decisions — belongs in the service or the domain.

The senior heuristic is that swapping the transport from HTTP to gRPC should
only require rewriting controllers. If it forces changes to services or
entities, the controller is doing too much.
