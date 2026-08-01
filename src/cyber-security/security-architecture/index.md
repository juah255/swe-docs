# Security Architecture

Security architecture is about making security a design property of the
system, not an afterthought bolted on during deployment.

This section covers threat modeling, design principles, and structured ways to
identify and reason about the risks that shape a system's design.

- [Threat Modeling](threat-modeling.md): structured reasoning about what can go
  wrong before a system is built or changed.
- [Secure Design Principles](secure-design-principles.md): core principles such
  as fail closed, least privilege, and defense in depth.
- [OWASP Top 10](owasp-top-10.md): the widely used risk list for web
  applications.
- [STRIDE](stride.md): a checklist of threat categories: spoofing, tampering,
  repudiation, information disclosure, denial of service, and elevation of
  privilege.
- [Least Privilege](least-privilege.md): grant only the access needed.
- [Defense in Depth](defense-in-depth.md): layered controls so one failure is
  not catastrophic.

See also [Security Fundamentals](../fundamentals/index.md) for the underlying
risk and control concepts.
