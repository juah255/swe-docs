# SBOM

A software bill of materials (`SBOM`) lists the components used in software.
SBOMs help teams understand exposure when a dependency vulnerability is
disclosed.

## What an SBOM Covers

- The packages, images, and libraries that make up a piece of software.
- Versions of each component so affected artifacts can be identified.
- Dependency relationships, including transitive dependencies.

## Using SBOMs

- Generate SBOMs at build time so they match the shipped artifact.
- Use them to respond quickly when a vulnerability is disclosed: check which
  releases contain the affected component.
- Attach SBOMs to artifacts and registries so they travel with the software.

## Formats

- Common formats include CycloneDX and SPDX.
- Pick a format that your scanning and deployment tooling can consume.

## Keeping SBOMs Fresh

- Regenerate SBOMs on every build.
- Keep them attached to the artifact they describe so they are not stale.
- Treat a missing or outdated SBOM as a deployment concern.

Related topics: [Dependency Security](dependency-security.md),
[Vulnerability Scanning](vulnerability-scanning.md),
[CI/CD Security](ci-cd-security.md).
