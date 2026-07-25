# OWASP Top 10

The **OWASP Top 10** is a regularly updated list of the most critical web application security risks, published by the Open Web Application Security Project. It is a standard awareness document and a baseline for application security.

## A01: Broken Access Control

Access control enforces policy so users cannot act outside their intended permissions. Failures lead to unauthorized information disclosure, modification, or destruction.

Common issues:

- Violation of the principle of least privilege
- Bypassing access control checks by modifying URLs, API requests, or HTML pages
- Viewing or editing another user's account by providing its unique identifier
- Accessing API with missing access controls for POST, PUT, and DELETE
- Privilege escalation (acting as admin when logged in as a user)
- Metadata manipulation (replaying or tampering with JWT tokens)

Prevention:

- Deny by default
- Implement access control mechanisms once and reuse them
- Model-based access control (ownership, tenant, role)
- Disable web server directory listing
- Log and alert access control failures

## A02: Cryptographic Failures

Previously known as "Sensitive Data Exposure." Failures related to cryptography that lead to exposure of sensitive data.

Common issues:

- Data transmitted in plaintext (HTTP, FTP, SMTP)
- Weak or outdated algorithms (MD5, SHA-1, DES)
- Default crypto keys or weak key generation
- Missing or incorrect use of TLS
- Hardcoded encryption keys

Prevention:

- Classify data and apply controls based on sensitivity
- Enforce TLS for all data in transit
- Use strong, current algorithms (AES-GCM, RSA-2048+, Ed25519)
- Use a proper key management process
- Do not store sensitive data unnecessarily

## A03: Injection

Injection occurs when untrusted data is sent to an interpreter as part of a command or query.

Types:

- **SQL injection** -- malicious SQL via user input
- **NoSQL injection** -- malicious queries in NoSQL databases
- **OS command injection** -- executing system commands via user input
- **LDAP injection** -- manipulating LDAP queries
- **XPath injection** -- manipulating XML queries
- **SSI injection** -- server-side includes

Prevention:

- Use parameterized queries (prepared statements)
- Use ORMs with proper escaping
- Validate and sanitize input on the server
- Use LIMIT and other SQL controls to prevent mass disclosure
- Run SAST and DAST tools

## A04: Insecure Design

Insecure design refers to missing or ineffective security controls at the architectural level. It is not about implementation bugs but about design flaws.

Examples:

- Missing threat modeling
- No rate limiting on sensitive endpoints
- Exposing detailed error messages to users
- Missing multi-tenant isolation
- No segregation of tenant data

Prevention:

- Establish secure development lifecycle (SDLC)
- Use threat modeling during design
- Write security user stories and abuse cases
- Integrate security patterns and reference architectures
- Use secure design principles (separation of duties, least privilege)

## A05: Security Misconfiguration

Missing appropriate security hardening across any part of the application stack.

Common issues:

- Default accounts and passwords enabled
- Error handling that reveals stack traces or internal details
- Missing security headers
- Unnecessary features enabled (ports, services, accounts)
- Cloud storage permissions set to public
- Verbose error messages in production

Prevention:

- Repeatable hardening process across environments
- Minimal platform (remove unused features, frameworks, documentation)
- Review and update configurations regularly
- Automated configuration verification
- Segmented application architecture

## A06: Vulnerable and Outdated Components

Using components (libraries, frameworks, OS) with known vulnerabilities.

Common issues:

- Not knowing which components are in use
- Not scanning for vulnerabilities regularly
- Not fixing or upgrading vulnerable components
- Not securing component configurations
- Using unsupported or end-of-life software

Prevention:

- Remove unused dependencies
- Continuously inventory components and versions
- Monitor CVE and NVD for vulnerabilities
- Only obtain components from official sources
- Monitor for unmaintained libraries

## A07: Identification and Authentication Failures

Confirmation of the user's identity, authentication, and session management is critical to protect against authentication-related attacks.

Common issues:

- Permitting brute-force or credential stuffing attacks
- Permitting weak passwords
- Missing or ineffective multi-factor authentication
- Exposing session identifiers in the URL
- Not properly invalidating sessions on logout

