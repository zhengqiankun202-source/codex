---
name: git-workflow
description: Practical Git workflow assistant. Use when committing, branching, merging, rebasing, resolving conflicts, writing commit messages, opening pull requests, or recovering from Git mistakes. Provides command recipes, branching-convention guidance, and a safe-recovery checklist.
metadata:
  short-description: Git workflow & recovery helper
---

# Git Workflow

Concise, safe Git recipes. Assume Git basics are known; focus on the commands and decisions that
actually trip people up. A command cheat sheet is in `references/git-cheatsheet.md`.

## When to use

- Starting a feature / fix; choosing a branch name and base.
- Staging changes, writing a good commit message, or squashing.
- Rebasing onto main, resolving a merge conflict.
- Recovering from a bad commit, accidental delete, or `reset --hard`.

## Branch strategy

- `main` / `master` is always releasable — never commit directly to it.
- Short-lived branches prefixed by intent: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`.
- Trunk-based: branch from `main`, open a PR early, squash-merge when green.

## Daily flow

```bash
git status
git fetch -p                       # prune deleted remote branches
git switch -c feat/order-api origin/main
git add -p                         # stage hunks interactively, review as you go
git commit -m "feat: add order creation endpoint"
git pull --rebase origin main      # keep a linear history before pushing
git push -u origin feat/order-api
```

## Commit messages (Conventional Commits)

`type(scope): subject` — types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`,
`build`, `ci`, `style`.
Body explains **why**, not what. Footer for `BREAKING CHANGE:` or `Closes #123`.

```
feat(orders): support partial refunds

Refund flow previously rejected amounts below the order total. Allow
proportional partial refunds per line item.

Closes #482
```

## Merge vs rebase

- Rebase your feature onto `main` for a clean linear history **before** the PR.
- Never rebase a branch others have already pulled — it rewrites shared history.
- Want an explicit merge commit on `main`? Use `git merge --no-ff`.

## Conflict resolution

1. `git status` → files with `both modified`.
2. Open each, resolve the `<<<<<<<` / `=======` / `>>>>>>>` blocks, delete the markers.
3. `git add <file>`; then `git rebase --continue` (rebase) or `git commit` (merge).
4. `git mergetool` if the diff is hard to read by eye.

## PR description template

```
## What
## Why
## How to test
## Risk / rollback
```

## Recovery (safe)

| Goal | Command |
|---|---|
| Undo last commit, keep changes | `git reset --soft HEAD~1` |
| Discard a file's working changes | `git restore <file>` |
| Recover a deleted branch | `git reflog` → `git branch <name> <sha>` |
| Amend last commit (not yet pushed) | `git commit --amend` |
| Safe public undo | `git revert <sha>` |

## Gotchas

- `git reset --hard` is **destructive** — don't use it on a shared branch without a backup.
- `git push --force` rewrites history; prefer `git push --force-with-lease`.
- Never commit secrets or large binaries; use `.gitignore` + Git LFS for big assets.
- `git pull` without `--rebase` creates a merge commit; be intentional about which you want.
