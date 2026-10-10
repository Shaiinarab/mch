# Changelog — mch

Versions follow the `HARNESS_VERSION` / `harness-version` lockstep; `test.sh`
fails if the current version is missing from this file.

## 0.7.0 — 2026-10-11 — final research wave + one-folder deliverable

- AGENTS.md: done-condition before work (never self-grade post-hoc), structured
  handoff notes at context boundaries, date-stamped durable facts, head/tail
  tool-output offloading, rule retirement in doc-gardening, entropy audit after
  3+ harness-file edits. Defensive pattern #10: the doer and the judge are
  different passes.
- doctor.sh: AGENTS.md map-budget gate (>220 lines warns) — pattern #9 applied
  to its own prose rule.
- README: quickstart fold, status line, post-install tree, bundle backup recipe.
- DEPLOY.md: publish checklist (description/topics, mirror remote, backup
  cadence, disposable-workspace rule).
- Everything important lives in this folder: research-raw/ subagent reports,
  session memory snapshots (download-only, gitignored), deployable mch.bundle.

## 0.6.0 — 2026-10-11 — multi-agent research integration

- AGENTS.md: sub-agent context filtering, pruning staleness, pre-compaction
  memory flush, memory-poisoning defense (observations, never imperatives),
  first-contact confirmation, updates are fresh trust decisions, doc-gardening
  rule, ≤200-line map budget. Defensive pattern #9: context files are context,
  not enforcement.
- doctor.sh: secret scan scope fix (root/skills/docs/memory), hidden/bidi
  character scan, BOOTSTRAP starter lifecycle (absence is healthy after first
  run), stray root SKILL.md warn.
- install.sh: write failures surface as INSTALL FAIL + exit 1 (was fake OK),
  empty-version refusal, unset-HOME clean failure, BOOTSTRAP.md never
  resurrected, no more memory/unknown.md on missing date.
- test.sh: 21 checks (hard errors, warn surfaces, non-vacuity).
- docs/research-2026-10-11.md + docs/research-raw/ provenance.

## 0.5.0 — 2026-10-10 — scripted install, proven idempotency

- install.sh (deterministic merge policy: managed mirror / judgment never-clobber
  / conflicts reported) and test.sh (idempotency, preservation, lockstep).
- PROMPT.md route A runs the installer; manual fallback documented.

## 0.4.0 — 2026-10-10 — platform fit (deep research)

- Memory rules match the real platform model (slugged daily files, MEMORY.md
  injection budget, distill/prune duty). SOUL.md is voice-only; policy lives in
  AGENTS.md. Skill description carries trigger conditions. Platform layers
  (dreaming/active-memory/hooks/commitments/context-engine) named, never wired.
- docs/openclaw-fit.md.

## 0.3.0 — 2026-10-10 — defensive patterns from peer harnesses

- 8 prevention rules distilled (rules, not code) from deepseek-ai/deepseek-harness
  and morluto/rea, both MIT. docs/adopted-patterns.md with provenance and
  explicit rejections (no binary RE, no plugin spine).

## 0.2.0 — 2026-10-10 — version marker, doctor, self-improvement loop

- HARNESS_VERSION + `harness-version` lockstep (docs promised it; no artifact
  existed). doctor.sh verifier. Memory template path fix. Install manifest
  aligned across README/PROMPT. .learnings/ loop (LEARNINGS/ERRORS/FEATURE_REQUESTS).

## 0.1.0 — 2026-10-06 — scaffold

- Initial harness drop: SOUL/AGENTS/USER/IDENTITY/MEMORY/PROMPT/BOOTSTRAP + boot
  SKILL.md + memory template.
