# PROJECT_CONTEXT.md template

Part of the optional memory-system bundle (see `HOW_TO_USE.md` → "Optional:
memory and decision continuity"). Copy into a target repository's root as
`PROJECT_CONTEXT.md` and fill in. Distinct from `PROJECT_STATUS.md`-style
build-progress ledgers: this file answers *why* the project exists and
*what the user wants*, not just what's currently built.

```markdown
# Project Context

## Last Updated

- Date:
- Updated by:
- Current status:

## Project Identity

What this project is and what it is intended to become.

## Purpose

Why this project exists.

## User Goals

What the user is trying to accomplish.

## Desired Outcome

What a successful final result looks like.

## Current State

What currently exists and what is working.

## Current Focus

The single most important thing being worked on now.

## Important Constraints

Technical, business, creative, legal, time, budget, compatibility, or
quality constraints.

## User Preferences

Important preferences the AI should remember. Only include preferences that
are actually known or explicitly provided by the user — do not guess.

Examples of the kind of thing that belongs here:

- Prefer practical execution over endless explanation.
- Prefer the strongest solution instead of asking about every minor choice.
- Avoid unnecessary rewrites.
- Preserve working functionality.
- Keep decisions documented.
- Do not repeatedly ask what to do next.

## Known Risks

Current technical, product, process, or information risks.

## Known Uncertainties

Information that is incomplete, unverified, ambiguous, or likely to change.

## Current Priorities

Ranked priorities, with one clearly identified as the next priority.

## Completed Milestones

Brief list of meaningful completed work.

## Next Recommended Action

One specific next action selected using current goals, constraints, risks,
and expected value.
```

Update this file whenever the project's direction, priorities, constraints,
or important context changes. Do not fill it with implementation detail
that belongs in code, a build-progress file, or `DECISIONS.md` instead.
