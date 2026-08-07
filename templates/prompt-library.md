# PROMPTS.md template

Part of the optional memory-system bundle (see `HOW_TO_USE.md` → "Optional:
memory and decision continuity"). Copy into a target repository's root as
`PROMPTS.md` and fill in. This is a project-specific log of the actual
large prompts that shaped *that* project — not a generic reusable prompt
library like this toolkit's own `prompts/` directory, and not a place for
every conversation message.

```markdown
# Prompt Library

## How to Use This File

This file stores important prompts, prompt summaries, and reusable
instruction sets specific to this project. Each prompt is labeled as one
of: Active, Reference, Experimental, Superseded, Archived.

## Prompt Index

| ID | Name | Type | Status | Purpose |
|---|---|---|---|---|

## Active Prompts

### PROMPT-001: Name

Status: Active

Purpose:

When to use:

Full prompt or link:

Key requirements:

Known limitations:

## Reference Prompts

Prompts that contain useful ideas but are not currently active.

## Superseded Prompts

Older prompts that were replaced, including the reason they were replaced.

## Prompt Summaries

For large prompts, create a concise summary containing: core objective,
required behavior, constraints, important preferences, expected output,
what should not happen, and whether the prompt is still active.
```

When a very large prompt is supplied: preserve the original (in `sources/`
if it's a document, or quoted directly here if inline), add an entry to the
index above, write a concise summary, and extract permanent rules into
`PROJECT_RULES.md` or current goals into `PROJECT_CONTEXT.md` only where
appropriate — do not duplicate the full prompt text across multiple files.
