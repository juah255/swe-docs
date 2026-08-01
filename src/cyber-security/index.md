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

1. [Fundamentals](fundamentals/index.md): CIA triad, security principles,
   threat/vulnerability/risk, attack surface, defense in depth, zero trust, and
   the security lifecycle.
2. [Identity and Access Management](identity-and-access-management/index.md):
   authentication, authorization, sessions, JWTs, OAuth 2.0, OIDC, MFA, and
   password security.
3. [Application Security](application-security/index.md): injection, XSS, CSRF,
   SSRF, XXE, file uploads, deserialization, CORS, CSP, and security headers.
4. [API Security](api-security/index.md): secure API design, authentication,
   authorization, rate limiting, API keys, HMAC signatures, webhooks, and
   GraphQL/REST/gRPC.
5. [Cryptography](cryptography/index.md): hashing, encryption, signatures,
   certificates, PKI, HTTPS/TLS, and secrets and key management.
6. [Infrastructure Security](infrastructure-security/index.md): network
   security, firewalls, VPN, DNS, cloud, containers, Kubernetes, and OS
   hardening.
7. [Software Supply Chain](software-supply-chain/index.md): dependency security,
   SBOMs, vulnerability scanning, package signing, and CI/CD security.
8. [Security Architecture](security-architecture/index.md): threat modeling,
   secure design principles, OWASP Top 10, and STRIDE.
9. [Monitoring and Incident Response](monitoring-incident-response/index.md):
   logging, security monitoring, SIEM, IDS/IPS, incident response, and forensics
   basics.
10. [Security Testing](security-testing/index.md): SAST, DAST, SCA, penetration
    testing, vulnerability assessment, and fuzz testing.

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
