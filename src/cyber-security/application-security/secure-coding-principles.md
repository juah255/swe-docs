# Secure Coding Principles

Secure coding treats all input as untrusted until proven otherwise and applies
controls at trust boundaries instead of scattering checks through the code.

Principles:

- Treat input as untrusted. Assume every field, header, and parameter can be
  crafted by an attacker.
- Validate at boundaries. Enforce type, length, range, enum, and format
  constraints where input enters the system.
- Parameterize queries. Bind values instead of concatenating them into SQL,
  NoSQL, or command interpreters.
- Escape output. Encode content for the context where it is rendered so it
  cannot run as code or markup.
- Enforce authorization on every action. Never rely on a single check at the
  entry point; re-check on each sensitive operation.
- Fail closed. When a check cannot run or an error occurs, deny access instead
  of allowing it.
- Avoid secrets in code. Keep credentials out of source, logs, and frontends;
  inject them from environment or a secrets manager.
- Keep dependencies current. Apply security patches and track known
  vulnerabilities in the supply chain.
- Use defense in depth. Layer controls so a single bypass does not lead to
  compromise.

Cross-links:

- [Input validation](input-validation.md)
- [SQL injection](sql-injection.md)
- [Command injection](command-injection.md)
- [Cross-Site Scripting](xss.md)
- [Path traversal](path-traversal.md)
- [Insecure deserialization](deserialization.md)
