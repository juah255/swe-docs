# REST Security

REST APIs are HTTP APIs organized around resources and methods. Their security
follows from applying the same controls to every endpoint: authenticate,
authorize, validate, and protect transport and data.

## Authentication and Authorization

- Apply authentication and authorization to every endpoint, not just the ones
  that look sensitive. See [API Authentication](api-authentication.md) and
  [API Authorization](api-authorization.md).
- Check object-level access for every resource request, not just route-level
  access.
- Use scoped tokens and idempotency where writes are involved.

## Transport and Input

- Use HTTPS for every endpoint; redirect or reject plain HTTP.
- Validate request bodies, query params, headers, and path params against a
  schema.
- Limit payload size and use pagination on list endpoints so a single request
  cannot pull an unbounded dataset.

## Errors and Leakage

- Avoid leaking internal errors, stack traces, or secrets in responses.
- Return generic error messages to clients and log the detail server-side.
- Never expose API keys or signing secrets in URLs; send them in headers.

## Safe HTTP Usage

- Keep `GET` (and `HEAD`/`OPTIONS`) side-effect-free: no state changes in
  reads, so links and caches cannot mutate data.
- Use proper status codes and methods (`POST` for creation, `PUT` for replace,
  `PATCH` for partial update, `DELETE` for removal).
- Use idempotency keys for retryable writes such as payments or order
  creation, as noted in [Secure API Design](secure-api-design.md).

## Versioning and Content Negotiation

- Version the API (URL, header, or content type) so breaking changes do not
  silently break old clients.
- Validate `Content-Type` and `Accept` headers and reject unsupported
  representations.

See [Rate Limiting](rate-limiting.md) for protecting endpoints from abuse.
