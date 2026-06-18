# Git and Collaboration

Git is the foundation for source control, code review, automated delivery, and infrastructure history.

## Git Fundamentals

- Repositories, commits, trees, and branches
- Working tree, staging area, and commit history
- Cloning, fetching, pulling, and pushing
- Merging and rebasing
- Resolving conflicts
- Tags and release versions
- Reverting changes safely

## Team Workflows

- Feature branches and short-lived branches
- Pull requests and code reviews
- Trunk-based development
- GitFlow and its trade-offs
- Protected branches and required checks
- Conventional commits and changelogs
- Release branches and hotfixes

## Repository Operations

- `.gitignore` and generated files
- Managing large files and artifacts
- Keeping secrets out of repository history
- Signed commits and tags
- Hooks and automated policy checks

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between `git merge` and `git rebase`?

**Answer:** `merge` combines histories by creating a merge commit, preserving
the original branch structure. `rebase` rewrites commits onto a new base,
creating a linear history with new commit hashes.

Use rebase for local cleanup before sharing. Be careful rebasing shared branches
because it rewrites history that others may already depend on.

### 2. When should a commit be reverted instead of reset?

**Answer:** Use `revert` when the bad commit has already been pushed or shared.
It creates a new commit that undoes the change without rewriting public history.

Use `reset` only for local history cleanup or when the team explicitly agrees to
rewrite a branch.

### 3. How do protected branches improve delivery safety?

**Answer:** Protected branches enforce review, required checks, signed commits,
linear history, deployment gates, or restricted write access. They reduce the
chance that unreviewed or unvalidated code reaches critical branches.

They are most effective when paired with fast CI and clear ownership rules, so
developers do not bypass process to keep work moving.

### 4. How would you recover a deleted branch or lost commit?

**Answer:** Use `git reflog` to find recent branch tips and checkout or recreate
the branch from the commit hash. If the branch was pushed, the remote or another
developer's clone may also still have it.

The key is to act before unreachable commits are garbage-collected.
