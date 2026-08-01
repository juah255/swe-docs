# gRPC Security

gRPC is a high-performance RPC framework for service-to-service communication
using HTTP/2 and protobuf messages. Its threat model is largely about untrusted
network segments and rogue callers, so transport security, authentication, and
resource limits dominate.

## Transport Security

- Use TLS for all gRPC traffic; nothing should travel in plaintext.
- Use mutual TLS (mTLS) for service-to-service calls so both ends present a
  certificate. This pairs well with service mesh identity.
- Keep TLS versions and ciphers current. See
  [HTTPS and TLS](../cryptography/https-and-tls.md).

## Authentication

- Authenticate every call with a token (bearer, JWT) or a client certificate,
  never trusting caller-reported identity.
- Use per-service credentials or SPIFFE-style identity so one leaked token
  cannot impersonate every service.

## Authorization

- Enforce authorization per service and per method, not only at the gateway.
- Mirror the object-level checks you would apply in REST. See
  [API Authorization](api-authorization.md).

## Resource Limits

- Set maximum request sizes; an oversized protobuf can exhaust memory on
  receive.
- Configure deadlines and timeouts on every call so a slow or malicious peer
  cannot hold connections open indefinitely.
- Bound concurrency and stream counts to resist resource exhaustion.

## Streaming Abuse

- Validate and cap payload sizes in both unary and streaming calls.
- Watch for streams that send endless messages; enforce per-stream limits and
  rate limits. See [Rate Limiting](rate-limiting.md).

## Schema and Validation

- Keep protobuf schemas reviewed and versioned; rejecting unknown or malformed
  fields beats silently ignoring them.
- Validate fields on the server regardless of client-side checks.
