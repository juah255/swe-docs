# FastAPI

FastAPI patterns, routing conventions, and service examples.

## Core Concepts

### What is FastAPI?

FastAPI is a lightweight Python framework for building APIs. It is built on top
of Starlette and Pydantic.

- **Starlette** handles the web/server layer, including routing, requests,
  responses, middleware, WebSockets, and background tasks.
- **Pydantic** handles data validation, parsing, and serialization.

### What is Starlette?

Starlette is a lightweight ASGI web framework used to build async web
applications in Python.

ASGI means **Asynchronous Server Gateway Interface**. It is a standard interface
that connects Python web applications with async web servers.

An async web server can handle many requests efficiently by not waiting idly
while one request is doing slow I/O work, such as database queries, HTTP calls,
or file operations.

### What is `Depends()`?

`Depends()` is FastAPI's dependency injection mechanism. It allows routes to
reuse logic such as database sessions, authentication, permission checks, or
common query parameters.

### FastAPI vs Django

FastAPI is lightweight and mainly focused on APIs. Django is a full-stack
framework with a built-in ORM, admin panel, authentication, forms, and
templating.

FastAPI is often a strong fit for high-performance APIs and microservices.
Django is often a strong fit when a product benefits from built-in full-stack
features and convention-heavy application structure.

## Mid/Senior Interview Questions and Answers

### 1. What makes FastAPI different from many older Python web frameworks?

**Answer:** FastAPI is built around type hints, automatic request validation,
OpenAPI generation, dependency injection, and ASGI support for async workloads.

The senior detail is that type hints improve developer tooling and schema
generation, but runtime validation still depends on request models and boundary
checks.

### 2. When should a FastAPI endpoint be `async`?

**Answer:** Use `async` when the endpoint awaits non-blocking I/O such as async
database drivers, HTTP clients, or queues. A route that calls blocking libraries
inside `async` can still block the event loop.

For blocking CPU work, use worker processes, task queues, or thread/process
offloading depending on workload.

### 3. How should dependencies be used in FastAPI?

**Answer:** Dependencies should provide reusable request-scoped behavior such as
database sessions, authentication, authorization, configuration, and service
objects.

Keep dependencies focused. A deeply nested dependency graph can make request
flow hard to understand and test.

### 4. How do you structure a production FastAPI app?

**Answer:** Separate routers, schemas, services, repositories, configuration,
database setup, and external integrations. Keep route functions thin and move
business logic into testable services.

Production concerns include ASGI server configuration, timeouts, connection
pooling, migrations, structured logging, metrics, and health checks.
