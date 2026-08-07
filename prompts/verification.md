---
title: Verification
use_when: After implementation, before reporting a change as done
related: chapters/01-daily-operating-loop.md (step 7, Verify), templates/verification.md
---

# Prompt: Verification

```
Verify the change to <task> before reporting completion:

1. Run the proportionate checks available in this repository: tests, type
   checks, lint, link checks, security scan, build — whichever apply.
2. For each check, report pass/fail/skipped/unavailable explicitly. Do not
   omit a check just because it failed or wasn't run.
3. For UI/frontend changes, actually exercise the feature (start the app,
   interact with it) rather than relying on type-checks/tests alone to claim
   the feature works — say explicitly if this wasn't possible.
4. If anything failed or was skipped, state the impact and whether it blocks
   calling the task done.
5. Record the verification result using templates/verification.md if this is
   a tracked deliverable.
```
