# Zero Trust

Zero trust is a security model that never trusts network location by
default. Identity, device, and context are verified on every request.

## Principles

- Continuous verification: verify identity, device, and context on every
  request.
- Least privilege: grant the minimum access needed, for the shortest
  reasonable time.
- Micro-segmentation: isolate workloads and data so a compromise cannot
  move laterally.
- Assume breach: design as if an attacker is already inside the network.

## Zero Trust vs Perimeter Security

- Perimeter security trusts anything inside the network boundary.
- Zero trust treats every request as potentially hostile, even from inside.
- This matters for cloud and remote work, where the network boundary is no
  longer meaningful.

Zero trust is a model, not a single product. It is implemented with a
combination of identity, device, network, and monitoring controls.

Related: [Attack Surface](attack-surface.md),
[Defense in Depth](defense-in-depth.md).
