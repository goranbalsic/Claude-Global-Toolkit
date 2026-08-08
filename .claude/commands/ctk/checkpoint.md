---
description: "Add one bounded, dated session checkpoint through ctk state."
allowed-tools: Bash
argument-hint: "<one-line completed work, verification, and next action>"
---

Create a checkpoint from: `$ARGUMENTS`.

!`date -u +%Y-%m-%dT%H:%M:%SZ`
!`git status --short 2>/dev/null | sed -n '1,40p'`

1. Reduce the checkpoint to one factual line: completed work; verification
   result; exact next action. Keep it under 240 characters and do not include
   secrets, raw command output, or a narrative.
2. Run this exact interface, passing the one-line summary as a single
   argument:

   ```sh
   if [ -x "$CLAUDE_PROJECT_DIR/bin/ctk" ]; then
     "$CLAUDE_PROJECT_DIR/bin/ctk" state add "<dated one-line summary>"
   else
     printf '%s\n' "ctk state unavailable: $CLAUDE_PROJECT_DIR/bin/ctk is missing or not executable" >&2
   fi
   ```

3. Do not write `.claude/ctk/STATE.md` directly. `ctk state add` owns its
   size limit and rotation.
4. Report the command result honestly. If the CLI is unavailable, report the
   checkpoint as unavailable and give the exact reason; do not claim it was
   persisted.
