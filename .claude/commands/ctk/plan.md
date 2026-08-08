---
description: "Produce a bounded file-level plan with verification and rollback."
allowed-tools: Bash, Read, Grep, Glob
argument-hint: "<task>"
---

Plan this task without editing files: `$ARGUMENTS`.

!`printf 'branch: '; git branch --show-current 2>/dev/null || true`
!`git status --short 2>/dev/null | sed -n '1,60p'`
!`find . -maxdepth 2 -type f \( -name 'pubspec.yaml' -o -name 'package.json' -o -name 'pyproject.toml' -o -name 'go.mod' -o -name 'Cargo.toml' -o -name 'Makefile' \) -print 2>/dev/null | sed -n '1,30p'`

1. Restate the objective, acceptance criteria, constraints, assumptions, and
   explicit out-of-scope work. Mark unverified assumptions Medium, Low, or
   Unknown.
2. Inspect only the code, configuration, tests, and local instructions needed
   to identify exact affected paths. Never use guessed paths in the plan.
3. Return a bounded plan with this table:

   | Step | Files (create/change) | Change | Verify | Rollback |
   |---|---|---|---|---|

4. Each step must name a real command or concrete manual check and a rollback
   that restores only the step's files. Order dependent steps explicitly.
5. Identify a checkpoint after each independently verifiable batch and flag
   any approval-required, destructive, external, or security-sensitive action.
6. Reject unrelated refactors, new dependencies, and new major components
   unless they are required by the task. End with the first safe action, but
   do not implement it in this command.
