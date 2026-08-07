# Open Questions

## High Importance

None currently — nothing here blocks current work.

## Medium Importance

None currently — see Resolved below for QUESTION-001.

## Low Importance

None currently — see Resolved below for QUESTION-002.

## Resolved

### QUESTION-001: What should `memory/` actually contain?

Date added: 2026-08-07 · Date resolved: 2026-08-07

Why it mattered: SRC-002 (`sources/update.txt`) lists `memory/` in its
required directory structure but never describes its contents anywhere in
the prompt body, unlike `summaries/` and `session_logs/`, which both get
explicit instructions. Creating the directory without a clear purpose risks
it becoming an unused or inconsistently-used dumping ground.

Possible answers considered: (a) a narrow interpretation — structured
extracts from large prompts too detailed for `PROJECT_CONTEXT.md`/
`PROJECT_RULES.md`; (b) a general scratch space for any structured memory
artifact; (c) leave it present but empty until a concrete need arises.

**Resolution: (c), per UPDATE-02 Phase 3** (`PROMPTS.md` PROMPT-003). No
user answer was received, and UPDATE-02 directed adopting the recommended
default unless Phase 1's real-world validation run (`DECISIONS.md` D-011)
suggested otherwise — it didn't touch `memory/` or surface any need for
it, so the default stands. `memory/README.md` reflects this as a settled
interpretation. Reopen only if a concrete case genuinely doesn't fit any
named root file.

### QUESTION-002: Should `PROMPTS.md` (project-level) and `prompts/` (generic library) have clearer cross-linking to avoid confusion?

Date added: 2026-08-07 · Date resolved: 2026-08-07

Why it mattered: The two serve different purposes (see `DECISIONS.md`
D-005) but the name similarity could confuse a future session skimming the
directory listing.

**Resolution: implemented the cheap fix, per UPDATE-02 Phase 3.** Added
`prompts/README.md` (didn't exist before) explaining `prompts/`'s purpose
and pointing at `PROMPTS.md`/`DECISIONS.md` D-005 for the distinction, and
added a matching one-line pointer atop `PROMPTS.md` pointing back. Both
files now cross-reference each other directly, not just describe
themselves in isolation.

## Question Template

### QUESTION-NNN: Title

Date added:

Why it matters:

Current assumptions:

Possible answers:

Does it block current work?

Recommended default if no answer is received:

Status:
