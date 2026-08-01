# HMAC Signatures

HMAC (hash-based message authentication code) is a keyed hash that
authenticates a request. The client and server share a secret and compute the
same keyed hash over the request contents; a matching value proves the request
came from someone holding the secret and was not tampered with in transit.

## How a Request Is Signed

Sign a canonical string built from:

- A timestamp, to bound the request's lifetime.
- The HTTP method and request path.
- The request body (or a hash of it).
- Any relevant headers, such as the content type.

The signer computes `HMAC(secret, canonicalString)` and sends it with the
request. The server recomputes it from its own copy of the secret and compares.

## What It Protects

- **Integrity**: modifying the body or path invalidates the signature.
- **Authenticity**: only parties with the shared secret can produce a valid
  signature.
- **Replay**: a timestamp window plus a nonce or per-request id lets the server
  reject old or duplicated requests.

## Example Usage

- Webhook verification: providers sign the raw body with a per-endpoint secret
  so receivers can confirm the delivery is genuine. See
  [Webhook Security](webhooks-security.md).
- AWS SigV4-style signing: AWS signs requests with a canonical request,
  including method, headers, payload hash, and a date, then signs it with a
  derived key.
- API keys paired with HMAC give both identity and request integrity, as noted
  in [API Keys](api-keys.md).

## Pitfalls

- Sign the exact raw body bytes; any re-encoding on either side breaks the
  match.
- Use constant-time comparison to avoid timing side channels.
- Rotate shared secrets and keep them out of source control. See
  [Secrets Management](../cryptography/secrets-management.md).
