# HTTP and REST

## What is a REST API?

A **REST API** is a **stateless**, HTTP-based interface through which clients access and manipulate server resources using HTTP methods on URL endpoints.

**Stateless:** It means each request contains all the information (authentication tokens or parameters) needed for the server to process it. The server does not store client session state between requests. The server does not remember previous requests.

## Difference Between `GET` and `POST`

- `GET` retrieves data from the server.
- `POST` sends data to create a new resource.

## Route Design

**Good route design uses nouns instead of actions**, because the HTTP method already describes the action.

Examples:

- `GET /users`
- `GET /users/42`
- `POST /users`
- `PATCH /users/42`
- `DELETE /users/42`

## Common HTTP Methods

- `GET`: read data
- `POST`: create a resource
- `PUT`: replace a resource
- `PATCH`: partially update a resource
- `DELETE`: remove a resource

## Status Code Categories

### `2xx`: success

- 200 OK:
- 201 Created:
- 202 Accepted
- 204 No Content:

### `3xx`: redirection

**301 Moved Permanently:** Resource has permanently moved to a new URL
**302 Found:** Resource is temporarily at a different URL.

### `4xx`: client error

- 400 Bad Request:
- **401 Unauthorized:** authentication required
- **403 Forbidden:** unauthorized
- **404 Not Found:** the requested resource does not exist
- 405 Method Not Allowed:
- 409 Conflict:
- 410 Gone:
- **422 Unprocessable Content:** The request syntax is correct, but semantic validation fails
- 429 Too Many Requests:

### `5xx`: server error

- **500 Internal Server Error:** The application processed the request but failed. (Bug in fast api backend)
- **502 Bad gateway:** The gateway got a bad response from the application. ( Fast api sends and invalid response)
- **503 Service Unavailable:** The application/service is not available to handle requests. ( fastapi stopped)
- **504 Gateway Timeout:** The application didn't respond in time. (Fast api took long time to give response)

## Mid/Senior Interview Questions and Answers

### 1. What does stateless mean in REST?

**Answer:** Stateless means each request contains all information the server
needs to process it. The server should not depend on remembering a previous
request in process memory.

The server can still use databases, caches, and sessions. The key is that the
request must carry an identifier, cookie, token, or parameters that let the
server reconstruct the needed context.

### 2. What is the difference between `PUT` and `PATCH`?

**Answer:** `PUT` usually replaces a resource representation. `PATCH` applies a
partial update.

In practice, APIs should document exact semantics. If `PUT /users/1` omits a
field, does that field get cleared or preserved? Ambiguity creates client bugs.

### 3. Which HTTP methods should be idempotent?

**Answer:** `GET`, `PUT`, and `DELETE` should be idempotent by HTTP semantics.
Calling them multiple times should have the same final effect as calling them
once. `POST` is not generally idempotent.

For important `POST` operations such as payments or order creation, use
idempotency keys so clients can retry safely after timeouts.

### 4. When should an API return `401`, `403`, or `404`?

**Answer:** Return `401` when authentication is missing or invalid. Return `403`
when the caller is authenticated but not allowed. Return `404` when the resource
does not exist or when hiding resource existence is part of the security model.

Be consistent. Leaking whether a private resource exists can be a security
issue.

### 5. How should pagination be designed for large datasets?

**Answer:** Offset pagination is simple but can become slow and inconsistent on
large or frequently changing datasets. Cursor pagination uses a stable sort key
and cursor to fetch the next page.

For senior design, define deterministic ordering, maximum page size, cursor
format, and behavior when items are inserted or deleted during pagination.

### 6. How should API errors be structured?

**Answer:** API errors should include a stable machine-readable code, a human
message, request or trace ID, and field-level validation details when relevant.

Avoid exposing stack traces or internal exception messages. Clients need stable
contracts, while operators need correlation IDs and logs for diagnosis.

### 7. What makes an API RESTful?

**Answer:** An API is RESTful when it follows these constraints:

- **Stateless**: each request contains all info needed (no server-side session)
- **Client-server**: separation of concerns
- **Uniform interface**: resources identified by URLs, manipulated via HTTP methods
- **Resource-based**: nouns not verbs (`/users` not `/getUsers`)
- **Hypermedia (HATEOAS)**: responses include links to related resources (optional but ideal)
- **Cacheable**: responses declare cacheability
- **Layered system**: client cannot tell if it connects directly to server

What most people actually mean in practice: resource URLs + proper HTTP methods + status codes + JSON.

### 8. When should you return 200, 201, 204, 400, 401, 403, 404, 409, 500?

**Answer:**

- **200 OK**: successful request (GET, PUT, PATCH, DELETE)
- **201 Created**: resource created (POST)
- **204 No Content**: successful, no body (DELETE)
- **400 Bad Request**: invalid input, validation error
- **401 Unauthorized**: not authenticated (missing/invalid token)
- **403 Forbidden**: authenticated but not allowed
- **404 Not Found**: resource doesn't exist
- **409 Conflict**: state conflict (duplicate, version mismatch)
- **500 Internal Server Error**: server bug, unexpected failure

### 9. Design REST APIs for an e-commerce product service

**Answer:**

```
GET    /products              → list products (pagination, filters)
GET    /products/{id}         → get product details
POST   /products              → create product (admin)
PUT    /products/{id}         → replace product (admin)
PATCH  /products/{id}         → partial update (admin)
DELETE /products/{id}         → delete product (admin)
GET    /products/{id}/reviews → get product reviews
POST   /products/{id}/reviews → add review (auth)
```

Design considerations:

- Use query params for filtering: `?category=electronics&min_price=100`
- Pagination: `?page=2&limit=20` or cursor-based
- Versioning: `/api/v1/products`
- Idempotency keys for POST
- Return 201 + `Location` header on create
- HATEOAS links: `{"_links": {"self": "/products/123", "reviews": "/products/123/reviews"}}`

### 10. Users report duplicate orders when clicking "Pay" multiple times. How would you prevent duplicate order creation?

**Answer:**

- **Idempotency keys**: client sends a unique key (UUID) with each request. Server
  stores key → result. Duplicate requests with the same key return the cached result
  instead of creating a new order.
- **Optimistic locking**: database version check on update. `UPDATE orders SET
  version=version+1 WHERE id=? AND version=?`. Fails if another write changed the
  version, preventing concurrent duplicates.
- **Unique constraint**: add a unique index on `(user_id, idempotency_key)` in the
  orders table so the database rejects duplicate inserts at the storage level.
- **Frontend**: disable the Pay button after the first click and show a loading state
  to prevent the user from triggering multiple requests.
- **Backend**: check for an existing pending order with the same idempotency key
  before creating a new one.

Best combination: idempotency key + unique constraint + frontend button disable.
Defense in depth -- no single layer is sufficient alone.
