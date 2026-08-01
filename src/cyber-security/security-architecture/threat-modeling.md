# Threat Modeling

Threat modeling is a structured way to reason about what can go wrong before a
system is built or changed.

## What To Identify

- Assets.
- Actors.
- Entry points.
- Trust boundaries.
- Sensitive data flows.
- Permissions.
- External dependencies.
- High-impact failure modes.

## Useful Questions

- What data is most sensitive?
- Who can access it?
- What happens if this endpoint is called by the wrong user?
- What happens if a dependency is unavailable or malicious?
- Can user input reach a query, command, file path, redirect, or internal URL?
- Can one tenant access another tenant's data?
- What needs to be logged for investigation?

## Output

A useful threat model produces concrete mitigations, test cases, ownership, and
follow-up tasks. It should not be only a diagram.

See [STRIDE](stride.md) for a common checklist of threat categories to work
through, and [Secure Design Principles](secure-design-principles.md) for the
principles that guide the mitigations.
