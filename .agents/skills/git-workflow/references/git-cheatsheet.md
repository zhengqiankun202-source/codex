# Git Cheat Sheet

## Status & inspect
| Command | Use |
|---|---|
| `git status -s` | short status |
| `git log --oneline -10` | recent commits |
| `git diff` / `git diff --staged` | unstaged / staged changes |
| `git show <sha>` | a commit's diff |
| `git blame <file>` | who changed each line |

## Branching
| Command | Use |
|---|---|
| `git branch -a` | all branches (incl. remote) |
| `git switch -c <name>` | create + checkout |
| `git switch main` | checkout existing |
| `git branch -d <name>` | delete merged branch |
| `git fetch -p` | fetch + prune stale remotes |

## Staging & committing
| Command | Use |
|---|---|
| `git add -p` | stage hunks interactively |
| `git commit -m "..."` | commit |
| `git commit --amend` | fix last commit (unpushed) |
| `git rebase -i HEAD~3` | squash/reword last 3 |

## Sync
| Command | Use |
|---|---|
| `git pull --rebase` | update + linear history |
| `git push -u origin <branch>` | publish + track |
| `git push --force-with-lease` | safe forced update |

## Recovery
| Command | Use |
|---|---|
| `git reset --soft HEAD~1` | undo commit, keep files |
| `git restore <file>` | discard working changes |
| `git reflog` | find lost commits/branches |
| `git stash` / `git stash pop` | temporarily shelve |

## Conflict markers
```
<<<<<<< HEAD          (your side)
=======               (incoming side)
>>>>>>> feature/x
```
Resolve, remove all three marker lines, then `git add`.
