---
chapter: 06
title: Handbook, templates, exports, final audit, and definition of done
source: SRC-001, p.8
confidence: Confirmed
---

# 06 — Handbook, templates, exports, and final audit

## Problem

An unstructured pile of advice is hard to trust or navigate; unverifiable
"exports exist" claims are worse than no export at all.

## Handbook, prompts, templates, checklists (source text)

Create focused chapters with one primary responsibility. Every recommendation
should explain problem, rationale, use and non-use conditions, risks,
evidence, confidence, and verification. Label assumptions, experiments,
uncertainty, and version-sensitive claims.

Create reusable prompts for: new session, resume, investigation,
requirements, planning, implementation, bug fixing, refactoring, security,
verification, adversarial review, and feature research.

Create templates for: specifications, investigations, plans, decisions,
verification, failures, and handoffs.

Create checklists for: startup, investigation, editing, completion, security,
performance, release, source evaluation, and chapter review.

*(Net new, not in SRC-001: `checklists/adoption-validation.md`, added by
UPDATE-02/SRC-003 — see `PROMPTS.md` PROMPT-003 — to close the real-world
validation gap this chapter's own "Risks if ignored" section didn't yet
have tooling for.)*

*(This chapter follows that structure — see the "problem / rationale / use
and non-use / risks / evidence / confidence / verification" headings used
throughout `chapters/`.)*

## Exports

Generate merged Markdown first. Create PDF/DOCX only when tools exist or
after approved installation. Verify each export is present, non-empty, opens
successfully, and contains readable expected content. Otherwise provide
reproducible build instructions and do not claim an export exists.

## Final audit and definition of done

- Check links, filenames, headings, references, duplication, contradictions,
  safety, privacy, security, approvals, rollback, outdated claims, and source
  mappings.
- Write `reviews/FINAL_AUDIT.md` and `reviews/PRINCIPAL_ENGINEER_REVIEW.md`.
- Do not declare completion until deliverables, reviews, source mappings,
  audits, script checks, exports/build instructions, and `PROJECT_STATUS.md`
  are complete.
- Run the repository health check and evaluate the measurable criteria before
  final reporting.

## Rationale

Requiring every recommendation to carry problem/rationale/risk/evidence/
confidence/verification is what makes the handbook resolvable in edge cases,
rather than a flat list of rules with no way to judge when they conflict.
The export rule ("do not claim an export exists" unless verified) is a
specific instance of the toolkit's core "never invent" principle applied to
build artifacts.

## When to apply

Any time new handbook content, a prompt, template, or checklist is added
(structure requirement); any time an export is requested (verification
requirement); at the end of a build pass (final audit requirement).

## When not to apply literally

Exports: if PDF/DOCX tooling genuinely isn't available and installing it
hasn't been approved, the correct output is reproducible build instructions,
not a refusal to produce anything and not a fabricated file.

## Risks if ignored

A handbook chapter with rules but no rationale becomes unmaintainable — no
one can tell if an edge case is an exception or a violation. Claiming an
export exists when it doesn't (or is empty/corrupt) is a fabrication that
this toolkit's own mission statement explicitly forbids.

## Evidence and confidence

Confirmed — quoted from SRC-001 (p.8).

## Verification

`reviews/` holds `reviews/FINAL_AUDIT.md` and
`reviews/PRINCIPAL_ENGINEER_REVIEW.md` once an actual audit has been run —
see `reviews/README.md` for current status. (As of this repository's
initial build, neither existed yet; a full audit was subsequently run
2026-08-07 and both now exist — see `reviews/README.md` for the current
state rather than relying on this chapter's own point-in-time wording.)
