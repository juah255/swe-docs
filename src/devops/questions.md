# DevOps Interview Questions

Comprehensive index of all mid/senior interview questions across DevOps topics.
Answers are in the referenced source files.

## DevOps Fundamentals

*Source:* `devops/index.md`, `devops/fundamentals.md`

- What is DevOps really trying to improve?
- What should a senior engineer care about in a deployment pipeline?
- How do you measure operational maturity?
- How do you reduce production risk?
- What happens between entering a command and receiving its output?
- How do you find which process is consuming CPU, memory, disk, or a port?
- How do file permissions differ for users, groups, and others?
- How do you inspect and restart a failed service?

## Linux

*Source:* `devops/linux.md`

- How do Linux file permissions work?
- How do you find which process is using a specific port?
- How do you check disk usage and find large files?
- How do you view and filter log files in real time?
- How do you manage systemd services?

## Git & Version Control

*Source:* `devops/git-and-version-control/`

- What is the difference between `git merge` and `git rebase`?
- When would you use `git cherry-pick`?
- How do you resolve a merge conflict?
- What is the difference between `git reset`, `git revert`, and `git restore`?
- How do you squash commits?
- What is the difference between `git fetch` and `git pull`?
- How do you find a commit that introduced a bug using `git bisect`?
- What is the difference between a fast-forward merge and a three-way merge?
- How does the GitHub Flow branching strategy work?
- How does a GitHub Actions workflow work?
- What is the difference between a `push` event and a `pull_request` event?
- How do you reuse workflow steps across jobs?

## Networking

*Source:* `devops/networking-and-web.md`

- What happens after entering a URL in a browser?
- How does DNS map a domain name to an application?
- What is the difference between a reverse proxy and a load balancer?
- How do you locate whether a failure is DNS, routing, firewall, TLS, or application?

## Docker

*Source:* `devops/docker/`

- What is the difference between an image and a container?
- What is the difference between `CMD` and `ENTRYPOINT`?
- How do you reduce the size of a Docker image?
- What is the difference between a bind mount and a volume?
- How do you share data between containers?
- How do Docker networks isolate containers?
- What is the difference between `bridge`, `host`, and `overlay` networks?
- How does Docker Compose handle service dependencies?
- What is the difference between `depends_on` and a health check?
- How do you pass environment variables with Docker Compose?
- What makes a Dockerfile production-ready?
- What is the difference between `COPY` and `ADD`?
- Why should you use a `.dockerignore` file?

## CI/CD

*Source:* `devops/ci-cd.md`

- What checks should block a change from being merged?
- What is the difference between continuous delivery and continuous deployment?
- How should build artifacts move between pipeline stages?
- How do you deploy without making an incompatible database change?

## Kubernetes

*Source:* `devops/orchestration.md`

- What is the difference between a Pod, Deployment, and Service?
- Why are readiness and liveness probes separate?
- How do resource requests differ from resource limits?
- When is Kubernetes unnecessary for an application?

## Infrastructure as Code

*Source:* `devops/infrastructure-as-code/`

- What is the difference between provisioning and configuration management?
- Why must Terraform state be protected and locked?
- What makes an Ansible task idempotent?
- How should development, staging, and production infrastructure differ?
- Why must Terraform state be protected and locked?
- What is the difference between `terraform plan` and `terraform apply`?
- How do you manage Terraform across multiple environments?
- What makes an Ansible task idempotent?
- How does Ansible Vault protect sensitive data?
- When should you use roles versus inline playbooks?

## Cloud Platforms

*Source:* `devops/cloud-platforms.md`

- How do regions and availability zones affect application design?
- When should an application use virtual machines, containers, or serverless compute?
- How do security groups and network ACLs differ?
- How would you estimate and monitor workload cost?

## AWS

*Source:* `devops/cloud/aws/`

- What is the difference between a security group and a NACL?
- When would you use an Application Load Balancer vs a Network Load Balancer?
- How does an Auto Scaling group determine when to launch a new instance?
- What is the difference between S3 Standard and S3 Glacier?
- How does S3 achieve strong read-after-write consistency?
- What is the difference between a Multi-AZ and a Read Replica deployment for RDS?
- What is the difference between a user and a role in IAM?
- How does an IAM policy evaluation work?
- What is the difference between a public subnet and a private subnet?
- What is a NAT Gateway and why would you need one?
- How does Route 53 routing differ from a load balancer?
- What is the difference between simple routing, weighted routing, and latency-based routing?
- How do you collect and query application logs in CloudWatch?
- What is the difference between CloudWatch Logs and CloudWatch Metrics?
- What is the difference between AWS Lambda and EC2 for running backend code?
- How does Lambda handle concurrency and scaling?

## Monitoring & Logging

*Source:* `devops/monitoring-and-logging.md`

- What information should every application log entry contain?
- When should you use a metric instead of a log?
- How does distributed tracing identify latency across services?
- What makes an alert actionable?

## Security and Secrets

*Source:* `devops/security-and-secrets.md`

- Why are short-lived credentials safer than static credentials?
- How should a CI pipeline receive a production secret?
- What must happen after a credential is exposed?
- How do vulnerability scanning and runtime protection differ?

## Testing and Reliability

*Source:* `devops/testing-and-reliability.md`

- Which tests should run on every pull request?
- How do load, stress, and soak tests differ?
- What should a health check verify?
- How do `RTO` and `RPO` guide disaster recovery?
- Why keep end-to-end tests small?

## Deployment Troubleshooting

*Source:* `devops/deployment-troubleshooting.md`

- The app works locally but fails after deployment. How would you debug it?
- What environment differences commonly break deployed applications?
- How do you verify ports, DNS, TLS, and proxy configuration?
- When should you roll back instead of continuing to debug?
