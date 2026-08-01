# DAST

## Automated Testing

Useful automated checks:

- Dynamic application security testing (`DAST`).

DAST tests a running application the way an attacker would: sending requests
and observing the responses. Because it exercises the live system, it catches
runtime issues and configuration problems that static analysis misses.

Run DAST against staging environments, not production. It is slower than SAST
and often requires authentication and session handling to reach protected
features.

See [SAST](sast.md) for static analysis, and [Fuzz Testing](fuzz-testing.md)
for malformed-input testing at runtime.
