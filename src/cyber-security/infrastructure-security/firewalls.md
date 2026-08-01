# Firewalls

A **firewall** controls allowed inbound or outbound traffic.

Firewalls are the boundary filter of a network. They decide which traffic is
permitted based on rules, so they are the first line of defense for anything
exposed to a network.

## Stateful vs WAF

- **Stateful firewalls** track connection state and allow traffic based on
  established sessions, not just static rules.
- **Web application firewalls (WAFs)** filter HTTP traffic at the application
  layer, blocking attacks such as SQL injection and XSS.
- Firewalls filter traffic; WAFs understand applications. Use WAFs as
  supporting controls for public apps, not as a replacement for secure code.

## Allowlist Rules

- Default to blocking; permit only what is required.
- Allow only specific source IPs, ports, and protocols.
- Keep rule sets minimal and review them regularly.
- Remove rules for services that no longer exist.

## Deny by Default

- Start with an implicit deny for both inbound and outbound traffic.
- Grant explicit rules for the services that must communicate.
- Apply the same deny-by-default posture internally, not only at the edge.

## Defense in Depth

- Do not rely on firewalls alone. Compromised applications or misconfigured
  rules can bypass them.
- Combine firewalls with network segmentation, TLS, authentication, and host
  hardening.
- Assume a firewall rule will be imperfect and layer additional controls.

## Inbound Controls

- Expose only required ports.
- Put public traffic behind load balancers or reverse proxies.
- Use web application firewalls as supporting controls for public apps.
- Keep admin interfaces private or strongly protected.

## Outbound Controls

Outbound restrictions reduce damage after compromise.

- Restrict egress from application networks.
- Block access to cloud metadata services when not required.
- Monitor unusual outbound traffic.
- Use explicit allowlists for sensitive integrations.

Related topics: [Network Security](network-security.md),
[VPN](vpn.md), [Cloud Security](cloud-security.md).
