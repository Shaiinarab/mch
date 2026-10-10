# Adopted patterns — what mch took from other harnesses

Distilled 2026-10-10 from two MIT-licensed repos, for the MiMo Claw workspace
harness (aistudio.xiamimimo.com cloud agent). Ideas and rules only — no code
copied verbatim.

Sources:

- `deepseek-ai/deepseek-harness` (dsh) — MIT, © 2026 DeepSeek. Open-source agent
  harness, "everything is a plugin", built on Cordis.
  <https://github.com/deepseek-ai/deepseek-harness>
- `morluto/rea` (REA) — MIT, © 2026 morluto. "Reverse Engineer Anything": a
  local-only reverse-engineering MCP toolkit with strict evidence and ownership
  discipline. <https://github.com/morluto/rea>

## What was adopted (now in AGENTS.md "Defensive patterns")

1. **Report orthogonal outcomes independently** (dsh) — a run can time out AND
   exit 0; never nest one flag's report inside another's branch. The BOOT and
   DOCTOR summary lines already obey this: written / merged / skipped / gaps are
   separate facts.
2. **Normalize at the owning boundary** (dsh) — one public contract per concept,
   documented where the type is defined, so callers never guess which layer
   failed.
3. **Untrusted output gets neither ambient env nor predictable paths** (dsh) —
   scrub `*KEY*`/`*SECRET*`/`*TOKEN*`/`*PASSWORD*` from spawned environments;
   temp/spill files live in private 0700 dirs with random names and owner-only
   0600 creates.
4. **Teardown must reach quiescence** (dsh) — kill then await the child's exit;
   close listeners before killing so late completions stay silent.
5. **Config changes are additive, idempotent, and backed up** (REA) — show
   planned changes before writing; never install or upgrade unrelated software
   while doing setup.
6. **Separate observations, derivations, inferences, and unknowns** (REA) —
   preserve provenance; state unknowns as unknowns instead of smoothing them over.
7. **Fix the producing representation before adding downstream repairs** (REA) —
   assess brittleness in touched code; abstractions only when they remove
   observed complexity.
8. **Generations are append-only** (dsh) — never move, overwrite, or delete
   committed versions of durable artifacts; record a breaking change at the
   moment it lands, not later.

## What was deliberately not adopted, and why

- **Cordis plugin architecture / package workspace layout** — dsh is a runtime
  system; mch is a docs-and-boot harness. Pulling in a plugin spine would be
  exactly the complexity rule (7) warns against.
- **Binary reverse engineering (REA's core purpose)** — not needed: dsh is
  source-available, so mining the source directly is both sufficient and the
  honest route. RE of a product to lift implementation for a competing platform
  is not something this harness does.
- **dsh's session/event wire format and lifecycle diagrams** — internal to that
  runtime; mch's lifecycle is one boot per session, already covered by PROMPT.md.

## Provenance note

Both projects are MIT-licensed; this file records the source of each adopted
rule as required attribution. If a future change copies literal code from either
repo, it must carry the upstream copyright notice and license text (see their
LICENSE files).
