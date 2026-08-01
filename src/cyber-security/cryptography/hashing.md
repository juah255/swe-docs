# Hashing

A hash function maps arbitrary data to a fixed-size digest. Hashing is one-way:
there is no key to reverse it, which makes it useful for integrity checks and
password verification, but not for confidentiality.

## Properties of a Good Hash

- **Deterministic**: the same input always produces the same digest.
- **Preimage resistance**: given a digest, it is infeasible to find an input
  that produces it.
- **Second-preimage resistance**: given an input, it is infeasible to find a
  different input with the same digest.
- **Collision resistance**: it is infeasible to find any two inputs that share
  a digest.

## Password Hashing

Password hashing should be slow and resistant to brute force.

Use dedicated password-hashing algorithms such as Argon2, bcrypt, or scrypt.
Avoid fast general-purpose hashes for passwords.

- Add a per-password salt so identical passwords produce different digests and
  precomputed rainbow tables are useless.
- Consider a site-wide pepper stored separately from the database for extra
  protection against full-database dumps.
- Treat password digests as secrets you must verify slowly, not fast.

## Fast Hashes for Integrity

- Fast hashes such as MD5, SHA-1, and SHA-256 are for integrity checks (file
  fingerprints, checksums, ETags), not for password storage.
- MD5 and SHA-1 are broken for collision resistance; prefer the SHA-2 or SHA-3
  families.

## Keyed Integrity

- An HMAC is a keyed hash that authenticates a message: only parties with the
  shared secret can produce a matching digest.
- Use HMACs for message authentication and request signing, as described in
  [HMAC Signatures](../api-security/hmac-signatures.md).

See [Cryptography Basics](cryptography-basics.md) for how hashing compares to
encryption and signing.
