# SAST

## Code Review

Review for:

- Missing authorization checks.
- Unsafe SQL or command construction.
- Unsafe rendering or DOM manipulation.
- Secret exposure.
- Weak session handling.
- Missing validation around trust boundaries.
- Dangerous defaults in infrastructure or CI/CD.

Static application security testing (SAST) automates part of this review.

## Automated Testing

Useful automated checks:

- Static application security testing (`SAST`).

SAST scans source code before it runs, which means it can find issues early in
the development cycle. It is good for CI because it is fast and runs on every
change, catching injection, authorization, and secret issues at the code level.

It has limits: SAST produces false positives, and it misses issues that only
appear at runtime, such as logic flaws and configuration problems.

See [DAST](dast.md) for runtime testing, [SCA](sca.md) for dependency
scanning, and [Penetration Testing](penetration-testing.md) for manual depth.
