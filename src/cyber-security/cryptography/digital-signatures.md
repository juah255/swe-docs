# Digital Signatures

A digital signature proves that a message came from a specific key holder and
was not modified: the signer hashes the data and encrypts the digest with their
private key; anyone can verify by decrypting with the public key. If the
message changed, or the signature was made by a different key, verification
fails.

## What They Provide

- **Authenticity**: only the private key holder can create a valid signature.
- **Integrity**: any modification to the data breaks verification.
- **Non-repudiation**: because the signature depends on the signer's private
  key, the signer cannot easily deny having signed it.

## Common Uses

- Signing software commits and releases so consumers can verify the artifact
  came from the maintainer and is unmodified.
- Signing JWTs and other tokens so recipients can verify issuer and content
  without a shared secret.
- Signing certificates so a certificate authority can bind a public key to an
  identity. See [Certificates](certificates.md) and [PKI](pki.md).
- Signing artifacts and SBOMs in the software supply chain.

## Hash-then-Sign

- Sign a digest of the data (e.g. SHA-256) rather than the raw data. It is
  faster, keeps signatures a fixed size, and the hash provides the
  collision-resistance that protects the scheme.
- Never reuse a signing key for general-purpose encryption; keep keys
  single-purpose.

## Algorithm Considerations

- Use modern signature schemes (e.g. Ed25519, ECDSA with strong curves,
  RSA-PSS) from established libraries.
- Avoid weak or legacy hashes and curves; a broken hash or small key lets an
  attacker forge signatures.
- Protect private keys: they live in the same category as any other secret.
  See [Secrets Management](secrets-management.md) and
  [Key Management](key-management.md).
