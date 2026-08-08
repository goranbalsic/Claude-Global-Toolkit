---
description: "Perform an adversarial current-diff review using the isolated code-reviewer agent."
allowed-tools: Bash, Read, Grep, Glob, Task
argument-hint: "[scope or acceptance criteria]"
---

Adversarially review the current diff: `$ARGUMENTS`.

!`git status --short 2>/dev/null | sed -n '1,80p'`
!`git diff --stat 2>/dev/null`
!`git diff --cached --stat 2>/dev/null`

1. Delegate the diff analysis to the `code-reviewer` subagent. Its isolated
   context is intentional: reconnaissance and adversarial reasoning should
   return a digest without consuming the main task context.
2. Give the agent the task scope, acceptance criteria if known, and both
   staged and unstaged diff scope. Ask it to inspect changed call paths and
   relevant tests, not to modify files.
3. Independently check that the agent reviewed the current Git state, then
   assess its findings against repository evidence. Do not accept a finding
   merely because it sounds plausible.
4. Report findings ranked Critical, High, Medium, Low. Every finding needs a
   file:line reference, concrete failure scenario, and recommended fix or
   `none`.
5. Explicitly report: correctness, error handling, security/privacy,
   regression coverage, scope drift, and unsupported claims. If no issue
   survives evidence review, say `No confirmed findings` and list what was
   inspected.
6. Do not edit, commit, push, tag, publish, or mark work shipped in this
   command.
