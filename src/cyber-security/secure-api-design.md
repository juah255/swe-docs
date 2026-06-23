# Secure API Design

Secure APIs validate identity, authorization, input, output, and usage patterns.

## Authentication

Common API authentication methods:

- Session cookies for browser-backed APIs.
- Bearer tokens for service or client APIs.
- OAuth/OIDC for delegated access.
- API keys for simple service identification.
- Mutual TLS for high-trust service-to-service communication.

API keys identify callers but are not enough for fine-grained user-level
authorization.

## Authorization

- Enforce authorization on every sensitive endpoint.
- Check object-level access, not only route-level access.
- Do not trust client-provided role or tenant fields.
- Use scoped tokens for limited access.
- Return minimal information on authorization failure.

## Request and Response Design

- Validate request bodies, query params, headers, and path params.
- Limit payload size.
- Use pagination for list endpoints.
- Avoid exposing internal errors, stack traces, or secrets.
- Use idempotency keys for retryable write operations such as payments or order
  creation.

## Abuse Resistance

- Rate-limit expensive or sensitive endpoints.
- Add account lockout or step-up verification for suspicious behavior.
- Protect password reset, login, signup, and search endpoints.
- Monitor unusual usage patterns.
- Use audit logs for admin and data-export actions.
