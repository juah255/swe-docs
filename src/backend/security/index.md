# Security

Backend security is about protecting systems, data, and users from unauthorized access, misuse, and attacks. It covers who can access resources (authentication), what they can do (authorization), how credentials and sessions are managed, and how common attack vectors are mitigated.

Key areas of backend security include:

- **Authentication** -- verifying identity (passwords, tokens, MFA, OAuth2, OIDC)
- **Authorization** -- controlling access (RBAC, ABAC, ACL, policies)
- **Sessions and Cookies** -- managing state securely (HttpOnly, Secure, SameSite, CSRF)
- **JWT and Tokens** -- token lifecycle (access, refresh, rotation, revocation)
- **Password Security** -- hashing, salting, and password policies
- **API Security** -- CORS, XSS, SQL injection, rate limiting, input validation, security headers
- **HTTPS and TLS** -- encrypting data in transit
- **OWASP Top 10** -- the most critical web application security risks

Security is not a feature added at the end. It must be considered from the start of system design and maintained throughout the lifecycle of the application.

## Core Principles

- **Defense in depth** -- multiple layers of security so that a single failure does not compromise the system
- **Least privilege** -- grant only the minimum access needed for a task
- **Separation of concerns** -- authentication, authorization, and business logic should be separate
- **Fail securely** -- errors should deny access, not grant it
- **Don't roll your own crypto** -- use well-tested libraries and protocols

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between authentication and authorization?

**Answer:** Authentication proves who the user or client is. Authorization
decides what that identity is allowed to do.

An authenticated user may still be forbidden from an action. Systems must check
both identity and permissions independently.

### 2. What does "defense in depth" mean in backend security?

**Answer:** Defense in depth means applying multiple layers of security controls
so that if one layer fails, others still protect the system.

For example, input validation, parameterized queries, ORM restrictions, and
database permissions together protect against SQL injection more reliably than
any single measure.

### 3. Why should you never build your own cryptographic algorithms?

**Answer:** Cryptographic algorithms are extremely difficult to get right.
Subtle implementation mistakes can make encryption trivially breakable.

Use well-audited, widely adopted libraries and standards. Even using a correct
algorithm incorrectly (wrong mode, weak keys, poor random number generation)
creates vulnerabilities.

### 4. How do you approach security in a microservices architecture?

**Answer:** Use mutual TLS or a service mesh for service-to-service
communication, centralized authentication (OAuth2/OIDC), token propagation,
least-privilege service accounts, secrets management, network policies,
and consistent audit logging.

Each service should validate tokens independently and not trust headers from
other services blindly.

### 5. What is the OWASP Top 10 and why does it matter?

**Answer:** The OWASP Top 10 is a regularly updated list of the most critical
web application security risks published by the Open Web Application Security
Project.

It provides a common framework for understanding, prioritizing, and mitigating
risks such as injection, broken authentication, XSS, and insecure design. It is
a baseline for security reviews and compliance.
