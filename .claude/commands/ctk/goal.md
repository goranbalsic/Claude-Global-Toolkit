---
description: "Create, inspect, or transition the single bounded active goal through ctk goal."
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
   apply (each value single-quoted, one line, no secrets):

   ```sh
   if [ -x "$CLAUDE_PROJECT_DIR/bin/ctk" ]; then
     "$CLAUDE_PROJECT_DIR/bin/ctk" goal <verb> [--objective '...'] [--acceptance '...'] [--phase '...'] [--next '...'] [--evidence '...'] --yes
   else
     printf '%s\n' "ctk goal unavailable: $CLAUDE_PROJECT_DIR/bin/ctk is missing or not executable" >&2
   fi
   ```

5. Do not write `.claude/ctk/GOAL.md` directly. `ctk goal` owns its size cap
   and format, and never continues work on its own after this command exits.
6. Report the command result honestly, including a rejection for an
   oversized goal or a missing required flag. Never claim a goal was set,
   paused, or completed if the command did not report `CHANGED:`.
