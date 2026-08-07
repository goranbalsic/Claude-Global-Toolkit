---
title: Claude Global Toolkit — repository operating instructions
version: 2.1.0
last_reviewed: 2026-08-07
---

# CLAUDE.md

Operating instructions for this repository (`C:\Claude-Global-Toolkit`), the toolkit's
own home. This file is repository-specific and operational; it is **not** the file
that gets copied into other repositories — that is `GLOBAL_CLAUDE.md`. Durable
policy for this repository lives in `PROJECT_CONSTITUTION.md`; significant choices
live in `DECISIONS.md`.

## What this repository is

The source-of-truth home for the Claude Global Toolkit: a reusable handbook,
prompt library, template set, checklist set, and install scripts that other
repositories can adopt. `sources/` holds the original reference material
(SRC-001, the master-prompt PDF; SRC-002, the memory-system prompt in
`update.txt` — see `SOURCE_REGISTER.md`); every other top-level file and
directory here is generated from it and is authoritative over it.

## Start or resume

This is the single canonical read order for this repository — `PROJECT_RULES.md`
points here rather than restating it, so there is exactly one order, not two.

1. Read this file, then `PROJECT_CONTEXT.md` and `PROJECT_RULES.md`.
2. Read `PROJECT_CONSTITUTION.md` and `DECISIONS.md`.
3. Read `PROMPTS.md` (or the relevant prompt summary in it) for any large
   standing instructions currently Active.
4. Read `PROJECT_STATUS.md` and `ROADMAP.md` for build-progress state.
5. Check the latest entry in `session_logs/`, then the latest in
   `summaries/`.
6. Inspect Git status and the actual current repository state — do not
   assume the files above are still accurate without checking.
7. Run the repository health check
   (`chapters/05-repository-health-check.md`) before making further changes
   if it's been a while since the last session.
8. Resume at the next recommended action recorded in `PROJECT_CONTEXT.md`
   / first incomplete deliverable in `PROJECT_STATUS.md`.

## Rules specific to this repository

- Do not edit `sources/` — it holds the original supplied reference material
  verbatim. Corrections belong in the generated Markdown, not the source PDF.
- `GLOBAL_CLAUDE.md` must stay limited to the ten universal rules. If a rule is
  repository-specific, it belongs in a chapter, checklist, or prompt instead,
  not in `GLOBAL_CLAUDE.md`.
- Any change to `GLOBAL_CLAUDE.md` is a change to what every downstream
  repository inherits — treat it as higher blast-radius than an ordinary edit
  and call it out explicitly when reporting.
- `scripts/install.ps1` and `scripts/install.sh` must never install packages,
  delete unrelated files, or overwrite an existing target `CLAUDE.md` without
  a timestamped backup and explicit confirmation.
- Follow the daily operating loop in `chapters/01-daily-operating-loop.md` for
  all non-trivial work in this repository.
