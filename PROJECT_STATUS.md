# PROJECT_STATUS.md

_Last updated: 2026-08-07 (batch 4)_

This file is the build-progress ledger (what's built, verified, and open).
For the higher-altitude "why this project exists / what the user wants /
current focus" narrative, see `PROJECT_CONTEXT.md` — the two are
deliberately not duplicates of each other; see `DECISIONS.md` D-005.

## Completed

- **IDEA-001 implemented.** SRC-002's memory-system additions are now also
  available to other adopting repositories: six generalized templates
  under `templates/` and a new `HOW_TO_USE.md` §3 documenting them as an
  opt-in bundle, without touching `GLOBAL_CLAUDE.md` (`DECISIONS.md` D-007).
- **SRC-002 ("General Project Memory and Decision System") implemented.**
  `sources/update.txt` reconciled against existing governance rather than
  duplicated — see `DECISIONS.md` D-005 (file-by-file mapping) and D-006
  (merged session-start order). New: `PROJECT_CONTEXT.md`,
  `PROJECT_RULES.md`, `PROMPTS.md`, `IDEAS.md`, `OPEN_QUESTIONS.md`,
  `memory/`, `session_logs/`. Reused as-is: `DECISIONS.md`, `CHANGELOG.md`,
  `summaries/`. Cross-reference check re-run on the enlarged repository (64
  files, 805 `.md` references, all resolve); found and fixed one genuine
  stale-fact inconsistency in `chapters/06-handbook-templates-and-exports.md`
  in the process. See `session_logs/2026-08-07-session-01.md`.

- Full reusable project structure generated from
  `sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf` (SRC-001, fully
  read and reconciled — text confirmed to match verbatim, pages 1–9): root
  governance files, `chapters/` (8), `prompts/` (12), `templates/` (7),
  `checklists/` (9), `scripts/install.ps1`/`install.sh`, and `reviews/`,
  `summaries/`, `exports/` scaffolding. See
  `summaries/BATCH-01-initial-toolkit-build.md`.
- Both install scripts verified end to end against disposable test
  repositories: all four cases (create-when-absent, no-op-when-identical,
  safe-abort-when-unconfirmed, backup-then-overwrite) passed for both
  PowerShell and POSIX shell versions (`DECISIONS.md` D-003).
- **A real (non-disposable) target repository is confirmed carrying the
  installed baseline — and has since diverged from it.** As of D-004
  (2026-08-07, earlier same day), `C:\salary-currency-pro\CLAUDE.md` was
  byte-identical to this repository's `GLOBAL_CLAUDE.md`. Re-verified
  during UPDATE-02 Phase 0 (2026-08-07, later same day): it is **no
  longer** byte-identical — the universal ten-rule baseline is still
  intact, but a repository-specific section has been appended referencing
  that project's own `PROJECT_CONTEXT.md`/`PROJECT_RULES.md`/`PROMPTS.md`/
  `session_logs/`/`DECISIONS.md` D-005, consistent with that repository
  having adopted this toolkit's optional memory-system bundle on its own.
  See `DECISIONS.md` D-009 — this is the first direct evidence of possible
  real-world use and feeds directly into UPDATE-02 Phase 1.
- **Claude Code version compatibility verified.** Installed CLI confirmed as
  `2.1.224` on Windows 11, no breaking changes found against this toolkit's
  assumptions. Scoped to this version/date/OS — see
  `chapters/07-compatibility-and-persistence.md` → "Compatibility
  (verified)".
- **Full final audit run.** `reviews/FINAL_AUDIT.md` (mechanical: links,
  empty files, duplication, source mappings — 215 cross-references checked,
  zero broken) and `reviews/PRINCIPAL_ENGINEER_REVIEW.md` (judgment-level)
  both written. Three real documentation inconsistencies found and fixed:
  a stale claim in `chapters/04-reusable-project-structure.md`, a path-
  qualification nit in `chapters/06-handbook-templates-and-exports.md`, and
  a resolved contradiction between `ROADMAP.md` and this file's prior
  version regarding install-run status.
- **Markdown export generated:**
  `exports/claude-global-toolkit-handbook-2026-08-07.md` — verified
  non-empty (59,725 bytes), contains all 8 chapters, 12 prompts, 7
  templates, 9 checklists.

## Risks / open items

- ~~**This toolkit has not yet been used end-to-end on a real engineering
  task in an adopting repository.**~~ **Resolved 2026-08-07** — UPDATE-02
  Phase 1 ran the new `checklists/adoption-validation.md` against
  `C:\salary-currency-pro` with the user's approval: session-start order
  followed, existing decisions reused, no silent scope expansion,
  verification honestly reported, credible resume point left. One finding
  (a wrong task-brief assumption caught by "inspect before acting" before
  wasted work happened) validated the mechanism rather than exposing a
  gap. See `DECISIONS.md` D-011. Separately, D-009 found evidence of
  earlier, independent real use in the same repository (10 completed
  phases, a real production bug found and fixed there) predating this
  specific run.
- **PDF/DOCX export not generated.** Requires a document-conversion tool
  (e.g. Pandoc) to be available or its installation explicitly approved —
  neither has happened. `exports/README.md` documents the reproducible
  Markdown-generation command in the meantime; no PDF/DOCX is claimed to
  exist.
- **This toolkit has not yet been used end-to-end on a real engineering
  task in an adopting repository.** `salary-currency-pro` has the baseline
  file installed, but there is no evidence yet that a session there has
  followed the daily operating loop, exercised an approval-matrix case, or
  found a chapter that doesn't hold up under real use. Flagged as the
  toolkit's largest untested assumption in
  `reviews/PRINCIPAL_ENGINEER_REVIEW.md`.
- **Version compatibility is a point-in-time fact, not self-updating.**
  `2.1.224` was confirmed 2026-08-07; nothing in this toolkit detects a
  future Claude Code upgrade automatically. Re-run `claude --version` and
  update `chapters/07-compatibility-and-persistence.md` after any upgrade
  before relying on the "verified" section as current.

## Measurable success criteria (chapters/05-repository-health-check.md)

| Criterion | Status |
|---|---|
| No unresolved broken links in reviewed scope | Met — 215 cross-references checked, all resolve |
| Every substantive recommendation has a source mapping | Met |
| No known duplicate guidance | Met |
| Every workflow includes a verification step | Met |
| Every major decision traces to `DECISIONS.md` | Met — D-001 through D-007 |
| No empty or corrupt planned deliverable remains | Met |
| Version-sensitive claims include version/date or verification instruction | Met — Claude Code compatibility verified and dated |
| `PROJECT_STATUS.md` states completed work, risks, remaining work, resume point | Met — this file |

## Exact resume point

`ROADMAP.md`'s "Open" section (PDF/DOCX export, blocked on tooling approval)
remains the only committed-and-open item. `IDEAS.md` IDEA-001 is now
Implemented; `OPEN_QUESTIONS.md` QUESTION-001 (what `memory/` should hold)
remains genuinely open and non-blocking. Beyond those, this toolkit's own
biggest gap is still real-world validation, not more internal documentation
work — see `PROJECT_CONTEXT.md`'s "Current Priorities" and the risk item
below. A
future session should prioritize either (a) getting explicit approval and
tooling for PDF/DOCX export, or (b) observing/supporting actual use of the
installed baseline in `salary-currency-pro` (or another adopting
repository) and feeding findings back into `DECISIONS.md` and the relevant
chapter, over generating further documentation-only batches in this
repository. Session-start order for any future session: follow `CLAUDE.md`'s
"Start or resume" section, which is now the single canonical order.
