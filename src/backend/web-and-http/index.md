# Web & HTTP

HTTP is the application-layer protocol used by browsers, mobile applications,
backend services, and other clients to communicate over the web. A backend
engineer should understand both the request-response model and the network
layers that support it.

## What Happens When a URL Is Requested?

For a URL such as `https://api.example.com/users/42`, the client generally:

1. Parses the URL into scheme, host, port, path, and query parameters.
2. Resolves the hostname to an IP address through DNS.
3. Opens a TCP connection, or a QUIC connection for HTTP/3.
4. Performs a TLS handshake for HTTPS.
5. Sends an HTTP request.
6. Receives and parses the HTTP response.
7. Reuses or closes the connection according to the protocol and headers.

Proxies, CDNs, load balancers, API gateways, and service meshes may process the
request before it reaches the application.

## URL Structure

```text
https://api.example.com:443/users/42?include=orders#profile
\___/   \_____________/\__/\_______/\____________/\______/
scheme        host      port   path       query      fragment
```

The fragment is handled by the client and is not sent in an HTTP request.

## HTTP Request

An HTTP request contains a method, target, headers, and an optional body:

```http
POST /orders HTTP/1.1
Host: api.example.com
Authorization: Bearer token
Content-Type: application/json
Idempotency-Key: 5d35b1bd

{"product_id": 42, "quantity": 2}
```

Common methods:

| Method | Typical purpose | Safe | Idempotent |
| --- | --- | --- | --- |
| `GET` | Read a resource | Yes | Yes |
| `HEAD` | Read headers only | Yes | Yes |
| `POST` | Create or trigger processing | No | No |
| `PUT` | Replace a resource | No | Yes |
| `PATCH` | Partially update a resource | No | Depends on design |
| `DELETE` | Remove a resource | No | Yes |

**Safe** means the method should not change server state. **Idempotent** means
repeating the same request has the same intended final effect as making it once.

## HTTP Response

```http
HTTP/1.1 201 Created
Content-Type: application/json
Location: /orders/981
Cache-Control: no-store

{"id": 981, "status": "pending"}
```

Status code groups:

- `1xx`: informational
- `2xx`: successful
- `3xx`: redirection
- `4xx`: client-side error
- `5xx`: server-side or upstream error

Frequently used codes include `200 OK`, `201 Created`, `202 Accepted`, `204 No
Content`, `301 Moved Permanently`, `304 Not Modified`, `400 Bad Request`, `401
Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`, `422
Unprocessable Content`, `429 Too Many Requests`, `500 Internal Server Error`,
`502 Bad Gateway`, `503 Service Unavailable`, and `504 Gateway Timeout`.

## Important Headers

- `Accept`: response media types the client can process
- `Content-Type`: media type of the request or response body
- `Authorization`: credentials supplied by the client
- `Cookie` and `Set-Cookie`: client and server cookie exchange
- `Cache-Control`: caching rules for browsers and shared caches
- `ETag` and `If-None-Match`: validation of cached representations
- `Location`: URL of a created or redirected resource
- `Origin`: origin of a browser request, used by CORS
- `Retry-After`: when a client should retry
- `X-Request-ID` or `traceparent`: request correlation and tracing

Header names are case-insensitive. Their values and semantics are not.

## HTTP Versions

### HTTP/1.1

HTTP/1.1 commonly reuses persistent TCP connections, but requests on one
connection are limited by ordering and head-of-line blocking.

### HTTP/2

HTTP/2 uses binary framing, multiplexes streams over one TCP connection, and
compresses headers. A lost TCP packet can still delay every stream sharing that
connection.

### HTTP/3

HTTP/3 runs over QUIC and UDP. QUIC provides encrypted, independent streams, so
packet loss on one stream does not block unrelated streams in the same way.

## HTTPS and TLS

HTTPS is HTTP carried over TLS. TLS provides:

- Encryption against passive observation
- Integrity against undetected modification
- Server authentication through certificates
- Optional client authentication through client certificates

TLS does not make application logic secure by itself. Authorization, input
validation, secure cookies, and safe data handling are still required.

## Cookies and Sessions

A cookie is a small value stored by the client and attached to matching HTTP
requests. Common security attributes are:

- `HttpOnly`: prevents JavaScript from reading the cookie
- `Secure`: sends the cookie only over HTTPS
- `SameSite`: controls cross-site sending behavior
- `Path` and `Domain`: limit where the cookie is sent
- `Max-Age` or `Expires`: controls lifetime

A session cookie normally contains an opaque session identifier. Session data
is stored on the server or in a shared session store. A signed token may carry
claims directly, but revocation and expiration still need deliberate design.

## CORS

Cross-Origin Resource Sharing is a browser security mechanism. It determines
whether frontend JavaScript from one origin may read a response from another
origin.

Some requests trigger an `OPTIONS` preflight. The server responds with allowed
origins, methods, and headers. CORS is not authentication and does not prevent
servers, scripts, or command-line clients from calling an API.

## HTTP Caching

Caching reduces latency and backend load. Common controls include:

- `Cache-Control: max-age=60`: representation is fresh for 60 seconds
- `Cache-Control: private`: only a private client cache may store it
- `Cache-Control: no-store`: do not store the response
- `ETag`: identifies a representation version
- `Last-Modified`: supports time-based validation
- `Vary`: identifies request headers that change the response

Cache personalized responses carefully. An incorrect shared-cache key can leak
one user's data to another user.

## Proxies and Client Identity

A reverse proxy receives requests on behalf of backend services. It may
terminate TLS, compress responses, enforce limits, or route traffic.

Headers such as `Forwarded` and `X-Forwarded-For` communicate the original
client address and scheme. Applications should trust these headers only when
they come from known proxies; clients can otherwise forge them.

## Timeouts and Connection Limits

Production HTTP clients and servers need explicit limits:

- Connection, read, write, and total timeouts
- Maximum request body and header sizes
- Connection-pool limits
- Maximum concurrent requests
- Idle connection timeouts
- Bounded retries with backoff and jitter

Retries should be used only when the operation is safe to repeat or protected by
an idempotency key.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between `502`, `503`, and `504`?

**Answer:** A `502 Bad Gateway` means a proxy received an invalid response from
an upstream. A `503 Service Unavailable` means the service cannot currently
handle the request. A `504 Gateway Timeout` means the proxy did not receive an
upstream response before its timeout.

### 2. Why can a request succeed on the server while the client sees a timeout?

**Answer:** The server may commit the operation but fail to deliver the response
before the client or proxy timeout. Retrying can then duplicate the operation.
Important writes should use idempotency keys and database constraints.

### 3. How does an `ETag` reduce bandwidth?

**Answer:** The client sends its cached ETag in `If-None-Match`. If the
representation has not changed, the server returns `304 Not Modified` without
the full response body.

### 4. Why should services use both client and server timeouts?

**Answer:** Client timeouts prevent a caller from waiting forever. Server
timeouts bound the work accepted by the service. Together with cancellation,
they prevent abandoned work from consuming resources after the caller is gone.
