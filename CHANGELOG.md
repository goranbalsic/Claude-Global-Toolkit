# CHANGELOG.md

## Unreleased — 2026-08-07 (batch 4)

- Implemented `IDEAS.md` IDEA-001: folded SRC-002's memory-system additions
  into this toolkit's reusable offering — six new generalized templates
  (`templates/project-context.md`, `project-rules.md`, `prompt-library.md`,
  `ideas-backlog.md`, `open-questions.md`, `session-log.md`) plus a new
  `HOW_TO_USE.md` §3 documenting them as an opt-in bundle. `GLOBAL_CLAUDE.md`
  itself was not changed (`DECISIONS.md` D-007).
- IDEA-001 moved from Deferred to Implemented in `IDEAS.md`.

## Unreleased — 2026-08-07 (batch 3)

- Implemented SRC-002 ("General Project Memory and Decision System",
  `sources/update.txt`), reconciled against the existing SRC-001-derived
  governance rather than duplicated — see `DECISIONS.md` D-005, D-006.
- New: `PROJECT_CONTEXT.md`, `PROJECT_RULES.md`, `PROMPTS.md`, `IDEAS.md`,
  `OPEN_QUESTIONS.md`, `memory/README.md`, `session_logs/` (with its first
  log, `session_logs/2026-08-07-session-01.md`).
- Reused as-is (no duplicate created): `DECISIONS.md`, `CHANGELOG.md`,
  `summaries/`.
- Merged SRC-002's session-start order into `CLAUDE.md`'s existing one,
  rather than leaving two competing orders (`DECISIONS.md` D-006).
- Found and fixed a genuine stale-fact inconsistency in
  `chapters/06-handbook-templates-and-exports.md` (still said no audit had
  been run, after batch 2's audit already had been) while re-running the
  cross-reference check on the enlarged repository (64 files, 805
  references checked, all resolve).
- Updated `README.md`'s structure table and `sources/README.md` to cover
  SRC-002/`update.txt` and all new files/directories.
- No version bump — governance/memory-system additions, not changes to
  `GLOBAL_CLAUDE.md`'s ten universal rules or the handbook's core content.

## Unreleased — 2026-08-07 (batch 2)

- Ran the full final audit (`reviews/FINAL_AUDIT.md`,
  `reviews/PRINCIPAL_ENGINEER_REVIEW.md`) — found and fixed three
  documentation inconsistencies (stale claim in chapter 04, path-
  qualification nit in chapter 06, a resolved contradiction between
  `ROADMAP.md` and `PROJECT_STATUS.md` on install-run status).
- Verified Claude Code version compatibility: `2.1.224` confirmed installed,
  no breaking changes found (`chapters/07-compatibility-and-persistence.md`,
  `SOURCE_REGISTER.md`).
- Confirmed a real (non-disposable) target repository
  (`C:\salary-currency-pro`) carries the installed baseline
  (`DECISIONS.md` D-004).
- Generated the first Markdown handbook export
  (`exports/claude-global-toolkit-handbook-2026-08-07.md`).
- No version bump — these are audit/verification/export deliverables, not
  content changes to `GLOBAL_CLAUDE.md` or the handbook's substance.

## 2.1.0 — 2026-08-07

- Initial generation of the full reusable project structure from
  `sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf`: root governance
  files, `chapters/`, `prompts/`, `templates/`, `checklists/`, `scripts/`
  (install scripts), and scaffolding for `reviews/`, `summaries/`,
  `exports/`.
- Version number carried forward from the source PDF's own
  "Toolkit Version: 2.1.0" front matter; no independent version bump applied
  in this initial build.
