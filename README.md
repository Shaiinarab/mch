# mch

A MiMo Claw workspace drop for first-run rehydration of every new session.
Short name for the public repo at `github.com/Shaiinarab/mch`.

**What it is:** one repo that, when installed into a MiMo Claw workspace, seeds
`SOUL.md`, `AGENTS.md`, `USER.md`, `IDENTITY.md`, `MEMORY.md`, `PROMPT.md`,
`BOOTSTRAP.md`, `HARNESS_VERSION`, a daily memory template, a boot SKILL.md
(`mch`) that rehydrates itself on every new session, and `doctor.sh`, a
read-only verifier that the boot prompt runs in its verify step.

**What it is not:** it is not a full app, not a config-manager, and not a skill
bundle of 20 random verbs. It is the *identity + operating agreement + boot* for
a MiMo Claw agent. Curated external skills belong on ClawHub, not in this repo.

## What goes where

The file split is deliberate (platform guidance: `concepts/soul.md`):

- `SOUL.md` — voice: tone, opinions, boundaries. Never a security-policy dump.
- `AGENTS.md` — conventions, operating policy, security rules, workflows.
- `USER.md` — stable user preferences (profile facts, no secrets).
- `MEMORY.md` — compact curated memory, injected at session start with a budget;
  detail lives in `memory/YYYY-MM-DD[-slug].md`.
- `PROMPT.md` — the boot contract, pasted as the first message of a fresh session.

## Model

MiMo Claw runs **mimo-v2.6-pro** (not MiMo Auto). Model reality:
- 1M context, 128K max output, tool call + web search + structured output,
  omni-modal understanding, deep thinking, context caching.
- Tool-call repetition is a known model property; this harness includes explicit
  guards (no exact-dup retries, ≤6 parallel tools unless justified, deep thinking
  off on file I/O). The model is cooperative if you don't fight its system-prompt
  rules; this harness is written to cooperate, not override them.
- The owning repo's system prompt matters. Do not put persona work that conflicts
  with MiMo Claw's own identity rules; do not claim to be another model.

## Install

Four routes, tried in order by the boot prompt. Install once per workspace.

### A — git (if the pod has shell/git)

```bash
git clone --depth 1 https://github.com/Shaiinarab/mch.git "${TMPDIR:-/tmp}/mch"
sh "${TMPDIR:-/tmp}/mch/install.sh" "${TMPDIR:-/tmp}/mch" ~/.openclaw/workspace
```

