# APIs and Communication

This section covers core backend communication concepts:

- HTTP methods and REST basics
- WebSockets and real-time communication
- Authentication and authorization
- JWT, access tokens, and refresh tokens
- Middleware, controllers, services, and repositories
- Common interview-style API questions

## Mid/Senior Interview Questions and Answers

### 1. How do you choose between REST, GraphQL, and gRPC?

**Answer:** REST is a strong default for resource-oriented public APIs. GraphQL
helps when clients need flexible selection across related data, but it adds
schema, authorization, caching, and query-cost concerns. gRPC is useful for
service-to-service communication where strict contracts and efficient binary
payloads matter.

Choose based on client needs, operational maturity, compatibility, and
debuggability rather than popularity.

### 2. What makes an API contract maintainable?

**Answer:** A maintainable API has stable resource names, clear request and
response schemas, consistent errors, documented status codes, validation rules,
versioning policy, and backward-compatible evolution.

Breaking changes should be rare and deliberate. Additive changes are usually
safer than changing field meaning or removing behavior.

### 3. How should APIs protect themselves under load?

**Answer:** Use rate limiting, request size limits, timeouts, pagination,
backpressure, authentication, caching, and circuit breakers for dependencies.

Senior-level API design also includes graceful degradation and clear error
responses so clients can retry safely when appropriate.

### 4. What should be considered when designing API authorization?

**Answer:** Authorization should account for identity, role, resource ownership,
tenant, action, resource state, and business policy.

Do not rely only on frontend checks. Every protected backend route must enforce
authorization at the server boundary or service layer.
