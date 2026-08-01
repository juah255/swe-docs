# API Keys

API keys are opaque credentials that identify a caller. They are suitable for
service identification and simple clients, but they are not user-level
authentication: a key proves the caller holds a credential, not which user or
what permissions it represents.

## Where They Fit

- Service-to-service identification where the caller is a known machine.
- Simple client and integration credentials with limited scope.
- Developer portals and external integrations that need a lightweight
  credential.

## Risks

- Keys sent in URLs get leaked into logs, referrers, and browser history.
- Keys with no scope or rotation are a single point of failure when leaked.
- Keys shared across teams or users are hard to revoke for one person.
- Keys identify a caller but carry no authorization context on their own.

## Defenses

- Store keys hashed in the database, not in plaintext.
- Never log keys or print them in errors or request dumps.
- Scope keys to specific services or permissions and rotate them on a schedule.
- Transmit keys via headers (e.g. `Authorization`) and require HTTPS.
- Treat keys as machine credentials and combine them with
  [HMAC Signatures](hmac-signatures.md) when requests carry sensitive payloads
  or need replay protection.

See [API Authentication](api-authentication.md) for where API keys fit among
authentication methods.
