# JWT and Tokens

Tokens are the backbone of modern stateless authentication. JWTs (JSON Web Tokens) are the most common token format, carrying signed claims between parties.

## Access Token

An **access token** is a short-lived credential that grants the holder access to protected resources.

- Typically valid for minutes (5-30 minutes)
- Sent in the `Authorization: Bearer <token>` header
- Contains claims (user ID, roles, permissions)
- Verified by the server using the signature
- Should be short-lived to limit the impact of theft

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

## Refresh Token

A **refresh token** is a longer-lived credential used to obtain new access tokens without requiring the user to re-authenticate.

- Typically valid for days or weeks
- Stored securely (HttpOnly cookie, secure storage)
- Sent to the authorization server, not resource servers
- Should be rotated on each use
- Can be revoked to invalidate the session

Refresh token flow:

1. Access token expires.
2. Client sends refresh token to the auth server.
3. Auth server validates the refresh token.
4. Auth server issues a new access token (and optionally a new refresh token).
5. Old refresh token is invalidated.

## Bearer Token

A **bearer token** is any token that grants access to whoever possesses it. The term "bearer" means the token itself is the credential -- no additional proof is needed.

```http
Authorization: Bearer <token>
```

- JWTs are typically bearer tokens
- The server trusts whoever presents the token
- Bearer tokens must be protected in transit (HTTPS) and at rest
- If a bearer token is stolen, the attacker can use it directly

This is why access tokens should be short-lived and refresh tokens should be rotated.

## Token Rotation

**Token rotation** is the practice of issuing a new token when the old one is used or expires. This limits the window of opportunity for stolen tokens.

Access token rotation:

- Issue a new short-lived access token on each refresh
- Old access token can be invalidated or left to expire

Refresh token rotation:

- Issue a new refresh token on each use
- Invalidate the old refresh token
- If the old refresh token is reused, revoke the entire token family (possible theft)

```text
Refresh Token Chain:
  RT1 -> RT2 -> RT3 -> ...
  If RT1 is reused after RT2 is issued, revoke RT2 and RT3
```

## Revocation

**Token revocation** is the ability to invalidate a token before its natural expiration.

Why revocation is needed:

- User logs out
- User changes password
- Account is compromised
- Token is detected as stolen
- Access needs to be revoked immediately

Revocation strategies:

- **Short-lived tokens** -- naturally expire quickly, reducing revocation urgency
- **Token blacklist** -- store revoked token IDs in a fast store (Redis) and check on each request
- **Refresh token invalidation** -- invalidate the refresh token to stop token renewal
- **Audience/issuer checks** -- allow different token audiences to be revoked independently
- **JWKS key rotation** -- rotating signing keys effectively invalidates tokens signed with old keys

Trade-offs:

- Blacklists add lookup overhead and break pure statelessness
- Short-lived tokens reduce but do not eliminate the need for revocation
- For high-security systems, a revocation mechanism is essential

## Token Storage

Where tokens are stored on the client affects security significantly.

**Browser (web apps):**

| Storage | XSS Risk | CSRF Risk | Accessibility |
|---|---|---|---|
| HttpOnly Cookie | Low | Yes (if SameSite=None) | JavaScript cannot read |
| localStorage | High (JS can read) | No | JavaScript can read |
| sessionStorage | High (JS can read) | No | JavaScript can read, tab-scoped |
| Memory (JS variable) | High | No | Lost on page refresh |

Best practices:

- Use `HttpOnly`, `Secure`, `SameSite=Lax` cookies for web apps
- Avoid storing tokens in `localStorage` for sensitive applications
- Store refresh tokens in `HttpOnly` cookies or secure back-channel storage
- For mobile apps, use secure enclave or OS-provided secure storage

**Server-side:**

- Store signing keys in environment variables or secrets managers (never in source code)
- Use key rotation to limit the impact of key compromise
- Never log tokens in application logs

## Mid/Senior Interview Questions and Answers

### 1. Why should access tokens be short-lived?

**Answer:** Short-lived access tokens reduce the window of opportunity for
attackers if a token is leaked. If an access token expires in 5 minutes, a
stolen token is only useful for that window.

Refresh tokens extend the session without exposing long-lived credentials.
Production systems should also support revocation for immediate invalidation
when needed.

### 2. How does refresh token rotation prevent token theft?

**Answer:** On each refresh, a new refresh token is issued and the old one is
invalidated. If an attacker replays the old refresh token, the server detects
the reuse and revokes the entire session family.

This limits replay attacks and gives the server a signal that the token may
have been compromised.

### 3. What is the difference between a bearer token and a proof-of-possession token?

**Answer:** A bearer token grants access to whoever possesses it. No
additional proof is needed -- the token itself is the credential.

A proof-of-possession (PoP) token requires the holder to prove they possess a
specific key (e.g., via a cryptographic challenge). This prevents stolen tokens
from being used by someone else.

### 4. How do you implement token revocation without losing statelessness?

**Answer:** Pure statelessness and immediate revocation are fundamentally at
odds. Common compromises include:

- Use very short-lived access tokens (5 minutes or less) to limit the window
- Maintain a small revocation list for critical cases (compromised accounts)
- Rotate refresh tokens to stop token renewal
- Rotate signing keys periodically to invalidate all tokens signed with old keys

The right approach depends on the threat model and system requirements.

### 5. Where should you store JWTs in a browser application?

**Answer:** For most web applications, `HttpOnly`, `Secure`, `SameSite=Lax`
cookies are the safest option. JavaScript cannot read them, which prevents XSS
token theft.

Cookies require CSRF protection. `localStorage` avoids CSRF but is accessible
to any JavaScript on the page. The choice depends on the threat model, client
type, and whether the app is a SPA or server-rendered.
