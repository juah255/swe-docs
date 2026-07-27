# Authentication

**Authentication** is the process of verifying the identity of a user, client, or system. It answers the question: "Who are you?"

## Basic Auth

**HTTP Basic Authentication** sends credentials (username and password) in the `Authorization` header with every request, encoded in Base64.

```text
Authorization: Basic dXNlcjpwYXNzd29yZA==
```

- Simple to implement
- Credentials are sent with every request (no expiry)
- Credentials are Base64-encoded, **not encrypted** -- always requires HTTPS
- No built-in logout or token revocation

**Use case:** Internal tools, simple APIs, or temporary prototyping. Not recommended for production user-facing systems without HTTPS.

## API Keys

An **API key** is a unique token passed in a header or query parameter to identify and authorize a client.

```text
X-API-Key: abc123xyz
```

- Simple for server-to-server authentication
- Usually long-lived and not user-specific
- Does not prove user identity -- proves application identity
- Should be rotated regularly and stored securely (environment variables, secrets managers)

**Use case:** Identifying third-party services, rate limiting, tracking API usage.

## Session Authentication

**Session-based authentication** creates a server-side session after the user logs in. A session ID is sent to the client (usually via a cookie) and included in subsequent requests.

Flow:

1. User submits credentials.
2. Server validates and creates a session in memory or a store (Redis, database).
3. Server sends a session ID to the client.
4. Client includes the session ID in every request.
5. Server looks up the session to identify the user.

- Stateful -- the server stores session data
- Easy to revoke (delete the session)
- Can become a bottleneck at scale (shared session store required)

## Cookie Authentication

**Cookie-based authentication** stores the session ID or token in a browser cookie. The browser automatically sends the cookie with each request to the same domain.

- Cookies can be configured with `HttpOnly`, `Secure`, and `SameSite` attributes
- Vulnerable to CSRF if not properly protected
- Works well with server-rendered applications
- Automatic expiration via cookie `Max-Age` or `Expires`

## JWT Authentication

**JWT (JSON Web Token)** authentication uses a signed token containing user claims. The server validates the token without storing session state.

Flow:

1. User submits credentials.
2. Server creates and signs a JWT.
3. Client stores the JWT and sends it in the `Authorization: Bearer <token>` header.
4. Server verifies the signature, expiration, and claims.

- Stateless -- no server-side session storage
- Scales well across multiple servers
- Token cannot be easily revoked before expiry (use short-lived tokens + refresh tokens)
- Claims are readable by anyone with the token (do not store secrets)

## OAuth2

**OAuth2** is an authorization framework that allows third-party applications to obtain limited access to a user's resources without sharing credentials.

Key roles:

- **Resource Owner** -- the user
- **Client** -- the application requesting access
- **Authorization Server** -- issues tokens after authenticating the user
- **Resource Server** -- hosts the protected resources

Grant types:

- **Authorization Code** -- most secure, standard for web and mobile apps
- **Client Credentials** -- for server-to-server communication
- **Device Code** -- for input-constrained devices (smart TVs, CLI tools)
- **Password Grant** -- legacy, not recommended for new applications

## OpenID Connect (OIDC)

**OpenID Connect** is an identity layer built on top of OAuth2. It adds a standardized way to authenticate users and retrieve profile information.

- Uses **ID tokens** (JWTs) to convey user identity
- Provides a `/userinfo` endpoint for profile data
- Standardizes scopes: `openid`, `profile`, `email`
- Most "Login with Google/GitHub" flows use OIDC

## Multi-factor Authentication (MFA)

**MFA** requires users to provide two or more verification factors to gain access.

Common factor types:

- **Something you know** -- password, PIN
- **Something you have** -- phone (SMS/TOTP), hardware key (YubiKey)
- **Something you are** -- fingerprint, face recognition

Implementation options:

