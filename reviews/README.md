# reviews/

Holds `FINAL_AUDIT.md` and `PRINCIPAL_ENGINEER_REVIEW.md` once an actual
final audit has been run against this repository, per
`chapters/06-handbook-templates-and-exports.md`, plus any batch-specific
final audit (e.g. `UPDATE-02-FINAL-AUDIT.md`) for a large supplied update.

## Current status

A full final audit was run 2026-08-07 — see `FINAL_AUDIT.md` (mechanical
checks: links, empty files, duplication, source mappings, three findings and
fixes) and `PRINCIPAL_ENGINEER_REVIEW.md` (judgment-level review: what the
toolkit gets right, judgment calls made, residual risks). Both files exist,
are non-empty, and reflect only what was actually inspected this pass.

`UPDATE-02-FINAL-AUDIT.md` (2026-08-07) is a second, batch-scoped final
audit covering UPDATE-02 (SRC-003) and its mid-batch addition SRC-004:
phase-by-phase status, a mechanical health-check re-run (103 pass, 0
fail, 0 skip), export status, and the version-bump decision (2.2.0). It
supplements, not replaces, the two files above.

## When a future audit is run

Write a new `FINAL_AUDIT.md` and `PRINCIPAL_ENGINEER_REVIEW.md` here
(overwriting or dating the previous ones, per whatever convention the
session adopts), following the "Final audit and definition of done"
requirements in `chapters/06-handbook-templates-and-exports.md`, and update
this README's "Current status" section accordingly.
