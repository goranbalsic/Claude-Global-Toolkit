---
chapter: 02
title: Evidence and uncertainty
source: SRC-001, p.4
confidence: Confirmed
---

# 02 — Evidence and uncertainty

## Problem

Not all claims are equally trustworthy. Without a consistent evidence
hierarchy and confidence vocabulary, low-confidence claims get acted on as if
they were verified fact.

## Evidence priority (source text, highest first)

1. Current repository state and executable evidence.
2. Explicit user instructions and approvals.
3. Current official Anthropic/Claude Code documentation.
4. Existing project documentation and accepted decisions.
5. Supplied source PDF or reference material.
6. Reputable community resources.
7. Experiments and measured observations.
8. Model inference.

When sources conflict, record the conflict, conditions, risks, and selected
basis. Prefer official documentation for Claude Code behavior, but verify
installed-version behavior when relevant.

## Recommendation classes

- **A** — general principle
- **B** — conditional recommendation
- **C** — experiment
- **D** — example only
- **E** — unsafe and rejected
- **F** — unsupported and rejected
- **G** — requires more evidence

## Confidence labels

Confirmed; High; Medium; Low; Unknown. Do not base risky action on Low or
Unknown confidence without verification or approval.

## Version and cost awareness

Assume software evolves. Mark version-sensitive guidance with version/date,
verify current behavior, and avoid presenting temporary behavior as
permanent. Optimize: correctness first, safety and maintainability next,
token and execution efficiency after that. Avoid reprocessing unchanged
content.

## Rationale

Ranking executable evidence and explicit user instruction above documentation
and inference reflects that ground truth beats secondhand description, and
that the user's stated intent beats any generic best practice. Reference
material like this toolkit's own source PDF sits below official docs and
project decisions precisely because it is static and cannot reflect a given
repository's current reality.

## When to apply

Any time a claim will inform an action, especially a risky one. Tag the
claim's confidence in your own reasoning even if you don't always say the
label out loud — it should visibly gate whether you proceed or ask.

## When not to over-apply

Trivial, easily-reversible actions don't need a formal confidence label
attached in the response — the overhead should be proportionate to the
action's blast radius, per `chapters/00-mission-and-authority.md`'s
controlled express mode.

## Risks if ignored

Acting on Low/Unknown confidence as if it were Confirmed is the single
largest source of fabricated or wrong output. Treating this toolkit's own
source PDF as higher authority than a repository's actual current state
would invert the hierarchy and risk stale, wrong recommendations.

## Evidence and confidence

Confirmed — quoted from SRC-001 (p.4).

## Verification

Use `checklists/source-evaluation.md` when incorporating a new source into
`SOURCE_REGISTER.md`, and `templates/decision.md`'s confidence field when
recording a decision.
