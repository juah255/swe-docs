# Security and Secrets

DevOps security protects source code, pipelines, infrastructure, workloads, and operational credentials.

## Identity and Access

- Least privilege
- Role-based access control
- Service accounts and workload identities
- Multi-factor authentication
- Short-lived credentials
- Access reviews and audit logs

## Secrets Management

- Keep secrets out of source control and images
- Use a secret manager or encrypted store
- Separate secrets by environment
- Rotate credentials
- Restrict and audit secret access
- Prevent secrets from appearing in logs and build artifacts

## Supply Chain Security

- Pin and review dependencies
- Scan dependencies and container images
- Generate a software bill of materials (`SBOM`)
- Sign and verify artifacts
- Protect CI/CD runners
- Restrict who can modify delivery workflows

## Infrastructure and Runtime Security

- Patch operating systems and dependencies
- Harden hosts and container images
- Segment networks
- Encrypt data in transit and at rest
- Back up critical data and test restoration
- Monitor security events

## Mid/Senior Interview Questions and Answers

### 1. Why are short-lived credentials safer than static credentials?

**Answer:** Short-lived credentials reduce the window of misuse if they are
leaked. They can be issued just in time, scoped to a specific workload, and
expired automatically.

Static credentials often remain valid until someone rotates them, so leaks can
remain dangerous for a long time.

### 2. How should a CI pipeline receive a production secret?

**Answer:** A CI pipeline should receive secrets from a protected secret manager
or trusted identity federation mechanism, scoped to the repository, branch,
environment, and job that needs them.

Secrets should not be stored in source control, printed in logs, baked into
images, or exposed to untrusted pull requests.

### 3. What must happen after a credential is exposed?

**Answer:** Revoke or rotate the credential immediately, identify where it was
used, remove it from logs or history where possible, audit access during the
exposure window, and deploy a replacement safely.

The follow-up is prevention: scanning, shorter credential lifetimes, tighter
permissions, and better secret handling in the workflow that leaked it.

### 4. How do vulnerability scanning and runtime protection differ?

**Answer:** Vulnerability scanning detects known issues in dependencies,
container images, infrastructure, or code before or during deployment. Runtime
protection detects or blocks suspicious behavior while the workload is running.

Scanning reduces known risk before release. Runtime controls help when unknown,
misconfigured, or actively exploited paths appear in production.
