# Security Testing

Security testing checks whether controls work and whether changes introduce new
risks.

This section covers the automated and manual testing techniques used to find
vulnerabilities before attackers do.

- [SAST](sast.md): static analysis of source code for vulnerabilities.
- [DAST](dast.md): dynamic testing of a running application like an attacker.
- [SCA](sca.md): scanning dependencies for known vulnerabilities.
- [Penetration Testing](penetration-testing.md): authorized manual security
  testing of the system.
- [Vulnerability Assessment](vulnerability-assessment.md): systematic scanning
  for known weaknesses.
- [Fuzz Testing](fuzz-testing.md): feeding malformed input to find crashes and
  bugs.

See also [Threat Modeling](../security-architecture/threat-modeling.md) for
finding what to test and [Secure Design Principles](../security-architecture/secure-design-principles.md)
for the controls testing verifies.
