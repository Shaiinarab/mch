# OpenClaw platform fit — deep research notes (2026-10-10)

What mch learned from the MiMo Claw platform's own documentation (local
`openclaw/docs`), plus community standards, and what changed because of it.
Companion to `adopted-patterns.md` (peer harnesses) — this file is about
platform fit, not peer engineering.

## Sources

| Source | What it gave us |
| --- | --- |
| `docs/concepts/soul.md` | SOUL.md is voice, not policy: "do not turn it into a security policy dump"; short beats long |
| `docs/concepts/memory.md` | The real memory model: MEMORY.md (curated, injected, budgeted) + `memory/YYYY-MM-DD[-slug].md` (working layer) + optional DREAMS.md |
| `docs/concepts/dreaming.md` | Opt-in background consolidation (light/deep/REM) that promotes into MEMORY.md |
| `docs/concepts/active-memory.md` | Opt-in pre-reply memory recall plugin |
| `docs/concepts/agent-workspace.md` | Workspace is default cwd, not a hard sandbox; single active workspace; `openclaw doctor` |
| `docs/automation/hooks.md` | Lifecycle hooks exist (e.g. session-memory on `/new`) |
| agents.md standard (agents.md) | AGENTS.md = "README for agents": commands, conventions, separate from human README |
| Agent Skills best practices (Claude Platform docs) | Skill metadata (name/description) is what's preloaded — descriptions must carry trigger words; SKILL.md stays concise; progressive disclosure |

## Findings that changed mch

1. **Memory naming was half-right.** The platform also picks up slugged daily
   files (`memory/YYYY-MM-DD-<slug>.md`, e.g. from the session-memory hook), and
   MEMORY.md is injected with a budget — over-budget files are truncated in
   context while kept on disk. mch's memory rules now cover both: write either
   daily filename form, keep MEMORY.md compact and curated, treat truncation as
   a signal to move detail down, and distill daily notes into MEMORY.md at
   natural breakpoints while pruning stale entries.
2. **SOUL.md hygiene.** Platform guidance explicitly rejects security-policy
   dumps in SOUL.md. mch's repo SOUL.md was already voice-only, so the rule is
   now stated where it protects future edits: policy and conventions live in
   AGENTS.md; SOUL.md is how the agent sounds. (Pre-install safety policy kept
   in the live workspace was relocated accordingly, verbatim, from SOUL.md into
   the AGENTS.md preserved section.)
3. **Skill descriptions are trigger surfaces.** Only name/description are
   preloaded for skill discovery, so the boot skill's description now says when
   to load it (fresh session, missing/stale workspace, pasted boot prompt,
   version check) instead of only what it contains. Keep triggers narrow (name
   the moment of use and the adjacent non-use case), third person, minimal
   length — over-broad triggers fire at the wrong time (community guidance,
   see `research-2026-10-11.md`).
4. **Optional platform layers exist and should be named, not silently relied
   on:** dreaming (memory consolidation), active-memory (pre-reply recall),
   session hooks (`openclaw hooks enable session-memory`), and `openclaw doctor`
   as the platform-level health check next to this repo's `doctor.sh`. mch never
   edits `openclaw.json`; these are user config decisions, documented only.

## What was considered and not adopted

- **Dreaming/active-memory auto-wiring** — opt-in platform features behind
  `openclaw.json` edits; mch's red line is not editing platform config.
- **Context-budget numbers** — the platform documents budgets but values are
  config-dependent; doctor.sh warns about shape, not guessed thresholds.
- **agents.md repo-level format for the workspace** — mch's AGENTS.md is a
  workspace operating agreement (OpenClaw convention), not a repo README for
  agents; it keeps the spirit (commands, conventions, predictable location).

## Provenance

Platform docs are Apache-2.0/CC per the OpenClaw repository; ideas used, no text
copied beyond short quoted phrases attributed above. Agent Skills and agents.md
findings are standards knowledge (format conventions), not copied content.
