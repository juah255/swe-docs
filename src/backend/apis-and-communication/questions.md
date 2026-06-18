# API and Communication Questions

## Mid/Senior Interview Questions and Answers

### 1. What is a REST API?

**Answer:** A REST API exposes resources over HTTP and uses HTTP methods such as
`GET`, `POST`, `PUT`, `PATCH`, and `DELETE` to act on those resources.

Good REST APIs are stateless, use clear resource names, return meaningful status
codes, and document request and response shapes.

### 2. What does stateless mean in HTTP?

**Answer:** Stateless means each request must include enough information for the
server to process it. The server should not depend on previous in-memory request
state for correctness.

Authentication tokens, cookies, resource IDs, and request payloads are common
ways to provide that context.

### 3. What is the difference between `GET`, `POST`, `PUT`, and `PATCH`?

**Answer:** `GET` retrieves data, `POST` commonly creates a resource or starts a
non-idempotent operation, `PUT` usually replaces a resource, and `PATCH`
partially updates a resource.

The important senior detail is idempotency. Retrying an unsafe `POST` can create
duplicates unless the API supports idempotency keys.

### 4. What is the difference between `401 Unauthorized` and `403 Forbidden`?

**Answer:** `401` means the request is not authenticated or the credentials are
invalid. `403` means the caller is authenticated but does not have permission.

Some APIs intentionally return `404` for unauthorized resource access to avoid
leaking whether a private resource exists.

### 5. Why can an API request work in Postman but fail in the browser?

**Answer:** Browsers enforce security policies such as CORS, cookie rules,
mixed-content blocking, and preflight checks. Postman is not a browser and does
not enforce the same origin policy.

If a browser request fails before reaching the API, check CORS headers,
preflight responses, credentials mode, allowed methods, and allowed headers.

### 6. What is CORS?

**Answer:** Cross-Origin Resource Sharing (`CORS`) is a browser security
mechanism that controls whether frontend JavaScript from one origin can read
responses from another origin.

CORS is enforced by the browser, not by curl or Postman. The server must return
appropriate `Access-Control-*` headers for allowed origins, methods, headers,
and credentials.

### 7. What is the difference between cookies, local storage, and session storage?

**Answer:** Cookies are sent automatically with matching HTTP requests and can
be marked `HttpOnly`, `Secure`, and `SameSite`. Local storage persists until
cleared and is accessible to JavaScript. Session storage is scoped to a browser
tab session and is also accessible to JavaScript.

For sensitive tokens, JavaScript-accessible storage increases XSS impact.
Cookie-based auth needs CSRF-aware design.

### 8. What is JWT, and why is it URL-safe?

**Answer:** A JWT is a signed token format containing a header, payload, and
signature. It is URL-safe because it uses Base64Url encoding, which avoids
characters that are awkward in URLs.

Signing protects integrity, not confidentiality. The payload can usually be
decoded by anyone who has the token.

### 9. What is RBAC?

**Answer:** Role-based access control maps users to roles and roles to
permissions. It simplifies common authorization decisions such as admin,
manager, vendor, or customer access.

Real systems often need more than RBAC: ownership checks, tenant boundaries,
resource state, feature flags, and policy rules may also be required.

### 10. What is the difference between a service and a repository?

**Answer:** A service implements business use cases. A repository abstracts data
access.

The service should not know SQL details, and the repository should not decide
business rules such as whether an order can be cancelled after shipment.
