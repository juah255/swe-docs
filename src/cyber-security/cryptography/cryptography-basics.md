# Cryptography Basics

Cryptography protects confidentiality, integrity, authenticity, and password
verification when used correctly.

## Hashing vs Encryption

- **Hashing** is one-way. It is used for integrity checks and password
  verification.
- **Encryption** is reversible with a key. It is used for confidentiality.
- **Signing** proves authenticity and integrity.

Passwords should be hashed with a password-hashing algorithm and per-password
salt, not encrypted for later recovery.

## Practical Rules

- Do not design custom cryptographic algorithms.
- Use well-maintained libraries.
- Store keys outside source code.
- Rotate keys when exposure is suspected.
- Separate encryption keys by environment and purpose.

See [Hashing](hashing.md), [Encryption](encryption.md), and
[Key Management](key-management.md) for the details.
