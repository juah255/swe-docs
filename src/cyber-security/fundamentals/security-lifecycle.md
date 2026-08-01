# Security Lifecycle

Security is applied across the software development lifecycle (SDLC), not
only at the end.

## Design

- Run threat modeling to identify risks before code is written.
- Set security requirements alongside functional requirements.

## Develop

- Use secure coding practices and framework defaults.
- Run static analysis (SAST) on every change.

## Build

- Scan dependencies for known vulnerabilities.
- Sign artifacts and verify supply-chain integrity.

## Deploy

- Harden infrastructure and apply least privilege.
- Scan infrastructure as code before it is applied.

## Operate

- Monitor for anomalies and alert on suspicious activity.
- Have an incident response plan and rehearse it.

## Review

- Revisit threats and controls regularly as the system changes.
- Track security debt alongside functional debt.

Related: [Threat, Vulnerability, Risk](threat-vulnerability-risk.md),
[Security Principles](security-principles.md).
