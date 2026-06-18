# DevOps

DevOps-focused notes covering infrastructure, delivery, and operations workflows.

## Learning Path

Follow these topics in order when learning DevOps from the beginning:

1. [DevOps Fundamentals](fundamentals.md): understand DevOps principles, Linux, the command line, processes, and services.
2. [Git and Collaboration](git-and-collaboration.md): manage source code and team workflows.
3. [Networking and Web Infrastructure](networking-and-web.md): learn how applications communicate and receive traffic.
4. [Containers](containers.md): package and run applications consistently with Docker.
5. [CI/CD](ci-cd.md): automate application validation, building, and delivery.
6. [Infrastructure as Code](infrastructure-as-code.md): provision and configure infrastructure with code.
7. [Orchestration](orchestration.md): operate containerized applications with Kubernetes or Nomad.
8. [Cloud Platforms](cloud-platforms.md): learn core cloud compute, storage, networking, and identity services.
9. [Observability](observability.md): use logs, metrics, traces, and alerts to understand systems.
10. [Security and Secrets](security-and-secrets.md): protect infrastructure, credentials, and delivery pipelines.
11. [Testing and Reliability](testing-and-reliability.md): validate releases and design dependable operations.
12. [Deployment Troubleshooting](deployment-troubleshooting.md): diagnose failures across an application's deployment path.

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
