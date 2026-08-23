# API

An **Application Programming Interface** defines how software components
communicate. An API is a contract: it specifies operations, inputs, outputs,
errors, authentication, and behavioral guarantees that clients can depend on.

## API Styles

### REST

REST APIs model data and behavior as resources accessed through HTTP methods.
They are widely supported, easy to inspect, and work well with HTTP caching and
infrastructure.

```http
GET    /users/42
POST   /orders
PATCH  /orders/981
DELETE /sessions/current
```

### GraphQL

GraphQL exposes a typed schema and allows clients to request specific fields.
It is useful when clients need different views of connected data. Servers must
control query depth, complexity, authorization, and N+1 database queries.

### gRPC

gRPC uses Protocol Buffers and HTTP/2. It provides strongly typed contracts,
code generation, streaming, and efficient binary messages. It is common for
internal service-to-service communication but is less convenient for direct
browser use and manual inspection.

### Webhooks

A webhook is an HTTP callback sent when an event occurs. Webhook consumers must
verify signatures, handle duplicates, return quickly, and process events
idempotently.

## Resource and Route Design

Use nouns for resources and HTTP methods for actions:

```text
GET  /users/42/orders
POST /users/42/orders
GET  /orders/981
```

Use action endpoints when the operation is not naturally CRUD:

```text
POST /orders/981/cancel
POST /reports/quarterly/generate
```

Routes should be predictable. Avoid exposing database table names or deeply
nested paths that couple the public contract to internal storage.

## Request and Response Contracts

Validate requests at the API boundary. Define:

- Required and optional fields
- Data types and allowed values
- String, number, and collection limits
- Unknown-field behavior
- Date, time, identifier, and currency formats
- Nullability and default values

Do not return database entities directly. Response DTOs prevent accidental
exposure of internal fields and allow storage models to evolve independently.

```json
{
  "id": "ord_981",
  "status": "pending",
  "total": {
    "amount": "49.90",
    "currency": "USD"
  }
}
```

Use strings or integer minor units for money. Binary floating-point values can
introduce rounding errors.

## Error Design

Errors should be consistent and useful to both clients and operators:

```json
{
  "error": {
    "code": "insufficient_inventory",
    "message": "The requested quantity is unavailable.",
    "details": {"product_id": 42},
    "request_id": "req_7fd31"
  }
}
```

Use stable machine-readable codes. Do not expose stack traces, SQL errors,
secret values, or internal service details.

## Authentication and Authorization

Authentication establishes identity. Authorization decides what that identity
may do.

Common authentication mechanisms include:

- Server-side sessions stored behind secure cookies
- OAuth 2.0 access tokens
- OpenID Connect identity tokens and flows
- API keys for identifying applications
- Mutual TLS for service identity

Authorization should be enforced for each protected resource and action. A
valid token does not imply access to every object.

## Pagination, Filtering, and Sorting

```http
GET /orders?status=paid&sort=-created_at&limit=25&cursor=eyJpZCI6OTgxfQ
```

Offset pagination is simple but can become slow and inconsistent as rows are
inserted or removed. Cursor pagination performs better for large, changing
datasets when it uses a stable, deterministic sort order.

Always enforce a maximum page size and allowlist sortable and filterable fields.

## Idempotency

An idempotent operation can be repeated without changing its intended final
effect. `GET`, `PUT`, and `DELETE` are idempotent by HTTP semantics, although
responses may differ between calls.

Important `POST` operations can support an idempotency key:

```http
POST /payments
Idempotency-Key: 0f92785d-48e1-4e74-9059-47481847dded
```

The server stores the key, request fingerprint, and result. A retry with the
same key returns the original result. A database unique constraint should
protect against concurrent duplicate requests.

## Concurrency Control

Two clients may read the same resource and overwrite each other's changes.
Optimistic concurrency uses a version or ETag:

```http
PATCH /documents/42
If-Match: "version-7"
```

The server applies the update only if the version still matches. Otherwise, it
returns a conflict or precondition failure so the client can refresh.

## API Versioning and Compatibility

Versioning approaches include URL versions such as `/v1/orders`, headers, and
media types. Version only when the contract requires a breaking change.

Prefer backward-compatible evolution:

- Add optional fields instead of changing existing meanings
- Do not remove or rename fields without a migration period
- Accept old enum values while clients migrate
- Publish deprecation and removal dates
- Measure usage before removing an endpoint

Clients should generally ignore unknown response fields so additive changes do
not break them.

## Rate Limiting

Rate limits protect capacity and enforce fair use. Limits may apply per user,
API key, IP address, tenant, endpoint, or cost unit.

Common algorithms include fixed window, sliding window, token bucket, and
leaky bucket. A limited response normally uses `429 Too Many Requests` and may
include `Retry-After` and quota headers.

Rate limiting is not enough for expensive APIs. Also enforce input-size limits,
query complexity limits, concurrency limits, and timeouts.

## API Architecture

A common request flow is:

```text
Router -> middleware -> controller -> application service -> repository
```

- **Middleware** handles cross-cutting concerns such as tracing and authentication.
- **Controller** translates transport input and output.
- **Application service** coordinates business use cases.
- **Repository** abstracts persistence operations.
- **Domain model** owns core business rules and invariants.

Database constraints remain necessary for integrity under concurrency, even
when validation also exists in the application.

## Documentation and Contracts

OpenAPI documents HTTP APIs in a machine-readable format. It can drive
interactive documentation, validation, SDK generation, and contract tests.

Documentation should include authentication, examples, error formats,
pagination, rate limits, retry behavior, and lifecycle policies. A list of
routes alone is not a complete API contract.

## Observability

Measure API request rate, error rate, and latency. Logs and traces should include
request IDs, authenticated subject or tenant identifiers where appropriate,
route templates, status codes, and dependency timing.

Do not use raw URLs as metric labels when they contain resource identifiers;
this creates high-cardinality metrics. Record `/users/{id}` instead of
`/users/849213`.

## Mid/Senior Interview Questions and Answers

### 1. How do you evolve an API without breaking clients?

**Answer:** Prefer additive changes, keep existing field meanings stable, make
new inputs optional, and support old behavior during a documented migration
period. Use usage telemetry and contract tests before removing anything.

### 2. When should an API return `202 Accepted`?

**Answer:** Return `202` when the request is accepted but processing will finish
asynchronously. Provide a job or resource URL where the client can observe
status, result, failure, and cancellation behavior.

### 3. How do you prevent one tenant from accessing another tenant's data?

**Answer:** Derive tenant identity from trusted authentication context, scope
every query and cache key by tenant, enforce authorization in application
services, and add database protections where possible. Never trust a tenant ID
from the request body without checking it against the authenticated identity.

### 4. REST, GraphQL, or gRPC: how do you choose?

**Answer:** Choose based on consumers and operational needs. REST is broadly
interoperable, GraphQL supports flexible client-driven reads, and gRPC provides
efficient typed service communication and streaming. Team capability,
debuggability, caching, browser support, and security controls matter as much as
raw performance.
