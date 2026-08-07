# PROJECT_RULES.md template

Part of the optional memory-system bundle (see `HOW_TO_USE.md` → "Optional:
memory and decision continuity"). Copy into a target repository's root as
`PROJECT_RULES.md` and fill in. If that repository has already installed
`GLOBAL_CLAUDE.md` as its `CLAUDE.md`, trim sections below that only repeat
what's already covered there (autonomous decision-making, scope control,
evidence/verification) and keep the parts that aren't (contradiction
handling, prompt classification, decision-quality comparison) — see this
toolkit's own `PROJECT_RULES.md` for a worked example of that trimming.

```markdown
# Project Rules

## Source of Truth

The repository is the source of truth for persistent project context. Do
not rely on previous chat history being available. At the start of every
session: read PROJECT_CONTEXT.md, PROJECT_RULES.md, DECISIONS.md, the
latest relevant prompt or prompt summary, and the latest session log —
then inspect the current project state before making assumptions. (If this
repository also has a CLAUDE.md with its own start/resume order, merge the
two into one canonical list there rather than keeping both — see
"Contradiction Handling" below.)

## Autonomous Decision-Making

Make normal decisions independently. Do not repeatedly ask the user what
should happen next, which minor option they prefer, or which small
implementation detail to choose. Choose the best solution based on the
user's stated goals, current project context, existing constraints,
evidence, quality, simplicity, reliability, long-term maintainability, and
expected user value. Ask only when the decision requires information the
AI cannot reasonably know, or when the consequences are serious and
irreversible.

## Context Preservation

Important information from conversations must be transferred into
repository files — do not assume a long conversation will remain available
after restart. When the user provides an important prompt, requirement,
preference, idea, correction, or decision, determine whether it belongs in
PROJECT_CONTEXT.md, PROJECT_RULES.md, PROMPTS.md, DECISIONS.md, IDEAS.md,
OPEN_QUESTIONS.md, a summary, or a session log.

## Prompt Management

Do not blindly treat every prompt as permanent. Classify prompts as:
Permanent instructions, Project-level instructions, Task-specific
instructions, Temporary experiments, Ideas under consideration, or
Superseded instructions. Preserve original prompts when useful, but also
write concise summaries so future sessions don't need to reread everything.

## Contradiction Handling

When instructions conflict:

1. Identify the conflict.
2. Determine which instruction is newer.
3. Determine which is more specific.
4. Check whether the newer instruction intentionally changes the previous
   direction.
5. Check the project's goals and constraints.
6. Prefer the option that best serves the user's current objective.
7. Record the resolution in DECISIONS.md.
8. Ask the user only if the conflict cannot be resolved safely.

Do not silently combine contradictory requirements.

## Decision Quality

Do not treat all ideas as equally valuable. Compare alternatives using:
alignment with the user's goal, expected value, user benefit, simplicity,
reliability, cost, time, risk, maintainability, scalability, reversibility,
evidence, and compatibility with existing work. Select the strongest
practical option. If there's no clear winner, explain the trade-offs
briefly and choose the safest reversible option.

## Scope Control

Focus on the current highest-value objective. Do not implement every
interesting idea immediately — keep future ideas in IDEAS.md. Prefer
completing one meaningful end-to-end result over starting many unfinished
tasks. Avoid unnecessary rewrites, dependencies, and uncontrolled scope
expansion.

## Evidence and Verification

Do not claim success without verification. Clearly distinguish between:
Proposed, Planned, In progress, Implemented, Tested, Verified, Partially
verified, Blocked, Rejected, Superseded.

## Memory Maintenance

At the end of every meaningful session: update PROJECT_CONTEXT.md, update
relevant decisions, save important new prompts or prompt summaries, update
ideas and open questions, create a session log, record what was changed
and verified, and record the next recommended action. Keep memory
accurate, concise, and free from duplication.
```
