# OS Hardening

OS hardening reduces the attack surface of the hosts that run your software.

## Minimize

- Install only the packages that are needed.
- Disable unused services and close unused ports.
- Remove default accounts, samples, and development tools from production hosts.

## Patch and Maintain

- Apply security patches regularly and in a timely way.
- Track the versions of installed software and their known vulnerabilities.
- Automate patching where possible and verify it works.

## Authentication and Access

- Enforce strong authentication and rotate SSH keys on a schedule.
- Disable password-based login where key-based access is enough.
- Run services as non-root users with minimal privileges.
- Use separate accounts for administrative actions.

## Monitoring and Defense

- Enable audit logging for logins, privilege changes, and config changes.
- Use security modules such as SELinux or AppArmor to constrain processes.
- Make configuration immutable or read-only where possible.
- Combine host controls with network controls; see
  [Firewalls](firewalls.md) and [Network Security](network-security.md).

Related topics: [Container Security](container-security.md),
[Kubernetes Security](kubernetes-security.md).
