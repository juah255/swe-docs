# Merge vs Rebase

Both integrate changes between branches, but they produce different history shapes.

## Merge

Merge combines two branches by creating a **merge commit** that has two parents.

```bash
git checkout main
git merge feature/auth
```

**Result:**
```
*   Merge branch 'feature/auth'     (main)
|\
| * Add login validation
| * Add auth middleware
|/
* Previous commit on main
```

History is preserved exactly as it happened. Merge commits can clutter the log.

## Rebase

Rebase replays your branch's commits on top of another base, rewriting history to produce a **linear** sequence.

```bash
git checkout feature/auth
git rebase main
```

**Result:**
```
* Add auth middleware       (feature/auth)
* Add login validation
* Previous commit on main   (main)
```

No merge commit. Clean, linear history.

## When to Use Each

| Scenario | Use | Reason |
|---|---|---|
| Integrating into shared branch | **Merge** | Does not rewrite history others depend on |
| Cleaning up local branch before PR | **Rebase** | Produces linear history for review |
| Reverting a feature | **Merge** | Merge commit can be reverted in one operation |
| Keeping branch up to date | **Rebase** | Avoids unnecessary merge commits |

### The Golden Rule

**Never rebase commits that have been pushed to a shared branch.** Rewriting shared history breaks other developers' clones.

## Interactive Rebase

Clean up local commits before merging.

```bash
git rebase -i HEAD~3
```

```
pick a1b2c3d Add login validation
squash d4e5f6a Fix typo in validation
pick g7h8i9j Add auth middleware
```

- `pick` — keep commit as-is
- `squash` — meld into previous commit
- `reword` — keep commit, edit message
- `fixup` — meld into previous, discard message

## Conflict Resolution

Both merge and rebase can produce conflicts.

**During merge:**
```bash
# Fix conflicted files, then:
git add .
git commit                    # completes the merge commit
```

**During rebase:**
```bash
# Fix conflicted files, then:
git add .
git rebase --continue         # replays next commit
git rebase --abort            # cancel rebase entirely
```

## Branching Strategies

| Strategy | Workflow | Best For |
|----------|----------|----------|
| **Git Flow** | Develop, feature, release, hotfix branches | Scheduled releases, longer release cycles |
| **GitHub Flow** | Feature branches off main, PR to merge | Continuous deployment, simple pipelines |
| **Trunk-based** | Short-lived branches or direct commits to main | Strong CI/CD, feature flags |

**Git Flow** uses `main` for production, `develop` for integration, `feature/*` for new work, `release/*` for stabilization, and `hotfix/*` for emergency patches. More ceremony but clearer release management.

**GitHub Flow** is simpler: create a branch, commit, open a PR, merge to main, deploy. Main is always deployable. Most common for teams with CI/CD pipelines.

**Trunk-based** development keeps branches short-lived (hours, not weeks) and relies on feature flags to hide incomplete work. Requires strong test coverage and fast CI to keep main stable.

## Useful Commands

```bash
git stash                    # Temporarily shelve changes
git stash pop                # Reapply stashed changes
git cherry-pick <commit>     # Apply a specific commit to current branch
git log --oneline --graph    # Visual branch history
git reflog                   # Recover lost commits
git reset --hard HEAD~1      # Undo last commit (destructive)
git revert <commit>          # Undo a commit safely (creates new commit)
```

- **`git stash`** is useful when you need to switch branches mid-work without committing half-done changes.
- **`git cherry-pick`** lets you pull a specific commit from another branch (e.g., backporting a bugfix).
- **`git revert`** is safer than `reset` for shared branches because it creates a new commit that undoes the target commit without rewriting history.

## Interview Q&A

**Q: Why is rebase generally discouraged on shared branches?**
A: Rebase rewrites commit hashes. If others have based work on those commits, their history diverges from the rewritten branch, causing confusion, duplicate commits, and potential data loss.

**Q: How does `git pull --rebase` differ from `git pull`?**
A: `git pull` fetches and merges the remote branch, creating a merge commit. `git pull --rebase` fetches and rebases your local commits on top of the remote, keeping a linear history without merge commits.

**Q: Can you revert a rebase?**
A: Not easily. Since rebase rewrites history (changes commit hashes), there is no single commit to revert. You must use `git reflog` to find the original state and `git reset --hard` to restore it.

**Q: How do you recover from a bad merge or rebase?**
A: Use `git reflog` to find the state before the operation, then reset to the desired commit:

```bash
git reflog
git reset --hard HEAD@{2}    # Go back to the state before the bad operation
```

For a safer approach, create a new branch at the recovered point so you do not lose any work. The reflog is your safety net for almost all destructive Git operations.
