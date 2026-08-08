---
description: "Add one bounded, dated session checkpoint through ctk state (global entry point)."
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
   argument and the current project as the target. This is a global command,
   so it resolves the registered CTK root at runtime instead of assuming any
   project-local CTK files exist:

   ```sh
   sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" state add "<dated one-line summary>" --target "${CLAUDE_PROJECT_DIR:-$(pwd)}" --yes
   ```

   If this fails because CTK is not bootstrapped, or CTK is not installed in
   this project, report the exact error; do not fall back to writing
   `.claude/ctk/STATE.md` directly.
3. Do not write `.claude/ctk/STATE.md` directly. `ctk state add` owns its
   size limit and rotation.
4. Report the command result honestly. If the CLI is unavailable, report the
   checkpoint as unavailable and give the exact reason; do not claim it was
   persisted.
