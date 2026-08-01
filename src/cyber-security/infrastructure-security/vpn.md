# VPN

A **VPN** provides controlled network access for users or services.

VPNs encrypt traffic between a client or service and a private network, so
remote users and machines can work as if they were connected directly.

## What VPNs Provide

- Encrypted tunnels for traffic between endpoints and the private network.
- Controlled remote access for users and services.
- Site-to-site connectivity between office or cloud networks.
- An encrypted path for traffic that would otherwise cross the public internet.

## Use Cases

- Remote access for employees connecting from outside the office.
- Site-to-site tunnels joining branch offices or cloud VPCs to each other.
- Encrypting legacy protocols that lack transport security.

## Limitations

- A VPN is not a substitute for application-layer authentication. Once inside,
  users still need to be authorized per resource.
- VPN access is often broad, granting full network reach. Treat it as a
  boundary, not a trust decision.
- Compromised endpoints inside the tunnel can reach the whole network.

## Zero Trust Alternatives

- For fine-grained access, consider zero-trust or ZTNA alternatives.
- Zero trust verifies identity and authorization continuously instead of
  trusting a network location by default.
- Prefer per-application, identity-based access over full network access where
  possible.

Related topics: [Network Security](network-security.md),
[Firewalls](firewalls.md), [OS Hardening](os-hardening.md).
