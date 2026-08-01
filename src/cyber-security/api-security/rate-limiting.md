# Rate Limiting

Rate limiting caps how many requests a caller can make in a window. It protects
an API from abuse, brute-force login attempts, scraping, and runaway cost from
expensive operations.

## Strategies

- **Fixed window**: reset a counter each bucket of time. Simple, but bursts at
  window edges can double throughput.
- **Sliding window**: track requests over a rolling time span. Smoother and
  fairer than fixed windows, at slightly more cost.
- **Token bucket**: refill tokens at a steady rate, allowing controlled bursts.
  Good for APIs that need some burst tolerance.

## What to Limit

- Per IP address, to slow distributed scraping and brute force.
- Per user or account, to cap behavior tied to a logged-in identity.
- Per API key, to bound what a single client can consume.
- Per endpoint, to protect expensive or sensitive operations (search, export,
  login, password reset) with stricter limits.

## Response

- Return `429 Too Many Requests` with a `Retry-After` header so clients know
  when they can try again.
- Consider a temporary block or a challenge for clearly abusive clients instead
  of silently dropping traffic.

## Trade-offs

- Too strict limits break legitimate clients and batch jobs; tune limits per
  endpoint and caller type.
- Global limits are easy to bypass with many keys or IPs; combine them with
  anomaly detection and per-account limits.
- Rate limiting is a control, not a substitute for authentication or
  authorization.

See [Secure API Design](secure-api-design.md) for the Abuse Resistance
checklist that rate limiting supports.
