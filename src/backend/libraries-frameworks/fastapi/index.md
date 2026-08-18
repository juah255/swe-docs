# FastAPI

FastAPI is a lightweight, high-performance Python framework for building APIs. It is built on top of Starlette (ASGI web layer) and Pydantic (validation/serialization), and it generates OpenAPI documentation automatically from Python type hints.

## Topics

| # | Topic | What you will learn |
|---|-------|---------------------|
| 1 | [Fundamentals](fundamentals.md) | ASGI, Starlette, path operations, OpenAPI, uvicorn |
| 2 | [Pydantic & Data Validation](pydantic.md) | BaseModel, Field, validators, settings, Pydantic v2 |
| 3 | [Dependency Injection](dependency-injection.md) | Depends(), nested deps, overrides for testing |
| 4 | [Request & Response Handling](request-response-handling.md) | Headers, cookies, forms, uploads, streaming, errors |
| 5 | [Routing & Application Structure](routing-and-structure.md) | APIRouter, prefixes, tags, project organization |
| 6 | [Database Integration](database-integration.md) | SQLAlchemy 2.x, asyncpg, sessions, migrations, CRUD |
| 7 | [Authentication & Authorization](authentication-and-authorization.md) | OAuth2, JWT, cookies, RBAC, protecting routes |
| 8 | [Async Programming](async-programming.md) | Event loop, coroutines, blocking vs non-blocking I/O |
| 9 | [Middleware & Request Lifecycle](middleware-and-lifecycle.md) | CORS, custom middleware, timing, exception middleware |
| 10 | [Background Tasks & Job Queues](background-tasks-and-queues.md) | BackgroundTasks, Celery, Redis, RabbitMQ, cron |
| 11 | [Testing](testing.md) | pytest, TestClient, overrides, mocking, integration tests |
| 12 | [API Design](api-design.md) | REST, pagination, filtering, versioning, idempotency |
| 13 | [Performance & Scalability](performance-and-scalability.md) | Uvicorn/Gunicorn, workers, caching, N+1, Nginx |
| 14 | [Production & Deployment](production-and-deployment.md) | Docker, HTTPS, logging, health checks, CI/CD |
| 15 | [Advanced FastAPI](advanced-fastapi.md) | WebSockets, SSE, custom OpenAPI, microservices, gRPC |

## Recommended learning order

```
1. FastAPI Fundamentals
        ↓
2. Pydantic
        ↓
3. Request/Response Handling
        ↓
4. Dependency Injection
        ↓
5. Routing & Project Structure
        ↓
6. SQLAlchemy + PostgreSQL
        ↓
7. Authentication & Authorization
        ↓
8. Async Programming
        ↓
9. Middleware & Lifecycle
        ↓
10. Background Tasks / Celery
        ↓
11. Testing
        ↓
12. REST API Design
        ↓
13. Performance & Scalability
        ↓
14. Docker + Nginx + Deployment
        ↓
15. Advanced FastAPI
```

## What is most important for getting job-ready

**Must know:** FastAPI fundamentals, Pydantic, dependency injection, SQLAlchemy,
PostgreSQL, authentication/JWT, async programming, API design, testing, Docker,
deployment.

**Learn afterward:** Redis, Celery, WebSockets, advanced middleware, performance
optimization, microservices.

**Specialized:** gRPC, SSE, event-driven architecture, advanced OpenAPI
customization.

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

### 5. Why does marking an endpoint `async def` not automatically make it scalable?

**Answer:** `async def` only lets the event loop interleave work while the
handler awaits. If anything inside the handler blocks - a sync database driver,
`requests.get`, file reads - the event loop stalls for that whole duration and
every concurrent request sharing the loop queues behind it.

For real scalability the whole path must be async end to end: async database
drivers (asyncpg, SQLAlchemy `AsyncSession`), async HTTP clients
(`httpx.AsyncClient`), and connection pooling. CPU-bound work should be
offloaded to a task queue such as Celery, not run on the event loop.