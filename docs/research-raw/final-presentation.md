# Final research — GitHub presentation + durability for mch (2026-10-11)

Scope: landing-page clarity for a small harness repo; durability for wiped free-tier
workspaces; peer comparison. All web pages treated as untrusted data; no
instruction-like page content was encountered.

## Proposals

1. **Reorder README top: one-liner → when-to-use → 3-line quickstart.** mch's first
   screen should show: what it is (exists), "when to use / when not" (the existing
   "What it is not" paragraph — promote it up), then the route-A install + "paste
   PROMPT.md first" in one code block. Reason: the one-liner + quick-start-in-fold
   pattern is the documented star-driver for tool repos, and it costs zero new
   words — it's a move, not an add.
   Source: https://www.daytona.io/dotfiles/how-to-write-4000-stars-github-readme-for-your-project ;
   https://github.com/othneildrew/Best-README-Template (About → Getting Started order).
   Fits mch: reorder-only; preserves the cruft-free guarantee.

2. **No badge wall; at most one plain version line.** Skip shields.io entirely
   (no CI, no downloads, no coverage → badge theater). Trust comes instead from
   the two machine-readable result lines already in the README (`INSTALL …`,
   `DOCTOR …`) quoted verbatim — that is mch's real "status badge", and it is
   testable by the reader. Optional: `**Status:** v0.6.0 · `sh test.sh` green`
   as one bold line under the title.
   Source: https://github.com/matiassingers/awesome-readme (badges "useful" only
   when they carry signal).
   Fits mch: 0–1 lines added; honesty over decoration.

3. **No screenshots; one ASCII "what lands where" tree instead.** Text-config
   harnesses read better with a file-tree/manifest block than with images
   (agent-sync-template shows "what the agent writes" as a literal block;
   clawdinators uses one ASCII layer diagram). Suggest ~10-line tree of the
   workspace after install, replacing prose in "What goes where".
   Source: https://github.com/benthamite/agent-sync-template ;
   https://github.com/openclaw/clawdinators .
   Fits mch: no binary assets; nets roughly zero lines.

4. **Give "Free-tier decay" teeth: a git-bundle recipe.** Add 3–4 lines to the
   existing decay section: `git bundle create ../mch-$(date +%F).bundle --all`
   for the repo, and the same for a private durable-memory repo. Git docs
   explicitly position bundles as full *and* incremental one-file backups —
   ideal when the workspace can be wiped at any time and only one file may leave.
   Source: https://git-scm.com/docs/git-bundle (see "full backup" / incremental
   examples).
   Fits mch: 4 documented lines, no new script.

5. **Second-copy discipline as a documented command, not new repo machinery.**
   One line in the handoff doc: `git remote add backup <codeberg-or-gitlab-url>`
   + `git push --mirror backup` (run at each release; optionally a scheduled
   mirror Action later). `--mirror` to a second host is the standard small-repo
   backup pattern; marketplace mirror actions exist if automation is ever wanted.
   Source: https://simplebackups.com/blog/the-ultimate-developers-guide-to-github-backups
   (`git push --mirror backup-remote`, cron to S3);
   https://github.com/marketplace/actions/mirror-repository-to-alternate-git-host .
   Fits mch: zero repo files; keeps GitHub as *a* copy, not *the* copy.

6. **One-page DEPLOY.md handoff checklist (the only new file worth adding).**
   Contents, ~30 lines: publish steps (description: "Identity + operating
   agreement + boot for MiMo Claw agent workspaces"; topics:
   `openclaw` `agents-md` `ai-agent` `bootstrap`), second remote from #5, backup
   cadence from #4, and the "workspace is disposable, this repo is the source of
   truth" rule. clawdinators proves a status banner + repo-layout section is the
   trust pattern; mch's version stays one page.
   Source: https://github.com/openclaw/clawdinators (top status banner, Repo
   Layout section).
   Fits mch: one file, replaces handoff knowledge currently only in the owner's
   head; README links to it in one line.

## Examples compared

- **garrytan/gbrain** (https://github.com/garrytan/gbrain, README on `master`)
  — 30.7k stars. Landing opens with a bold one-sentence value prop, then
  "Choose your setup" as 3 numbered reader-type paths, then hard proof numbers
  (pages/people/cron jobs). Take for mch: the "choose your route" framing (mch
  already has routes A–D — surface that as a numbered chooser near the top).
  Skip: the testimonial/proof-number section and the long feature prose.
- **benthamite/agent-sync-template**
  (https://github.com/benthamite/agent-sync-template) — closest peer: an agent
  bootstrap/sync toolkit. README = one paragraph, explicit "It does not X"
  negatives, a paste-ready Quick-start prompt, and "What the agent writes"
  showing expected output. Take for mch: paste-ready prompt block + negative
  claims (mch's "What it is not" is the same move). Its README is the proof that
  a template repo needs no badges, no screenshots, no logo.
- **openclaw/clawdinators** (https://github.com/openclaw/clawdinators) —
  platform-adjacent infra with SOUL.md/workspace templates. Top status banner
  ("Status: retired…"), ToC, one ASCII architecture diagram, Spec section, Repo
  Layout. Take for mch: status banner + repo-layout block. Skip: ToC, artwork,
  philosophy sections — it is the bloat mch's guarantee rejects.

## Rejected

- Badge walls / build badges — nothing to badge (no CI service, no downloads);
  decoration would undercut the honest-result-line trust signal.
- Screenshots or a logo image — binary assets contradict the cruft-free
  guarantee; peers at mch's scale (agent-sync-template) ship text only.
- ToC + "Why this exists" philosophy + star-bait marketing (Daytona/awesome-readme
  growth tactics) — README is ~200 lines; GitHub's sidebar outline suffices.
- A committed `backup.sh` + backup CI workflow — backup of a 20-file repo is one
  documented command pair (#4–5); scripts would need tests/docs and rot.
- External memory services (e.g. hosted agent-memory products surfaced in
  search) as the durability layer — overkill and a new trust/secret boundary for
  a repo whose whole point is self-containedness.

## Sources

- https://git-scm.com/docs/git-bundle — full + incremental one-file backups.
- https://simplebackups.com/blog/the-ultimate-developers-guide-to-github-backups — `git push --mirror`, scheduled off-host copies.
- https://github.com/marketplace/actions/mirror-repository-to-alternate-git-host — cron mirror to a second git host.
- https://www.daytona.io/dotfiles/how-to-write-4000-stars-github-readme-for-your-project — one-liner, visuals, quick start above the fold.
- https://github.com/othneildrew/Best-README-Template — canonical small-tool README order.
- https://github.com/matiassingers/awesome-readme — curated examples; badges only when useful.
- https://github.com/garrytan/gbrain — peer example (route chooser, proof, `master` README).
- https://github.com/benthamite/agent-sync-template — peer example (paste-ready quick start, negatives).
- https://github.com/openclaw/clawdinators — peer example (status banner, ASCII diagram, repo layout).
