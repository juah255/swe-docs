# PKI

A Public Key Infrastructure (PKI) is the system of certificate authorities,
certificates, revocation, and trust stores that lets parties verify each
other's keys and identities at scale.

## Core Pieces

- **Certificate authorities (CAs)**: trusted entities that issue and sign
  certificates. Root CAs sign intermediates, which sign leaf certificates.
- **Certificate chains**: the path from a leaf certificate up to a root in a
  trust store. See [Certificates](certificates.md).
- **Trust stores**: the set of roots a client accepts; certificates that do not
  chain to a trusted root are rejected.
- **Private keys**: the secret halves of key pairs. If a CA's private key is
  stolen, everything it issued is untrusted, so protecting them is paramount.

## Revocation

- **CRLs (certificate revocation lists)**: periodically published lists of
  revoked certificates.
- **OCSP (Online Certificate Status Protocol)**: real-time queries about a
  single certificate's status.
- Both exist because certificates stay valid until expiry; revocation covers
  keys that were compromised or issued in error.

## Public vs Private CAs

- Public CAs (e.g. Let's Encrypt) are trusted by default in every browser and
  device; use them for externally facing services.
- Private/internal CAs serve internal services, service meshes, and
  internal-facing tooling where public trust is neither needed nor desirable.
- Choose based on who must trust the certificates: public for the internet,
  internal for your own infrastructure.

## When to Use an Internal PKI

- When you need to control issuance, revocation, and key protection for
  internal hosts.
- For mTLS between services, where each service gets its own identity
  certificate. See [HTTPS and TLS](https-and-tls.md) and
  [gRPC Security](../api-security/grpc-security.md).
- When running your own CA, run it with strong key protection, monitoring, and
  a documented issuance policy.

## Protection

- Keep CA private keys offline or in HSMs.
  See [Key Management](key-management.md).
- Rotate and monitor certificates; track expiries so nothing is silently
  serving stale trust.
