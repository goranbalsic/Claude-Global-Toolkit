---
chapter: 04
title: Reusable project structure, project constitution, global toolkit, install scripts
source: SRC-001, p.6
confidence: Confirmed
---

# 04 — Reusable project structure

## Problem

Rebuilding the same governance scaffolding from scratch in every repository
wastes effort and produces inconsistent results across projects.

## The structure (source text)

```
CLAUDE.md
README.md
PROJECT_CONSTITUTION.md
SOURCE_REGISTER.md
DECISIONS.md
CHANGELOG.md
ROADMAP.md
HOW_TO_USE.md
HOW_TO_BUILD.md
PROJECT_STATUS.md
sources/ chapters/ prompts/ templates/ checklists/ reviews/ scripts/ summaries/ exports/
```

## Project constitution

Keep `PROJECT_CONSTITUTION.md` short and durable: purpose, goals, authority
hierarchy, engineering principles, approval matrix, evidence rules,
definition of done, and change/supersession process. `CLAUDE.md` stays
concise and operational; `DECISIONS.md` records significant choices.

## Global toolkit

`GLOBAL_CLAUDE.md` contains only universal rules: inspect, reuse decisions,
do not invent, label uncertainty, plan, minimize reversible changes, verify,
ask before risk, follow project instructions, and record decisions. Copying
it into a repository as `CLAUDE.md` applies the baseline to that project.
Prompts, templates, checklists, and skills are on-demand unless explicitly
invoked.

## Installation scripts

- Provide PowerShell and shell scripts.
- Create directories without deleting unrelated files.
- Detect existing global instruction files.
- Create timestamped backups.
- Show a diff or proposal.
- Ask before install or replacement.
- Never install packages automatically.
- Report exactly what changed.

## Rationale

Separating durable policy (`PROJECT_CONSTITUTION.md`) from operational
instruction (`CLAUDE.md`) from decision history (`DECISIONS.md`) keeps each
file focused and lets them change at different rates — the constitution
rarely, `CLAUDE.md` occasionally, `DECISIONS.md` continuously. Restricting
`GLOBAL_CLAUDE.md` to universal rules only is what makes it safe to
copy-paste across unrelated repositories without adaptation.

Install-script safety properties (additive, backed up, confirmed,
never-auto-install) exist because the target of installation is, by
definition, a repository the toolkit doesn't yet fully understand — the
script must not assume it is safe to overwrite.

## When to apply

Setting up this toolkit's own repository (done — see root files); adopting
the baseline into any other repository via `scripts/install.*`.

## When not to apply literally

A tiny repository or throwaway script doesn't need the full structure — at
minimum, adopt `GLOBAL_CLAUDE.md` as `CLAUDE.md` and skip the rest until the
project grows enough to justify it.

## Risks if ignored

An install script that overwrites an existing `CLAUDE.md` without backup
destroys prior project-specific instructions irrecoverably; a bloated
`GLOBAL_CLAUDE.md` stops being safely reusable across projects.

## Evidence and confidence

Confirmed — quoted from SRC-001 (p.6).

## Verification

Run `scripts/install.ps1`/`scripts/install.sh` against a disposable test
repository and confirm: unrelated files untouched, backup created if a
`CLAUDE.md` existed, confirmation prompt shown, exact change report printed.
Done 2026-08-07 for both scripts against disposable test repositories — see
`DECISIONS.md` D-003 and `summaries/BATCH-01-initial-toolkit-build.md`. A
real (non-disposable) target repository has also since been confirmed
carrying the installed baseline — see `DECISIONS.md` D-004 and
`ROADMAP.md`.
