# Open Questions

## High Importance

None currently — nothing here blocks current work.

## Medium Importance

### QUESTION-001: What should `memory/` actually contain?

Date added: 2026-08-07

Why it matters: SRC-002 (`sources/update.txt`) lists `memory/` in its
required directory structure but never describes its contents anywhere in
the prompt body, unlike `summaries/` and `session_logs/`, which both get
explicit instructions. Creating the directory without a clear purpose risks
it becoming an unused or inconsistently-used dumping ground.

Current assumptions: `memory/README.md` proposes a narrow, stated-as-inferred
interpretation: a place for structured extracts from large prompts that are
too detailed to inline in `PROJECT_CONTEXT.md` or `PROJECT_RULES.md` (e.g. a
longer prompt-summary write-up than `PROMPTS.md`'s "Prompt Summaries"
section comfortably holds).

Possible answers: (a) the narrow interpretation above; (b) a general
scratch space for any structured memory artifact not covered by the other
named files; (c) the directory was listed but not meant to be used unless a
concrete need arises — leave it present but empty until then.

Does it block current work? No — the directory and README exist either way;
this only affects what gets put in it later.

Recommended default if no answer is received: (c) — leave it present with
its README's stated purpose, add content only when a concrete case arises
that doesn't fit `PROJECT_CONTEXT.md`, `PROJECT_RULES.md`, or `PROMPTS.md`.

Status: Open

## Low Importance

### QUESTION-002: Should `PROMPTS.md` (project-level) and `prompts/` (generic library) have clearer cross-linking to avoid confusion?

Date added: 2026-08-07

Why it matters: The two serve different purposes (see `DECISIONS.md` D-005)
but the name similarity could confuse a future session skimming the
directory listing.

Current assumptions: The distinction is explained in both `PROMPTS.md`'s
"How to Use This File" section and `DECISIONS.md` D-005; assumed sufficient
for now.

Possible answers: Leave as-is; or add a one-line cross-reference at the top
of `prompts/`'s own listing (there's no `prompts/README.md` currently) and
in `PROMPTS.md` pointing at each other explicitly.

Does it block current work? No.

Recommended default if no answer is received: Leave as-is; revisit only if
a future session actually gets confused by it in practice.

Status: Open

## Question Template

### QUESTION-NNN: Title

Date added:

Why it matters:

Current assumptions:

Possible answers:

Does it block current work?

Recommended default if no answer is received:

Status:
