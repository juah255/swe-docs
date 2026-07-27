# Cherry-Pick

Cherry-pick applies a specific commit from one branch onto another without merging the entire branch.

## Basic Usage

```bash
# Apply a single commit to the current branch
git cherry-pick abc1234

# Apply multiple commits
git cherry-pick abc1234 def5678

# Apply a range (exclusive of start)
git cherry-pick abc1234..ghi9012

# Apply without committing (stage changes only)
git cherry-pick --no-commit abc1234
```

## Common Use Cases

**Hotfix to another branch:**
```bash
git checkout release/v1.0
git cherry-pick <commit-sha>    # apply the hotfix commit
git push origin release/v1.0
```

**Recover a commit that was accidentally reverted:**
```bash
git cherry-pick <reverted-commit-sha>
```

**Apply a single feature commit to a stable branch:**
```bash
git checkout stable
git cherry-pick <feature-commit>
```

## Handling Conflicts

```bash
# Fix conflicted files, then:
git add .
git cherry-pick --continue     # continue applying remaining commits
git cherry-pick --abort        # cancel and restore to pre-cherry-pick state
git cherry-pick --skip         # skip the current commit
```

## When NOT to Cherry-Pick

- **When you need the full context of a branch** — use merge or rebase instead
- **When the commit depends on other commits** — cherry-picking a commit without its predecessors may break functionality
- **When reverting is safer for shared history** — if a commit was pushed to `main`, revert it with `git revert` rather than cherry-picking a fix, since revert creates a new commit that documents the undo

## Cherry-Pick vs Revert

| Operation | Effect | History |
|---|---|---|
| `cherry-pick` | Applies a commit to a different branch | Adds a new commit (different SHA) |
| `revert` | Creates an inverse commit on the same branch | Preserves original, adds undo commit |

Revert is preferred for shared branches because it documents what happened. Cherry-pick is preferred for selectively moving commits between branches.

## Interview Q&A

**Q: What is the difference between `cherry-pick` and `merge`?**
A: Merge integrates all commits from one branch into another. Cherry-pick applies only selected commits. Merge preserves branch topology; cherry-pick is a surgical operation for individual commits.

**Q: Can cherry-pick create duplicate commits?**
A: Yes. If you cherry-pick a commit and later merge the original branch, both copies exist. Git may or may not detect them as identical depending on context, potentially causing confusion.

**Q: When should you use `git revert` instead of `git cherry-pick`?**
A: Use `revert` when undoing a commit on a shared branch, because it creates a new commit that clearly documents the reversal without rewriting history. Cherry-pick is for moving commits forward, not undoing them.
