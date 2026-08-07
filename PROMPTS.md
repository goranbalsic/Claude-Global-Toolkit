# Prompt Library

Not to be confused with `prompts/` (generic, reusable task-execution
prompts for any project) — see `prompts/README.md` and this file's "How to
Use This File" section immediately below for the distinction.
`OPEN_QUESTIONS.md` QUESTION-002.

## How to Use This File

This file tracks the actual large prompts/instruction sets this project's
user has supplied that shaped this repository — not every conversation
message, and not the generic reusable task-execution prompts in `prompts/`
(those are for *any* project's day-to-day work; this file is specific to
*this project's own history*).

Each entry is labeled: Active, Reference, Experimental, Superseded, or
Archived.

## Prompt Index

| ID | Name | Type | Status | Purpose |
|---|---|---|---|---|
| PROMPT-001 | Claude Global Toolkit — AIO Master Prompt v2.1.0 | Foundational | Active | Defines this repository's entire governance structure |
| PROMPT-002 | General Project Memory and Decision System | Extension | Active | Adds context/memory/decision-tracking files on top of PROMPT-001 |
| PROMPT-003 | UPDATE-02 — from internally consistent to real-world proven | Extension | Active | Six-phase plan: real-world validation, adoption-lifecycle completeness, open-question closure, reproducible health tooling, honest exports, 2.2.0 release |

## Active Prompts

### PROMPT-001: Claude Global Toolkit — AIO Master Prompt v2.1.0

Status: Active

Purpose: The original specification for this entire repository — mission,
authority order, daily operating loop, evidence rules, the reusable project
structure, install-script requirements, health check, and export/audit
rules.

When to use: Read via the chapters it was decomposed into
(`chapters/00`–`07`); the full original text lives in `sources/`.

Full prompt or link: `sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf`
(SRC-001 in `SOURCE_REGISTER.md`).

Key requirements: See `chapters/00-mission-and-authority.md` through
`chapters/07-compatibility-and-persistence.md` — each chapter quotes its
relevant source text directly.

Known limitations: Static export; Claude Code version compatibility was
listed as "Unknown — verify installed version" (subsequently verified once,
2026-08-07, `2.1.224` — see `SOURCE_REGISTER.md`).

### PROMPT-002: General Project Memory and Decision System

Status: Active

Purpose: Domain-agnostic memory/context/prompt/decision-management system,
supplied to extend this repository with `PROJECT_CONTEXT.md`,
`PROJECT_RULES.md`, `PROMPTS.md` (this file), `IDEAS.md`,
`OPEN_QUESTIONS.md`, `memory/`, and `session_logs/`.

When to use: Already implemented in this repository as of 2026-08-07 — see
`DECISIONS.md` D-005/D-006 for the reconciliation against what already
existed. Reread `sources/update.txt` directly only if a future session
needs to re-verify something wasn't missed in that reconciliation.

Full prompt or link: `sources/update.txt` (SRC-002 in `SOURCE_REGISTER.md`;
note it's UTF-16 encoded, see that entry).

Key requirements: Reuse/improve existing files instead of duplicating;
session-start/session-end procedures; contradiction handling; prompt
classification (this section); decision-quality comparison; evidence/
verification-status vocabulary. See `PROJECT_RULES.md` for the parts not
already covered by `GLOBAL_CLAUDE.md`/`PROJECT_CONSTITUTION.md`.

Known limitations: Does not define what `memory/` should contain — see
`OPEN_QUESTIONS.md` QUESTION-001. Was supplied as an instruction to apply
directly to *this* repository; whether to also fold it into the toolkit's
*reusable* offering for other adopting repositories is unresolved — see
`IDEAS.md` IDEA-001.

### PROMPT-003: UPDATE-02 — Claude Global Toolkit: from internally consistent to real-world proven

Status: Active

Purpose: A six-phase update grounded in this repository's actual batch-4
state — close the real-world validation gap (Phase 1), complete the
adoption lifecycle (Phase 2), close the two open questions (Phase 3), add
reproducible health tooling and a versioning policy (Phase 4), regenerate
exports honestly (Phase 5), and produce a final audit plus a 2.2.0 release
(Phase 6).

When to use: Being executed phase by phase starting 2026-08-07 — see
`PROJECT_STATUS.md` for current progress and `DECISIONS.md` for decisions
made during execution (git-under-version-control decision, adoption-
validation-protocol approval question, versioning-policy decision, etc.).

Full prompt or link:
`sources/UPDATE-02-claude-global-toolkit-prompt.md` (SRC-003 in
`SOURCE_REGISTER.md`).

Key requirements: Re-verify "known state" claims rather than assume them;
resolve contradictions via `PROJECT_RULES.md`'s algorithm; implement
directly for ordinary decisions, ask only for approval-matrix cases (Pandoc
install, running the validation protocol against another repository);
report per the end-of-batch format after every meaningful batch.

Known limitations: Its Phase 1 real-world validation step requires the
user's explicit approval before touching `C:\salary-currency-pro`
(approval matrix, `PROJECT_CONSTITUTION.md`) — it cannot complete
unattended.

## Reference Prompts

None currently.

## Superseded Prompts

None currently.

## Prompt Summaries

**PROMPT-001 summary** — Core objective: give Claude Code a safe, resumable,
evidence-aware baseline. Required behavior: inspect before editing, minimal
reversible changes, verify before claiming done, ask before risky/external
actions. Constraints: never invent facts/results; don't touch files outside
the active repo without approval. Expected output: the full reusable
project structure (root governance files + `chapters/`/`prompts/`/
`templates/`/`checklists/`/`scripts/`/`reviews/`/`summaries/`/`exports/`).
What should not happen: unrestricted autonomy, fabricated verification,
silent scope expansion. Still active: yes.

**PROMPT-002 summary** — Core objective: make the repository the reliable
source of truth for context/decisions across session restarts. Required
behavior: classify instructions as permanent vs. task-specific, compare
alternatives rather than taking the first idea, resolve contradictions
explicitly, act autonomously on ordinary decisions. Constraints: don't
duplicate the same large prompt across multiple files; don't restart or
casually rewrite the existing project. Expected output: `PROJECT_CONTEXT.md`,
`PROJECT_RULES.md`, `PROMPTS.md`, `IDEAS.md`, `OPEN_QUESTIONS.md`, `memory/`,
`session_logs/`, reconciled with what already existed. What should not
happen: creating confusing duplicates of `DECISIONS.md`/`CHANGELOG.md`/
`summaries/`, which already existed and already fit the ask. Still active:
yes.

**PROMPT-003 summary** — Core objective: prove the toolkit works on a real
engineering task, not just internally, and finish the adoption lifecycle
and open questions it left behind. Required behavior: re-verify inherited
state before acting on it; decide-and-record rather than defer (Git
version control, versioning policy, QUESTION-001/002); ask exactly one
precise approval question before running the validation protocol against
another repository; keep exports honest (no PDF/DOCX claimed without
tooling). Constraints: same approval matrix as always — no auto-install,
no touching other repositories without fresh confirmation. Expected
output: an adoption-validation checklist, lifecycle docs (drift/update/
recovery/removal), both open questions closed, a dependency-free health
script, a regenerated export, a final audit, and — only if genuinely
earned — a 2.2.0 release. What should not happen: fabricated verification,
silent scope expansion, folding this repository's memory bundle into
`GLOBAL_CLAUDE.md`. Still active: yes.
