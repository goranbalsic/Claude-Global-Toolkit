---
chapter: 05
title: Repository health check and measurable success criteria
source: SRC-001, p.7
confidence: Confirmed
---

# 05 — Repository health check and measurable success criteria

## Problem

Documentation and prompt libraries rot: links break, guidance duplicates or
contradicts itself, status goes stale. Without a periodic check, this rot is
invisible until it causes a bad decision.

## Repository health check (source text)

Before resuming, and periodically in long projects, evaluate health. The
check is diagnostic unless corrective changes are approved.

- Broken links and missing targets.
- Orphaned documents and stale summaries.
- Duplicate prompts, checklists, chapters, or guidance.
- Empty, partial, corrupt, or unexpectedly ignored files.
- Inconsistent naming, numbering, headings, or placement.
- Outdated references, version claims, commands, APIs, paths, or
  compatibility notes.
- Unrecorded major decisions, contradictions, stale status, and missing
  verification evidence.

Report severity, evidence, affected files, recommended action, and approval
status. Never silently delete, merge, rename, or rewrite material to improve
the result.

## Measurable success criteria (source text)

- No unresolved broken links in reviewed scope.
- Every substantive recommendation has a source mapping or explicit
  classification.
- No known duplicate guidance in reviewed scope.
- Every workflow includes a verification step.
- Every major decision traces to `DECISIONS.md`.
- No empty or corrupt planned deliverable remains.
- Version-sensitive claims include version/date or verification instruction.
- `PROJECT_STATUS.md` states completed work, risks, remaining work, and exact
  resume point.

Mark Not Applicable only with a reason. These criteria support judgment; they
do not replace it.

## Rationale

"Diagnostic unless corrective changes are approved" separates *finding*
problems from *fixing* them — a health check that auto-repairs what it finds
could destroy content the user actually wanted (e.g. a document intentionally
left in draft form). The measurable criteria give the diagnostic phase a
concrete, checkable target instead of a vague "does this look okay."

## When to apply

Before resuming work after any gap; periodically during long-running work;
always before declaring a build pass or final audit complete
(`chapters/06-handbook-templates-and-exports.md`).

## When not to apply literally

A single-file, single-session task doesn't need a full health check — but
the "no broken links, no fabricated claims" spirit still applies at that
scale.

## Risks if ignored

Stale `PROJECT_STATUS.md` causing a future session to redo completed work or
miss an open risk; duplicated guidance that silently drifts out of sync;
broken cross-references that erode trust in the whole toolkit.

## Evidence and confidence

Confirmed — quoted from SRC-001 (p.7).

## Verification

Use `checklists/completion.md` and `checklists/chapter-review.md`, and cross
-check every criterion above explicitly rather than asserting "looks fine."

## Reproducible mechanical check (net new, UPDATE-02 Phase 4)

`scripts/health-check.ps1` (PowerShell) and `scripts/health-check.sh`
(POSIX) automate the mechanically-checkable subset of the criteria above:
required root files present, `README.md`'s structure table matches the
actual top-level tree, frontmatter `version`/`last_reviewed` consistency
across `CLAUDE.md`/`GLOBAL_CLAUDE.md`/`PROJECT_CONSTITUTION.md`/
`README.md`, no empty/near-empty files in content directories, and
best-effort internal cross-reference resolution. Both are read-only,
never modify a file, and print a plain pass/fail/skip line per check plus
a summary; a non-zero exit code means at least one FAIL. Run either from
the repository root:

```powershell
.\scripts\health-check.ps1
```

```bash
./scripts/health-check.sh
```

This automates the mechanical portion only — broken links, missing
targets, empty files, version drift. It does **not** automate: duplicate
guidance detection, orphaned-document judgment, contradiction detection,
or unrecorded-decision detection, all of which still need the
judgment-level review this chapter describes (`reviews/PRINCIPAL_ENGINEER_REVIEW.md`-style). A clean script run is necessary, not sufficient, for
"health check passed." The cross-reference check in particular is a
best-effort regex scan with documented limitations (see the script's own
header comment) — treat a FAIL there as a lead to investigate, and a
clean run as "no obvious breakage found," not as a full Markdown-link
audit.
