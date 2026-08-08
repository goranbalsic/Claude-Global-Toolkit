---
description: "Create, inspect, or transition the single bounded active goal through ctk goal (global entry point)."
allowed-tools: Bash
argument-hint: "<set|show|pause|complete|cancel|clear> [details]"
---

Handle the goal request: `$ARGUMENTS`.

!`date -u +%Y-%m-%dT%H:%M:%SZ`

1. Determine the verb from the request: `set`, `show`, `pause`, `complete`,
   `cancel`, or `clear`.
2. For `set`: reduce the request to a one-line `--objective` and a one-line,
   verifiable `--acceptance`. Add `--phase` and `--next` only if the user
   stated them. Do not invent acceptance criteria the user did not give.
3. For `complete`: require a one-line `--evidence` naming the test/build
   result that proves it. If the user has not stated evidence, ask for it
   instead of inventing one — a goal is never complete merely because a
   budget or step limit was reached.
4. Run this exact interface, substituting the verb and only the flags that
   apply (each value single-quoted, one line, no secrets). This is a global
   command, so it resolves the registered CTK root at runtime and targets
   the current project explicitly instead of assuming any project-local CTK
   files exist:

   ```sh
   sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" goal <verb> [--objective '...'] [--acceptance '...'] [--phase '...'] [--next '...'] [--evidence '...'] --target "$CLAUDE_PROJECT_DIR" --yes
   ```

   If this fails because CTK is not bootstrapped, or CTK is not installed in
   this project, report the exact error.
5. Do not write `.claude/ctk/GOAL.md` directly. `ctk goal` owns its size cap
   and format, and never continues work on its own after this command exits.
6. Report the command result honestly, including a rejection for an
   oversized goal or a missing required flag. Never claim a goal was set,
   paused, or completed if the command did not report `CHANGED:`.