- **TOTP (Time-based One-Time Password)** -- Google Authenticator, Authy
- **SMS codes** -- less secure due to SIM swapping risks
- **WebAuthn / FIDO2** -- phishing-resistant, hardware-based
- **Backup codes** -- one-time recovery codes stored securely

## Comparison

| Method | State | Scalability | Revocation | Use Case |
|---|---|---|---|---|
| Basic Auth | Stateless | Low | Difficult | Internal tools |
| API Key | Stateless | High | Rotate key | Server-to-server |
| Session | Stateful | Medium | Easy | Traditional web apps |
| JWT | Stateless | High | Hard (short-lived) | SPAs, microservices |
| OAuth2 | Depends | High | Token revocation | Third-party access |
| OIDC | Stateless | High | Token revocation | SSO, social login |

## Mid/Senior Interview Questions and Answers

### 1. When would you choose session-based authentication over JWT?

**Answer:** Session-based authentication is better when you need immediate
revocation, have a monolithic or server-rendered application, and want to keep
sensitive data on the server.

JWT is better for stateless, distributed systems where the token is verified
independently by multiple services without a shared session store.

### 2. Why is Basic Auth considered insecure?

**Answer:** Basic Auth sends credentials with every request, encoded (not
encrypted) in Base64. Without HTTPS, credentials are visible to anyone sniffing
traffic. Even with HTTPS, there is no built-in expiry, revocation, or MFA
support.

It should only be used over HTTPS for simple, internal, or short-lived use
cases.

### 3. What are the security risks of API keys and how do you mitigate them?

**Answer:** API keys can be leaked in source code, logs, or client-side code.
They are usually long-lived and not user-specific.

Mitigations: never commit keys to source control, store them in environment
variables or secrets managers, rotate keys regularly, scope keys to minimal
permissions, rate-limit by key, and monitor for unusual usage patterns.

### 4. How does OAuth2 authorization code flow work?

**Answer:** The client redirects the user to the authorization server. The user
authenticates and consents. The authorization server redirects back with an
authorization code. The client exchanges the code for an access token (and
optionally a refresh token) via a back-channel request.

This keeps credentials and tokens out of the browser's URL bar and is the
recommended flow for web and mobile applications.

### 5. What is the difference between OAuth2 and OpenID Connect?

**Answer:** OAuth2 is an authorization framework for delegated access to
resources. It does not define how to authenticate users.

OpenID Connect adds an identity layer on top of OAuth2, defining ID tokens,
the `openid` scope, and a userinfo endpoint. It standardizes user
authentication on top of OAuth2's authorization capabilities.

### 6. What are the risks of SMS-based MFA and what are better alternatives?

**Answer:** SMS-based MFA is vulnerable to SIM swapping, SS7 attacks, and
phishing. An attacker who takes over a phone number can receive OTP codes.

Better alternatives include TOTP apps (Google Authenticator, Authy), hardware
security keys (YubiKey via WebAuthn/FIDO2), and push-based MFA. WebAuthn is
the most phishing-resistant option.

### 7. How would you implement authentication? Compare Session, JWT, and OAuth.

**Answer:**

- **Session**: server stores session data, client gets a session ID cookie. Simple,
  stateful, easy to revoke by deleting the server-side record. Problem: doesn't scale
  well across servers without a shared session store, and is vulnerable to CSRF.
- **JWT**: stateless token with encoded claims, signed by the server. Scales easily
  (no server state needed), works across services. Problem: can't revoke until expiry
  (requires a blacklist for revocation), token size grows with claims, and needs
  refresh token rotation for long-lived sessions.
- **OAuth**: delegated authorization framework. User grants limited access to a third
  party without sharing credentials. Used for social login (Google, GitHub). Combines
  with JWT as the token format.

When to use:

| Approach | Best For |
|---|---|
| Session | Traditional web apps, monoliths |
| JWT | APIs, microservices, mobile apps |
| OAuth | Third-party access, social login, SSO |

In practice, most systems combine these: OAuth for social login, JWT for API
authentication, and sessions only for server-rendered apps where immediate
revocation matters.
