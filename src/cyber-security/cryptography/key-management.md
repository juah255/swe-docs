# Key Management

Encryption keys need stronger controls than ordinary configuration.

- Keep master keys in managed key systems where possible.
- Use separate keys by environment and data class.
- Limit who can decrypt production data.
- Log key usage and administrative changes.

## KMS vs HSM

- A **KMS** (key management service) provides key creation, rotation, and
  usage logging as a service; most applications should use one rather than
  managing keys themselves.
- An **HSM** (hardware security module) keeps keys in tamper-resistant
  hardware; use HSMs where the highest assurance is required, such as CA or
  signing keys.

## Key Lifecycle

- **Generate**: create keys inside the KMS or HSM, not in application code, so
  the private material never leaves protected hardware.
- **Store**: keep keys in the managed system or a vault, never in source code,
  config files, or repositories.
- **Rotate**: rotate keys on a schedule and on suspected exposure, using
  dual-read or dual-write periods so data stays decryptable during the
  transition.
- **Retire**: retire keys when they are no longer needed, and log
  administrative changes to key material.

## Separation and Access

- Separate keys by environment and data class so a compromise in staging or a
  low-sensitivity dataset does not expose production data.
- Limit who and which services can decrypt production data; use access reviews
  and audit logs.
- Never store keys in source code. See
  [Secrets Management](secrets-management.md) for the same rule applied to
  all secrets.
