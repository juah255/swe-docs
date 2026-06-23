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

## STRIDE

STRIDE is a common threat modeling checklist:

- **Spoofing**: pretending to be someone else.
- **Tampering**: modifying data or code.
- **Repudiation**: denying an action without audit evidence.
- **Information disclosure**: exposing data to the wrong party.
- **Denial of service**: making a system unavailable.
- **Elevation of privilege**: gaining more access than intended.

## Output

A useful threat model produces concrete mitigations, test cases, ownership, and
follow-up tasks. It should not be only a diagram.
