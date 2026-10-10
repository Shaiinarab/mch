# LEARNINGS.md

Corrections, knowledge gaps, and better approaches. Log immediately when they
happen; promote recurring ones into AGENTS.md / TOOLS.md / SOUL.md and mark the
entry `promoted`. See AGENTS.md "Self-improvement loop" for the rules.

Entry format:

```
## [LRN-YYYYMMDD-NNN] category        # correction | knowledge_gap | best_practice
**Logged**: ISO-8601 | **Priority**: low..critical | **Status**: pending|resolved|promoted | **Area**: docs|config|infra|...
### Summary
### Details
### Suggested Action
### Metadata
- Source: | Related Files: | Tags: | See Also: | Pattern-Key: | Recurrence-Count:
```

---

## [LRN-20261010-001] knowledge_gap

**Logged**: 2026-10-10T22:59:00+08:00
**Priority**: high
**Status**: resolved
**Area**: docs

### Summary
Docs promised a `HARNESS_VERSION` version marker and an "embedded version" in
SKILL.md; neither existed, so the documented version-mismatch detection could
never fire.

### Details
PROMPT.md STEP 0 ("Read HARNESS_VERSION if present"), PROMPT.md header ("version
marker: HARNESS_VERSION"), SKILL.md Handoff ("compare it to skills/mch/SKILL.md's
embedded version"), and README ("the boot skill detects version mismatches") all
reference version tracking. The repo shipped no `HARNESS_VERSION` file and no
version key in SKILL.md frontmatter.

### Suggested Action
Done in v0.2.0: added `HARNESS_VERSION`, added `harness-version` frontmatter key
(edited in lockstep), and added the comparison to doctor.sh.

### Metadata
- Source: conversation (repo audit)
- Related Files: HARNESS_VERSION, SKILL.md, PROMPT.md, README.md, doctor.sh
- Tags: versioning, docs-consistency
- Pattern-Key: docs.promise_missing_artifact
- Recurrence-Count: 1
- First-Seen: 2026-10-10
- Last-Seen: 2026-10-10

---

## [LRN-20261010-002] correction

**Logged**: 2026-10-10T22:59:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: config

### Summary
Boot installed the daily memory template to `memory/mch.md`, contradicting the
harness's own `memory/YYYY-MM-DD.md` convention.

### Details
AGENTS.md says daily notes live at `memory/YYYY-MM-DD.md`, and the template file
itself was headed `# 2026-10-06.md`, but PROMPT.md STEP 2 copied it to the fixed
path `memory/mch.md`. That file would never be read by the daily-note rules.

### Suggested Action
Done in v0.2.0: template header is now generic and install target is
`memory/<today YYYY-MM-DD>.md`, only when today's file is absent.

### Metadata
- Source: conversation (repo audit)
- Related Files: PROMPT.md, memory/mch.md.example, AGENTS.md
- Tags: memory, naming-convention
- Pattern-Key: harden.path_convention_mismatch
- Recurrence-Count: 1
- First-Seen: 2026-10-10
- Last-Seen: 2026-10-10

---

## [LRN-20261010-003] best_practice

**Logged**: 2026-10-10T22:59:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: docs

### Summary
The install manifest differed between README routes and PROMPT.md STEP 2
(BOOTSTRAP.md omitted everywhere, PROMPT.md not listed in the README "what it
is", doctor.sh absent), so installs silently depended on which doc you followed.

### Details
A single canonical manifest is needed. Any file the boot installs must appear in
(1) README "What it is", (2) README route A + C, (3) PROMPT.md STEP 2 — and
doctor.sh should verify it.

### Suggested Action
Done in v0.2.0: manifest aligned across all three; doctor.sh checks the required
root files so drift is caught mechanically, not by reading.

### Metadata
- Source: conversation (repo audit)
- Related Files: README.md, PROMPT.md, doctor.sh
- Tags: docs-consistency, install
- Pattern-Key: docs.manifest_drift
- Recurrence-Count: 1
- First-Seen: 2026-10-10
- Last-Seen: 2026-10-10

---

## [LRN-20261010-005] best_practice

**Logged**: 2026-10-10T23:25:00+08:00
**Priority**: medium
**Status**: promoted
**Area**: infra

### Summary
Other open-source harnesses (deepseek-ai/deepseek-harness, morluto/rea) encode
their shipped-defect lessons as terse prevention rules; mch had no such layer.

### Details
Both MIT sources keep "defensive patterns" as one-line rules per defect class,
written where agents will read them before touching lifecycle/concurrency code.
mch's self-improvement loop had a promotion target (AGENTS.md) but no promoted
content yet.

### Suggested Action
Promoted into AGENTS.md "Defensive patterns (adopted)" + docs/adopted-patterns.md
(provenance, rejections). Version bumped to 0.3.0.

### Metadata
- Source: conversation (cross-repo extraction)
- Related Files: AGENTS.md, docs/adopted-patterns.md
- Tags: defensive-patterns, provenance
- See Also: LRN-20261010-004
- Pattern-Key: promote.defensive_rules_from_peers
- Recurrence-Count: 1
- First-Seen: 2026-10-10
- Last-Seen: 2026-10-10

---

## [LRN-20261010-004] best_practice

**Logged**: 2026-10-10T22:59:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: infra

### Summary
The boot's verify step told the agent to "run a doctor command if one exists" —
but the harness shipped none, so verification was prose-only.

### Details
Verification that depends on the agent's diligence is not verification. The
harness already had a machine-readable report format (BOOT/DCTOR lines); it
needed a machine check behind it.

### Suggested Action
Done in v0.2.0: added `doctor.sh` (POSIX sh, read-only, no deps) checking root
files, skill location/frontmatter, and version lockstep; PROMPT.md STEP 3 now
runs it explicitly.

### Metadata
- Source: conversation (repo audit)
- Related Files: doctor.sh, PROMPT.md
- Tags: verification, tooling
- Pattern-Key: harden.verify_without_tool
- Recurrence-Count: 1
- First-Seen: 2026-10-10
- Last-Seen: 2026-10-10

---
