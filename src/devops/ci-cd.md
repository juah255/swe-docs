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

## Questions to Answer

- What checks should block a change from being merged?
- What is the difference between continuous delivery and continuous deployment?
- How should build artifacts move between pipeline stages?
- How do you deploy an application without making an incompatible database change?
