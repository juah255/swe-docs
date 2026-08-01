# STRIDE

STRIDE is a common threat modeling checklist:

- **Spoofing**: pretending to be someone else.
  - Example: an attacker uses a stolen session token to act as a user.
- **Tampering**: modifying data or code.
  - Example: an attacker alters a request payload or a config file.
- **Repudiation**: denying an action without audit evidence.
  - Example: a user denies a financial transaction that was not logged.
- **Information disclosure**: exposing data to the wrong party.
  - Example: a debug endpoint leaks records the caller should not see.
- **Denial of service**: making a system unavailable.
  - Example: a flood of requests exhausts application resources.
- **Elevation of privilege**: gaining more access than intended.
  - Example: a low-privilege user reaches an admin endpoint.

See [Threat Modeling](threat-modeling.md) for how to apply STRIDE as part of a
threat model, and [Secure Design Principles](secure-design-principles.md) for
the mitigations that address these categories.
