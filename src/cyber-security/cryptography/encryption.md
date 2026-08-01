# Encryption

Encryption is reversible with a key: it protects confidentiality, and only
someone holding the right key can recover the original data.

## Symmetric and Asymmetric Crypto

- **Symmetric encryption** uses the same key to encrypt and decrypt. It is fast
  and used for bulk data.
- **Asymmetric encryption** uses public/private key pairs. It is useful for key
  exchange, signatures, and identity.

## How to Choose

- Use symmetric encryption for bulk data (files, databases, message bodies)
  because it is fast.
- Use asymmetric crypto for the hard parts: exchanging a shared key (e.g. TLS
  key agreement), creating digital signatures, and binding identity to keys.
- Hybrid schemes combine them: asymmetric crypto protects a random session key,
  and symmetric crypto encrypts the payload.

## At Rest vs In Transit

- **In transit**: TLS protects data while it moves between parties. See
  [HTTPS and TLS](https-and-tls.md).
- **At rest**: encrypt data stored in databases, buckets, disks, and backups
  with authenticated encryption.
- Encrypting at rest does not protect data during use; keep access controls and
  key hygiene alongside it.

## Use Established Algorithms and Libraries

- Use vetted, current algorithms (AES-GCM, ChaCha20-Poly1305) from
  well-maintained libraries.
- Never roll your own cipher. See [Cryptography Basics](cryptography-basics.md)
  for the practical rules.
- Protect the keys that make encryption reversible. See
  [Key Management](key-management.md).
