# Container Security

Container security covers image hygiene and runtime behavior.

## Container Images

- Use minimal base images.
- Pin image versions where practical.
- Scan images for known vulnerabilities.
- Avoid running containers as root.
- Do not bake secrets into images.
- Rebuild images when base layers need security updates.

## Runtime

- Run containers as a non-root user.
- Mount filesystems read-only where the workload allows.
- Do not use privileged containers unless strictly required.
- Set resource limits so a compromised container cannot exhaust the host.
- Scan images in CI and on pull to catch known vulnerabilities early.
- Sign images so deployment can verify the artifact is trusted.

Related topics: [Cloud Security](cloud-security.md),
[Kubernetes Security](kubernetes-security.md),
[OS Hardening](os-hardening.md),
[Vulnerability Scanning](../software-supply-chain/vulnerability-scanning.md),
[Package Signing](../software-supply-chain/package-signing.md).
