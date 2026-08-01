# Dependency Security

Modern applications depend on packages, build tools, container images, CI/CD
systems, and deployment credentials.

## Dependency Risk

Risks include:

- Vulnerable packages.
- Malicious packages.
- Typosquatting.
- Compromised maintainers.
- Abandoned dependencies.
- Unpinned transitive updates.

## Controls

- Use lockfiles.
- Review new dependencies before adding them.
- Remove unused packages.
- Run dependency scanning in CI.
- Pin container base images where appropriate.
- Keep build tools and package managers updated.
- Separate production secrets from CI jobs that do not need them.

Related topics: [SBOM](sbom.md),
[Vulnerability Scanning](vulnerability-scanning.md),
[CI/CD Security](ci-cd-security.md),
[Package Signing](package-signing.md).
