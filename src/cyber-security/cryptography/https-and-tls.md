# HTTPS and TLS

Transport Layer Security (`TLS`) protects data in transit.

TLS provides:

- Server authentication.
- Confidentiality.
- Integrity.
- Optional client authentication with mutual TLS (`mTLS`).

Use HTTPS everywhere for web applications and APIs.

## Server Authentication

- TLS proves the server's identity via its certificate, chained to a trusted
  CA. See [Certificates](certificates.md) and [PKI](pki.md).
- Clients must verify hostname, chain, and expiry; never disable verification.

## Mutual TLS (mTLS)

- mTLS requires the client to present a certificate too, so both ends are
  authenticated.
- It is ideal for service-to-service calls and high-trust integrations, where
  each service gets an identity certificate. See
  [gRPC Security](../api-security/grpc-security.md).

## Keeping TLS Current

- Use current TLS versions (TLS 1.2 and 1.3) and modern ciphers; disable old
  protocols and weak cipher suites.
- Configure HSTS to force clients onto HTTPS and prevent downgrade attacks.
- Rotate and renew certificates before expiry and pin the correct trust
  anchors.

## Use HTTPS Everywhere

- HTTPS is not just for login pages: cookies, tokens, API traffic, and
  redirects all travel over the wire. See
  [REST Security](../api-security/rest-security.md).
- Redirect plain HTTP to HTTPS and reject plaintext where possible.

See [Cryptography Basics](cryptography-basics.md) for the underlying
cryptographic primitives.
