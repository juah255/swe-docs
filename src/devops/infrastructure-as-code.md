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

## Questions to Answer

- What is the difference between provisioning and configuration management?
- Why must Terraform state be protected and locked?
- What makes an Ansible task idempotent?
- How should development, staging, and production infrastructure differ?
