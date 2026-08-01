# Cloud Security

Cloud security focuses on identity, configuration, storage, and the boundary
between provider-managed and customer-managed controls.

## Shared Responsibility Model

- The cloud provider secures the physical infrastructure and the underlying
  platform.
- The customer is responsible for their workloads: configuration, access,
  data, images, and network settings.
- Treat every cloud resource as customer-managed security until the provider
  contract says otherwise.

## Cloud IAM

- Grant least-privilege permissions.
- Prefer roles and short-lived credentials over long-lived keys.
- Separate production, staging, and development access.
- Review admin permissions regularly.
- Log sensitive actions such as policy changes, key creation, and data exports.

## Storage Security

- Keep private buckets and databases private by default.
- Encrypt sensitive data at rest.
- Restrict public access explicitly.
- Enable access logs for sensitive storage.
- Review backup access, not only primary data access.

## Default Deny for Public Exposure

- Assume resources are public only when explicitly configured.
- Check for unintended public buckets, databases, and security groups.
- Use private networking and VPCs for internal services.

## Infrastructure as Code

- Scan IaC templates for insecure defaults and misconfigurations before
  applying them.
- Detect drift so manual changes cannot silently weaken the deployed
  configuration.
- Apply the same review and change control to IaC as to application code.

Related topics: [Network Security](network-security.md),
[Container Security](container-security.md),
[Kubernetes Security](kubernetes-security.md),
[Firewalls](firewalls.md).
