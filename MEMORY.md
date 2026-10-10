# MEMORY.md

Main-session durable memory. Do not expose these contents in shared/public channels.

## What lives here

- Durable facts and decisions that are not profile/person details.
- Lessons learned that should survive more than one session.
- Important one-offs worth carrying forward.

## What does not belong here

- API keys, tokens, passwords, or other secrets.
- Raw session logs — those belong in `memory/YYYY-MM-DD.md`.
- Personal profile details that belong in USER.md.

## Starter entries

- This workspace is maintained from `Shaiinarab/mch`.
- Boot is idempotent: re-run on a fresh session; merge, never clobber, hand-edited files.
- Free-tier MiMo Claw clears workspace data on a schedule; keep durable copies elsewhere if needed.
- MEMORY.md stays compact and curated: the platform injects it with a budget and
  truncates over-budget content in context. Detail belongs in daily notes.

Add real entries only when something durable actually happens.
