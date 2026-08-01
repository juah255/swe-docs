# Secrets Management

Secrets are credentials that grant access: passwords, API keys, tokens, private
keys, database credentials, webhook signing secrets, and encryption keys. They
need careful handling because a leaked secret is a live credential, not just
exposed data.

## Storage

- Do not commit secrets to source control.
- Use a secrets manager or vault for production secrets.
- Use environment-specific secrets.
- Restrict read access to only the services that need the secret.
- Avoid sharing long-lived personal credentials with applications.

## Rotation

Secrets should be rotatable without a full outage.

Plan for:

- Dual-read or dual-write periods when needed.
- Short-lived credentials where possible.
- Emergency rotation after leakage.
- Audit logs for secret access.

## Leakage Prevention

- Scan commits and CI logs for secrets.
- Redact secrets from application logs.
- Avoid printing full environment variables during builds.
- Keep local `.env` files out of source control.
- Revoke leaked credentials rather than only deleting them from history.

## Related Topics

- [Key Management](key-management.md) covers encryption keys, which need even
  stronger controls.
- API and webhook secrets are handled in
  [API Keys](../api-security/api-keys.md) and
  [Webhook Security](../api-security/webhooks-security.md).
