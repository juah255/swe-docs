# Cloud and Container Security

Cloud and container security focuses on identity, configuration, images,
runtime, and network boundaries.

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

## Container Images

- Use minimal base images.
- Pin image versions where practical.
- Scan images for known vulnerabilities.
- Avoid running containers as root.
- Do not bake secrets into images.
- Rebuild images when base layers need security updates.

## Kubernetes

Important controls:

- Role-based access control (`RBAC`).
- Network policies.
- Pod security controls.
- Secrets management.
- Image admission policies.
- Resource limits.
- Audit logs.

Cluster access should be treated as production infrastructure access.
