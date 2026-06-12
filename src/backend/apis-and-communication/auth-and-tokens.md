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
