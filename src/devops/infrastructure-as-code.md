# Infrastructure as Code

Infrastructure as code (`IaC`) makes infrastructure changes reviewable, repeatable, and version controlled.

## Core Concepts

- Declarative and imperative automation
- Desired state
- Idempotency
- State files and state locking
- Modules, variables, and outputs
- Planning changes before applying them
- Drift detection
- Separate environments and reusable configuration

## Terraform

- Providers and resources
- Input variables, local values, and outputs
- State and remote backends
- Modules
- Data sources
- Plans and applies
- Importing existing resources
- Managing secrets outside state where possible

## Ansible

- Inventories and host groups
- Playbooks, plays, and tasks
- Modules
- Variables and templates
- Roles
- Handlers
- Ansible Vault
- Writing idempotent configuration

## Infrastructure Workflow

- Store configuration in version control
- Validate and format changes in CI
- Review an execution plan
- Require approval for production changes
- Apply from a controlled environment
- Record outputs and monitor for drift

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between provisioning and configuration management?

**Answer:** Provisioning creates or changes infrastructure resources such as
networks, servers, databases, and load balancers. Configuration management
installs packages, writes config files, manages services, and prepares those
resources to run workloads.

Terraform is commonly used for provisioning. Ansible is commonly used for
configuration management, though the boundary can vary by team.

### 2. Why must Terraform state be protected and locked?

**Answer:** Terraform state maps configuration to real resources and may contain
sensitive outputs. If state is lost, corrupted, or exposed, infrastructure
changes become risky and secrets may leak.

Locking prevents two applies from changing the same infrastructure at once.
Remote state with encryption, access control, backups, and locking is standard
for production.

### 3. What makes an Ansible task idempotent?

**Answer:** An idempotent task can run repeatedly and leave the system in the
same desired state without unnecessary changes. For example, using a package
module to ensure a package is present is idempotent; running a raw install
command every time may not be.

Idempotency makes automation safe for repeated deployments, recovery, and drift
correction.

### 4. How should development, staging, and production infrastructure differ?

**Answer:** They should be structurally similar enough to catch deployment
issues, but scaled and protected according to risk. Production usually has
stricter access control, backups, monitoring, high availability, and change
approval.

Avoid hidden manual differences. Use variables, modules, and environment
configuration to express intentional differences in code.
