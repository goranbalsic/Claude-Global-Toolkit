---
name: session-continuity
description: "Maintain a small, mechanically bounded resume point without loading growing project history."
---

# Session continuity

Use `.claude/ctk/STATE.md` as the only always-read continuity record. Keep it
under the configured 400-token budget through `bin/ctk state add`; never edit
or rotate it by hand.

At session start, inspect only the bounded state tail plus branch, status, and
recent commits. Reconcile those facts before acting. Do not make large files
such as `DECISIONS.md`, logs, or summaries mandatory reading.

Every meaningful batch ends with one checkpoint containing completed work,
verification outcome, and exact next action. If state conflicts with Git,
Git is current evidence and the discrepancy must be reported.
