# Project Context

## Last Updated

- Date: 2026-08-07
- Updated by: Claude Code session implementing SRC-002 (see `sources/update.txt`, `DECISIONS.md` D-005)
- Current status: Active — mid-implementation of the general memory/decision system this file is itself part of.

## Project Identity

This repository (`C:\Claude-Global-Toolkit`) *is* the Claude Global Toolkit:
a reusable governance/prompt/handbook system for Claude Code projects,
generated from `sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf`
(SRC-001) and now being extended per `sources/update.txt` (SRC-002, a
domain-agnostic memory/decision-management system).

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

See `PROJECT_STATUS.md` for the detailed, evidence-backed build ledger
(what's built, what's verified, what's open). In short: the full SRC-001
structure exists and passed a final audit (`reviews/`); a real adopting
repository (`salary-currency-pro`) carries the baseline; SRC-002's
memory-system additions are being implemented now (this file included).

## Current Focus

Implementing SRC-002's required files/directories in this repository,
reconciled against what already existed rather than duplicated — see
`DECISIONS.md` D-005 for the file-by-file mapping.

## Important Constraints

- Windows 11, PowerShell primary shell (Bash tool also available via
  Git Bash).
- This repository is not itself under Git version control as of this
  writing (no `.git` detected) — "reversible" here means file-level
  edits/backups, not commit-level rollback, until/unless that changes.
- Per `PROJECT_CONSTITUTION.md`'s approval matrix: installing this
  toolkit into another repository, or any action outside this repository,
  requires explicit confirmation first — already exercised in practice
  (the user was asked before, and separately confirmed, the install into
  `salary-currency-pro`).

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

- SRC-002 lists `memory/` in its required directory structure but never
  defines its intended contents anywhere in the prompt body — see
  `OPEN_QUESTIONS.md` QUESTION-001 (still open).

## Current Priorities

1. ~~**Finish implementing SRC-002 in this repository.**~~ Done (batch 3–4).
2. ~~**Real-world validation.**~~ Done 2026-08-07 — see `DECISIONS.md`
   D-011.
3. **UPDATE-02 (SRC-003) remaining phases** — adoption lifecycle
   completeness, open-question closure, reproducible health tooling,
   honest exports, final audit/2.2.0 release. See `ROADMAP.md`.
4. PDF/DOCX export — blocked on tooling availability/approval, lowest
   priority (see `ROADMAP.md`).

## Completed Milestones

- Batch 1 (2026-08-07): full SRC-001 structure generated and verified —
  `summaries/BATCH-01-initial-toolkit-build.md`.
- Batch 2 (2026-08-07): full audit, Claude Code version verification, real-
  install confirmation, Markdown export — `summaries/BATCH-02-audit-verification-export.md`.
- Baseline confirmed installed in a real adopting repository
  (`C:\salary-currency-pro\CLAUDE.md`, `DECISIONS.md` D-004).

## Next Recommended Action

Complete the remaining SRC-002 files/directories (`PROJECT_RULES.md`,
`PROMPTS.md`, `IDEAS.md`, `OPEN_QUESTIONS.md`, `memory/`, `session_logs/`),
update the cross-referencing root files, re-run the health check, and
report per SRC-002's own end-of-task reporting checklist. After that: shift
toward priority 2 above (real-world validation) rather than further
internal documentation batches.
