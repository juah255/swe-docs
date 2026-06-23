# Secrets and Key Management

Secrets include passwords, API keys, tokens, private keys, database credentials,
webhook signing secrets, and encryption keys.

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

## Key Management

Encryption keys need stronger controls than ordinary configuration.

- Keep master keys in managed key systems where possible.
- Use separate keys by environment and data class.
- Limit who can decrypt production data.
- Log key usage and administrative changes.
