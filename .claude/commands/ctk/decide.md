---
description: "Append a compact, reversible decision record without loading decision history."
allowed-tools: Bash, Read, Edit, Write
argument-hint: "<title> | <context> | <options> | <choice> | <reversibility> | <confidence>"
---

Record this decision: `$ARGUMENTS`.

!`date -u +%Y-%m-%d`
!`git status --short 2>/dev/null | sed -n '1,20p'`

1. Do not read `DECISIONS.md` as a mandatory startup step and do not copy
   historical decisions into context. Read a named, directly relevant entry
   only when resolving a conflict.
2. Create `DECISIONS.md` with `# Decisions` if it is absent. Append one new
   entry with a timestamp-based ID, not a sequence number that requires
   scanning the file.
3. Keep the entry to six lines or fewer and 600 characters or fewer:

   ```markdown
   ## D-YYYYMMDD-HHMMSS: short title
   - Context: factual trigger
   - Options: A; B
   - Choice: selected option and why
   - Reversibility: undo path/cost
   - Confidence: Confirmed|High|Medium|Low|Unknown
   ```

4. Use only decisions supported by repository evidence or explicit user
   direction. If an input field is unknown, write `Unknown`; do not invent it.
5. Confirm the exact entry appended and whether it is reversible. Do not
   rewrite, reformat, or summarize existing decision history.
