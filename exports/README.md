# exports/

Generated exports of the handbook, per
`chapters/06-handbook-templates-and-exports.md`: merged Markdown first;
PDF/DOCX only when tooling exists or after approved installation.

## Current status

`claude-global-toolkit-handbook-2026-08-07.md` was generated 2026-08-07 by
concatenating `README.md`, `PROJECT_CONSTITUTION.md`, and every file under
`chapters/`, `prompts/`, `templates/`, and `checklists/` in filename order
(the `bash` command used is reproducible from the "To generate" section
below). Verified: 59,725 bytes, 1,667 lines, non-empty; contains all 8
chapter headings, all 12 prompt titles, and checklist content — confirmed by
grepping the output file for expected section markers. No PDF/DOCX export
exists — see below.

## To generate the Markdown export

Concatenate, in order: `README.md`, `PROJECT_CONSTITUTION.md`, all files
under `chapters/` in filename order, all files under `prompts/`,
`templates/`, and `checklists/` in filename order. Already done for
2026-08-07 (see above); re-run the same concatenation with a new date suffix
if handbook content changes.

## To generate PDF/DOCX

Requires a document-conversion tool (e.g. Pandoc) to be available or its
installation explicitly approved. Not yet performed — see `ROADMAP.md`.