Prevention:

- Implement MFA
- Do not deploy with default credentials
- Check against breached password databases
- Limit failed login attempts
- Use a server-side, secure session manager

## A08: Software and Data Integrity Failures

Failures relating to code and infrastructure that does not protect against integrity violations. Includes insecure CI/CD pipelines and auto-update mechanisms without verification.

Common issues:

- Insecure deserialization (accepting serialized objects without validation)
- CI/CD pipeline compromise
- Auto-update without signature verification
- Insecure plugins or libraries from untrusted sources
- Software supply chain attacks

Prevention:

- Use digital signatures to verify software/data integrity
- Review code and configuration changes
- Ensure CI/CD pipelines have proper segregation and access control
- Do not send unsigned or unencrypted serialized data to untrusted clients
- Use SBOM (Software Bill of Materials) to track dependencies

## A09: Security Logging and Monitoring Failures

Insufficient logging, detection, monitoring, and active response allows attackers to further attack, maintain persistence, and tamper with data.

Without proper logging:

- Breaches go undetected
- Incident response is delayed
- Forensic analysis is impossible
- Compliance requirements are not met

What to log:

- Login attempts (successful and failed)
- Access control failures
- Input validation failures
- Server-side errors
- High-value transactions

Best practices:

- Log in a format consumable by log management solutions
- Use centralized logging (ELK, Datadog, Splunk)
- Set up real-time alerts for suspicious patterns
- Establish an incident response plan
- Test logging and monitoring regularly

## A10: Server-Side Request Forgery (SSRF)

SSRF occurs when an application fetches a remote resource based on a user-supplied URL without proper validation.

Attack:

```text
User input: https://internal-server/admin
Application fetches the URL, exposing internal resources
```

Risks:

- Accessing internal services (databases, metadata endpoints)
- Port scanning internal networks
- Reading local files
- Remote code execution in some cases

Prevention:

- Validate and sanitize user-supplied URLs
- Whitelist allowed domains and protocols
- Disable unnecessary URL schemes
- Use network segmentation to limit internal access
- Do not return raw responses from fetched URLs

## Mid/Senior Interview Questions and Answers

### 1. How does broken access control differ from broken authentication?

**Answer:** Broken authentication means an attacker can impersonate a user
(weak passwords, credential stuffing, session hijacking). Broken access control
means an authenticated user can do things they should not be able to do
(privilege escalation, accessing other users' data).

A user can be properly authenticated but still have broken access control if
the application does not check what they are allowed to do.

### 2. Why is injection still in the OWASP Top 10 after decades?

**Answer:** New injection vectors emerge with new technologies (NoSQL, GraphQL,
ORM raw queries). Developers still write raw queries, use string concatenation,
or bypass ORM protections.

Injection remains critical because the impact is severe (full database
compromise) and the defense (parameterized queries, input validation) is
well-understood but inconsistently applied.

### 3. What is the difference between insecure design and security misconfiguration?

**Answer:** Insecure design is a flaw in the architecture or requirements -- the
system was never designed to handle a specific threat. Security misconfiguration
is a deployment or operational error -- the system was designed correctly but
configured wrong.

For example, missing rate limiting on login is insecure design. Having default
admin credentials in production is security misconfiguration.

### 4. How do you protect against SSRF?

**Answer:** Validate user-supplied URLs against a whitelist of allowed domains
and protocols. Disable URL schemes other than HTTP/HTTPS. Use network
segmentation so the application cannot reach sensitive internal services.

For applications that must fetch user-provided URLs (webhooks, file imports),
use a dedicated proxy or sandbox with restricted network access. Never return
raw responses from internal fetches.

### 5. Why is security logging and monitoring in the OWASP Top 10?

**Answer:** Without logging and monitoring, breaches go undetected. Attackers
can maintain persistence, exfiltrate data, and tamper with systems without
triggering alerts.

Effective logging enables detection, incident response, forensic analysis, and
compliance. It is one of the most cost-effective security measures and is
required by most regulatory frameworks (PCI DSS, SOC 2, GDPR).
