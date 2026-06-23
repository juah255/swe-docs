# Security Fundamentals

Security work starts with understanding risk and reducing it with practical
controls.

## Core Terms

- **Asset**: something valuable, such as user data, credentials, money, source
  code, infrastructure, or availability.
- **Threat**: a possible harmful event or actor.
- **Vulnerability**: a weakness that could be exploited.
- **Risk**: the likelihood and impact of a threat exploiting a vulnerability.
- **Control**: a safeguard that reduces likelihood or impact.
- **Attack surface**: all places an attacker can interact with the system.
- **Trust boundary**: a point where data or control crosses between different
  levels of trust.

## Core Principles

- **Least privilege**: grant only the access needed for the job.
- **Defense in depth**: use multiple layers of protection.
- **Secure by default**: the default behavior should be safe.
- **Fail closed**: deny access when authorization or validation cannot be
  completed.
- **Complete mediation**: check authorization on every sensitive action.
- **Separation of duties**: avoid giving one user or service too much power.
- **Auditable actions**: log sensitive actions with enough context to investigate
  later.

## Practical Engineering View

Security is a system property. A secure password hash does not help if session
cookies are stolen. Strong authorization logic does not help if object IDs are
checked in one endpoint but not another.

A senior security answer connects the control to the failure mode it prevents.
