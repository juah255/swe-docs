# HTTP and REST

4xx client side issue:
400 bad request:
401 unauthorized:
authentication required

403 Forbidden: unauthorized

404 not found:
the requested resource does not exist

5xx server issue:

500 Internal Server Error:
The application processed the request but failed. (Bug in fast api backend)

502 Bad gateway:
The gateway got a bad response from the application. ( Fast api sends and invalid response)

503 Service Unavailable:
The application/service is not available to handle requests. ( fastapi stopped)

504 Gateway Timeout:
The application didn't respond in time. (Fast api took long time to give response)

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

- `2xx`: success
- `3xx`: redirection
- `4xx`: client error
- `5xx`: server error

Common examples:

- `200 OK`
- `201 Created`
- `204 No Content`
- `400 Bad Request`
- `401 Unauthorized`
- `403 Forbidden`
- `404 Not Found`
- `409 Conflict`
- `500 Internal Server Error`

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
