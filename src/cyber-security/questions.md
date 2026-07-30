# Cyber Security Interview Questions

Comprehensive index of all mid/senior interview questions across cyber security topics.
Answers are in the referenced source files.

## Fundamentals

*Source:* `cyber-security/fundamentals.md`

- What is the difference between a vulnerability, a threat, and a risk?
- What is defense in depth and how do you apply it?
- What does the principle of least privilege mean in practice?
- What is the difference between a trust boundary and an attack surface?
- What is the CIA triad and how does it apply to backend security?

## Web Security

*Source:* `cyber-security/web-security.md`

- What is CSRF and how do you prevent it?
- What is CORS, and what does it not protect?
- What is the difference between stored, reflected, and DOM-based XSS?
- How do you prevent XSS?
- What is a Content Security Policy and how do you deploy it safely?
- What does HttpOnly, Secure, and SameSite do on a cookie?
- What security headers should every backend response include?

## Authentication and Sessions

*Source:* `cyber-security/authentication-and-sessions.md`

- How should passwords be stored in a backend system?
- What is MFA and when should you enforce it?
- What makes a session ID secure?
- What are the common JWT validation mistakes?
- How does OAuth 2.0 work for delegated authorization?
- What is the difference between OAuth and OpenID Connect?
- How do you handle session expiration and renewal?

## Authorization and Access Control

*Source:* `cyber-security/authorization-and-access-control.md`

- What is insecure direct object reference and how do you fix it?
- How does RBAC differ from ABAC and ReBAC?
- How do you enforce object-level authorization?
- How do you isolate data in a multi-tenant system?
- What is privilege escalation and how do you prevent it?

## Injection and Input Validation

*Source:* `cyber-security/injection-and-input-validation.md`

- How do you prevent SQL injection?
- What is command injection and how do you prevent it?
- What is SSRF and how do you defend against it?
- What is path traversal and how do you prevent it?
- When should you use an allowlist vs a blocklist for input validation?

## Cryptography Basics

*Source:* `cyber-security/cryptography-basics.md`

- What is the difference between hashing and encryption?
- How does bcrypt or Argon2 work for password hashing?
- What is the difference between symmetric and asymmetric encryption?
- How does a TLS handshake work?
- When should you not implement cryptography yourself?

## Secrets and Key Management

*Source:* `cyber-security/secrets-and-key-management.md`

- How do you protect secrets in production?
- How do you rotate secrets without downtime?
- How do you detect secret leaks in a codebase?
- What is the difference between a KMS and an HSM?
- How do you manage encryption keys across environments?

## Secure API Design

*Source:* `cyber-security/secure-api-design.md`

- How do you authenticate API requests?
- How do you authorize each endpoint call?
- How do you protect an API from abuse?
- What makes a security log useful?
- How do you prevent sensitive data exposure in API responses?

## Network Security

*Source:* `cyber-security/network-security.md`

- What is the difference between a firewall and a WAF?
- What is mutual TLS and when should you use it?
- How do you segment a network for security?
- What is a zero-trust network architecture?
- How do you prevent data exfiltration from a backend service?

## Cloud and Container Security

*Source:* `cyber-security/cloud-and-container-security.md`

- How do you apply least privilege to cloud IAM roles?
- How do you secure a container image pipeline?
- What Kubernetes security controls matter most?
- How do you protect cloud storage buckets from unauthorized access?
- How do you handle credentials in a containerized environment?

## Dependency and Supply Chain

*Source:* `cyber-security/dependency-and-supply-chain.md`

- What are the biggest supply chain risks for backend services?
- How do you keep dependencies safe without slowing development?
- What is a software bill of materials and why does it matter?
- How do you verify build integrity in a CI pipeline?
- What is typosquatting and how do you protect against it?

## Logging, Monitoring, and Incident Response

*Source:* `cyber-security/logging-monitoring-incident-response.md`

- What information should every security log entry contain?
- How do you prevent sensitive data from appearing in logs?
- What are the phases of an incident response plan?
- How do you design an actionable security alert?
- What should a postmortem for a security incident include?

## Threat Modeling

*Source:* `cyber-security/threat-modeling.md`

- What is threat modeling and when should you do it?
- How does STRIDE help identify threats?
- What is a trust boundary and why does it matter?
- How do you prioritize threats after modeling?
- How do you keep threat models from going stale?

## Security Testing

*Source:* `cyber-security/security-testing.md`

- What is the difference between SAST and DAST?
- What should a security-focused code review look for?
- How do you write regression tests for past security vulnerabilities?
- When should you use an external penetration tester?
- How do you build a security test suite into CI/CD?
