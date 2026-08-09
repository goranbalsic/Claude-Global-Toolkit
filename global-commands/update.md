---
description: "Update the CTK-managed files in the current project, after approval (global entry point)."
allowed-tools: Bash
---

Update CTK in the current project.

!`sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" status --target "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>&1 || true`

1. This is a global command. It never loads CTK's core instructions, skills,
   state, or other project files just because it ran; it only resolves the
   registered CTK root above and routes to the real `ctk` CLI.
2. If the status line above is an error (not bootstrapped, registered
   checkout missing, etc.), report it verbatim and stop.
3. If the status shows no managed block present, tell the user to run
   `/ctk:install` instead and stop; `update` only refreshes an existing
   install.
4. State briefly what will happen: the managed `CLAUDE.md` block is
   refreshed and the installed profile's files are re-staged in the current
   project. A local edit to any managed file blocks the write for that file
   and is reported, never silently overwritten. Ask the user to approve
   before proceeding.
5. Only after explicit approval, run exactly:

   ```sh
   sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" update --target "${CLAUDE_PROJECT_DIR:-$(pwd)}" --yes
   ```

6. Report the command's own CHANGED/SKIP/KEPT output compactly. Never claim
   an update happened if the command did not report `CHANGED:`.
