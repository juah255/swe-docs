# DevOps

DevOps-focused notes covering infrastructure, delivery, and operations workflows.

## Learning Path

Follow these topics in order when learning DevOps from the beginning:

1. [DevOps Fundamentals](fundamentals.md): understand DevOps principles and core concepts.
2. [Linux](linux.md): command line, processes, services, and system administration.
3. [Git & Version Control](git-and-version-control/git-basics.md): source control, branching, merging, and team workflows.
4. [Networking](networking-and-web.md): how applications communicate and receive traffic.
5. [Docker](docker/images.md): package and run applications consistently with containers.
6. [CI/CD](ci-cd.md): automate validation, building, and delivery.
7. [Kubernetes](orchestration.md): orchestrate containerized applications at scale.
8. [Infrastructure as Code](infrastructure-as-code/terraform.md): provision and configure infrastructure with code.
9. [Cloud](cloud/aws/ec2.md): compute, storage, networking, and identity services across AWS, Azure, and GCP.
10. [Monitoring & Logging](monitoring-and-logging.md): use logs, metrics, traces, and alerts to understand systems.
11. [Security and Secrets](security-and-secrets.md): protect infrastructure, credentials, and delivery pipelines.
12. [Testing and Reliability](testing-and-reliability.md): validate releases and design dependable operations.
13. [Deployment Troubleshooting](deployment-troubleshooting.md): diagnose failures across an application's deployment path.

## Suggested Practice

- Containerize an application and its database with Docker Compose.
- Build a CI pipeline that runs linting, tests, and an application build.
- Provision a server with Terraform and configure it with Ansible.
- Deploy an application behind a reverse proxy with HTTPS.
- Add application metrics, dashboards, logs, and an actionable alert.
- Document a rollback procedure and practice recovering from a failed deployment.

## Reference

- <https://chatgpt.com/share/6a0b5f39-d084-8323-b2fc-b16d1fb7884c>

## Mid/Senior Interview Questions and Answers

### 1. What is DevOps really trying to improve?

**Answer:** DevOps improves the flow from code change to reliable production
operation. It focuses on automation, ownership, feedback, observability,
repeatable delivery, and reducing handoff friction.

It is not only tools. Tools support the operating model.

### 2. What should a senior engineer care about in a deployment pipeline?

**Answer:** Correctness checks, artifact integrity, reproducibility, secrets
handling, environment promotion, approvals, rollback, observability, and audit
history.

A pipeline should make safe releases boring and failed releases recoverable.

### 3. How do you measure operational maturity?

**Answer:** Look at deployment frequency, lead time, change failure rate, mean
time to recovery, incident quality, alert noise, runbook coverage, and how often
manual steps or tribal knowledge are required.

Metrics should guide improvement, not become vanity numbers.

### 4. How do you reduce production risk?

**Answer:** Use small changes, automated tests, staging validation, feature
flags, canary or rolling deployments, health checks, fast rollback, monitoring,
and incident reviews.

Risk is reduced by both technical safeguards and team process discipline.
