# DEPLOY.md — one folder, everything that matters

The `mch/` folder is the complete deliverable. Download it, and you have the
harness, the research, the session record, and the deployable git history.

## What's in this folder

| Path | What it is | On GitHub? |
| --- | --- | --- |
| `SOUL.md` `AGENTS.md` `USER.md` `IDENTITY.md` `MEMORY.md` | workspace harness files | yes (templates) |
| `PROMPT.md` `BOOTSTRAP.md` `HARNESS_VERSION` | boot contract + starter + version marker | yes |
| `SKILL.md` `doctor.sh` `install.sh` `test.sh` | boot skill, verifier, idempotent installer, dev suite | yes |
| `memory/mch.md.example` | daily-note template | yes |
| `.learnings/` | self-improvement log (7 entries, mostly promoted/resolved) | yes |
| `docs/` | research provenance: `adopted-patterns.md`, `openclaw-fit.md`, `research-2026-10-11.md`, `research-raw/` (subagent reports) | yes |
| `memory/2026-10-1*.md` `memory/MEMORY-workspace-snapshot.md` | session record + durable memory from this workspace | no (gitignored — download-only) |
| `mch.bundle` | full git history as a deployable bundle | no (gitignored) |

## Deploy to github.com/shaiinarab/mch

Method 1 — bundle (works even if your download stripped `.git/`):

```bash
git clone mch.bundle mch-deploy
cd mch-deploy
git remote set-url origin https://github.com/shaiinarab/mch.git
git push -u origin main   # fast-forward onto existing history
```

Method 2 — folder is a git checkout (if `.git/` survived the download):

```bash
cd mch
git remote set-url origin https://github.com/shaiinarab/mch.git
git push -u origin main
```

## Before you publish

- Repo description: "Identity + operating agreement + boot for MiMo Claw agent
  workspaces"; topics: `openclaw` `agents-md` `ai-agent` `bootstrap`.
- Set a second remote and mirror on each release — GitHub is *a* copy, not
  *the* copy:

```bash
git remote add backup <codeberg-or-gitlab-url>
git push --mirror backup
```

- Backup cadence: `git bundle create ~/mch-$(date +%F).bundle --all` (full
  history in one file; survives a workspace wipe).
- The rule that makes this work: the workspace is disposable, this repo is the
  source of truth.

## After deploying

1. Fill in `USER.md` (profile blanks) — it is a judgment file; the installer
   will never overwrite your version.
2. Fresh-workspace install is one command: `sh install.sh <repo> ~/.openclaw/workspace`
   then `sh doctor.sh` — expect `DOCTOR OK`.
3. Before changing anything in the repo: `sh test.sh` — expect `TEST OK checks=21`.
4. The version rule: `HARNESS_VERSION` and SKILL.md's `harness-version` move
   together in one commit; the test suite fails otherwise.
