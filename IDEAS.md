# Ideas Backlog

## How Ideas Are Managed

Ideas here are not automatically approved work. Each must be evaluated
against `PROJECT_CONTEXT.md`'s current priorities before implementation.
Distinct from `ROADMAP.md`, which tracks committed, planned work — this file
is for ideas that haven't been committed to yet, including ones rejected
with reasons preserved.

## High-Potential Ideas

None currently — IDEA-001 (below) moved to Implemented.

## Possible Ideas

None currently.

## Rejected Ideas

None currently.

## Deferred Ideas

None currently.

## Implemented Ideas

### IDEA-001: Fold SRC-002's net-new additions into the toolkit's reusable offering

Date added: 2026-08-07 · Date implemented: 2026-08-07

Source: Arose while implementing SRC-002 (`DECISIONS.md` D-005) — the memory
system was applied to this repository only, per its own instruction, but
`IDEAS.md`, `OPEN_QUESTIONS.md`, `session_logs/`, and `PROJECT_RULES.md`'s
new procedural content (contradiction handling, prompt classification,
decision-quality comparison) are generically useful, not specific to this
repository being the toolkit's own home.

Problem it solved: Repositories that install `GLOBAL_CLAUDE.md` got the ten
universal rules but none of SRC-002's memory/decision continuity machinery,
even though that machinery solves the same "sessions don't persist"
problem `GLOBAL_CLAUDE.md` itself exists for.

What was implemented: Six generalized templates under `templates/`
(`project-context.md`, `project-rules.md`, `prompt-library.md`,
`ideas-backlog.md`, `open-questions.md`, `session-log.md`), documented as
an opt-in bundle in `HOW_TO_USE.md` §3 ("Optional: memory and decision
continuity"). `GLOBAL_CLAUDE.md` itself was not touched — see
`DECISIONS.md` D-007 for the reasoning and rejected alternatives.

Status: Implemented — see `DECISIONS.md` D-007, `HOW_TO_USE.md` §3.

## Idea Template

### IDEA-NNN: Title

Date added:

Source:

Problem it may solve:

Proposed solution:

Expected benefit:

Potential risks:

Dependencies:

Alternatives:

Priority:

Status:

Reason for current status:
