# Cyber Security Interview Questions

Comprehensive index of all mid/senior interview questions across cyber security topics.
Answers are in the referenced source files.

## 1. Fundamentals

*Source:* `cyber-security/fundamentals/`

- What is the difference between a vulnerability, a threat, and a risk?
- What is the CIA triad and how does it apply to backend security?
- What is defense in depth and how do you apply it?
- What does the principle of least privilege mean in practice?
- What is the difference between a trust boundary and an attack surface?
- How do you reduce the attack surface of a service?
- What is a zero-trust network architecture?
- Where in the software lifecycle do you apply security?

## 2. Identity and Access Management

*Source:* `cyber-security/identity-and-access-management/`

- How should passwords be stored in a backend system?
- What is MFA and when should you enforce it?
- What makes a session ID secure?
- What does HttpOnly, Secure, and SameSite do on a cookie?
- What are the common JWT validation mistakes?
- When would you choose opaque server-side sessions over JWTs?
- How does OAuth 2.0 work for delegated authorization?
- What is the difference between OAuth and OpenID Connect?
- What is insecure direct object reference and how do you fix it?
- How does RBAC differ from ABAC and ReBAC?
- How do you enforce object-level authorization?
- How do you isolate data in a multi-tenant system?
- What is privilege escalation and how do you prevent it?

## 3. Application Security

*Source:* `cyber-security/application-security/`

- How do you prevent SQL injection?
- What is NoSQL injection and how is it different from SQL injection?
- What is command injection and how do you prevent it?
- What is the difference between stored, reflected, and DOM-based XSS?
- How do you prevent XSS?
- What is CSRF and how do you prevent it?
- What is SSRF and how do you defend against it?
- What is XXE and how do you prevent it?
- How do you secure a file upload feature?
- What is path traversal and how do you prevent it?
- What is insecure deserialization and why is it dangerous?
- What is clickjacking and how do you prevent it?
- What is CORS, and what does it not protect?
- What is a Content Security Policy and how do you deploy it safely?
- What security headers should every backend response include?
- When should you use an allowlist vs a blocklist for input validation?

## 4. API Security

*Source:* `cyber-security/api-security/`

- How do you authenticate API requests?
- How do you authorize each endpoint call?
- How do you protect an API from abuse?
- How do rate limiting strategies differ?
- When should you use API keys vs OAuth tokens?
- What is an HMAC signature and what does it protect against?
- How do you verify an incoming webhook?
- What security concerns are specific to GraphQL?
- How do you secure service-to-service calls in gRPC?
- How do you prevent sensitive data exposure in API responses?

## 5. Cryptography

*Source:* `cyber-security/cryptography/`

- What is the difference between hashing and encryption?
- How does bcrypt or Argon2 work for password hashing?
- What is the difference between symmetric and asymmetric encryption?
- What is a digital signature and when would you use one?
- What is in an X.509 certificate?
- What is a certificate chain and why does it matter?
- How does a TLS handshake work?
- When should you not implement cryptography yourself?
- How do you protect secrets in production?
- How do you rotate secrets without downtime?
- How do you detect secret leaks in a codebase?
- What is the difference between a KMS and an HSM?
- How do you manage encryption keys across environments?

## 6. Infrastructure Security

*Source:* `cyber-security/infrastructure-security/`

- What is the difference between a firewall and a WAF?
- What is mutual TLS and when should you use it?
- How do you segment a network for security?
- What is a zero-trust network architecture?
- How do you prevent data exfiltration from a backend service?
- What DNS-related attacks should you protect against?
- How do you apply least privilege to cloud IAM roles?
- How do you secure a container image pipeline?
- What Kubernetes security controls matter most?
- How do you protect cloud storage buckets from unauthorized access?
- How do you harden a server operating system?
- How do you handle credentials in a containerized environment?

## 7. Software Supply Chain

*Source:* `cyber-security/software-supply-chain/`

- What are the biggest supply chain risks for backend services?
- How do you keep dependencies safe without slowing development?
- What is a software bill of materials and why does it matter?
- How do you verify build integrity in a CI pipeline?
- What is typosquatting and how do you protect against it?
- How do you prioritize vulnerabilities found by scanning?
- Why sign artifacts and container images?
- How do you secure secrets in a CI/CD pipeline?

## 8. Security Architecture

*Source:* `cyber-security/security-architecture/`

- What is threat modeling and when should you do it?
- How does STRIDE help identify threats?
- What is a trust boundary and why does it matter?
- How do you prioritize threats after modeling?
- How do you keep threat models from going stale?
- What are the OWASP Top 10 and how should you use them?
- How do you apply least privilege across an architecture?

## 9. Monitoring and Incident Response

*Source:* `cyber-security/monitoring-incident-response/`

- What information should every security log entry contain?
- How do you prevent sensitive data from appearing in logs?
- What is a SIEM and when does it make sense?
- What is the difference between IDS and IPS?
- What are the phases of an incident response plan?
- How do you design an actionable security alert?
- What should a postmortem for a security incident include?
- How do you preserve evidence during a security investigation?

## 10. Security Testing

*Source:* `cyber-security/security-testing/`

- What is the difference between SAST and DAST?
- What is software composition analysis and what does it catch?
- What should a security-focused code review look for?
- How do you write regression tests for past security vulnerabilities?
- When should you use an external penetration tester?
- What is the difference between a vulnerability assessment and a penetration test?
- What is fuzz testing and where does it add value?
- How do you build a security test suite into CI/CD?
