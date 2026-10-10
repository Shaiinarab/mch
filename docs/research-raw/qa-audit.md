# qa-audit — mch harness (doctor.sh / install.sh / test.sh / PROMPT.md / README.md)

All repros executed 2026-10-11 in `.openclaw/tmp/qa-scratch/` (repo copied there; real repo untouched).
shellcheck not installed (not installed per constraints); `sh -n`, `bash -n`, `dash -n` used instead.

## Defects (severity-ordered)

### HIGH

1. **install.sh:48-58,94-97 — failed managed-file writes still report `INSTALL OK`, exit 0.**
   `mirror()` ignores `mkdir`/`cp` failure (`cp ... && written=...`) and the summary hardcodes `status=OK`
   unless there are conflicts. A broken install (boot skill missing) is reported as success to automation.
   Repro: `mkdir ws && touch ws/skills && sh install.sh <repo> ws`
   Observed: `INSTALL OK version=0.5.0 written=12 skipped=0 conflicts=0`, exit=0, but
   `test -f ws/skills/mch/SKILL.md` → NO (3 managed files silently absent; only stderr noise).
   Expected: `INSTALL FAIL` or exit 1 (contract: install.sh:22 "1 = hard error").

### MED

2. **test.sh:44 — `hashes()` is vacuous when WORKDIR path contains spaces; "byte-identical" check can never fail.**
   `find "$ws" -type f | sort | xargs cksum` word-splits spacey paths; every `cksum` errors (suppressed by
   `2>/dev/null`), so `before`/`after` are both empty strings and `test "$before" = "$after"` always passes.
   Repro: `ws="$Q/space dir/ws"; find "$ws" -type f | sort | xargs cksum 2>/dev/null | wc -l`
   Observed: `0` — while `find "$ws" -type f | wc -l` → `15` (and `find … -print0 | xargs -0 cksum | wc -l` → `15`).
   Expected: one cksum line per file (15), so corruption would actually be detected.

3. **install.sh:30 — `set -u` + unset `HOME` crashes with no machine-readable summary line.**
   `WS="${2:-$HOME/.openclaw/workspace}"` expands `$HOME` when `$2` is absent.
   Repro: `env -u HOME sh install.sh <repo>` (no 2nd arg)
   Observed: `install.sh: 30: HOME: parameter not set`, exit=2, **no** `INSTALL …` line.
   Expected: the documented contract (install.sh:19) "Output ends in one machine-readable line".

4. **install.sh:28,96 — empty/whitespace HARNESS_VERSION is accepted; `version=` value is blank.**
   Repro: `printf '   \n\n' > repo/HARNESS_VERSION; sh install.sh repo ws`
   Observed: `INSTALL OK version= written=15 skipped=0 conflicts=0` (same for a 0-byte file), exit=0 —
   yet `sh doctor.sh ws` on that tree reports `gap: HARNESS_VERSION is missing or empty`,
   `DOCTOR PARTIAL version=- files=8 gaps=1 warns=0`, exit=1.
   Expected: install should fail (or at least not emit `INSTALL OK` / an unparseable empty `version=` field
   for a repo it knows doctor will reject). Machine-readability of `version=<v>` breaks.

5. **doctor.sh:62-70 — a second, conflicting root `SKILL.md` is silently ignored ("exactly one SKILL.md" unverified).**
   Repro: install tree, then `sed 's/0.5.0/9.9.9/' repo/SKILL.md > ws/SKILL.md` (root copy claims 9.9.9;
   `ws/skills/mch/SKILL.md` claims 0.5.0); `sh doctor.sh ws`
   Observed: `DOCTOR OK version=0.5.0 files=8 gaps=0 warns=0`, exit=0 — no mention of the extra root SKILL.md.
   Expected: warn/gap on duplicate boot-skill location; README:190 promises "exactly one SKILL.md" but
   nothing verifies it.

### LOW

