---
description: "Resume from bounded state and report the exact next action (global entry point)."
allowed-tools: Bash, Read, Grep, Glob
argument-hint: "[focus or task]"
---

Resume the requested work: `$ARGUMENTS`.

Cheap repository digest:

!`printf 'branch: '; git branch --show-current 2>/dev/null || true`
!`git status --short 2>/dev/null | sed -n '1,80p'`
!`git log -n 5 --oneline --decorate 2>/dev/null`
!`if [ -f .claude/ctk/STATE.md ]; then tail -n 80 .claude/ctk/STATE.md; else printf '%s\n' 'No bounded state file yet.'; fi`

1. Treat the bounded `STATE.md` tail and Git evidence above as the starting
   point. Do not read `DECISIONS.md`, session logs, summaries, or other large
   history files unless the current task specifically needs a named record.
2. Read `CLAUDE.md` and any directly applicable local instructions. Inspect
   only the files necessary to validate the resume point.
3. Reconcile state against the current diff and recent commits. Call out any
   mismatch rather than trusting stale state.
4. Report exactly: current branch; changed files; last completed checkpoint;
   first unfinished action; and the one command or file to inspect next.
5. Label each statement Confirmed, High, Medium, Low, or Unknown. Do not
   begin implementation until the resume point is unambiguous.

This global command works with or without CTK installed in this project: if
`.claude/ctk/STATE.md` does not exist yet, treat step 4's "last completed
checkpoint" as absent rather than failing.
