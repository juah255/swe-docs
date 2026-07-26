# Security

**Security** in system design is about protecting data, systems, and users from unauthorized access, misuse, and attacks. It must be considered from the start, not bolted on at the end.

## Core Principles

- **Defense in depth** -- multiple layers of security so a single failure does not compromise the system
- **Least privilege** -- grant only the minimum access needed for a task
- **Fail securely** -- errors should deny access, not grant it
- **Don't roll your own crypto** -- use well-tested libraries and standards

## Key Areas

- **Authentication** -- verifying identity (passwords, tokens, MFA, OAuth2, OIDC)
- **Authorization** -- controlling access (RBAC, ABAC, ACL, policies)
- **Encryption in transit** -- TLS for all data moving between services
- **Encryption at rest** -- encrypt stored data (databases, object storage)
- **Rate limiting** -- prevent abuse and brute-force attacks
- **Input validation** -- reject unexpected data before it reaches business logic
- **Secrets management** -- never hardcode keys, use secrets managers or env vars
- **Audit logging** -- track who did what and when for sensitive operations

## How Security Drives Architecture

- Authentication and authorization at the API gateway or service mesh
- Encryption everywhere (TLS internally, not just at the edge)
- Network segmentation and firewall rules between services
- Secrets rotation and management
- Compliance requirements (GDPR, HIPAA, PCI DSS) constrain data storage and processing location

## Levers

- Authentication and authorization (OAuth2, OIDC, RBAC, ABAC)
- Encryption in transit (TLS) and at rest
- Least privilege and zero-trust principles
- Input validation and parameterized queries
- Secret management (vaults, env vars, rotation)
- Audit logging and regular patching

## Trade-offs

- Security friction slows developer velocity
- Stronger auth adds UX friction for end users
- Compliance requirements constrain architecture choices
- Security is a cross-cutting concern that must be baked into every layer, not bolted on

## Mid/Senior Interview Questions and Answers

### 1. What does "defense in depth" mean in backend security?

**Answer:** Apply multiple layers of security controls so that if one layer
fails, others still protect the system.

For example, input validation, parameterized queries, ORM restrictions, and
database permissions together protect against SQL injection more reliably than
any single measure.

### 2. Why should you never build your own cryptographic algorithms?

**Answer:** Cryptographic algorithms are extremely difficult to get right.
Subtle implementation mistakes can make encryption trivially breakable.

Use well-audited, widely adopted libraries and standards. Even using a correct
algorithm incorrectly (wrong mode, weak keys, poor random number generation)
creates vulnerabilities.

### 3. How do you approach security in a microservices architecture?

**Answer:** Use mutual TLS or a service mesh for service-to-service
communication, centralized authentication (OAuth2/OIDC), token propagation,
least-privilege service accounts, secrets management, network policies,
and consistent audit logging.

Each service should validate tokens independently and not trust headers from
other services blindly.
