---
description: "Detect the current project and install CTK into it, after approval (global entry point)."
allowed-tools: Bash
argument-hint: "[profile: minimal|standard|full]"
---

Install CTK into the current project: `$ARGUMENTS`.

!`sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" status --target "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>&1 || true`
!`sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" detect-profile --target "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>&1 || true`

1. This is a global command. It never loads CTK's core instructions, skills,
   state, or other project files just because it ran; it only resolves the
   registered CTK root above and routes to the real `ctk` CLI.
2. If either line above is an error (not bootstrapped, registered checkout
   missing, etc.), report it verbatim and stop. Do not try to locate
   `bin/ctk` yourself or guess a path.
3. Determine the profile: if the argument above names `minimal`, `standard`,
   or `full`, use that. Otherwise use the profile the detection line
   reported.
4. State in one or two sentences what will happen: the chosen profile, the
   target directory (the current project), and that this adds a managed
   block to `CLAUDE.md` and stages CTK-managed files under `.claude/` and
   `hooks/`. Ask the user to approve before proceeding.
5. Only after explicit approval, run exactly (substituting the chosen
   profile):

   ```sh
   sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" install --profile <profile> --target "${CLAUDE_PROJECT_DIR:-$(pwd)}" --yes
   ```

6. Report the command's own CHANGED/SKIP output compactly. Never claim CTK
   was installed if the command did not report `CHANGED:` or an
   already-installed `SKIP:`.
7. If new slash commands were staged into this project, tell the user they
   become visible after the next Claude Code restart, same as for any
   project-local command.
