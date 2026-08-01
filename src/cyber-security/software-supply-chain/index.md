# Software Supply Chain

Software supply chain security covers the code, packages, images, tools, and
credentials that go into producing software. A compromise anywhere in that
chain can reach everything built and shipped downstream.

Protecting the supply chain means controlling what gets built, verifying what
is delivered, and tracking what is inside every artifact.

## Topics

- [Dependency Security](dependency-security.md): package risk, lockfiles, and
  controls.
- [SBOM](sbom.md): component lists for understanding exposure.
- [Vulnerability Scanning](vulnerability-scanning.md): scanning dependencies,
  images, and IaC.
- [Package Signing](package-signing.md): signing artifacts and verifying them.
- [CI/CD Security](ci-cd-security.md): build integrity and pipeline controls.
