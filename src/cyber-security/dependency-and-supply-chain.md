# Dependency and Supply Chain Security

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

## Build Integrity

- Build from trusted source repositories.
- Protect main branches.
- Require reviews for deployment pipeline changes.
- Use signed commits or signed artifacts where required.
- Keep audit logs for releases.
- Avoid running untrusted code with access to deployment credentials.

## SBOM

A software bill of materials (`SBOM`) lists the components used in software.
SBOMs help teams understand exposure when a dependency vulnerability is
disclosed.
