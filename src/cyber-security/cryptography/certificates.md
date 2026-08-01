# Certificates

A certificate (in practice an X.509 certificate) is a signed statement that
binds a public key to an identity. When a client connects over TLS, the server
presents its certificate so the client can verify who it is talking to.

## Fields

- **Subject**: the identity the certificate belongs to, including a common name
  or subject alternative names (SANs) such as `api.example.com`.
- **Issuer**: the certificate authority that issued it.
- **Validity**: the not-before and not-after dates that bound the certificate's
  lifetime.
- **Public key**: the key the holder uses to prove possession and to encrypt or
  verify.
- **Extensions**: SANs, key usage, and extended key usage restrictions.

## Certificate Chains

- A certificate is verified against a chain that leads to a trusted root: the
  leaf certificate, one or more intermediate CAs, and a root CA in the client's
  trust store.
- Servers should send the leaf plus any intermediates so clients can build the
  chain without extra lookups.
- Root CAs sign intermediate CAs; intermediates sign leaf certificates, so a
  compromised intermediate can be rotated without replacing the root.

## Verification

- Always verify hostname, issuer, expiry, and revocation status; TLS libraries
  do this when configured with the right trust anchors.
- Reject expired certificates and mismatched SANs, even if the chain is valid.
- Never disable certificate verification, even for tests or internal
  endpoints.

## Operational Notes

- Certificates expire; rotate before expiry and monitor for near-expiry
  warnings so outages do not force emergency renewals.
- Certificate pinning (hard-coding a specific key or cert) is fragile: it
  breaks rotation and can cause outages, so prefer trusting a CA chain.
- Use certificates from a trusted CA or a well-run internal PKI.
  See [PKI](pki.md).

See [HTTPS and TLS](https-and-tls.md) for how certificates are used in
transport security.
