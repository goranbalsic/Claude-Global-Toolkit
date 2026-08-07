---
chapter: 03
title: "Phase 0: investigation, decision register, source register, batching"
source: SRC-001, p.5
confidence: Confirmed
---

# 03 — Phase 0: investigation, decision register, source register, batching

## Problem

Jumping straight to implementation without first establishing ground truth
about the repository, environment, and available sources leads to work built
on wrong assumptions.

## Phase 0 investigation steps (source text)

- Inspect directory, files, repository instructions, and all applicable
  `CLAUDE.md` files.
- Inspect Git status, branch, and diffs if available.
- Identify OS, shell, runtime, Python, package managers, and available tools
  without installing.
- Locate and read supplied source documents; stop dependent work if required
  sources are inaccessible.
- Detect export, test, lint, link-checking, and validation tools.
- Detect empty, partial, corrupt, sensitive, generated, and ignored files.

## Decision register

Before any major component: identify options, explain trade-offs, select an
approach, record rejected alternatives, confidence, reversibility, and
approval. Store significant choices in `DECISIONS.md`.

## Source register

Record identifier, title, type, location, date, authority, claims,
recommendations, limitations, outdated risks, status, and traceable page or
URL. Separate official documentation, engineering principles, community
advice, experiments, repository practice, and inference.

## Batching

- Initialization and governance.
- Investigation and source evaluation.
- Bounded feature or chapter batches.
- Prompts, templates, and checklists.
- Reviews and final audit.
- Export preparation.

After each batch, review changed files and cross-references, remove
duplication, check links and filenames, update `PROJECT_STATUS.md`, and
write `summaries/BATCH-<n>.md`.

## Rationale

Investigation before commitment catches wrong assumptions cheaply. The
decision and source registers exist so that later sessions (or other people)
can audit *why* a choice was made without re-deriving it — this is what makes
work resumable across sessions that don't share memory. Batching keeps each
unit of work small enough to review and checkpoint, rather than one
unreviewable mega-change.

## When to apply

Phase 0 investigation: at the start of any work in an unfamiliar or
long-idle repository. Decision/source registers: whenever a non-trivial
choice or new source is introduced. Batching: any multi-step build, this
toolkit's own construction included (see `HOW_TO_BUILD.md`).

## When not to apply literally

A single trivial edit in a repository already fully investigated this
session doesn't need Phase 0 repeated — but "already investigated this
session" must be true, not assumed.

## Risks if ignored

Building on an inaccessible or misread source and not noticing; undocumented
decisions that get silently re-litigated or contradicted later; unreviewable
giant batches that hide regressions.

## Evidence and confidence

Confirmed — quoted from SRC-001 (p.5).

## Verification

Use `templates/investigation.md` for investigation notes,
`templates/decision.md` for each `DECISIONS.md` entry, and
`checklists/investigation.md` before moving from investigation to
implementation.
