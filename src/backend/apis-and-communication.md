# APIs and Communication

## What is a REST API?

A **REST API** is a **stateless**, HTTP-based interface through which clients can access and manipulate server resources by using HTTP methods on URL endpoints.

**Stateless** means the server does not remember previous requests. Each request must include all data needed to process it, such as authentication tokens or parameters.

## Difference Between `GET` and `POST`

- `GET` retrieves data from the server.
- `POST` sends data to create a new resource.

## Refresh Token and Access Token

- **Access token**: a short-lived token used to access protected resources.
- **Refresh token**: a longer-lived token used to obtain a new access token when the old one expires.

## What is JWT?

**JWT** (JSON Web Token) is a compact, URL-safe, digitally signed token format used to securely transmit claims such as user identity between parties. A JWT usually has **three parts**:

```text
header.payload.signature
```

### Why JWT is URL-safe

- **JWT uses Base64Url encoding** instead of standard Base64.
- **Base64Url avoids characters** such as `+`, `/`, and `=`, which are awkward inside URLs.
- It uses URL-friendly characters such as `-` and `_`.

### What “digitally signed” means

- **The token is signed** with a secret key or a public/private key pair.
- **The signature provides**:
  - **Integrity**: the token data was not changed.
  - **Authenticity**: the token was issued by a trusted party.
- Signing is not encryption. The payload is readable if decoded, but changing it breaks the signature.

### JWT structure

#### Header

Contains metadata about the token.

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

#### Payload

Contains claims, such as user identity or role.

```json
{
  "userId": 1,
  "email": "user@example.com",
  "role": "admin"
}
```

#### Signature

Generated using a secret or private key to ensure the token has **not been modified**.

### Typical JWT authentication flow

1. User submits email and password.
2. Server verifies the credentials.
3. Server creates a JWT containing user information.
4. Server returns the token to the client.
5. Client stores the token, usually in memory or an `HttpOnly` cookie.
6. Client sends the token with each request:

```http
Authorization: Bearer <token>
```

7. Server verifies the token and identifies the user.

### Why JWT is useful

- **Stateless authentication**
- **Scales well** across multiple servers
- **Works well** with SPAs and mobile apps
- **Can include useful claims** such as user ID and role

## Stateful vs. Stateless Authentication

- **Stateful authentication** stores session data on the server and identifies users via a session ID.
- **Stateless authentication** stores user-related claims in a signed token such as JWT, so the server does not need to keep session state.

**Stateless authentication scales more easily**, but token revocation is harder.

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

**OAuth** is an authorization framework that allows third-party applications to access user data without sharing the user's password. Instead, it uses access tokens with limited permissions.

Common examples include "Login with Google" and "Login with Facebook".

## Middleware

**Middleware** is reusable code that runs between a request and a response to handle common tasks such as:

- Authentication
- Logging
- Validation
- Error handling

## Controller

A **controller** handles the incoming request, calls the necessary business logic or service, and returns the response.

## Service, Provider, Repository

### Service

A **service** is a backend class or module that contains application business logic.

### Provider

A **provider** is a reusable class that contains shared logic or functionality and can be injected into other parts of the application through dependency injection.

All services can be providers, but not all providers are services.

### Repository

A **repository** is a data access layer abstraction used to read from and write to a data source, usually a database.

## Business Logic

**Business logic** is the set of rules that defines how an application behaves according to real-world business requirements.

Example business requirement:

> A customer should not be able to order a product if it is out of stock.

The implementation that enforces that rule is business logic.

## DTO

A **DTO** (Data Transfer Object) is an object used to carry data between layers or systems. DTOs are commonly used for:

- Validation
- Type safety
- Cleaner code boundaries
- Controlling what data enters or leaves the application

## Route Design

**Good route design uses nouns instead of actions**, because the HTTP method already describes the action.
