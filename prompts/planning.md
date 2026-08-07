---
title: Planning
use_when: After requirements are clear, before touching any files
related: chapters/01-daily-operating-loop.md (step 5, Plan), templates/plan.md
---

# Prompt: Planning

```
Produce a bounded, file-level plan for <task>:

1. List the exact files to be created or changed, and why each is needed.
2. State dependencies/ordering between steps.
3. State the verification command(s) for each step (test, lint, type-check,
   build, manual check) and what "passed" looks like.
4. State the rollback path if a step needs to be undone.
5. State the checkpoint(s) — natural points to pause, report, and confirm
   before continuing, especially before anything in the approval matrix
   (PROJECT_CONSTITUTION.md) that needs explicit sign-off.
6. Flag any step that would create a major new component not explicitly
   requested — get approval for that step specifically before including it
   in the plan as something to execute.

Do not begin implementation until the plan has been stated (and, for
higher-risk work, confirmed).
```
