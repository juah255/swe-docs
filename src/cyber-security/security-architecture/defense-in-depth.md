# Defense in Depth

Defense in depth means layering independent controls so that one failure is
not catastrophic. If a single layer fails, others still stand between an
attacker and the data.

Typical layers:

- **Policy**: standards, rules, and expected behavior.
- **Physical**: access to buildings, machines, and hardware.
- **Network**: firewalls, segmentation, and network-level access rules.
- **Host**: patching, hardening, endpoint protection, and least privilege on
  the OS.
- **Application**: input validation, authentication, authorization, and secure
  defaults.
- **Data**: encryption at rest and in transit, and access controls on the data
  itself.

Each layer should rely on different weaknesses. Avoid placing all of your
protection in the same kind of control, because a single bypass would then
defeat everything.

See [Least Privilege](least-privilege.md) and
[Secure Design Principles](secure-design-principles.md), and the fundamentals
view in [../fundamentals/defense-in-depth.md](../fundamentals/defense-in-depth.md).
