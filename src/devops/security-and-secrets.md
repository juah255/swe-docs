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

## Questions to Answer

- Why are short-lived credentials safer than static credentials?
- How should a CI pipeline receive a production secret?
- What must happen after a credential is exposed?
- How do vulnerability scanning and runtime protection differ?
