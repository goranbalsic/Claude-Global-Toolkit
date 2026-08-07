# UPDATE-02 — Claude Global Toolkit (grounded in the actual repository state)

Paste everything inside the code block into Claude Code **from inside `C:\Claude-Global-Toolkit`**.

```text
# UPDATE-02 — Claude Global Toolkit: from internally consistent to real-world proven

You are working in C:\Claude-Global-Toolkit, the source-of-truth home of the Claude Global Toolkit, currently at version 2.1.0 (last reviewed 2026-08-07, batch 4 complete).

This prompt is a new supplied instruction set. Per this repository's own rules, before doing anything else:

1. Follow the canonical session-start order in CLAUDE.md's "Start or resume" section exactly (CLAUDE.md → PROJECT_CONTEXT.md / PROJECT_RULES.md → PROJECT_CONSTITUTION.md / DECISIONS.md → PROMPTS.md → PROJECT_STATUS.md / ROADMAP.md → latest session_logs/ entry → latest summaries/ entry → inspect actual repository state → health check if stale → resume point).
2. Register this prompt as SRC-003 in SOURCE_REGISTER.md and as PROMPT-003 (Status: Active) in PROMPTS.md, with a concise summary, per PROJECT_RULES.md's prompt-management section. Its authority: the instruction to act is tier 2 (explicit user instruction); its prescribed content is tier 5 reference material, to be reconciled against existing governance — the same treatment SRC-002 received (DECISIONS.md D-005).
3. Where this prompt conflicts with existing repository facts, apply PROJECT_RULES.md's contradiction-handling algorithm and record the resolution in DECISIONS.md. Do not silently pick a side.

## Known repository state you are inheriting (verify, don't assume)

- GLOBAL_CLAUDE.md holds exactly ten universal rules and is the only file copied into adopting repositories (D-002). Any change to it is high blast-radius (CLAUDE.md, HOW_TO_BUILD.md).
- Both install scripts passed all four scenarios against disposable repos (D-003). C:\salary-currency-pro\CLAUDE.md is byte-identical to GLOBAL_CLAUDE.md — resulting state Confirmed, mechanism Unknown (D-004).
- SRC-002's memory system is implemented and reconciled, not duplicated (D-005, D-006), and generalized into an opt-in six-template bundle in HOW_TO_USE.md §3 (D-007, IDEA-001 Implemented).
- Claude Code CLI 2.1.224 verified compatible on Windows 11 on 2026-08-07 — a point-in-time fact. Re-run claude --version this session; if it changed, update chapters/07-compatibility-and-persistence.md before relying on the "verified" section.
- Cross-reference health: 64 files, 805 .md references, all resolving as of batch 4. Re-verify, don't restate.
- Markdown handbook export exists (exports/claude-global-toolkit-handbook-2026-08-07.md). PDF/DOCX export is honestly marked blocked on tooling availability/approval — the only committed-and-open ROADMAP.md item.
- OPEN_QUESTIONS.md: QUESTION-001 (what memory/ should contain, default (c)) and QUESTION-002 (PROMPTS.md vs prompts/ cross-linking) are open.
- The repository was NOT under Git version control as of PROJECT_CONTEXT.md's last update — "reversible" currently means file-level backups only.
- The single largest known gap, flagged in PROJECT_STATUS.md, PROJECT_CONTEXT.md, and reviews/PRINCIPAL_ENGINEER_REVIEW.md: the toolkit has never been used end-to-end on a real engineering task in an adopting repository. UPDATE-02 exists primarily to close or materially shrink this gap.

## Non-negotiables (unchanged from existing governance)

- Do not edit sources/ (including the UTF-16 update.txt — leave encoding as supplied).
- GLOBAL_CLAUDE.md stays limited to the ten universal rules; repository-specific material belongs in chapters/checklists/prompts.
- The memory/decision bundle stays opt-in; never fold it into GLOBAL_CLAUDE.md or force it via the install scripts (D-007's rejected options stay rejected).
- Never claim any command, test, install, audit, or export ran unless you actually ran it and captured the result. Use the confidence labels (Confirmed/High/Medium/Low/Unknown) and work-status vocabulary (Proposed … Superseded) already adopted in PROJECT_RULES.md.
- Per the approval matrix in PROJECT_CONSTITUTION.md: touching any repository other than this one (including C:\salary-currency-pro), installing packages (including Pandoc), altering global config, publishing, or pushing all require explicit fresh approval in this session. Do not treat past approvals as standing permission.
- Implement directly; do not stop to ask about ordinary decisions. Ask only for approval-matrix cases or genuinely missing information.

## Phase 0 — Session start, re-verification, and UPDATE-02 plan

- Complete the session-start order and the repository health check (chapters/05-repository-health-check.md).
- Re-verify the "known state" claims above against the actual repository. Record any discrepancy honestly.
- Decide and record (DECISIONS.md): should this repository be brought under Git version control now? It is a local, reversible, in-repo action (no approval needed per the matrix) that would upgrade "reversible" from file-backups to commit-level rollback and make every later UPDATE-02 change auditable. Weigh it with the decision-quality table in PROJECT_RULES.md. If adopted: git init, a sensible .gitignore, and an initial commit capturing the current 2.1.0 state BEFORE any UPDATE-02 edits — but do not create a remote, push, or publish.
- Write a bounded UPDATE-02 plan into ROADMAP.md (committed items) with priorities:
  - P0 — false claims, broken references, safety issues found in re-verification.
  - P1 — the real-world validation gap (Phase 1).
  - P2 — adoption lifecycle completeness (Phase 2) and open-question closure (Phase 3).
  - P3 — reproducible health tooling, release discipline, exports (Phases 4–5).
- Then begin implementing immediately. Do not wait for another instruction.

## Phase 1 — Close the real-world validation gap (the point of UPDATE-02)

Create a reusable adoption-validation protocol as a new checklist plus, if genuinely needed, one new prompt — checked first against the existing 12 prompts and 9 checklists for near-duplicates per HOW_TO_BUILD.md. It must define:

- A target-repository preflight (baseline present? which optional layers adopted? local CLAUDE.md read order sane?).
- One bounded, real engineering task as the test vehicle — small enough to finish in a session, real enough to exercise the daily operating loop (chapters/01), at least one decision worth recording, and one verification step.
- Observable pass/fail signals: did the session follow the read order, reuse existing decisions, avoid silent scope expansion, record a usable DECISIONS.md entry, run proportionate checks, and leave a credible resume point?
- A short post-task evaluation form (clarity, friction, missing guidance, harmful or duplicative behavior) and a defined path for feeding anonymized findings back into this toolkit (new SRC entry if substantial, DECISIONS.md entry, chapter fix).

Then ask ONE precise approval question: whether you may run this protocol now against C:\salary-currency-pro using a bounded task of the user's choosing (or one you propose). If approved, execute it there following that repository's own CLAUDE.md, record only anonymized findings here, and update chapters where real use contradicts written guidance. If not approved, leave the protocol ready-to-run, record the status honestly, and continue with the later phases.

## Phase 2 — Complete the adoption lifecycle (install exists; verify/update/recover barely do)

HOW_TO_USE.md documents install well. Extend the lifecycle without turning the scripts into a package manager:

- Drift check: a documented, tested way to see whether a target CLAUDE.md still matches the current GLOBAL_CLAUDE.md (a one-line diff/fc recipe per platform is acceptable; a small read-only script is acceptable only if tested against disposable fixtures like D-003).
- Update path: confirm the existing scripts' backup-then-overwrite branch is the documented update mechanism and say so explicitly in HOW_TO_USE.md.
- Recovery path: documented restore-from-timestamped-backup instructions.
- Removal: documented manual removal only, never automated.
- Evaluate (decision-quality table, record the outcome either way) whether GLOBAL_CLAUDE.md's frontmatter version should be the drift-detection anchor, and whether install output should state the installed version.

Test any changed script behavior against disposable directories only, all four D-003 scenarios, both PowerShell and POSIX.

## Phase 3 — Close the open questions instead of carrying them

- QUESTION-001 (memory/ contents): adopt recommended default (c) as the standing answer unless evidence from Phase 1 suggests otherwise. Record in DECISIONS.md, update memory/README.md and OPEN_QUESTIONS.md (status: resolved with default).
- QUESTION-002 (PROMPTS.md vs prompts/): implement the cheap fix — a prompts/README.md one-liner and a matching pointer atop PROMPTS.md — and close it.
- Sweep IDEAS.md and OPEN_QUESTIONS.md for anything newly relevant; park new ideas there rather than building them (no silent scope expansion).

## Phase 4 — Reproducible health check and release discipline

- The health check in chapters/05 currently depends on a session doing it well. Add a small, dependency-free local script (PowerShell first, POSIX if practical) that mechanically checks: internal .md cross-references resolve, no empty planned deliverables, required root files present, README.md's structure table matches the actual tree, frontmatter version/date consistency across the four versioned files. Read-only by default, clear pass/fail/skip output, tested on fixtures, documented in chapters/05. If a check can't be made reliable, keep it documented as manual — do not fake automation.
- Define the versioning policy explicitly (in HOW_TO_BUILD.md or PROJECT_CONSTITUTION.md, whichever inspection shows is the right home): patch = fixes/clarifications; minor = new assets or lifecycle capability; major = changes to GLOBAL_CLAUDE.md's ten rules or installer contract. UPDATE-02's work, once verified, is a minor bump to 2.2.0 — apply it only at the end, with CHANGELOG.md moving the accumulated "Unreleased" batches into the release.

## Phase 5 — Exports without false claims

- Regenerate the Markdown handbook export so it reflects UPDATE-02's final content, using the reproducible command documented in exports/README.md; verify non-empty and inventory-complete; date it.
- Check whether a converter (e.g. Pandoc) is ALREADY installed. If yes, generate PDF/DOCX, validate output opens and is non-empty, document the procedure, and close the ROADMAP item. If no, ask once whether installation is approved; if declined or unanswered, leave the item honestly blocked exactly as it is now.

## Phase 6 — Final audit and release

Produce reviews/UPDATE-02-FINAL-AUDIT.md: every phase's checks with passed/failed/skipped/blocked and actual evidence; cross-reference re-count; confirmation GLOBAL_CLAUDE.md is unchanged OR a full blast-radius report if it changed; validation-protocol status; export status. Then:

- summaries/BATCH-05-update-02.md (existing naming convention),
- a dated session_logs/ entry,
- PROJECT_STATUS.md rewritten to the new state with an exact resume point,
- PROJECT_CONTEXT.md, ROADMAP.md, CHANGELOG.md, DECISIONS.md, PROMPTS.md, IDEAS.md, OPEN_QUESTIONS.md updated only where something actually changed — each file keeps its narrow purpose, no duplicated facts,
- version bump to 2.2.0 per Phase 4's policy, only if the definition of done in PROJECT_CONSTITUTION.md is genuinely met.

## End-of-batch report (after every meaningful batch, not only at the end)

Objective and phase · Inspected · Implemented · Decisions (with the Options/Benefits/Costs/Risks/Reversibility/Fit table for non-trivial ones) · Verification (check / status / actual evidence) · Files changed · Deferred or blocked · Exact next action.

Start now with Phase 0.
```
