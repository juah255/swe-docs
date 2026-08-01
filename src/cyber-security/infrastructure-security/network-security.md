# Network Security

Network security controls how systems communicate and which paths are allowed.

## Core Concepts

- **Firewall**: controls allowed inbound or outbound traffic.
- **Network segmentation**: separates systems by trust level or function.
- **Private networking**: keeps internal services away from the public internet.
- **VPN**: provides controlled network access for users or services.
- **Zero trust**: verifies identity and authorization continuously instead of
  trusting a network location by default.

## TLS and Service Communication

- Use TLS for public APIs and internal service calls where practical.
- Validate certificates.
- Use mutual TLS when service identity needs strong verification.
- Avoid plaintext credentials over the network.

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

Related topics: [Firewalls](firewalls.md), [VPN](vpn.md),
[DNS Security](dns-security.md).
