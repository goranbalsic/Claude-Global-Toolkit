# Project Rules

Behavior rules for future AI sessions in this repository, per SRC-002
(`sources/update.txt`). Kept thin by design: where a rule is already fully
covered by this repository's existing governance, this file points there
instead of restating it — see `DECISIONS.md` D-005 for why.

## Source of truth and session start

The repository is the source of truth; do not rely on chat history
persisting across restarts. **The canonical session-start read order is in
`CLAUDE.md`'s "Start or resume" section** — it was updated to include this
file, `PROJECT_CONTEXT.md`, `PROMPTS.md`, and `session_logs/` alongside the
files it already listed, so there is exactly one read order, not two. Read
`CLAUDE.md` first; it tells you what to read next.

## Autonomous decision-making

Already covered: `GLOBAL_CLAUDE.md` rules 1–10 (especially "ask before
risk" and "plan before large changes") and `chapters/01-daily-operating-loop.md`'s
"no silent scope expansion." In short: make ordinary decisions
independently using the user's stated goals, current context, and
constraints; do not repeatedly ask about minor choices; ask only when the
decision needs information the AI cannot reasonably know, or when
consequences are serious and irreversible.

## Context preservation

Already covered in spirit by `GLOBAL_CLAUDE.md` rule 10 ("record
decisions") and `chapters/01`. Concretely, in this repository: an important
prompt, requirement, preference, idea, correction, or decision goes into
one of `PROJECT_CONTEXT.md`, this file, `PROMPTS.md`, `DECISIONS.md`,
`IDEAS.md`, `OPEN_QUESTIONS.md`, a `summaries/` batch summary, or a
`session_logs/` entry — pick the narrowest file whose stated purpose
matches, and don't copy the same content into more than one.

## Prompt management (net new — not covered elsewhere)

Do not treat every prompt as permanent. Classify each large or important
prompt in `PROMPTS.md` as one of: Active, Reference, Experimental,
Superseded, Archived. Preserve the original in `sources/` when it's
supplied as a document (as SRC-001 and SRC-002 were), or quote it directly
in `PROMPTS.md` when supplied inline; either way, also write a concise
summary so future sessions don't have to reread the full text.

## Contradiction handling (net new — not covered elsewhere)

When instructions conflict:

1. Identify the conflict explicitly — don't silently pick one side.
2. Determine which instruction is newer.
3. Determine which is more specific to the situation at hand.
4. Check whether the newer instruction intentionally changes prior
   direction, or is just silent on it.
5. Check both against current project goals and constraints
   (`PROJECT_CONTEXT.md`, `PROJECT_CONSTITUTION.md`).
6. Prefer whichever option best serves the user's current objective.
7. Record the resolution in `DECISIONS.md`.
8. Ask the user only if the conflict can't be resolved safely with the
   above steps.

Do not silently blend contradictory requirements into something neither
instruction actually asked for. (This process was applied this session to
resolve SRC-002's own session-start-order list conflicting with
`CLAUDE.md`'s pre-existing one — see the "Source of truth and session
start" section above and `DECISIONS.md` D-005/D-006.)

## Decision quality (net new — not covered elsewhere)

Not all ideas are equally good. When comparing alternatives, weigh:
alignment with the user's actual goal, expected value, simplicity,
reliability, cost, time, risk, maintainability, scalability, reversibility,
evidence, and compatibility with existing work. Select the strongest
practical option; if there's no clear winner, state the trade-offs briefly
and pick the safest reversible option rather than stalling. A comparison
table is useful for non-trivial choices:

| Option | Benefits | Costs | Risks | Reversibility | Fit |
|---|---|---|---|---|---|

Skip the table for simple decisions — per `PROJECT_CONSTITUTION.md`'s
engineering principles, effort should be proportionate to the decision's
weight.

## Scope control

Already covered: `chapters/01-daily-operating-loop.md`'s "no silent scope
expansion" and `PROJECT_CONSTITUTION.md`'s engineering principles. In
short: stay on the current highest-value objective, park other ideas in
`IDEAS.md` rather than building them immediately, and propose (don't just
do) anything that amounts to a new major component.

## Evidence and verification (vocabulary is net new)

Already covered in principle by `chapters/02-evidence-and-uncertainty.md`'s
confidence labels (Confirmed/High/Medium/Low/Unknown) and
`GLOBAL_CLAUDE.md` rule 3 ("do not invent"). SRC-002 additionally asks for a
work-status vocabulary, which this repository adopts: Proposed, Planned, In
progress, Implemented, Tested, Verified, Partially verified, Blocked,
Rejected, Superseded. Use it in `DECISIONS.md`, `IDEAS.md`, and
`OPEN_QUESTIONS.md` entries where it adds clarity over a free-text status.

## Memory maintenance

At the end of every meaningful session: update `PROJECT_CONTEXT.md` if
anything material changed, record any significant decision in
`DECISIONS.md`, save any large new prompt to `PROMPTS.md`, update `IDEAS.md`
/`OPEN_QUESTIONS.md`, write a `session_logs/` entry, and state what was
verified and the next recommended action. `chapters/01-daily-operating-loop.md`
step 8 ("Review and report") and `templates/handoff.md` already cover the
build-progress half of this (`PROJECT_STATUS.md`, `summaries/`); this
section is about the context/decision half SRC-002 adds on top.
