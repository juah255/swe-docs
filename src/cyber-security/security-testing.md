# Security Testing

Security testing checks whether controls work and whether changes introduce new
risks.

## Code Review

Review for:

- Missing authorization checks.
- Unsafe SQL or command construction.
- Unsafe rendering or DOM manipulation.
- Secret exposure.
- Weak session handling.
- Missing validation around trust boundaries.
- Dangerous defaults in infrastructure or CI/CD.

## Automated Testing

Useful automated checks:

- Static application security testing (`SAST`).
- Dependency scanning.
- Secret scanning.
- Container image scanning.
- Infrastructure-as-code scanning.
- Dynamic application security testing (`DAST`).

Automated tools find classes of issues, but they do not replace design review.

## Security Regression Tests

Write regression tests for fixed vulnerabilities.

Examples:

- User A cannot read User B's object.
- Deleted sessions cannot access protected endpoints.
- Invalid CSRF token blocks state-changing requests.
- Unsafe file paths are rejected.
- SQL inputs are treated as values, not query syntax.

## Penetration Testing

Penetration testing is useful before major launches, after large architecture
changes, or for compliance requirements. Findings should become tracked
engineering work with owners and deadlines.
