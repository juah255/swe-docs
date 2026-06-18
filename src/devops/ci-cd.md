# CI/CD

- **CI** = Continuous Integration
- **CD** = Continuous Delivery / Continuous Deployment

## Define CI/CD

Document what **CI/CD means in practice** for a backend project.

Continuous integration validates each change by automatically building and testing it. Continuous delivery keeps validated changes ready for release, while continuous deployment releases validated changes automatically.

## Pipeline Fundamentals

- Triggers from pushes, pull requests, tags, and schedules
- Jobs, steps, runners, and execution environments
- Dependency caching and build artifacts
- Linting, tests, security checks, and builds
- Environment variables and protected secrets
- Approval gates and protected environments
- Deployment strategies and rollback
- Pipeline status, logs, and notifications

## CI/CD Tools

- **GitHub Actions**
- **GitLab CI/CD**
- **Jenkins**
- **CircleCI**
- **Bitbucket Pipelines**

## Delivery Strategies

- Rolling deployment
- Blue-green deployment
- Canary deployment
- Feature flags
- Database migration compatibility
- Automated and manual rollback

## Mid/Senior Interview Questions and Answers

### 1. What checks should block a change from being merged?

**Answer:** Required checks should cover correctness, maintainability, and
release safety. Typical blockers include failing tests, lint or type errors,
security scan failures, broken builds, missing approvals, and policy violations
such as secrets committed to the repository.

For senior teams, the exact checks depend on risk. A backend service might
require unit tests, integration tests, migration validation, contract tests,
container image scanning, and ownership approval before merging.

### 2. What is the difference between continuous delivery and continuous deployment?

**Answer:** Continuous delivery means every validated change is ready to deploy,
but production release may still require manual approval. Continuous deployment
means every validated change is automatically released to production.

The main difference is the production gate. Both require automated validation,
repeatable builds, environment configuration, and rollback or mitigation plans.

### 3. How should build artifacts move between pipeline stages?

**Answer:** Build once and promote the same artifact through test, staging, and
production. Do not rebuild separately for each environment because that can
create differences between what was tested and what was released.

Environment-specific behavior should come from configuration, secrets, feature
flags, or deployment metadata, not from changing the artifact itself.

### 4. How do you deploy without making an incompatible database change?

**Answer:** Use backward-compatible migration steps. A common approach is
expand, migrate, and contract: add the new schema in a compatible way, deploy
code that can work with both old and new data, backfill safely, then remove old
columns or behavior in a later release.

Avoid coupling destructive migrations to the same deployment that first depends
on the new schema. That makes rollback much harder.
