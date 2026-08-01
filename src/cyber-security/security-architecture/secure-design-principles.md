# Secure Design Principles

Security is a design property. It has to be designed in from the start, because
it cannot reliably be bolted on later. These principles guide that design.

- **Fail closed**: deny access when authorization or validation cannot be
  completed; never let a failure silently grant access.
- **Least privilege**: grant only the access needed for the job.
- **Defense in depth**: use multiple layers of protection so one failure is not
  catastrophic.
- **Minimize attack surface**: remove unneeded features, services, ports, and
  code that an attacker could use.
- **Complete mediation**: check authorization on every sensitive action.
- **Secure by default**: the default behavior should be safe.
- **Separation of duties**: avoid giving one user or service too much power.
- **Assume breach**: design and monitor as if an attacker is already inside.
- **Don't trust user input**: validate and sanitize input at every trust
  boundary.
- **Log and audit**: log sensitive actions with enough context to investigate
  later.

Related: [OWASP Top 10](owasp-top-10.md) describes the most common failure
classes in practice, and [Least Privilege](least-privilege.md) digs into one of
the core principles. See also [Defense in Depth](defense-in-depth.md) and the
fundamentals view in
[../fundamentals/security-principles.md](../fundamentals/security-principles.md).
