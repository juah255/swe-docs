# Cyber Security

Cyber security is the practice of protecting applications, infrastructure,
data, users, and delivery systems from misuse, compromise, and accidental
exposure.

For software engineers, security is not a separate phase. It affects design,
implementation, deployment, operations, dependency management, and incident
response.

## Learning Path

Follow these topics in order when learning cyber security for software
engineering:

1. [Security Fundamentals](fundamentals.md): risk, threat, vulnerability,
   controls, least privilege, and defense in depth.
2. [Web Security](web-security.md): browser security, XSS, CSRF, CORS, cookies,
   headers, and content security policy.
3. [Authentication and Sessions](authentication-and-sessions.md): login,
   passwords, MFA, sessions, cookies, JWTs, OAuth, and OIDC.
4. [Authorization and Access Control](authorization-and-access-control.md):
   RBAC, ABAC, object-level authorization, tenancy, and permission checks.
5. [Injection and Input Validation](injection-and-input-validation.md): SQL
   injection, command injection, SSRF, path traversal, and validation.
6. [Cryptography Basics](cryptography-basics.md): hashing, encryption,
   signatures, TLS, password hashing, and key handling.
7. [Secrets and Key Management](secrets-and-key-management.md): credentials,
   environment variables, vaults, rotation, and leakage prevention.
8. [Secure API Design](secure-api-design.md): API authentication, rate limits,
   request validation, idempotency, pagination, and abuse resistance.
9. [Network Security](network-security.md): firewalls, TLS, VPNs, segmentation,
   private networking, and zero trust basics.
10. [Cloud and Container Security](cloud-and-container-security.md): IAM,
    storage policies, container images, Kubernetes, and runtime controls.
11. [Dependency and Supply Chain Security](dependency-and-supply-chain.md):
    package risk, lockfiles, SBOMs, signing, CI/CD, and build integrity.
12. [Logging, Monitoring, and Incident Response](logging-monitoring-incident-response.md):
    audit logs, alerts, detection, triage, containment, and post-incident
    reviews.
13. [Threat Modeling](threat-modeling.md): assets, actors, trust boundaries,
    attack paths, and mitigations.
14. [Security Testing](security-testing.md): code review, SAST, DAST,
    dependency scanning, penetration testing, and regression tests.

## Suggested Practice

- Add CSRF protection to a form-based web application.
- Fix an insecure direct object reference by enforcing object-level access
  control.
- Convert unsafe SQL string concatenation to parameterized queries.
- Add secure cookie flags and review session lifetime behavior.
- Create a basic threat model for a file-upload feature.
- Add dependency scanning to a CI pipeline.
- Write an incident runbook for leaked credentials.

## Interview Preparation

Use [Cyber Security Questions](questions.md) for mid/senior interview questions
and answers.
