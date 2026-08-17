# NestJS

NestJS is a progressive Node.js framework for building server-side applications. It is built on top of Express (default) or Fastify and uses TypeScript by default.

It borrows ideas from Angular such as modules, decorators, and dependency injection, which makes application structure predictable across teams.

## Topics

| # | Topic | What you will learn |
|---|-------|---------------------|
| 1 | [Fundamentals](fundamentals.md) | Core architecture, CLI, modules, controllers, providers, DI |
| 2 | [Controllers & HTTP](controllers-and-http.md) | Routing, HTTP methods, parameters, responses, custom decorators |
| 3 | [DTO & Validation](dto-and-validation.md) | DTOs, class-validator, ValidationPipe, transformation, whitelisting |
| 4 | [Database & ORM](database-and-orm.md) | Prisma/TypeORM, entities, migrations, relations, transactions |
| 5 | [Authentication & Authorization](authentication-and-authorization.md) | JWT, guards, roles, permissions, cookies, OAuth basics |
| 6 | [Request Lifecycle](request-lifecycle.md) | Middleware, guards, interceptors, pipes, filters, ExecutionContext |
| 7 | [Advanced Modules & Architecture](advanced-modules.md) | Dynamic modules, custom providers, DI scopes, forwardRef |
| 8 | [API Design](api-design.md) | REST design, versioning, Swagger, serialization, error responses |
| 9 | [Testing](testing.md) | Unit tests, e2e tests, mocking, test databases |
| 10 | [Real-time & Async](realtime-and-async.md) | WebSockets, Socket.IO, BullMQ, queues, cron |
| 11 | [Microservices](microservices.md) | Transport layers, message patterns, event-driven architecture |
| 12 | [Production & Deployment](production-and-deployment.md) | Config, logging, Docker, CI/CD, security, performance |

## Recommended learning order

Follow the topics in order. Fundamentals first, then HTTP, validation, and the database. Authentication and the request lifecycle come after you can build a working CRUD API. Leave microservices for last, once you are comfortable with normal NestJS applications.

```
1. Fundamentals
        ↓
2. Controllers & HTTP
        ↓
3. DTO + Validation
        ↓
4. Database + Prisma
        ↓
5. Authentication + Authorization
        ↓
6. Request Lifecycle (Guards / Pipes / Interceptors / Filters)
        ↓
7. Advanced Modules + DI
        ↓
8. API Design + Swagger
        ↓
9. Testing
        ↓
10. Real-time + Async (Redis + Caching + Queues)
        ↓
11. WebSockets
        ↓
12. Microservices
        ↓
13. Production / Deployment
```

## Mid/Senior Interview Questions and Answers

### 1. What problem does NestJS solve in Node.js backend projects?

**Answer:** NestJS provides a structured application architecture with modules,
controllers, providers, dependency injection, guards, pipes, interceptors, and
filters.

It is useful when a Node.js codebase needs clear boundaries and conventions
similar to enterprise backend frameworks.

### 2. What is the difference between a controller and a provider?

**Answer:** A controller handles incoming transport requests and returns
responses. A provider is an injectable class that implements reusable behavior,
such as services, repositories, clients, or configuration helpers.

Controllers should stay thin. Business logic belongs in services or domain
classes.

### 3. How do guards, pipes, interceptors, and filters differ?

**Answer:** Guards decide whether a request is allowed. Pipes transform or
validate input. Interceptors wrap execution for concerns such as logging,
mapping responses, or timing. Filters handle exceptions and convert them into
responses.

Order and responsibility matter because putting validation, authorization, and
error handling in the wrong layer makes behavior inconsistent.

### 4. How should modules be designed in NestJS?

**Answer:** Modules should group cohesive features and expose only the providers
that other modules need. Avoid a single global module that imports everything.

Feature modules, shared infrastructure modules, and explicit exports keep
dependency direction understandable.