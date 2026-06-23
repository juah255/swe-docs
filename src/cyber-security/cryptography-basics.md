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

## Password Hashing

Password hashing should be slow and resistant to brute force.

Use dedicated password-hashing algorithms such as Argon2, bcrypt, or scrypt.
Avoid fast general-purpose hashes for passwords.

## Symmetric and Asymmetric Crypto

- **Symmetric encryption** uses the same key to encrypt and decrypt. It is fast
  and used for bulk data.
- **Asymmetric encryption** uses public/private key pairs. It is useful for key
  exchange, signatures, and identity.

## TLS

Transport Layer Security (`TLS`) protects data in transit.

TLS provides:

- Server authentication.
- Confidentiality.
- Integrity.
- Optional client authentication with mutual TLS (`mTLS`).

Use HTTPS everywhere for web applications and APIs.

## Practical Rules

- Do not design custom cryptographic algorithms.
- Use well-maintained libraries.
- Store keys outside source code.
- Rotate keys when exposure is suspected.
- Separate encryption keys by environment and purpose.
