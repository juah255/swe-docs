# Package Signing

Use signed commits or signed artifacts where required, so consumers can verify
the origin and integrity of what they receive.

## Sign Artifacts and Images

- Sign build artifacts and container images so their origin can be verified.
- Attach signatures to the artifact or push them to a trusted registry.
- Publish the verification keys or trust store separately from the artifacts.

## Verify at Install and Deploy

- Verify signatures at install and deploy time, not only at build time.
- Fail closed when a signature is missing or cannot be verified.
- Verify in the same pipeline that consumes the artifact.

## Sign Commits

- Sign commits so maintainers can trust that history is authentic.
- Use verified commits as a basis for code review and release decisions.

## Protect Signing Keys

- Store signing keys in a hardware or managed key store.
- Never place signing keys in CI variables, images, or repositories.
- Rotate and revoke keys that may have been compromised.
- Code signing certificates are valuable; keep them protected and tracked.

Related topics: [CI/CD Security](ci-cd-security.md),
[Dependency Security](dependency-security.md),
[SBOM](sbom.md),
[Container Security](../infrastructure-security/container-security.md).
