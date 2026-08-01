# OWASP Top 10

The OWASP Top 10 is a widely used risk list for web applications. It ranks the
most common and impactful categories of weakness, and it is a useful starting
point for prioritization and secure design.

- **A01 Broken Access Control**: restrictions on what users can do are not
  enforced.
- **A02 Cryptographic Failures**: sensitive data exposed because of weak or
  missing cryptography.
- **A03 Injection**: untrusted input executed as code, queries, or commands.
- **A04 Insecure Design**: flaws in the architecture, such as missing threat
  modeling or weak business rules.
- **A05 Security Misconfiguration**: insecure defaults, open cloud storage, or
  unneeded features left enabled.
- **A06 Vulnerable and Outdated Components**: known-vulnerable libraries and
  frameworks in use.
- **A07 Identification and Authentication Failures**: weak authentication or
  session management.
- **A08 Software and Data Integrity Failures**: code or data accepted without
  integrity checks, such as tampered updates.
- **A09 Security Logging and Monitoring Failures**: attacks go undetected
  because events are not logged or monitored.
- **A10 Server-Side Request Forgery (SSRF)**: the server is tricked into
  fetching attacker-controlled URLs.

The list is a prioritization guide, not a standard. It helps teams focus on the
highest-risk categories, but it should not be treated as a compliance checklist
or a substitute for threat modeling.

Related: see [Injection Attacks](../application-security/injection-attacks.md),
[Authentication](../identity-and-access-management/authentication.md),
[Authorization](../identity-and-access-management/authorization.md),
[Secrets Management](../cryptography/secrets-management.md), and
[Logging](../monitoring-incident-response/logging.md)
for deeper coverage of several of these categories.