6. **install.sh:85 — date-unavailable fallback works (no crash) but seeds `memory/unknown.md`, breaking the
   filename contract and cross-run idempotency.**
   Repro: PATH without `date`; run install.sh → `ls ws/memory` shows `unknown.md`
   (PROMPT.md:27 requires `memory/<today YYYY-MM-DD>.md`). Re-run the same install later with `date`
   available → `INSTALL PARTIAL … written=1 …` (seeds `memory/2026-10-10.md`), contradicting
   install.sh:21-22 "run twice and the second run reports written=0". Observed both outputs above.

## Consistency gaps

- **README:41 says "Three routes" then lists four** (A, B, C, D — route D at README:100).
- **PROMPT.md:16 route B manifest ≠ STEP 2 manifest (PROMPT.md:23-25) ≠ doctor's required list.**
  Route B fetches only `SOUL AGENTS USER IDENTITY MEMORY PROMPT`; BOOTSTRAP.md + HARNESS_VERSION are skipped.
  Repro: install tree, `rm ws/BOOTSTRAP.md ws/HARNESS_VERSION`, `sh doctor.sh ws` →
  `DOCTOR PARTIAL version=- files=6 gaps=3 warns=0` — a clean route B install cannot pass STEP 3 verify.
  README:70 has the same omission ("Memory and USER/MEMORY files still need copying" only).
- **Route C file list omits `install.sh`** (README:74-88 lists 11 URLs; PROMPT.md:17 "each needed path")
  while STEP 2 (PROMPT.md:25) mandates `skills/mch/install.sh`; doctor.sh never checks for it either.
  Repro: remove `ws/skills/mch/install.sh` → `DOCTOR OK version=0.5.0 files=8 gaps=0 warns=0`.
  Three different "manifests" (README manual route / PROMPT STEP 2 / doctor's 8-file list) disagree.
- **PROMPT.md:44 report format asks for `files: <n> written / <n> merged / <n> skipped`** but no script
  emits a "merged" count — install.sh reports `written/skipped/conflicts` (install.sh:96); "merged" is
  unobtainable machine-readably.
- **`INSTALL FAIL` (install.sh:34,39) is an undocumented third status**; the documented format is
  `INSTALL <OK|PARTIAL>` (install.sh:19, README:52).
- Minor: install.sh:87-91 counts `skipped` on first run when `memory/mch.md.example` is absent, inflating
  the skip counter without a skip having occurred.

## Verified-clean (tested, passed)

- `sh -n`, `bash -n`, `dash -n` on doctor.sh/install.sh/test.sh: zero errors.
- No bashisms found; POSIX-only constructs (`${1:-}`, `$((…))`, `case`, functions); `cd --`/`dirname --`
  accepted by both dash and bash.
- test.sh with `WORKDIR` containing spaces: `TEST OK checks=10 failures=0` (aside from defect 2).
- install.sh target path with spaces: `INSTALL OK version=0.5.0 written=15 skipped=0 conflicts=0`;
  doctor.sh on same tree: `DOCTOR OK version=0.5.0 files=8 gaps=0 warns=0` (quoted globs handle spaces).
- test.sh with `date` missing from PATH: no crash, `TEST OK checks=10 failures=0` (fallback at install.sh:85).
- Idempotency within one environment: second install `written=0`, tree byte-identical (test.sh checks 2).
- Judgment files never clobbered: `USER-OWNED-CONTENT`/`HAND-EDITED-SOUL` survive reinstall;
  conflicts reported as `conflicts=2` + `INSTALL PARTIAL`, not decided silently (test.sh checks 3).
- Version lockstep: `HARNESS_VERSION`=`0.5.0` matches `SKILL.md` `harness-version`; mismatch path
  (`gap: version mismatch`) exercised via whitespace-version tree.
- doctor.sh read-only: full-tree cksum identical before/after a doctor run.
- Doctor frontmatter extraction and secret scan work on spacey roots; missing-boot-skill path emits
  the correct `DOCTOR FAIL`-class gap line (checked in route-B/tree variants).
