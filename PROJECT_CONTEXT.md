# Project Context

## Last Updated

- Date: 2026-08-07
- Updated by: Claude Code session executing UPDATE-02 (SRC-003) and SRC-004
  end to end (see `reviews/UPDATE-02-FINAL-AUDIT.md`, `DECISIONS.md` D-008
  through D-015).
- Current status: Active, at rest — UPDATE-02/SRC-004 fully complete and
  released as 2.2.0. No forced next action; see "Next Recommended Action"
  below.

## Project Identity

This repository (`C:\Claude-Global-Toolkit`) *is* the Claude Global Toolkit:
a reusable governance/prompt/handbook system for Claude Code projects,
generated from `sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf`
(SRC-001), extended per `sources/update.txt` (SRC-002, a domain-agnostic
memory/decision-management system), and further extended per UPDATE-02
(SRC-003) and SRC-004 — real-world validation, adoption-lifecycle
completeness, and automatic global loading via Claude Code's native
`@import` mechanism. Currently version 2.2.0.

## Purpose

Per SRC-001: establish a safe, evidence-aware, resumable baseline for
AI-assisted engineering that does not grant unrestricted autonomy. Per
SRC-002 (now layered on top): make the repository itself the reliable
source of truth for context and decisions, since chat sessions do not
persist across restarts.

## User Goals

The user (goranbalsic@gmail.com) wants a governance baseline that:

- Can be installed into any of their real projects, not just live as
  documentation here. Confirmed by direct use: the baseline was installed
  into `C:\salary-currency-pro` (a Flutter/Dart finance app with
  Android/iOS targets) and the user separately asked whether it would
  "auto read" and apply on resuming another, unnamed Android Studio
  project — indicating multiple active projects they want this applied to.
- Actually persists and gets used across session restarts, not just exists
  as one-time output — the user's own question about resuming work
  ("will it use this new logic when i resume?") is the core problem both
  SRC-001 and SRC-002 are trying to solve.
- Stays honest: verification claims must be real, not asserted.

## Desired Outcome

A toolkit that a future Claude Code session — in this repository or one
that has installed `GLOBAL_CLAUDE.md` — can read cold and pick up exactly
where the last session left off, without re-deriving context, re-deciding
settled questions, or receiving fabricated claims of work that didn't
happen.

## Current State

See `PROJECT_STATUS.md` for the detailed, evidence-backed build ledger.
In short: the full SRC-001 structure exists and passed a final audit
(`reviews/`); SRC-002's memory system is fully implemented; UPDATE-02
(SRC-003) and SRC-004 are fully executed and released as 2.2.0 — real-world
validation done and passed, adoption lifecycle complete, both open
questions closed, automatic global loading live, PDF/DOCX exports exist.
This repository is under Git version control (D-008).

## Current Focus

None forced — UPDATE-02/SRC-004 closed out this repository's committed
work. Next focus comes from a fresh user request, or a sweep of
`IDEAS.md`/`OPEN_QUESTIONS.md` if neither has anything pending (currently
neither does).

## Important Constraints

- Windows 11, PowerShell primary shell (Bash tool also available via
  Git Bash). Note: Git Bash subprocess spawns (e.g. calling external
  commands like `basename` inside a loop) carry real overhead on this
  machine — D-014 found a 5+ minute health-check run caused by exactly
  this, fixed by minimizing subprocess calls. Keep this in mind for any
  future POSIX scripting here.
- This repository is under Git version control since 2026-08-07 (D-008)
  — local only, no remote configured, nothing pushed. "Reversible" now
  means commit-level rollback, not just file-level backups.
- Per `PROJECT_CONSTITUTION.md`'s approval matrix: installing this
  toolkit into another repository, package installation, or any action
  outside this repository requires explicit confirmation first. This was
  exercised repeatedly during UPDATE-02 (local git identity; the
  adoption-validation task in `salary-currency-pro`; creating
  `%USERPROFILE%\.claude\CLAUDE.md`; installing Pandoc/wkhtmltopdf) — all
  granted, none of which stand as blanket approval for future sessions.

