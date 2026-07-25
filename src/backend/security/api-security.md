# API Security

API security protects web services from common attacks and ensures that only authorized clients can access protected resources.

## CORS (Cross-Origin Resource Sharing)

**CORS** is a browser security mechanism that controls which origins can access resources on a server.

When a browser makes a cross-origin request, the server must explicitly allow it using headers:

```http
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
```

Key points:

- CORS is enforced by browsers, not the server
- `Access-Control-Allow-Origin: *` allows any origin -- avoid for authenticated endpoints
- Preflight requests (`OPTIONS`) check permissions before the actual request
- CORS does not protect against server-side attacks -- it is a browser-only mechanism
- Never use `Access-Control-Allow-Credentials: true` with `Access-Control-Allow-Origin: *`

Common misconfigurations:

- Allowing `*` origin with credentials
- Reflecting the request origin without validation
- Not restricting allowed methods and headers

## CSRF (Cross-Site Request Forgery)

**CSRF** forces an authenticated user's browser to submit unintended requests to a web application where they are authenticated.

Defense mechanisms:

- **SameSite cookies** -- primary modern defense (`Lax` or `Strict`)
- **CSRF tokens** -- unique, unpredictable tokens in forms validated server-side
- **Origin / Referer header validation** -- verify the request source
- **Double-submit cookie** -- cookie value must match a form/header value
- **Re-authentication** for sensitive operations

## XSS (Cross-Site Scripting)

**XSS** injects malicious scripts into web pages viewed by other users.

Types:

- **Stored XSS** -- malicious script is saved in the database (e.g., in a comment) and served to users
- **Reflected XSS** -- script is reflected off the server in a URL parameter or form field
- **DOM-based XSS** -- script executes entirely in the browser via client-side DOM manipulation

Prevention:

- **Output encoding** -- encode special characters when rendering data in HTML, JavaScript, CSS, or URLs
- **Input validation** -- reject or sanitize dangerous input
- **Content Security Policy (CSP)** -- restrict which scripts can execute on the page
- **HttpOnly cookies** -- prevent JavaScript from accessing session tokens
- **Use frameworks that escape by default** -- React, Angular, and modern templating engines auto-escape

```http
Content-Security-Policy: default-src 'self'; script-src 'self'
```

## SQL Injection

**SQL injection** inserts malicious SQL code into queries via user input, allowing attackers to read, modify, or delete data.

Vulnerable code:

```sql
query = "SELECT * FROM users WHERE id = '" + userId + "'"
```

Attack:

```sql
userId = "1' OR '1'='1"
```

Resulting query:

```sql
SELECT * FROM users WHERE id = '1' OR '1'='1'
```

Prevention:

- **Parameterized queries (prepared statements)** -- the primary defense
- **ORMs** -- use frameworks that handle query construction
- **Stored procedures** -- precompiled database logic
- **Input validation** -- whitelist expected values
- **Least privilege** -- database users should have minimal permissions
- **WAF (Web Application Firewall)** -- additional layer of detection

## Rate Limiting

**Rate limiting** restricts how many requests a client can make within a time window.

Purpose:

- Prevent brute-force attacks
- Mitigate denial-of-service (DoS)
- Protect against API abuse
- Fair usage across clients

Implementation approaches:

- **Fixed window** -- count requests in fixed time periods (e.g., 100 requests per minute)
- **Sliding window** -- rolling time window for smoother limiting
- **Token bucket** -- clients get tokens at a fixed rate, each request consumes one
- **Leaky bucket** -- requests are queued and processed at a fixed rate

Common headers:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1640995200
Retry-After: 30
```

## Input Validation

**Input validation** ensures that user-supplied data conforms to expected formats, types, and ranges before processing.

Principles:

- **Validate on the server** -- client-side validation is bypassable
- **Whitelist, not blacklist** -- define what is allowed, reject everything else
- **Validate type, length, range, and format** -- check all dimensions
- **Reject dangerous input early** -- fail before reaching business logic
- **Use established libraries** -- JSON Schema, validation frameworks

```text
Email: validate format, length, domain
ID: validate integer, positive, within expected range
Name: validate length, allowed characters
File upload: validate MIME type, file size, file content
```

## API Keys

**API keys** identify and authenticate API clients. They are different from user authentication.

- Pass via header (`X-API-Key`) or query parameter (less secure)
- Should be long, random, and unique per client
- Rotate regularly and support multiple active keys during rotation
- Scope to minimal required permissions
- Monitor for unusual usage patterns
- Never expose in client-side code, URLs, or logs

## Security Headers

**HTTP security headers** instruct browsers to enforce security policies.

Essential headers:

| Header | Purpose |
|---|---|
| `Strict-Transport-Security` | Force HTTPS for a period |
| `Content-Security-Policy` | Restrict resource loading sources |
| `X-Content-Type-Options` | Prevent MIME sniffing (`nosniff`) |
| `X-Frame-Options` | Prevent clickjacking (`DENY` or `SAMEORIGIN`) |
| `Referrer-Policy` | Control referrer information leakage |
| `Permissions-Policy` | Restrict browser features (camera, microphone) |
| `X-XSS-Protection` | Legacy XSS filter (use CSP instead) |

Example:

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'; script-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=()
```

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between CORS and CSRF?

**Answer:** CORS is a browser mechanism that controls which origins can access
a server's resources. It is a security feature that restricts cross-origin
requests.

CSRF is an attack where a malicious site tricks a user's browser into making
unwanted requests to a site where the user is authenticated. CORS does not
prevent CSRF because the browser sends cookies automatically for same-site
requests.

### 2. How do parameterized queries prevent SQL injection?

**Answer:** Parameterized queries separate the SQL structure from the data. The
database compiles the query structure first, then binds the parameters
separately. User input is never interpreted as SQL code.

This makes it impossible for an attacker to inject SQL because the input is
always treated as data, never as part of the query structure.

### 3. What is Content Security Policy and why does it matter?

**Answer:** CSP is an HTTP header that restricts which resources (scripts,
styles, images, frames) a page can load and execute. It is a primary defense
against XSS.

A strict CSP blocks inline scripts, restricts scripts to trusted origins, and
prevents loading resources from untrusted domains. Even if an attacker injects
a script tag, the browser refuses to execute it if it violates the policy.

### 4. How do you design rate limiting for a distributed API?

**Answer:** Use a centralized store (Redis, Memcached) to track request counts
across all API instances. Implement sliding window or token bucket algorithms
in middleware.

Consider per-user, per-IP, and per-API-key limits. Return `429 Too Many
Requests` with a `Retry-After` header. For critical endpoints, add additional
limits regardless of the general rate limit.

### 5. What are the most important HTTP security headers?

**Answer:** The most critical are `Strict-Transport-Security` (force HTTPS),
`Content-Security-Policy` (prevent XSS), `X-Content-Type-Options` (prevent
MIME sniffing), `X-Frame-Options` (prevent clickjacking), and
`Referrer-Policy` (control information leakage).

Set these at the web server or reverse proxy level so they apply to all
responses. Use tools like securityheaders.com to audit your configuration.
