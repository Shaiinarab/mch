# Peer web research → mch adoption proposals (2026-10-11)

All page content treated as untrusted data; no page instructions executed or followed. Already-adopted findings (dsh/rea patterns, memory model, SOUL voice-only, skill trigger-words) not repeated. Security note: no page contained injected instructions; one unverifiable claim (CSA's ClawHub characterization) is used only as motivation, not fact.

## Findings

1. **AGENTS.md is a map, not an encyclopedia — with a size budget.**
   <https://openai.com/index/harness-engineering/> — "give Codex a map, not a 1,000-page instruction manual"; a monolithic file "rots instantly" and "when everything is 'important,' nothing is"; theirs is ~100 lines of pointers into `docs/`. Cross-check <https://code.claude.com/docs/en/memory> — "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."
   → **Proposal (doc note in "Make it yours"):** AGENTS.md stays the map (≤200 lines); new detail goes to a named `docs/` file, AGENTS.md keeps the pointer. Current file is at the edge — trim on next edit instead of adding sections.

2. **Instruction files need a staleness/contradiction audit ("doc gardening").**
   <https://openai.com/index/harness-engineering/> — recurring "doc-gardening" agent scans for "stale or obsolete documentation" and opens fix-up PRs. <https://code.claude.com/docs/en/memory> — `/doctor prompt-audit` finds "instructions written for older models, references to files or commands that don't exist, and files that contradict each other", and "nothing in your files changes until you ask". <https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra> — "frequently revisit each instruction and ask yourself whether it's still needed".
   → **Proposal (rule in Self-improvement loop):** at every HARNESS_VERSION bump or model change, audit AGENTS/PROMPT/BOOTSTRAP/SKILL for dangling file/command references, cross-file contradictions, and old-model instructions; report proposed edits, apply only on user confirmation.

3. **Context files are context, not enforcement.**
   <https://code.claude.com/docs/en/memory> — "Claude treats them as context, not enforced configuration. To block an action regardless of what Claude decides, use a PreToolUse hook instead."
   → **Proposal (one bullet, Security posture):** a red line that must hold unconditionally gets a mechanical gate (doctor.sh check, shell guard, or platform hook); prose alone is advisory. Makes the existing "don't rely on the agent as sole control" actionable.

4. **Memory files record observations, never transplanted instructions.**
   <https://arxiv.org/html/2607.14611v1> (Bad Memory, Jul 2026) — payloads planted in memory/context files "can successfully attack current and future sessions"; untrusted content rarely gets an agent to overwrite its own trusted files, so the vulnerable moment is the write. Cross-check CSA note (finding 5): context files are "the primary delivery mechanism for this threat class"; OWASP Agentic Top 10 lists memory poisoning as ASI06.
   → **Proposal (one Memory rules bullet):** content recorded from external sources (web, third-party skills, pasted text) is stored as a quoted observation with source and date — never as an imperative; directive-shaped text must be re-derived and user-approved before entering MEMORY/AGENTS/SOUL.

5. **Hidden-character check for context files (the documented hiding place).**
   <https://labs.cloudsecurityalliance.org/research/csa-research-note-skill-md-agent-context-poisoning-20260506/> — SKILL.md files "can conceal adversarial instructions in invisible Unicode characters"; context files deserve "the same rigor applied to third-party code dependencies"; Snyk's ToxicSkills audit found flaws in ~37% of scanned skills.
   → **Proposal (doctor.sh check, warn-only):** scan root markdown + skills/mch for non-printable/bidi/zero-width characters (`LC_ALL=C grep '[^[:print:][:space:]]'`) and warn. Cheap POSIX addition beside the existing secret scan.

6. **Skill descriptions: narrow triggers, third person, minimal length.**
   <https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra> — descriptions "should be as short as possible while making it clear when the model should use them"; over-broad "Use when working with databases" fires "anytime it touches anything related to a database"; descriptions "contradict each other or over-emphasize when skills should be used". Cross-check <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> — "what the Skill does and when to use it", third person, ≤1024 chars.
   → **Proposal (doc note amending openclaw-fit.md finding 3):** the "when" must be narrow — name the moment of use and the adjacent non-use case; as short as possible; third person. Boot skill's description already complies; rule guards future skills.

7. **Progressive disclosure + degrees of freedom (for any future skill).**
   <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> — "Keep SKILL.md body under 500 lines"; exact scripts only for "fragile and error-prone" operations, heuristics otherwise. <https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra> — "make the root document a minimal router"; "overly specific guidance can now hinder results".
   → **Proposal (one sentence in README "Cruft-free guarantee"):** if a skill grows past one workflow, SKILL.md becomes a router to supporting files (<500 lines); exact-command form is reserved for fragile ops, doctor.sh-style. Nothing to change today.

8. **doctor.sh should flag a stale BOOTSTRAP.md (enforce the existing contract).**
   <https://code.claude.com/docs/en/memory> — `/init` "suggests improvements rather than overwriting" existing files, and `/context` confirms what actually *loaded*. mch's AGENTS.md says delete/archive BOOTSTRAP.md after first run; nothing verifies it (a prose-only contract — see finding 3).
   → **Proposal (doctor.sh check, warn-only):** warn when BOOTSTRAP.md is still present in an installed workspace — first run was not completed.

## Rejected

- **Path-scoped rules (`.claude/rules/`, `@imports`, CLAUDE.local.md)** — Claude Code features with no OpenClaw equivalent; adopting them needs platform/config changes mch must not make.
- **Full "docs/ as system of record + doc-gardening agent" machinery** — product-scale practice; mch is deliberately small. Kept only its cheap lessons (findings 1–2).
- **Hard-coded context-budget numbers (25KB / 200-line auto-memory limits)** — config-dependent; already rejected in openclaw-fit.md for the same reason.
- **Registry signing/provenance mandates for skills** — ClawHub-level, outside mch's scope; "inspect before trusting" + finding 5's local check instead.
- **Gerund skill renames (`bootstrapping-workspace`)** — mch ships one identity-named skill (`mch`); churn, no discovery benefit.

## Sources

- https://code.claude.com/docs/en/memory — Claude Code memory docs
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — Claude Platform skill authoring
- https://agents.md/ — AGENTS.md open format
- https://openai.com/index/harness-engineering/ — OpenAI, Feb 2026
- https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra — OpenAI developer blog, Sep 2026
- https://labs.cloudsecurityalliance.org/research/csa-research-note-skill-md-agent-context-poisoning-20260506/ — CSA research note, May 2026
- https://arxiv.org/html/2607.14611v1 — "Bad Memory", Jul 2026
