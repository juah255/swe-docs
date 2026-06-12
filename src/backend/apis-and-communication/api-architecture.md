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