## User Preferences

- Prefers explicit confirmation before an action touches a repository
  other than the current one — observed directly: install into
  `salary-currency-pro` was proposed and confirmed before running.
- Wants verification claims to be real, not asserted (SRC-002 states this
  explicitly; SRC-001's mission section states the equivalent — "never
  claim to have inspected, executed, generated, installed, opened, or
  verified anything unless you actually did it").
- Wants existing systems reused/improved rather than duplicated when
  updating this repository (explicit in SRC-002, applied in `DECISIONS.md`
  D-005).
- Prefers concise, direct answers to quick questions over long explanations
  (observed: "ok a quick question" got a short, direct reply, not a
  restructured essay).
- Do not repeatedly ask what to do next on ordinary decisions — proceed
  and report (explicit in SRC-002's "Autonomous Decision-Making" section;
  consistent with SRC-001's "controlled express mode").

Only the preferences above are recorded because they were actually
observed or explicitly stated this session — no others are assumed.

## Known Risks

See `PROJECT_STATUS.md`'s Risks section for the full, current list.
Formerly the single largest one, per `reviews/PRINCIPAL_ENGINEER_REVIEW.md`:
this toolkit had been audited for internal consistency but not yet
validated by a real engineering session using it end-to-end in an
adopting repository. **Resolved 2026-08-07** — see `DECISIONS.md` D-011
(UPDATE-02 Phase 1 adoption-validation run, passed) and D-009 (earlier,
independent real use found in the same repository).

## Known Uncertainties

- None currently open — `OPEN_QUESTIONS.md` QUESTION-001 (what `memory/`
  should hold) and QUESTION-002 (prompts/PROMPTS.md cross-linking) were
  both resolved 2026-08-07 (UPDATE-02 Phase 3).

## Current Priorities

1. ~~**Finish implementing SRC-002 in this repository.**~~ Done (batch 3–4).
2. ~~**Real-world validation.**~~ Done 2026-08-07 — see `DECISIONS.md`
   D-011.
3. ~~**UPDATE-02 (SRC-003) and SRC-004, all phases.**~~ Done 2026-08-07 —
   released as 2.2.0. See `reviews/UPDATE-02-FINAL-AUDIT.md`.
4. ~~**PDF/DOCX export.**~~ Done 2026-08-07 — see `DECISIONS.md` D-015.

No committed priority remains open. Future priorities come from a fresh
user request.

## Completed Milestones

- Batch 1 (2026-08-07): full SRC-001 structure generated and verified —
  `summaries/BATCH-01-initial-toolkit-build.md`.
- Batch 2 (2026-08-07): full audit, Claude Code version verification, real-
  install confirmation, Markdown export — `summaries/BATCH-02-audit-verification-export.md`.
- Batch 3–4 (2026-08-07): SRC-002 memory system implemented and
  generalized into a reusable template bundle (IDEA-001).
- Batch 5 (2026-08-07): UPDATE-02 (SRC-003) and SRC-004 fully executed —
  real-world validation (passed), adoption lifecycle, open questions
  closed, automatic global loading, health-check tooling, PDF/DOCX
  exports, 2.2.0 release — `summaries/BATCH-05-update-02.md`.
- Baseline confirmed installed in a real adopting repository
  (`C:\salary-currency-pro\CLAUDE.md`, `DECISIONS.md` D-004), later found
  to have independently adopted the full memory-system bundle and used it
  through 10 real phases (`DECISIONS.md` D-009).

## Next Recommended Action

None forced. All committed work through UPDATE-02/SRC-004 is complete and
released. A future session should follow `CLAUDE.md`'s "Start or resume"
order, confirm nothing has drifted (`scripts/health-check.ps1`/`.sh`), and
take up whatever the user asks for next — or, absent a specific request,
sweep `IDEAS.md`/`OPEN_QUESTIONS.md` (currently both empty) before
starting anything new, per `chapters/01-daily-operating-loop.md`.
