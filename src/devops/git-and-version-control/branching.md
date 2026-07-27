# Branching

Branches let multiple lines of development exist simultaneously without interfering with each other.

## Why Branch Isolate Work

- Develop features without affecting `main`
- Fix bugs in production while continuing feature work
- Experiment safely, delete on failure
- Enable parallel development across a team

## Core Commands

```bash
# List branches
git branch

# Create a branch
git branch feature/auth

# Switch to a branch
git checkout feature/auth
git switch feature/auth          # modern alternative

# Create and switch in one step
git checkout -b feature/auth
git switch -c feature/auth

# Delete a branch
git branch -d feature/auth       # safe delete (merged)
git branch -D feature/auth       # force delete (unmerged)

# Rename a branch
git branch -m old-name new-name

# Merge a branch into current
git merge feature/auth

# View merged branches
git branch --merged
```

## Tracking Branches

A local branch linked to a remote counterpart.

```bash
# When you clone, main tracks origin/main automatically
git branch -vv                   # show tracking info

# Set upstream explicitly
git branch --set-upstream-to=origin/feature/auth feature/auth

# Push and set upstream
git push -u origin feature/auth
```

## Branch Naming Conventions

```
feature/user-login
bugfix/null-pointer
hotfix/security-patch
release/v2.1.0
```

## Short-Lived vs Long-Lived Branches

| Type | Lifetime | Example |
|---|---|---|
| Short-lived | Hours to days | `feature/xyz`, `bugfix/123` |
| Long-lived | Weeks to months | `main`, `develop`, `staging` |

Short-lived branches are merged or deleted frequently, keeping history clean. Long-lived branches represent ongoing integration lines.

## Interview Q&A

**Q: What is the difference between `git checkout` and `git switch`?**
A: `git checkout` is a multi-purpose command (switch branches, restore files, create branches). `git switch` (Git 2.23+) is dedicated to switching branches and is more explicit, reducing accidental file overwrites.

**Q: What happens to a branch when it is deleted?**
A: The branch pointer is removed, but the commits remain in the object store and are accessible via reflog or other branches that contain them. Git garbage-collects unreachable objects after ~30 days.

**Q: Why prefer short-lived branches over long-lived feature branches?**
A: Long-lived branches accumulate merge conflicts and diverge significantly from `main`, making integration risky. Short-lived branches are merged frequently, reducing conflict surface and enabling continuous integration.
