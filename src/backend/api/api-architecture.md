# API Architecture

## Middleware

**Middleware** is reusable code that runs between a request and a response to handle common tasks such as:

- Authentication
- Logging
- Validation
- Error handling

## Controller

A **controller** handles the incoming request, calls the necessary business logic or service, and returns the response.

## Service, Provider, Repository

### Service

A **service** is a backend class or module that contains application business logic.

### Provider

A **provider** is a reusable class that contains shared logic or functionality and can be injected into other parts of the application through dependency injection.

All services can be providers, but not all providers are services.

### Repository

A **repository** is a data access layer abstraction used to read from and write to a data source, usually a database.

## Business Logic

**Business logic** is the set of rules that defines how an application behaves according to real-world business requirements.

Example:

> A customer should not be able to order a product if it is out of stock.

The implementation that enforces that rule is business logic.

## DTO

A **DTO** (Data Transfer Object) is an object used to carry data between layers or systems.

DTOs are commonly used for:

- Validation
- Type safety
- Cleaner code boundaries
- Controlling what data enters or leaves the application

## Mid/Senior Interview Questions and Answers

### 1. What should middleware handle, and what should it avoid?

**Answer:** Middleware should handle cross-cutting request concerns such as
authentication, request IDs, logging, CORS, rate limiting, parsing, and common
validation. It should avoid business decisions that belong to application
services.

At senior level, middleware should be predictable, ordered carefully, and cheap
to run. Expensive database calls or business workflows in global middleware can
make every request slower and harder to debug.

### 2. What is the responsibility of a controller?

**Answer:** A controller translates HTTP input into application calls and
translates application results into HTTP responses. It should parse route
parameters, validate request DTOs, call services, and return status codes and
response bodies.

Controllers should not contain complex business logic. Keeping them thin makes
API behavior easier to test and allows the same business logic to be reused from
jobs, events, CLIs, or other transports.

### 3. How do services and repositories differ?

**Answer:** A service owns business use cases and coordinates rules. A
repository owns data access and persistence details.

For example, `OrderService.placeOrder()` may validate inventory, call payment,
create an order, and publish an event. `OrderRepository` should focus on
loading and saving orders. Mixing these roles creates code that is hard to test
and hard to change when the database or business process changes.

### 4. Why are DTOs useful in API design?

**Answer:** DTOs define what data is accepted or returned at an API boundary.
They protect internal models from leaking into public contracts and make
validation explicit.

Senior teams often separate request DTOs, response DTOs, domain models, and
database entities. This avoids accidental exposure of internal fields such as
password hashes, flags, or implementation-specific relationships.

### 5. Where should business logic live in a layered backend?

**Answer:** Business logic should live in domain or application services, not in
controllers, middleware, repositories, or database triggers by default.

Some invariants should still be enforced by database constraints. Application
logic and database constraints work together: the application gives clear
behavior and errors, while the database protects integrity under concurrency or
unexpected code paths.
