# Application Security

Application security covers the practices that keep application code, data, and
users safe from attackers: validating input, preventing injection, controlling
how content is rendered, and hardening HTTP responses.

Attacks usually succeed because untrusted input is trusted somewhere along the
way. These topics cover the common vulnerability classes and the defenses that
stop them.

## Topics

- [Secure Coding Principles](secure-coding-principles.md): trust boundaries,
  validation, parameterization, and defense in depth.
- [Input Validation](input-validation.md): validating input at boundaries and
  validation vs sanitization.
- [Injection Attacks](injection-attacks.md): when untrusted input becomes code,
  commands, query syntax, file paths, or internal instructions.
- [SQL Injection](sql-injection.md): untrusted input changing the meaning of a
  SQL query.
- [NoSQL Injection](nosql-injection.md): query operators such as `$gt` and
  `$where` injected into database queries.
- [Command Injection](command-injection.md): untrusted input reaching an
  operating system command.
- [Cross-Site Scripting](xss.md): untrusted content running as JavaScript in a
  user's browser.
- [Cross-Site Request Forgery](csrf.md): tricks a logged-in browser into sending
  state-changing requests.
- [Server-Side Request Forgery](ssrf.md): attacker-controlled outbound request
  targets.
- [XML External Entity](xxe.md): XML parsers processing external entities.
- [File Upload Security](file-upload-security.md): safe handling of
  user-supplied files.
- [Path Traversal](path-traversal.md): input changing a filesystem path outside
  the intended directory.
- [Insecure Deserialization](deserialization.md): deserializing untrusted data
  can execute code.
- [Clickjacking](clickjacking.md): framing a page to trick users into unwanted
  clicks.
- [CORS](cors.md): which origins may read responses via browser JavaScript.
- [Content Security Policy](csp.md): restricting which resources a page may
  load.
- [Security Headers](security-headers.md): HTTP headers that support safer
  browser behavior.

## Related Topics

- [Secure API Design](../api-security/secure-api-design.md): API
  authentication, rate limits, and request validation.
- [Sessions and Cookies](../identity-and-access-management/sessions-and-cookies.md):
  session handling and cookie flags.
- [Threat Modeling](../security-architecture/threat-modeling.md): assets, actors,
  trust boundaries, and attack paths.
