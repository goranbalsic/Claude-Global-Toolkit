---
chapter: 01
title: Daily operating loop and no silent scope expansion
source: SRC-001, p.3
confidence: Confirmed
---

# 01 — Daily operating loop

## Problem

Without a repeatable loop, sessions either re-derive context that already
exists (wasteful, and risks contradicting prior decisions) or skip steps
(investigation, verification) that catch mistakes before they ship.

## The eight steps (source text)

1. **Start or resume.** Read `CLAUDE.md`, `PROJECT_CONSTITUTION.md` if
   present, `PROJECT_STATUS.md`, `DECISIONS.md`, `ROADMAP.md`, and the latest
   handoff. Inspect Git status and find the first incomplete deliverable.
2. **Investigate.** Inspect relevant files, configuration, tests, runtime,
   tools, and current behavior. Do not infer repository facts that can be
   inspected.
3. **Clarify.** State objective, constraints, acceptance criteria,
   assumptions, risks, and whether scope expands. Ask only blocking
   questions.
4. **Decide.** Identify options and trade-offs; record selected approach,
   rejected alternatives, confidence, and reversibility. Record major
   decisions.
5. **Plan.** Create a bounded file-level plan with dependencies, verification
   commands, rollback, and checkpoint.
6. **Implement.** Make minimal coherent changes using existing conventions.
   Do not create major components unless required, requested, or necessary.
7. **Verify.** Run proportionate syntax, tests, types, lint, links, security,
   build, or manual checks. Distinguish passed, failed, skipped, and
   unavailable.
8. **Review and report.** Check correctness, security, privacy, duplication,
   scope drift, unsupported claims, and failure scenarios; update status and
   report exact results.

## No silent scope expansion

Do not invent extra deliverables. Propose any non-required major component
with rationale, cost, risks, and approval status before creating it.

## Rationale

Steps 1–2 exist so decisions are made against current reality, not stale
memory. Step 3 bounds the work before it starts. Steps 4–5 make the approach
and its trade-offs explicit and auditable before code changes. Step 6 keeps
changes minimal and reversible. Steps 7–8 close the loop with honest,
checkable evidence rather than a claim of success.

"No silent scope expansion" exists because an agent that quietly does more
than asked erodes the user control the mission section commits to
preserving — even when the extra work is well-intentioned.

## When to apply

Any non-trivial task. For genuinely trivial single-step edits, the full
eight-step ceremony is disproportionate — but investigation and verification
(steps 2 and 7) still apply in miniature: look before you edit, check after
you edit.

## When not to apply literally

Emergency/blocking fixes explicitly requested by the user with urgency may
compress steps 3–5 into a single fast exchange — but step 7 (verify) and
step 8 (report honestly) are never skippable, per `chapters/00-mission-and-authority.md`.

## Risks if skipped

Skipping step 1 → contradicting a decision already recorded in
`DECISIONS.md`. Skipping step 2 → acting on stale or invented assumptions.
Skipping step 7 → reporting success that wasn't verified. Ignoring "no silent
scope expansion" → the user discovers unrequested changes after the fact,
which is the exact failure mode `PROJECT_CONSTITUTION.md`'s approval matrix
is designed to prevent.

## Evidence and confidence

Confirmed — quoted from SRC-001 (p.3).

## Verification

Use `prompts/resume.md` for step 1, `prompts/investigation.md` for step 2,
`templates/plan.md` for step 5, and `checklists/completion.md` for steps 7–8.
