# API Authentication

Common API authentication methods:

- Session cookies for browser-backed APIs.
- Bearer tokens for service or client APIs.
- OAuth/OIDC for delegated access.
- API keys for simple service identification.
- Mutual TLS for high-trust service-to-service communication.

API keys identify callers but are not enough for fine-grained user-level
authorization.

Choosing between methods:

- Browser-backed APIs generally need session cookies or an OAuth/OIDC flow so
  the browser never sees a raw credential.
- Service and CLI clients fit bearer tokens or API keys, with mTLS when the
  callers are known and the trust level is high.
- Prefer OAuth/OIDC when you need delegated, user-scoped access and token
  revocation; prefer API keys or mTLS when callers are machines.

See [API Authorization](api-authorization.md) for what to check after identity
is established.
