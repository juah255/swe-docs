# Webhook Security

Webhooks are outbound callbacks: the API sends an HTTP POST to a URL you
registered when an event happens. Because the endpoint receives unauthenticated
traffic, a webhook can be forged by an attacker or replayed by an observer, so
every delivery needs verification.

## Verify with HMAC Signatures

- Sign the raw request body with a secret shared with the webhook provider.
- Compute an [HMAC Signature](hmac-signatures.md) over the exact body bytes and
  compare with a constant-time check.
- Reject any delivery that does not match the signature.

## Use Per-Endpoint Secrets

- Give each receiving endpoint its own signing secret so a leaked secret only
  compromises one integration.
- Rotate secrets on a schedule and support dual-secret periods so providers can
  switch over without missed events.

## Handle Replays

- Include a timestamp in the signed payload and reject deliveries older than a
  few minutes.
- Track delivery IDs or nonces and drop duplicates.
- Make handlers idempotent so retries and duplicate deliveries are harmless.

## Delivery Hygiene

- Allowlist destination URLs so compromised configurations cannot point
  webhooks at arbitrary hosts.
- Never send secrets in URLs; put them in headers and require HTTPS.
- Fail closed: on signature mismatch, log the attempt and refuse to process.

## Payload Handling

- Validate the payload shape and size even though it is signed.
- Keep webhook handlers fast; push heavy work to a queue so slow consumers do
  not stall deliveries.

See [HMAC Signatures](hmac-signatures.md) and
[Secrets Management](../cryptography/secrets-management.md).
