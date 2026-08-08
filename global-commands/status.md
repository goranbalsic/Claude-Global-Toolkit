---
description: "Compact CTK installation/source/profile/state summary for the current project (read-only, global entry point)."
allowed-tools: Bash
---

Report CTK status for the current project.

!`awk -F '\t' '$1=="root"{print "registered root: " $2} $1=="version"{print "registered version: " $2}' "${CTK_HOME:-$HOME}/.claude/ctk/registration.txt" 2>/dev/null || printf '%s\n' "CTK: not bootstrapped (no registration.txt under ${CTK_HOME:-$HOME}/.claude/ctk/)"`
!`sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" status --target "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>&1`

1. This is a global command. It never loads CTK's core instructions, skills,
   state, or other project files just because it ran; it only resolves the
   registered CTK root and routes to the real `ctk` CLI.
2. This command is read-only: it never writes anything and never needs
   approval.
3. Report a compact summary combining both lines above: the registered CTK
   source (root and version), and the project's own target file, managed
   block state, installed profile, and staged file count. If registration
   is missing, say so and stop instead of guessing project state.
