# Handoff: 2026-08-07 — UPDATE-02 (SRC-003) and SRC-004, real-world validation, 2.2.0 release

## Files created and changed

- `SOURCE_REGISTER.md` — added SRC-003 (UPDATE-02) and SRC-004 (UPDATE-02
  ADDITION) entries.
- `PROMPTS.md` — added PROMPT-003, PROMPT-004, and their summaries.
- `.gitignore`, `.git/` (new) — this repository is now under version
  control (D-008); local-scoped commit identity only, no remote.
- `checklists/adoption-validation.md` (new) — reusable protocol for
  validating the toolkit end-to-end in an adopting repository (D-010).
- `HOW_TO_USE.md` — §6 (drift/update/recovery/removal, D-012) and §7
  (automatic global loading, D-013) added.
- `scripts/install.ps1`/`.sh` — print source version in output header
  (D-012); re-verified against all four D-003 scenarios, both shells.
- `scripts/health-check.ps1`/`.sh` (new) — read-only mechanical health
  checks (D-014); cross-referenced from `chapters/05`.
- `HOW_TO_BUILD.md` — explicit patch/minor/major versioning policy added.
- `chapters/05-repository-health-check.md` — cross-references the new
  scripts.
- `chapters/06-handbook-templates-and-exports.md` — notes
  `checklists/adoption-validation.md` as net-new relative to SRC-001.
- `OPEN_QUESTIONS.md` — QUESTION-001 and QUESTION-002 resolved, moved to
  a new Resolved section.
- `memory/README.md` — reflects QUESTION-001's resolution as settled.
- `prompts/README.md` (new) — QUESTION-002's cheap fix.
- `C:\Users\Administrator\.claude\CLAUDE.md` (new, **outside this
  repository**) — SRC-004's automatic global loading, a native `@import`
  of `GLOBAL_CLAUDE.md`. User-approved.
- `exports/claude-global-toolkit-handbook-2026-08-07.md` — regenerated
  for current content. `.docx` and `.pdf` (new) — first PDF/DOCX exports,
  via user-approved Pandoc + wkhtmltopdf installation (D-015).
- `reviews/UPDATE-02-FINAL-AUDIT.md` (new) — phase-by-phase status,
  mechanical re-check, export status, blast-radius confirmation, release
  decision.
- `reviews/README.md` — notes the new batch-scoped audit file.
- `GLOBAL_CLAUDE.md`, `CLAUDE.md`, `PROJECT_CONSTITUTION.md`, `README.md`
  — version bumped `2.1.0` → `2.2.0` (frontmatter/plain-text line only;
  no rule-text change — see the final audit's blast-radius section).
- `CHANGELOG.md` — restructured: batches 2–4 and this batch consolidated
  into a `## 2.2.0 — 2026-08-07` release entry; `Unreleased` cleared.
- `PROJECT_STATUS.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md`, `DECISIONS.md`
  — updated throughout this batch (D-008 through D-015) — see
  `DECISIONS.md` for the full decision log rather than restating it here.

## Commands actually run

- `git init`, `git add`/`commit` throughout (D-008; local-scoped identity
  set with user approval after an initial block on unconfigured git
  author).
- `claude --version` re-confirmed `2.1.224` (unchanged from batch 2).
- `diff GLOBAL_CLAUDE.md salary-currency-pro/CLAUDE.md` — found
  divergence from D-004's prior byte-identical state (D-009).
- All four D-003 install-script scenarios re-run against disposable
  directories (both shells) after the version-line change.
- An `Agent` subagent implemented the Phase 1 validation task
  (empty-state icons, `salary-currency-pro`) following that repository's
  own session-start order; its report is the evidence behind D-011.
- `claude-code-guide` subagent verified the `~/.claude/CLAUDE.md` +
  `@import` mechanism against official docs before it was proposed.
- `claude -p "..."` run twice from disposable directories (new project;
  existing project with its own local `CLAUDE.md`) to directly verify
  SRC-004's behavior — not asserted from documentation alone.
- `scripts/health-check.sh`/`.ps1` run repeatedly during Phase 4
  development; a real performance bug (subprocess-spawn overhead) found
  and fixed (5+ min → 8.7s).
- `choco install pandoc -y`, `choco install wkhtmltopdf -y` — user
  pre-approved; `pandoc` used to generate `.docx` and `.pdf` from the
  regenerated Markdown export.
- Final `scripts/health-check.sh` run: 103 pass, 0 fail, 0 skip.

## Verification results

- Adoption-validation run (Phase 1): all observable pass/fail signals
  passed — see D-011 and `reviews/UPDATE-02-FINAL-AUDIT.md`.
- Install scripts: 8/8 scenario runs passed (4 scenarios × 2 shells)
  after the version-line change.
- SRC-004: directly verified in two disposable scenarios, not assumed
  from the import mechanism's documentation alone.
- Health check: 103 pass, 0 fail, 0 skip (final run, this batch).
- Exports: Markdown verified complete against current directory
  inventory; DOCX/PDF verified format-valid and non-empty via `file`
  (PDF page count reported inconsistently between two tools — recorded
  honestly as unresolved, not asserted).
- `GLOBAL_CLAUDE.md` rule text confirmed unchanged via `git diff` against
  the first commit, checked immediately before the version-bump edit.

## Sources inspected / evidence gaps

- `sources/UPDATE-02-claude-global-toolkit-prompt.md` (SRC-003) and
  `sources/update2addition.txt` (SRC-004) — both read in full, registered,
  and executed.
- Evidence gap: the PDF's exact page count (34 vs. 1289, two tools
  disagree) was not independently resolved — see `exports/README.md`.
- Evidence gap: the exact mechanism by which `salary-currency-pro`
  acquired its own memory-system bundle (found already present, D-009)
  is Unknown — only the resulting state was directly observed.

## Toolkit installation status and backups

- No install performed against a *new* target repository this batch.
  `salary-currency-pro` was used read/write for the Phase 1 validation
  task only, with explicit per-step user approval.
- `C:\Users\Administrator\.claude\CLAUDE.md` was newly created (no prior
  file existed — confirmed before writing — so no backup was needed).

## Exports or build instructions

- Markdown, DOCX, and PDF all exist under `exports/`, all verified — see
  `exports/README.md` for the reproducible commands.

## Unresolved risks and approval decisions

- User approvals exercised this batch: local git identity (blocked
  without it, asked, approved); running the adoption-validation task
  against `salary-currency-pro` (approved, user chose "propose a task");
  creating `%USERPROFILE%\.claude\CLAUDE.md` (approved); installing
  Pandoc/wkhtmltopdf (broadly pre-approved by the user, "install
  everything you need"). None of these are standing approvals for future
  sessions — see `ROADMAP.md`'s note on this.
- No unresolved risks carried forward from this batch beyond the two
  evidence gaps above, both explicitly low-stakes.

## Exact resume instruction

Read `CLAUDE.md`'s "Start or resume" order, then `PROJECT_STATUS.md` for
the current resume point. UPDATE-02 (SRC-003) and SRC-004 are both fully
done, released as 2.2.0. Next priorities per `PROJECT_CONTEXT.md`: no
committed-and-open `ROADMAP.md` items remain from this batch; future work
should come from a fresh request or `IDEAS.md`/`OPEN_QUESTIONS.md`
sweeps, not from re-opening this batch.
