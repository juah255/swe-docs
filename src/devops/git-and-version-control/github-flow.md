# GitHub Flow

GitHub Flow is a lightweight, branch-based workflow designed for continuous deployment.

## The Workflow

```
1. Create a branch from main
2. Make changes and commit
3. Open a Pull Request
4. Get feedback and iterate
5. Merge to main
6. Deploy
```

### Step by Step

```bash
# 1. Create a feature branch
git switch -c feature/add-search

# 2. Work and commit
git add .
git commit -m "Add search endpoint"
git commit -m "Add search UI component"

# 3. Push and open PR
git push -u origin feature/add-search
# Open a Pull Request on GitHub

# 4. Address review feedback
git add .
git commit -m "Address review: add input validation"
git push

# 5. Merge via PR (squash or merge commit)

# 6. Deploy automatically (CI/CD pipeline triggers on main)
```

## Key Principles

- **`main` is always deployable** — never push broken code directly
- **All work happens on branches** — never commit directly to `main`
- **Pull Requests are for discussion and review** — not just a merge button
- **Merge triggers deployment** — CI/CD handles the rest

## PR Best Practices

```
- Keep PRs small (< 400 lines changed)
- Write descriptive titles and descriptions
- Link related issues
- Request specific reviewers
- Use draft PRs for work-in-progress
- Require status checks to pass before merge
```

## GitHub Flow vs GitFlow

| Aspect | GitHub Flow | GitFlow |
|---|---|---|
| Branches | `main` + feature branches | `main`, `develop`, `release`, `hotfix`, `feature` |
| Complexity | Simple | Heavy |
| Release cycle | Continuous deployment | Scheduled releases |
| Best for | Web apps, SaaS | Versioned software, mobile apps |
| Deploy trigger | Merge to main | Manual or scheduled |

### When to Choose Which

- **GitHub Flow**: Your team deploys frequently (daily or more), you have CI/CD, and you ship to users continuously.
- **GitFlow**: You have distinct release versions, need release candidates, support multiple production versions, or ship boxed software.

## Interview Q&A

**Q: What makes GitHub Flow suitable for continuous deployment?**
A: It requires `main` to always be deployable. Every merge to `main` is a release candidate. Short-lived branches and fast PR reviews keep the cycle tight, and automated CI/CD deploys on merge.

**Q: What is the role of Pull Requests in GitHub Flow?**
A: PRs serve as the unit of review and discussion. They trigger CI checks, allow code review, provide a place for automated testing, and create a documented history of why changes were made.

**Q: Why is GitFlow considered heavier than GitHub Flow?**
A: GitFlow has five branch types with strict rules about where they merge and when. It requires manual release management and is designed around versioned releases, adding overhead that is unnecessary for teams deploying continuously.
