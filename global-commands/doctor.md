---
description: "Diagnose CTK in the current project: block integrity, drift, budget, staged assets, backups (read-only, global entry point)."
allowed-tools: Bash
---

Diagnose CTK in the current project.

!`sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" doctor --target "$CLAUDE_PROJECT_DIR" 2>&1`

1. This is a global command. It never loads CTK's core instructions, skills,
   state, or other project files just because it ran; it only resolves the
   registered CTK root and routes to the real `ctk` CLI.
2. This command is read-only: it never writes anything and never needs
   approval.
3. If the output above is a registration/root resolution error (not
   bootstrapped, registered checkout missing, etc.), report it verbatim
   instead of attempting a diagnosis.
4. Otherwise, report the PASS/WARN/FAIL lines compactly. If any FAIL lines
   are present, name the one next command that addresses it (`ctk update`
   for drift or a missing staged asset, `ctk bootstrap` for a moved
   checkout) rather than editing anything yourself.
