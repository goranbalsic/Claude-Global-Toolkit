---
description: "Propose one reviewable, evidence-based improvement to a project-local skill, checklist, or routing rule; apply only after explicit approval (global entry point)."
allowed-tools: Bash, Read, Grep, Glob, Edit
argument-hint: "[skill, checklist, or routing rule to improve]"
---

Propose a refinement for: `$ARGUMENTS`.

!`git status --short 2>/dev/null | sed -n '1,40p'`

1. Identify exactly one concrete, evidence-based improvement to a single
   project-local skill (`.claude/skills/**/SKILL.md`), module skill
   (`modules/*/skills/**/SKILL.md`), checklist, or deterministic routing
   rule. The evidence must be something observed in this session — a
   failure, a repeated correction, a gap the current task just exposed —
   never a hypothetical.
2. Refuse the target and stop if it is `core/CLAUDE.core.md`, any file
   inside a `<!-- ctk:begin ... ctk:end -->` managed block, or any file
   outside this repository. Refining always-loaded core content is out of
   scope for this command.
3. Before editing, show: the exact file, the exact diff (old text vs. new
   text), the concrete evidence/reason, the expected benefit, the
   token-cost impact (does this grow a file others load on demand, and by
   how much), and the rollback command (`git checkout -- <file>` for a
   tracked file, `git clean -n -- <file>` if the file is new).
4. Do not call Edit until the user explicitly approves this specific
   proposal. If the user asks for changes, revise and show the diff again
   before touching the file.
5. Reject a proposal that only makes the file larger without a measurable,
   stated benefit. Prefer tightening or correcting existing text over
   adding new sections.
6. After an approved edit, record one line through the existing bounded
   history mechanism instead of creating a new log file. This is a global
   command, so it resolves the registered CTK root at runtime and targets
   the current project explicitly instead of assuming any project-local CTK
   files exist:

   ```sh
   sh "${CTK_HOME:-$HOME}/.claude/ctk/global-router.sh" state add "refine: <file> - <one-line summary>" --target "${CLAUDE_PROJECT_DIR:-$(pwd)}" --yes
   ```

   If this fails because CTK is not bootstrapped, or CTK is not installed in
   this project, report the exact error; the edit itself is still applied.
7. Report exactly what changed, the rollback command, and confirm that no
   always-loaded file (`core/CLAUDE.core.md`, `hooks/session-start.sh`) was
   touched.
