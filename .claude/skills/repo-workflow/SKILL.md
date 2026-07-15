---
name: repo-workflow
description: >-
  Git and GitHub procedures for AMZL-dailydemo — how to coordinate, commit, push,
  open a PR, and merge when `main` is a protected branch and two people (Eric and
  Jason) plus their Claude assistants share the repo. Covers coordinating before
  you start, the standard branch flow, the commit-on-main recovery flow,
  commit/PR conventions, the "lint is not a required check" trap, CHANGELOG
  discipline, and branch cleanup.
  TRIGGER when the user asks to commit, push, open/create a PR, merge, "ship it",
  land a change, branch, clean up branches, or when a push to `main` is rejected
  (GH006 / protected branch / "Changes must be made through a pull request").
  SKIP for questions about what the code does, AAP CaC behavior, Terraform/AWS
  provisioning, the EE build, or AL2023 specifics — use CLAUDE.md / ROADMAP.md.
---

# Repo Workflow — AMZL-dailydemo

How to land changes in this repo. The golden rule: **`main` is a protected
branch — nobody pushes to it directly, admins included** (`enforce_admins` is
on; no force-pushes, no deletions). Every change goes through a pull request,
even a one-line fix.

This repo is **shared**: Eric and Jason Horn both work here, each possibly
driving their own Claude. Some contributions arrive through the **GitHub web
UI** (the giveaway: auto-named `<user>-patch-N` branches and `"Add files via
upload"` PR titles). Assume you are never the only writer — coordinate first.

## Coordinate before you start (shared repo)

Do this at the top of any change so two people don't collide or duplicate work:

```bash
git fetch --prune origin                       # sync refs, drop deleted remotes
git log --oneline origin/main -5               # is local main behind? if so:
git checkout main && git pull --ff-only origin main
gh pr list --repo ericcames/AMZL-dailydemo --state open   # open PRs in flight?
git branch -r                                  # in-flight branches to avoid?
```

If someone else is already touching the same file (an open PR or a `-patch-N`
branch), work with that PR rather than opening a competing one.

## The standard flow (local Claude Code)

Work on a feature branch, never commit straight to `main`:

```bash
git checkout -b <type>/<short-kebab-desc>     # e.g. fix/credential-name-day2-templates
# ...make edits, update CHANGELOG.md...
git add <specific files>                      # never `git add -A` blindly — audit for secrets
git commit -m "..."                           # see message conventions below
git push -u origin <branch>
gh pr create --repo ericcames/AMZL-dailydemo --base main --head <branch> \
  --title "..." --body "..."
```

Branch prefixes used here: `fix/`, `feature/`. Match that.

## The web-UI flow (GitHub.com contributor)

A collaborator editing on github.com can't run these commands. When helping that
path, the same rules still hold and are enforced by branch protection:

- Edit on a branch and open a PR — a direct commit to `main` is blocked anyway.
- GitHub auto-names the branch `<user>-patch-N`; that's fine, but keep **one
  concern per PR** — don't batch unrelated file edits into one `patch-N`.
- `"Add files via upload"` is the default web commit message. Replace it with a
  real imperative subject before merging where you can.
- Update `CHANGELOG.md` in the same PR — the web editor can edit it inline.

## Recovery: you already committed on `main`

If you committed to local `main` and the push was rejected with:

```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: - Changes must be made through a pull request.
```

The commit is safe — it's just on the wrong branch. Move it and rewind `main`:

```bash
git branch <type>/<desc>          # capture the commit on a new branch
git reset --hard origin/main      # rewind local main to the remote
git checkout <type>/<desc>        # switch to the branch holding your commit
git push -u origin <type>/<desc>  # push the branch
gh pr create ...                  # open the PR
```

Non-destructive: `git branch` captures the commit before the reset.

## Commit message conventions

- Imperative subject line, ~50 chars, no trailing period.
- Body explains the **why**, wrapped ~72 chars.
- End every commit with a co-author trailer naming **the model that actually
  wrote the commit** — never hardcode one model. Each assistant substitutes its
  own name (Eric's Claude and Jason's Claude may differ):

  ```
  Co-Authored-By: <the model that wrote this commit> <noreply@anthropic.com>
  ```

  For example, a commit written by Claude Opus 4.8 ends with
  `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

## PR conventions

- Repo slug for `gh`: `ericcames/AMZL-dailydemo`. `--base main`, head is your branch.
- Body: a `## Summary` of what and why, plus the concrete change list.
- End the PR body with:

  ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  ```

## CI: verify green yourself — lint is NOT a required check

The `lint.yml` (ansible-lint) workflow runs on PRs, but **no required status
checks are configured on `main`** — a red lint does not block merge and can ride
along silently. Auto-merge succeeding is *not* evidence CI passed. Always confirm
explicitly before merging:

```bash
gh pr checks <N> --repo ericcames/AMZL-dailydemo
```

All jobs should read `pass`. A common offline-lint failure is
`syntax-check[unknown-module]` for a certified module — fix it by adding the
module to `mock_modules` in `.ansible-lint`, not by skipping (syntax-check is
unskippable). This is exactly how PR #7 had to repair lint that slipped past.

## Merging

Merges complete on GitHub with a **merge commit** (`Merge pull request #N from
ericcames/<branch>`) — keep that style. **Always delete the branch on merge** so
merged branches don't pile up:

```bash
gh pr merge <N> --repo ericcames/AMZL-dailydemo --merge --delete-branch
```

Then sync local `main`:

```bash
git checkout main && git pull --ff-only origin main
```

Only merge when the user asks, or when a fix is verified.

## Branch cleanup

Delete every branch as soon as its PR merges (`--delete-branch` above). To sweep
up stale branches that slipped through:

```bash
git fetch --prune origin
git branch -r --merged origin/main | grep -v 'origin/main$'   # remote branches safe to delete
git push origin --delete <branch>                             # delete a merged remote branch
```

A **closed-but-unmerged** branch (its PR was rejected/superseded) still holds
commits that are not on `main` — deleting it drops that work. Confirm it's truly
abandoned before removing it. Never delete a branch whose PR is still open. After
a clean sweep, only `main` plus any in-flight feature branches should remain.

## Non-negotiables (also in CLAUDE.md / ~/.claude/CLAUDE.md)

- **Open a GitHub Issue before fixing** (document-before-fixing) and **label
  every new issue** — `gh label list --repo ericcames/AMZL-dailydemo`, apply all
  that fit (`bug`, `enhancement`, `documentation`, `good first issue`, …).
- **One concern per PR** — group by shared root cause. Would you revert these
  together? If not, split them. Behavior changes and anything risky stay isolated.
- **Update `CHANGELOG.md`** in the same commit — an entry under Added / Changed /
  Fixed / Removed with a `(YYYY-MM-DD)` date heading.
- **Additive only** — don't remove old capabilities until replacements are proven.
- **Audit every diff for customer data** before committing — no customer names,
  RHDP URLs, cluster/instance IDs, passwords, or tokens in any tracked file,
  commit, or PR. `docs/dev-environment.sh` is gitignored and must never be staged.
- **Never ship a project-local `ansible.cfg`** — it shadows `~/.ansible.cfg` and
  breaks certified-collection installs. Set options via CLI flags / env vars.
- **Commit/push/merge only when the user asks.** Don't act on your own initiative.