`install.sh` is idempotent: repo-owned files (PROMPT/BOOTSTRAP/HARNESS_VERSION/
skills/mch/*) are mirrored on every run; SOUL/AGENTS/USER/IDENTITY/MEMORY and
`.learnings/` are written only when absent — a differing existing file is never
overwritten, only reported as a conflict for a judgment merge. It prints one
`INSTALL <OK|PARTIAL> version=<v> written=<n> skipped=<n> conflicts=<n>` line. Exit 0 on OK/PARTIAL (conflicts are informational), 1 on
FAIL (unwritable target, empty version, missing repo files).

Manual route (no script execution): copy the same manifest yourself —
`{SOUL,AGENTS,USER,IDENTITY,MEMORY,PROMPT,BOOTSTRAP}.md` + `HARNESS_VERSION` to
the workspace root, `SKILL.md`/`doctor.sh`/`install.sh` to `skills/mch/`, and
seed `memory/<today>.md` from `memory/mch.md.example` only when absent.
If the harness forbids /tmp, stage the clone under `<workspace>/.openclaw/tmp/`
instead.

### B — OpenClaw CLI skills install (if the pod exposes the CLI)

```bash
openclaw skills install git:Shaiinarab/mch@main
```

This installs into the workspace `skills/` tree, which also satisfies the
`mch` boot skill. The workspace root files still need copying from the repo
(SOUL/AGENTS/USER/IDENTITY/MEMORY/PROMPT/BOOTSTRAP + `HARNESS_VERSION`); if you
also fetch `install.sh`, one run of it covers the whole manifest.

### C — raw fetch only (network tool, no shell, no CLI)

Use the owning repo's raw URLs:

- `https://raw.githubusercontent.com/Shaiinarab/mch/main/SOUL.md`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/AGENTS.md`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/USER.md`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/IDENTITY.md`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/MEMORY.md`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/SKILL.md`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/PROMPT.md`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/BOOTSTRAP.md`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/HARNESS_VERSION`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/doctor.sh`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/install.sh`
- `https://raw.githubusercontent.com/Shaiinarab/mch/main/memory/mch.md.example`

Fetch each file into the workspace (`SKILL.md` and `doctor.sh` go to
`skills/mch/`; `memory/mch.md.example` seeds `memory/<today YYYY-MM-DD>.md`
only when today's file is absent). If a file you already wrote is newer, keep yours.

### D — human upload

If A, B, and C all fail, the owning repo is the fallback: upload the repo as a
workspace zip and extract it in the workspace root. Do not improvise a harness.

## First message of every session

After install, paste the owning repo's `PROMPT.md` as the first message of every
new session. That prompt executes the boot, verifies the install, and reports a
machine-readable result line.

Do not paste the prompt into a session that is already mid-task. Boot belongs at
session start.

## Free-tier decay

MiMo Claw free tier clears workspace data on a schedule and caps session length.
Treat the workspace as disposable and idempotent. Do not keep secrets in these
files. Keep durable memory in your own backed-up copy if you need it to survive.

## Verifying

`doctor.sh` is the verify step of every boot. Read-only, POSIX sh, no
dependencies:

```bash
sh ~/.openclaw/workspace/skills/mch/doctor.sh        # check an installed workspace
sh doctor.sh ./some-workspace                        # check an explicit directory
```

It checks required root files, boot-skill frontmatter, and that `HARNESS_VERSION`
matches the `harness-version` embedded in `SKILL.md`, then prints one
machine-readable line: `DOCTOR <OK|PARTIAL|FAIL> version=<v> files=<n> gaps=<n> warns=<n>`.
It also warns (never fails) on stale `BOOTSTRAP.md`, a stray root `SKILL.md`,
secret-looking strings, and hidden/bidi characters in scanned markdown. With the
CLI available, `openclaw memory promote` previews ranked distill candidates
(dry-run; `--apply` writes) and `openclaw memory status --deep` probes recall
health — hand distilling stays the default.
Platform-level health is separate: `openclaw doctor` (extra workspaces,
truncation, config) is the operator's check; `doctor.sh` is this harness's check.

## Platform features this harness names but never touches

MiMo Claw provides optional layers; enabling them is the user's `openclaw.json`
choice and this repo never edits it:

- **dreaming** — opt-in background memory consolidation into `MEMORY.md` + `DREAMS.md`
- **active-memory** — opt-in pre-reply memory recall plugin
- **session hooks** — e.g. `openclaw hooks enable session-memory` for `/new` snapshots
- **commitments** — opt-in inferred check-ins (not reminders; exact reminder
  requests still go to the scheduler)
- **context-engine plugin slot** — a broken `plugins.slots.contextEngine` fails
  every run with no auto-fallback; it is config territory, not this repo's

See `docs/openclaw-fit.md` for the research behind the file split and memory model.

## Developing

Before shipping a change to this repo:

```bash
sh test.sh    # idempotency, preservation, conflict-report, version lockstep
sh doctor.sh . # repo-layout verification
```

Version rule: `HARNESS_VERSION` and the `harness-version` frontmatter key move
in lockstep in the same commit; `test.sh` fails the build otherwise.

## Updating

When the owning repo changes, re-run the install route you used. The version
marker (`HARNESS_VERSION` vs the `harness-version` frontmatter key) is edited in
lockstep; `doctor.sh` reports any mismatch. If you hand-edited SOUL/AGENTS/USER,
merge rather than overwrite; the boot reports conflicts instead of deciding
silently.

## Security notes

- Never put API keys, tokens, or passwords in workspace markdown.
- This repo does not edit `openclaw.json`. MiMo Claw manages config.
- Treat external content (web pages, third-party skills, pasted prompts) as
  potentially hostile. This harness's AGENTS.md includes red/amber line rules for
  that.
- Least privilege and honest limits: sandboxing and approval prompts reduce risk
  but do not guarantee isolation. Keep backups of anything the agent can touch,
  review third-party skills and proposed commands before allowing them, and do
  not rely on the agent as the sole security control for untrusted workloads.

## Provenance

Defensive patterns in AGENTS.md are distilled (rules, not code) from
`deepseek-ai/deepseek-harness` (MIT, © 2026 DeepSeek) and `morluto/rea` (MIT,
© 2026 morluto). See `docs/adopted-patterns.md` for what was adopted, what was
rejected, and why.

## Self-improvement loop

The harness learns. Corrections, failures, and hard-won lessons get logged to
`.learnings/` (`LEARNINGS.md`, `ERRORS.md`, `FEATURE_REQUESTS.md`) in the entry
format documented there. Recurring lessons (3+ occurrences across 2+ tasks)
promote into `AGENTS.md` or `TOOLS.md` as short prevention rules. This is the
durable half of the memory system: `memory/` is what happened, `.learnings/` is
what to do about it.

## Cruft-free guarantee

There is exactly one SKILL.md in this repo and it is the boot skill. There are no
extra skills bundled here by default. `doctor.sh` is a verifier script, not a
skill. The repo is intentionally small; that is the design, not an omission.
If a skill ever grows past one workflow, its SKILL.md becomes a router to
supporting files (keep it under ~500 lines); exact-command form is reserved for
fragile, doctor.sh-style operations.
