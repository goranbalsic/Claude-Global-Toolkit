# PRINCIPAL_ENGINEER_REVIEW.md

Judgment-level review accompanying `reviews/FINAL_AUDIT.md`, per
`chapters/06-handbook-templates-and-exports.md`. The audit checks mechanical
correctness (links, emptiness, duplication); this review asks whether the
toolkit is actually good and safe to hand to another repository.

## What this toolkit gets right

- **Authority hierarchy is unambiguous and consistently applied.** Every
  chapter, prompt, and checklist defers to `PROJECT_CONSTITUTION.md` and the
  active repo's `CLAUDE.md` rather than asserting itself as the final word.
  Spot-checked across all 8 chapters — none contradicts the order stated in
  `PROJECT_CONSTITUTION.md`.
- **The install scripts are genuinely conservative.** Read both in full
  (`scripts/install.ps1`, `scripts/install.sh`): no-op on identical content,
  mandatory timestamped backup before any overwrite, explicit confirmation
  gate (skippable only via an explicit `-Yes`/`--yes` flag, itself still a
  deliberate choice by the caller, not a default), no package installation,
  no writes outside `$TargetRepo`/`$TARGET_REPO`. This matches what
  `chapters/04-reusable-project-structure.md` promises, which matters more
  than most other claims in this repository since it's the one component
  that writes to *other* repositories.
- **The evidence/confidence discipline is applied to itself, not just
  preached.** `SOURCE_REGISTER.md` labels its own source's outdated risk as
  "Medium," and this review's own predecessor documents (`PROJECT_STATUS.md`,
  `ROADMAP.md`) were caught practicing exactly the failure mode
  `chapters/02-evidence-and-uncertainty.md` warns against — two true
  statements that quietly contradicted each other. That the contradiction
  was catchable at all is because both files were specific enough to compare
  (see Finding 3 in `reviews/FINAL_AUDIT.md`).

## Where judgment calls were made this pass

- **Not re-running the installer against `salary-currency-pro`.** The
  install script is a documented no-op when the target is already
  byte-identical to the source — running it again would produce "no change
  needed" and no new evidence beyond what `diff` already showed. Re-running
  it anyway would have been process theater, not verification. Recorded as
  `DECISIONS.md` D-004, including the honest gap: *how* that file got there
  is Unknown confidence (this toolkit's script, a prior session's manual
  copy, or something else) — only *that* it's there, byte-identical, is
  Confirmed. A reviewer relying on this section should not read D-004 as
  proof the installer itself was exercised against a real repo — it wasn't,
  in this session; only its *output state* was found and confirmed.
- **Scope discipline.** This batch stayed inside `C:\Claude-Global-Toolkit`
  except for the read-only `diff` against `C:\salary-currency-pro\CLAUDE.md`
  needed to resolve Finding 3. No file outside this repository was written.
  This matches `chapters/00-mission-and-authority.md`'s "do not modify files
  outside the active repository without approval" — reading for evidence and
  writing are different things, and only reading occurred outside this repo.

## Residual risks not fully closed by this batch

- **Exports are Markdown-only.** PDF/DOCX generation remains blocked on
  tool availability/approval (`ROADMAP.md`) — this is a correctly-labeled
  open item, not a gap in this review, but a future session should not
  assume PDF/DOCX exists just because Markdown export now does.
- **Version compatibility is a point-in-time fact.** `2.1.224` was confirmed
  today; nothing in this toolkit auto-detects a future Claude Code upgrade.
  A future session that skips `chapters/07-compatibility-and-persistence.md`
  could act on a stale version claim without realizing it's stale — the
  chapter says to re-verify, but nothing enforces that beyond the reader
  actually doing it.
- **This toolkit has never been dropped into a repository and then actually
  *used* end-to-end for a real engineering task.** `salary-currency-pro` has
  the file; there's no evidence yet (Confirmed or otherwise) that a session
  there has actually followed the daily operating loop, hit an approval-
  matrix case, or found a chapter that doesn't hold up under real use. That
  remains the toolkit's biggest untested assumption, and no amount of
  internal link-checking substitutes for it.

## Verdict

No fabricated claims found in the reviewed content, and the three defects
found this pass were real but low-blast-radius documentation
inconsistencies, not structural or safety problems. The toolkit is
internally consistent and its riskiest component (the install scripts) is
conservatively built and was actually exercised, not just described. The
open item worth flagging most strongly to a future reader is the last one
above: this has been audited for internal consistency, not yet validated by
real-world use.
