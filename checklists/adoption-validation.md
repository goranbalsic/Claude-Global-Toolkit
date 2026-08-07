# Adoption validation checklist

Purpose: prove this toolkit works end-to-end in a real adopting repository
on a real task, not just internally-consistent within this repository. Added
by UPDATE-02 (`PROMPTS.md` PROMPT-003) to close the gap flagged in
`reviews/PRINCIPAL_ENGINEER_REVIEW.md` and carried in `PROJECT_STATUS.md`'s
risks. Requires explicit approval before running against any specific
target repository — see `PROJECT_CONSTITUTION.md`'s approval matrix.

## 1. Target-repository preflight

- [ ] Baseline present: target's `CLAUDE.md` exists and traces to
      `GLOBAL_CLAUDE.md` (diff, or a documented repository-specific
      addition layered on top of an intact universal section — see
      `HOW_TO_USE.md`'s drift-check recipe).
- [ ] Which optional layers are adopted noted explicitly (memory-system
      bundle from `HOW_TO_USE.md` §3? full governance structure? neither?).
- [ ] The target's own `CLAUDE.md`/read-order files (if any) are readable
      and internally consistent — no two competing session-start orders.
- [ ] Nothing about the target repository requires an approval-matrix
      action just to observe it (read-only preflight only).

## 2. Choose the test vehicle

- [ ] One bounded, real engineering task selected — small enough to finish
      in a session, real enough to exercise
      `chapters/01-daily-operating-loop.md`'s daily operating loop.
- [ ] The task naturally produces at least one decision worth recording
      (not manufactured just to exercise `DECISIONS.md`).
- [ ] The task includes at least one genuine verification step (test, type
      check, lint, build, or manual check proportionate to the change).
- [ ] Task chosen or confirmed with the user — not assumed unilaterally.

## 3. Observable pass/fail signals

Record each as pass/fail/partial with the actual evidence, not an assumed
outcome:

- [ ] The session followed the target's own read order at start.
- [ ] Existing decisions were reused, not silently re-decided
      (`GLOBAL_CLAUDE.md` rule 2).
- [ ] No silent scope expansion beyond the chosen task
      (`chapters/01-daily-operating-loop.md`).
- [ ] A usable `DECISIONS.md` entry (or target-repository equivalent) was
      recorded for the in-task decision.
- [ ] Verification was proportionate and its result reported honestly
      (pass/fail/skipped), not asserted.
- [ ] The session left a credible resume point a future session could act
      on cold.

## 4. Post-task evaluation

- [ ] Clarity: which instructions were followed easily vs. needed
      re-reading or guessing?
- [ ] Friction: where did the toolkit's process add overhead
      disproportionate to the task's size?
- [ ] Missing guidance: what did the target repository need that no
      chapter/prompt/checklist covered?
- [ ] Harmful or duplicative behavior: did following the toolkit produce
      worse output than not following it would have?

## 5. Feed findings back

- [ ] Substantial finding → new `SOURCE_REGISTER.md` entry (a real-world
      finding is itself evidence, tier per
      `chapters/02-evidence-and-uncertainty.md`).
- [ ] Any decision made while resolving a finding → `DECISIONS.md` here.
- [ ] Any chapter contradicted by real use → chapter fix, with the
      contradiction and fix both recorded in `DECISIONS.md`.
- [ ] Only anonymized findings (no target-repository proprietary content)
      are recorded in this repository.
