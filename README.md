# Claude Global Toolkit

All-in-one baseline for AI-assisted engineering with Claude Code: a universal
instruction file, a handbook explaining the reasoning behind it, and an
on-demand library of prompts, templates, checklists, and install scripts for
adopting the baseline in any repository.

Toolkit version: 2.2.0 · Last reviewed: 2026-08-07

This repository is generated from four sources in `sources/` (see
`SOURCE_REGISTER.md`): the original master-prompt PDF (SRC-001) and a
memory/decision-system prompt (SRC-002, `update.txt`). Both are reference
exports; the Markdown and scripts in this repository are authoritative (see
`sources/README.md`).

## What's in here

| Path | Purpose |
|---|---|
| `GLOBAL_CLAUDE.md` | The universal baseline. Copy into another repo as `CLAUDE.md`. |
| `CLAUDE.md` | Operating instructions for *this* repository specifically, including the canonical session-start order. |
| `PROJECT_CONTEXT.md` | Living overview: what this project is, why, user goals/preferences, current focus, risks, next action. |
| `PROJECT_RULES.md` | Behavior rules for future sessions not already covered by `GLOBAL_CLAUDE.md`/`PROJECT_CONSTITUTION.md` (contradiction handling, prompt classification, decision-quality comparison). |
| `PROJECT_CONSTITUTION.md` | Durable purpose, authority hierarchy, approval matrix, definition of done. |
| `DECISIONS.md` | Log of significant choices made while building/maintaining this toolkit. |
| `PROMPTS.md` | Log of the actual large prompts (SRC-001, SRC-002) that shaped this repository, with status. |
| `IDEAS.md` | Backlog of not-yet-committed ideas, including rejected/deferred ones with reasons. |
| `OPEN_QUESTIONS.md` | Unresolved questions with a safe default, so they don't block progress or get re-asked. |
| `SOURCE_REGISTER.md` | Register of source material this toolkit is derived from. |
| `PROJECT_STATUS.md` | Build-progress ledger: current state, risks, and exact resume point. |
| `ROADMAP.md` | Planned work, not yet done. |
| `CHANGELOG.md` | Version history of this toolkit. |
| `HOW_TO_USE.md` | How to adopt this toolkit in another repository. |
| `HOW_TO_BUILD.md` | How this toolkit itself is built/maintained. |
| `chapters/` | Handbook — one chapter per major topic, with rationale. |
| `prompts/` | Reusable task prompts for *any* project (resume, investigate, plan, implement, review, ...) — not to be confused with `PROMPTS.md` above. |
| `templates/` | Fill-in templates (spec, plan, decision, verification, handoff, ...), including an optional memory-system bundle — see `HOW_TO_USE.md` §3. |
| `checklists/` | Checklists (startup, security, release, adoption validation, ...). |
| `scripts/` | Install scripts (`install.ps1`, `install.sh`). |
| `reviews/` | Final audits, produced when a review is actually run. |
| `summaries/` | Batch summaries written after each unit of work. |
| `session_logs/` | Dated, per-session logs — finer-grained than `summaries/`. |
| `memory/` | Structured memory extracts too detailed for the files above (see its README — purpose is intentionally narrow/inferred, not fully specified by source). |
| `exports/` | Generated exports (Markdown-merged, and PDF/DOCX when tooling exists). |
| `sources/` | Original reference material, kept verbatim. |

## Quick start

See `HOW_TO_USE.md` for adopting the baseline in a target repository, and
`chapters/00-mission-and-authority.md` for the reasoning behind the rules
before you rely on them.

## Status

See `PROJECT_STATUS.md` for exactly what is built, what is still open, and
where to resume.
