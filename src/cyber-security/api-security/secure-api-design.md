# Secure API Design

Secure APIs validate identity, authorization, input, output, and usage patterns.

See [API Authentication](api-authentication.md) and
[API Authorization](api-authorization.md) for those topics.

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

See [Rate Limiting](rate-limiting.md) for choosing limits and responses.
