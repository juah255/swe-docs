# DNS Security

DNS is a common attack vector. Every name resolution is a chance for traffic to
be redirected, intercepted, or abused.

## Risks

- **DNS hijacking/poisoning**: attackers redirect resolution to malicious
  servers, leading users or services to the wrong destination.
- **DNS rebinding**: an attacker uses a DNS name that resolves to different
  addresses to make a victim's browser call internal or localhost services
  (SSRF).
- **Subdomain takeover**: expired or unclaimed subdomains can be registered by
  an attacker and used to serve malicious content or phish.
- **Data exfiltration via DNS**: DNS queries can carry stolen data out through
  allowed resolvers.

## Defenses

- Use a trusted, reputable resolver with filtering and protections.
- Sign zones with DNSSEC where supported and validate responses.
- Pin and harden outbound DNS so applications cannot trivially point to
  arbitrary resolvers.
- Monitor for suspicious queries, such as large volumes, unusual domains, or
  repeated failures.
- Keep DNS records and ownership reviewed so abandoned subdomains are removed
  or claimed.

Related topics: [Network Security](network-security.md),
[Firewalls](firewalls.md), [Cloud Security](cloud-security.md).
