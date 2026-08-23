# Authentication & Authorization

Authentication and authorization control access to backend systems.
Authentication verifies the identity of a user, application, or service.
Authorization determines which resources and actions that identity may access.

## Authentication

Common authentication methods include:

- Username and password
- Multi-factor authentication
- Server-side sessions and cookies
- Access and refresh tokens
- OAuth 2.0 and OpenID Connect
- API keys
- Mutual TLS for service-to-service authentication

Authentication credentials must be transmitted over HTTPS, stored securely,
rotated when appropriate, and protected against replay and brute-force attacks.

## Authorization

Authorization should be checked for every protected action and resource. Common
models include:

- **Role-based access control (RBAC):** permissions are assigned through roles
- **Attribute-based access control (ABAC):** policies evaluate user, resource,
  action, and environment attributes
- **Access control lists (ACLs):** resources list identities and their permissions
- **Relationship-based access control (ReBAC):** access depends on relationships
  such as owner, member, or manager

Use least privilege: grant only the access required to perform a task.

## Authentication vs. Authorization

```text
Request -> authenticate identity -> authorize action -> execute operation
```

An authenticated user is not automatically authorized. For example, a valid
user may read their own account but must not read another user's account unless
a policy explicitly allows it.

Return `401 Unauthorized` when authentication is missing or invalid. Return
`403 Forbidden` when the identity is known but lacks permission. Some systems
return `404 Not Found` for private resources to avoid revealing their existence.

## Sessions and Tokens

Server-side sessions usually store an opaque identifier in a secure cookie.
Token-based systems send signed access tokens with requests. Both approaches
need expiration, revocation, credential rotation, and protection against theft.

Access tokens should be short-lived. Refresh tokens require stricter storage,
rotation, reuse detection, and revocation because they can create new access
tokens.

## Password Security

Passwords should be hashed with a password-specific algorithm such as Argon2id,
bcrypt, or scrypt. Never store plaintext passwords or encrypt them with a
reversible key.

Apply rate limiting, breached-password checks, secure reset flows, and
multi-factor authentication for sensitive accounts. Password reset tokens must
be single-use, short-lived, and stored securely.

## Common Authorization Mistakes

- Checking authentication but not resource ownership
- Trusting a user or tenant ID supplied by the client
- Enforcing permissions only in the user interface
- Using roles without action- and resource-level checks
- Omitting tenant filters from database queries or cache keys
- Allowing stale permissions to remain in long-lived tokens
- Defaulting to allow when a policy evaluation fails

Authorization belongs on the server and should fail closed.

## Service-to-Service Access

Backend services also need identities. Use short-lived workload credentials,
mutual TLS, signed service tokens, or a cloud identity system instead of shared,
long-lived secrets.

Authorize services for specific operations and audiences. Being inside a private
network is not sufficient proof of identity or permission.

## Auditing and Observability

Record important authentication and authorization events, including login
failures, credential changes, permission changes, denied actions, and access to
sensitive resources.

Audit logs should identify the actor, action, resource, result, timestamp, and
request ID without storing passwords, tokens, or other secrets.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between authentication and authorization?

**Answer:** Authentication establishes who the caller is. Authorization decides
what that caller can do. The checks are separate, and both are required for a
protected operation.

### 2. Why is hiding a button not an authorization control?

**Answer:** A client can call the API directly without using the interface. The
backend must independently authorize every protected operation based on trusted
identity and resource data.

### 3. How do you prevent cross-tenant data access?

**Answer:** Derive tenant identity from authenticated context, scope every query
and cache key by tenant, enforce ownership or policy checks, and add database
protections where possible. Never trust a tenant identifier from request input
without validating it against the caller.

### 4. What are the trade-offs between sessions and JWT access tokens?

**Answer:** Sessions make immediate revocation and centralized control easier
but require a shared session store at scale. JWTs support decentralized
verification but remain valid until expiration unless additional revocation or
version checks are introduced. Either approach can be secure when its lifecycle
and threat model are designed carefully.
