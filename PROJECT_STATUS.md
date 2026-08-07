# PROJECT_STATUS.md

_Last updated: 2026-08-07 (batch 5, UPDATE-02/SRC-004 release, version 2.2.0)_

This file is the build-progress ledger (what's built, verified, and open).
For the higher-altitude "why this project exists / what the user wants /
current focus" narrative, see `PROJECT_CONTEXT.md` — the two are
deliberately not duplicates of each other; see `DECISIONS.md` D-005.

## Completed

- **UPDATE-02 (SRC-003) and SRC-004 fully executed and released as 2.2.0.**
  Full phase-by-phase status: `reviews/UPDATE-02-FINAL-AUDIT.md`. Decision
  log: `DECISIONS.md` D-008 through D-015. Batch summary:
  `summaries/BATCH-05-update-02.md`. In brief:
  - This repository is now under Git version control (D-008), local-only,
    no remote.
  - **The toolkit's largest previously-flagged risk — never validated
    end-to-end on a real engineering task — is resolved.**
    `checklists/adoption-validation.md` (new) was run against
    `C:\salary-currency-pro` with user approval; every observable
    pass/fail signal passed (D-011). Separately, re-verification found
    independent evidence that repository had already adopted the memory
    system and used it through 10 real phases, including a real
    production bug found and fixed there, before this session (D-009).
  - Adoption lifecycle completed: drift check, update path, recovery
    path, and removal all documented in `HOW_TO_USE.md` §6 (D-012).
  - Both standing open questions closed — `OPEN_QUESTIONS.md`'s Resolved
    section.
  - **Automatic global loading implemented and verified (SRC-004,
    D-013).** With user approval, created
    `C:\Users\Administrator\.claude\CLAUDE.md` importing `GLOBAL_CLAUDE.md`
    live via Claude Code's native `@import` mechanism — the toolkit's ten
    universal rules now load in every Claude Code session, in every
    project, without per-repository install. Verified directly with
    `claude -p` in two disposable scenarios (new project; existing
    project with its own local `CLAUDE.md`, correctly taking precedence).
    Documented in `HOW_TO_USE.md` §7.
  - Reproducible mechanical health-check scripts added
    (`scripts/health-check.ps1`/`.sh`, D-014), cross-referenced from
    `chapters/05`. A real performance bug (subprocess-spawn overhead) was
    found and fixed during testing. An explicit patch/minor/major
    versioning policy was added to `HOW_TO_BUILD.md`.
  - **PDF/DOCX export generated for the first time.** User approved
    installing Pandoc + wkhtmltopdf; both exports generated from the
    regenerated Markdown export and verified non-empty/format-valid
    (D-015).
  - Version bumped `2.1.0` → `2.2.0` across all four version-carrying
    locations (`CLAUDE.md`/`GLOBAL_CLAUDE.md`/`PROJECT_CONSTITUTION.md`
    frontmatter, `README.md`'s plain-text line) — a minor release per the
    new versioning policy. `GLOBAL_CLAUDE.md`'s rule *text* is unchanged
    throughout this entire batch (only its version label moved) —
    confirmed via `git diff` against the first commit, not assumed.
- **IDEA-001 implemented.** SRC-002's memory-system additions are now also
  available to other adopting repositories: six generalized templates
  under `templates/` and a new `HOW_TO_USE.md` §3 documenting them as an
  opt-in bundle, without touching `GLOBAL_CLAUDE.md` (`DECISIONS.md` D-007).
- **SRC-002 ("General Project Memory and Decision System") implemented.**
  `sources/update.txt` reconciled against existing governance rather than
  duplicated — see `DECISIONS.md` D-005 (file-by-file mapping) and D-006
  (merged session-start order). See `session_logs/2026-08-07-session-01.md`.
- Full reusable project structure generated from
  `sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf` (SRC-001, fully
  read and reconciled — text confirmed to match verbatim, pages 1–9). See
  `summaries/BATCH-01-initial-toolkit-build.md`.
- Both install scripts verified end to end against disposable test
  repositories, most recently after the D-012 version-line change: all
  four cases (create-when-absent, no-op-when-identical,
  safe-abort-when-unconfirmed, backup-then-overwrite) passed for both
  PowerShell and POSIX shell versions.
- **Claude Code version compatibility verified.** Installed CLI confirmed as
  `2.1.224` on Windows 11 (re-confirmed unchanged this batch), no breaking
  changes found against this toolkit's assumptions. Scoped to this
  version/date/OS — see `chapters/07-compatibility-and-persistence.md` →
  "Compatibility (verified)".
- **Two final audits on record.** `reviews/FINAL_AUDIT.md` +
  `reviews/PRINCIPAL_ENGINEER_REVIEW.md` (batch 2, mechanical + judgment
  review of the original toolkit build) and
  `reviews/UPDATE-02-FINAL-AUDIT.md` (batch 5, this release).
- **Exports current and complete.**
  `exports/claude-global-toolkit-handbook-2026-08-07.md` (regenerated
  this batch, 78,696 bytes, all 8 chapters/13 prompts/13 templates/10
  checklists verified present), `.docx` (49,571 bytes), `.pdf` (428,114
  bytes) — see `exports/README.md`.

## Risks / open items

- **Version compatibility is a point-in-time fact, not self-updating.**
  `2.1.224` was confirmed 2026-08-07; nothing in this toolkit detects a
  future Claude Code upgrade automatically. Re-run `claude --version` and
  update `chapters/07-compatibility-and-persistence.md` after any upgrade
  before relying on the "verified" section as current.
- **PDF's exact page count is unresolved.** `file`'s heuristic (1289)
  disagrees with wkhtmltopdf's own live render log (34); both files are
  confirmed valid and non-empty regardless — see `exports/README.md`.
  Low stakes, not blocking.
- No other open risks carried forward from this batch — see
  `reviews/UPDATE-02-FINAL-AUDIT.md` for the full check.

## Measurable success criteria (chapters/05-repository-health-check.md)

| Criterion | Status |
|---|---|
| No unresolved broken links in reviewed scope | Met — `scripts/health-check.sh` final run: 103 pass, 0 fail, 0 skip |
| Every substantive recommendation has a source mapping | Met |
| No known duplicate guidance | Met |
| Every workflow includes a verification step | Met |
| Every major decision traces to `DECISIONS.md` | Met — D-001 through D-015 |
| No empty or corrupt planned deliverable remains | Met — health-check script check 4 |
| Version-sensitive claims include version/date or verification instruction | Met |
| `PROJECT_STATUS.md` states completed work, risks, remaining work, resume point | Met — this file |

## Exact resume point

`ROADMAP.md` has no committed-and-open item remaining from UPDATE-02/SRC-004
— all of it shipped in the 2.2.0 release. `OPEN_QUESTIONS.md` has no open
entries (both resolved this batch); `IDEAS.md` has none pending. A future
session has no forced next action from this batch — pick up whatever the
user asks for next, or, absent a specific request, sweep
`IDEAS.md`/`OPEN_QUESTIONS.md` for anything newly relevant before starting
new work, per `chapters/01-daily-operating-loop.md`. Session-start order
for any future session: follow `CLAUDE.md`'s "Start or resume" section,
which is the single canonical order (and, since SRC-004, also loads
automatically as part of `~/.claude/CLAUDE.md`'s import in *any* other
project via `GLOBAL_CLAUDE.md` — but that file's ten rules only, not this
repository's own deeper history).
