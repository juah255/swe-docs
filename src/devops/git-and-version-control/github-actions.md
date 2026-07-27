# GitHub Actions

GitHub Actions is a CI/CD platform built into GitHub that automates build, test, and deploy workflows.

## Workflow Structure

Workflows live in `.github/workflows/` as YAML files.

```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build
```

## Triggers (`on`)

```yaml
on:
  push:               # on push to branches
    branches: [main]
  pull_request:        # on PR targeting branches
    branches: [main]
  schedule:            # cron
    - cron: '0 2 * * 1'   # Mondays at 2am UTC
  workflow_dispatch:    # manual trigger
  release:
    types: [published]
```

## Jobs and Steps

- **Job**: A set of steps running on the same runner. Jobs run in parallel by default.
- **Step**: A single task — either a `uses` (action) or `run` (shell command).

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps: [...]
  deploy:
    needs: test          # runs only after test succeeds
    runs-on: ubuntu-latest
    steps: [...]
```

## Secrets

Store sensitive data in repository settings, reference them in workflows.

```yaml
steps:
  - name: Deploy
    env:
      API_KEY: ${{ secrets.API_KEY }}
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
    run: ./deploy.sh
```

Never print secrets in logs. GitHub automatically masks values found in `secrets.*`.

## Matrix Builds

Test across multiple OS/language versions simultaneously.

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci && npm test
```

## Reusable Workflows

Extract common workflow logic into a callable workflow.

```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deploy
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      DEPLOY_KEY:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./deploy.sh ${{ inputs.environment }}
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

```yaml
# .github/workflows/ci.yml
jobs:
  deploy-staging:
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
    secrets:
      DEPLOY_KEY: ${{ secrets.STAGING_DEPLOY_KEY }}
```

## Complete CI Example

```yaml
name: Full CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm test

  deploy:
    needs: [lint, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build
      - run: ./deploy.sh
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

## Interview Q&A

**Q: What is the difference between `jobs` and `steps` in GitHub Actions?**
A: Steps are individual tasks (run a command or use an action) within a job. Jobs are collections of steps that run on the same runner. Jobs run in parallel by default; steps within a job run sequentially.

**Q: How do GitHub Actions secrets work?**
A: Secrets are encrypted values stored in repository (or organization) settings. They are injected as environment variables during workflow runs, masked in logs, and unavailable to pull requests from forks by default for security.

**Q: What is the `needs` keyword and how does it affect job execution?**
A: `needs` declares job dependencies. A job with `needs: [job1, job2]` waits for both `job1` and `job2` to complete successfully before starting. If any dependency fails, the dependent job is skipped.
