# Auth and Tokens

## Refresh Token and Access Token

- **Access token**: a short-lived token used to access protected resources.
- **Refresh token**: a longer-lived token used to obtain a new access token when the old one expires.

## What is JWT?

**JWT** (JSON Web Token) is a compact, URL-safe, digitally signed token format used to securely transmit claims such as user identity between parties.

A JWT usually has **three parts**:

```text
header.payload.signature
```

## Why JWT is URL-safe

- **JWT uses Base64Url encoding** instead of standard Base64.
- **Base64Url avoids characters** such as `+`, `/`, and `=`, which are awkward inside URLs.
- It uses URL-friendly characters such as `-` and `_`.

## What “digitally signed” means

- **The token is signed** with a secret key or a public/private key pair.
- **The signature provides** integrity and authenticity.
- Signing is not encryption. The payload is readable if decoded, but changing it breaks the signature.

## JWT structure

### Header

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### Payload

```json
{
  "userId": 1,
  "email": "user@example.com",
  "role": "admin"
}
```

### Signature

Generated using a secret or private key to ensure the token has **not been modified**.

## Typical JWT authentication flow

1. User submits email and password.
2. Server verifies the credentials.
3. Server creates a JWT containing user information.
4. Server returns the token to the client.
5. Client stores the token, usually in memory or an `HttpOnly` cookie.
6. Client sends the token with each request in the `Authorization` header.
7. Server verifies the token and identifies the user.

## Stateful vs. Stateless Authentication

- **Stateful authentication** stores session data on the server and identifies users via a session ID.
- **Stateless authentication** stores user-related claims in a signed token such as JWT, so the server does not need to keep session state.

## Authentication vs. Authorization

- **Authentication** answers: "Who are you?"
- **Authorization** answers: "What are you allowed to do?"

## What is Role-Based Access Control?

**RBAC** restricts actions based on a user's role.

For example, the server may store the user's role in the JWT payload:

```json
{
  "userId": 1,
  "role": "vendor"
}
```

When the user accesses a protected route, the server checks:

- Is the JWT valid?
- Does the user have the required role?

## What is OAuth?

**OAuth** is an authorization framework that allows third-party applications to access user data without sharing the user's password.

Common examples include "Login with Google" and "Login with Facebook".

## Mid/Senior Interview Questions and Answers

### 1. Why should access tokens be short-lived?

**Answer:** Short-lived access tokens reduce the impact of token theft. If an
access token leaks, the attacker has a smaller window to use it.

Refresh tokens or re-authentication can be used to obtain new access tokens.
Production systems should also support token revocation, device/session
tracking, and suspicious activity detection for sensitive accounts.

### 2. Where should a browser application store tokens?

**Answer:** For many web apps, an `HttpOnly`, `Secure`, `SameSite` cookie is
safer than local storage because JavaScript cannot read it directly. This helps
reduce token theft from XSS.

Cookies require CSRF protection depending on the flow. Local storage avoids
automatic cookie submission but is easier for injected JavaScript to read. The
right choice depends on threat model, client type, and authentication flow.

### 3. Why should sensitive data not be stored in a JWT payload?

**Answer:** A JWT payload is usually signed but not encrypted. Anyone with the
token can decode and read the claims.

Store only claims needed for authorization decisions or identity context, and
avoid secrets, passwords, payment data, or unnecessary PII. If confidentiality
is required, use encryption or store sensitive data server-side.

### 4. What is the difference between authentication and authorization?

**Answer:** Authentication proves who the user or client is. Authorization
decides what that identity is allowed to do.

An authenticated user may still be forbidden from an action. That is why APIs
must check both token validity and permissions, roles, ownership, or policy
rules.

### 5. How should refresh token rotation work?

**Answer:** On each refresh, issue a new refresh token and invalidate or mark
the previous one as used. If an old refresh token is reused, treat it as a
possible theft signal and revoke the session family.

Refresh token rotation limits replay attacks and gives the server a chance to
detect stolen tokens.

### 6. What is the difference between OAuth and OpenID Connect?

**Answer:** OAuth is mainly an authorization framework for delegated access.
OpenID Connect (`OIDC`) adds an identity layer on top of OAuth and defines ID
tokens for login and user identity claims.

"Login with Google" is usually OIDC for authentication, plus OAuth scopes when
the app needs access to Google APIs.

### 7. How do you design role-based access control safely?

**Answer:** Start with clear permissions, then map roles to those permissions.
Avoid scattering role checks such as `role === "admin"` throughout business
logic.

Senior systems often centralize authorization policy and include ownership,
tenant, resource state, and environment in the decision, not only user role.

### 8. What are common JWT validation mistakes?

**Answer:** Common mistakes include not verifying the signature, accepting the
wrong algorithm, ignoring expiration, trusting claims without issuer and audience
checks, using weak secrets, and failing to rotate keys.

JWT validation should check signature, algorithm, issuer, audience, expiration,
not-before time where relevant, and application-specific authorization rules.
