# Git Basics

Git is a distributed version control system that tracks changes in source code. Every developer has a full copy of the repository history.

## Core Concepts

- **Repository**: A directory tracked by Git, containing all files and `.git/` metadata.
- **Commit**: A snapshot of staged changes with a unique SHA-1 hash, author, message, and parent(s).
- **Staging Area (Index)**: Intermediate area where changes are prepared before committing.
- **HEAD**: Pointer to the current branch/commit.

## Essential Commands

```bash
# Initialize a repo
git init

# Clone a remote repo
git clone https://github.com/user/repo.git

# Check status of working tree
git status

# Stage files
git add file.txt          # stage one file
git add .                 # stage everything

# Commit
git commit -m "Add login feature"

# View commit history
git log --oneline --graph

# See changes before staging
git diff

# See staged changes
git diff --staged

# Undo working directory changes
git checkout -- file.txt

# Unstage a file
git reset HEAD file.txt
```

## .gitignore

Tells Git which files to ignore. Place it in the repo root.

```
# .gitignore
node_modules/
*.log
.env
dist/
.DS_Store
```

## Remote Operations

```bash
# Add a remote
git remote add origin https://github.com/user/repo.git

# Fetch (download without merging)
git fetch origin

# Pull (fetch + merge)
git pull origin main

# Push commits
git push origin main
```

## Tags

Tags mark specific commits (typically releases).

```bash
git tag v1.0.0
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
git push origin --tags        # push all tags
```

## Reflog

Reflog records every HEAD movement. Useful for recovering lost commits.

```bash
git reflog                    # show reflog
git checkout <sha>            # recover a "lost" commit
git reset --hard HEAD@{2}     # restore to a previous state
```

## Interview Q&A

**Q: What is the difference between `git fetch` and `git pull`?**
A: `fetch` downloads remote changes but does not merge them into your working branch. `pull` runs `fetch` followed by `merge` (or `rebase` if configured), integrating remote changes immediately.

**Q: How does Git store data internally?**
A: Git stores data as a content-addressable object store. Each object (blob, tree, commit, tag) is hashed with SHA-1. Commits point to a tree, which points to blobs (file contents) and other trees (directories).

**Q: What does `git reflog` do and when is it useful?**
A: Reflog records a local log of where HEAD and branch tips have pointed over time. It is invaluable for recovering commits that appear "lost" after a `reset`, `rebase`, or branch deletion, since the objects still exist in the object store until garbage-collected.
