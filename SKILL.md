---
name: mch
description: >
  MiMo Claw workspace bootstrap: SOUL/AGENTS/USER/IDENTITY + rehydration
  SKILL.md + daily memory template for every new MiMo Claw session. Model-aware:
  mimo-v2.6-pro, tool-call repetition guard, ≤6 parallel tools, deep thinking off
  on I/O. Install by clone or raw-fetch or openclaw skills install.
user-invocable: true
harness-version: 0.3.0
metadata:
  openclaw:
    requires:
      config: []
      env: []
      bins: []
      anyBins: []
---

# SKILL.md — mch

> Loaded on every new MiMo Claw session. Owned by `mch` repo.

## What this skill does

On every boot it rehydrates the workspace to match the owning repo, then adopts the SOUL/AGENTS/USER layers for the rest of the session. It never edits `openclaw.json` (Xiaomi manages it on MiMo Claw) and never tries to claim to be another model.

## How to invoke

The owning repo's README has the per-session master prompt (file `PROMPT.md`). If a user wants to re-run boot manually inside a session, they say the master prompt; this skill does not own the session-start rule — it *is* the content the master prompt reads and applies.

## Handoff

1. Run `sh doctor.sh <workspace-root>` (installed alongside this file as
   `skills/mch/doctor.sh`). It checks the required root files, frontmatter, and
   the `HARNESS_VERSION` vs `harness-version` match, and prints one
   `DOCTOR <status> ...` line.
2. Re-read all workspace files this skill installed and verify they match the repo.
3. Do NOT regenerate files the user already owns and updated in place — merge, never clobber.
4. Version rule: `HARNESS_VERSION` (repo root) and `harness-version` (this
   frontmatter) must always be edited together in the same commit.

## Safety

- No secrets inline. Reference env by name only.
- No claims of being another model. Keep MiMo/MiMo Claw identity intact.
- If the owning repo is unreachable on all install routes, stop at FAIL with the exact URLs and ask the human to upload the workspace zip. Do not improvise a harness.
