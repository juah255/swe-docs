# Attack Surface

The attack surface is all the places an attacker can interact with a
system: every endpoint, interface, input, and channel that accepts data or
control.

## Entry Points

- APIs and web endpoints.
- Authentication and authorization endpoints.
- File uploads and file processing.
- Admin and management interfaces.
- Third-party integrations and webhooks.
- Public assets such as static files and download links.
- Error pages and anything that reflects user input.

## Reducing the Attack Surface

- Minimize exposed features: ship only what users need.
- Harden defaults: disable unneeded services and verbose errors.
- Close unused ports, endpoints, and routes.
- Reduce dependencies and remove unused libraries.
- Apply least privilege to service accounts and network rules.

Every entry point crosses a [trust boundary](threat-vulnerability-risk.md),
so each one should be designed and tested with that in mind.
