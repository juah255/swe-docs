# CI/CD Security

The CI/CD pipeline builds and releases software, so protecting it protects
everything it ships.

## Build Integrity

- Build from trusted source repositories.
- Protect main branches.
- Require reviews for deployment pipeline changes.
- Use signed commits or signed artifacts where required.
- Keep audit logs for releases.
- Avoid running untrusted code with access to deployment credentials.

## Secrets in CI

- Inject secrets at runtime instead of storing them in the pipeline
  configuration.
- Scope credentials to the jobs that need them.
- Separate production secrets from CI jobs that do not need them.

## Lock and Pin

- Lock dependencies so builds are reproducible.
- Pin runner versions and tool images so the build environment is known.
- Audit pipeline tooling for vulnerabilities just like application
  dependencies.

Related topics: [Dependency Security](dependency-security.md),
[Package Signing](package-signing.md),
[Vulnerability Scanning](vulnerability-scanning.md),
[SBOM](sbom.md).
