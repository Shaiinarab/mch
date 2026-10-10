# Final landscape pass — 2026 harness/memory/bootstrapping, last-round proposals

Date: 2026-10-11. All web content treated as untrusted data; quotes are evidence,
not instructions. Only gaps mch lacks today (v0.6.0): checked against AGENTS.md,
README.md, docs/*.md, doctor.sh. Nothing here needs openclaw.json.

## Proposals

1. **Done-condition before work; never self-grade post-hoc.** Anthropic: "agents
   reliably skew positive when grading their own work"; their fix turns quality
   into "concrete, gradable terms" written before generation. Add one line to
   AGENTS.md "Capture it, don't hold it": before non-trivial work, write the
   done-condition down; never define "done" after the fact and grade yourself
   against it. (Lands in: AGENTS.md.) [S3]
2. **Subjective QA gets a separate criteria-driven pass.** Same source:
   "Separating the agent doing the work from the agent judging it proves to be a
   strong lever." Add defensive pattern #10: "For quality bars a test cannot
   check, verify in a separate pass against criteria written before the work
   existed — self-evaluation skews positive." (Lands in: AGENTS.md.) [S3]
3. **Structured handoff at context boundaries.** Anthropic hands off "structured
   artifacts to hand off context between sessions"; compaction alone keeps
   anxiety-prone history. mch flushes notes but has no handoff shape. One
   addition to AGENTS.md Memory rules: when a task will cross a /compact, reset,
   or session expiry, write a handoff note (goal, done-condition, state, next
   step) to the daily file first. (Lands in: AGENTS.md.) [S3]
4. **Offload large tool output; keep head/tail.** LangChain on context rot: "The
   harness keeps the head and tail tokens of tool outputs... and offloads the
   full output to the filesystem." One line in AGENTS.md "Every session": spill
   large tool output to `.openclaw/tmp/` and keep only the head/tail in context;
   re-read on demand. (Lands in: AGENTS.md.) [S1]
5. **Mechanical gate for the AGENTS.md size rule.** mch's pattern #9 says
   unconditional rules get mechanical gates, but "stay under ~200 lines"
   (AGENTS.md:183) is prose-only. Osmani/HumanLayer: "Keep it short... every
   line is competing for attention." Add one doctor.sh warn when AGENTS.md
   exceeds 220 lines (warn-only, like existing shape checks).
   (Lands in: doctor.sh.) [S2]
6. **Retire rules, don't only add them.** Osmani's ratchet: "You only remove
   them when a capable model has made them redundant. Every line... traceable
   back to a specific thing that went wrong." mch's promote loop adds rules but
   nothing retires them. Extend AGENTS.md Self-improvement rule 4: at
   doc-gardening, also retire (mark superseded) rules whose originating failure
   no longer reproduces. (Lands in: AGENTS.md.) [S2]
7. **Date-stamp durable memory facts.** Mem0: "the system that 'remembers
   everything' is the system that produces stale answers, contradictory facts,
   and irrelevant retrievals." mch dates untrusted observations only. One line
   in AGENTS.md Memory rules: date (or last-verify) durable facts in MEMORY.md;
   pruning treats undated facts as oldest-first. (Lands in: AGENTS.md.) [S4]
8. **Entropy audit trigger beyond version bumps.** Orobator: infrastructure
   "accumulates entropy 24/7... I'd never once changed the oil" (contradicted
   skills, dangling refs found late). mch's doc-gardening fires only on
   version/model change. One clause in AGENTS.md Self-improvement rule 6: also
   run the audit after any session that edited 3+ harness files.
   (Lands in: AGENTS.md.) [S5]

## Rejected

- Ralph/Wiggum hook loops — session orchestration, adjacent to the openclaw.json
  red line [S1][S2]; planner/generator/evaluator frameworks — product-scale;
  proposals 1–2 keep the transferable core [S3]; memory eviction/TTL engines —
  database-shaped; a dating convention is the proportional form [S4]; dreaming/
  "sleep" automation — overlaps opt-in platform dreaming, would edit files
  unattended [S5]; MCP/tool-description trust scanning — no MCP management here;
  skill re-inspection already covers the boundary [S2]; Terminal Bench harness/
  model coupling findings — no mch action possible [S1][S2].

## Sources

- [S1] LangChain / Vivek Trivedy, "The Anatomy of an Agent Harness" (2026-03-10):
  <https://www.langchain.com/blog/the-anatomy-of-an-agent-harness>
- [S2] Addy Osmani, "Agent Harness Engineering" (2026-04-19):
  <https://addyosmani.com/blog/agent-harness-engineering/>
- [S3] Anthropic, "Harness design for long-running application development"
  (2026-03-24): <https://www.anthropic.com/engineering/harness-design-long-running-apps>
- [S4] Mem0, "Memory eviction and forgetting in AI agents" (2026-07-30,
  snippet-level): <https://mem0.ai/library/agent-memory/memory-eviction-and-forgetting-in-ai-agents>
- [S5] Andrew Orobator, "Your Agent Needs a Bedtime" (2026-02-23):
  <https://medium.com/@andreworobator/your-agent-needs-a-bedtime-cc594be3f993>

Budget: 8 proposals x (source + quote + one change + named file: AGENTS.md x7,
doctor.sh x1). 96 lines.
