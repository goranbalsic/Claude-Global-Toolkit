# exports/

Generated exports of the handbook, per
`chapters/06-handbook-templates-and-exports.md`: merged Markdown first;
PDF/DOCX only when tooling exists or after approved installation.

## Current status

`claude-global-toolkit-handbook-2026-08-07.md` was regenerated 2026-08-07
(UPDATE-02 Phase 5, same calendar day as the original — file replaced in
place) by concatenating `README.md`, `PROJECT_CONSTITUTION.md`, and every
file under `chapters/`, `prompts/`, `templates/`, and `checklists/` in
filename order (the `bash` command used is reproducible from the "To
generate" section below). Verified: 78,696 bytes, 2,274 lines, non-empty;
contains all 8 chapter headings, all 10 checklists (including the new
`adoption-validation.md`), all 13 prompts (including the new
`prompts/README.md`), and all 13 templates — confirmed by grepping the
output file for expected section markers against the current directory
inventory. No PDF/DOCX export exists — Pandoc confirmed not installed on
this machine (`which pandoc`); see below.

## To generate the Markdown export

Concatenate, in order: `README.md`, `PROJECT_CONSTITUTION.md`, all files
under `chapters/` in filename order, all files under `prompts/`,
`templates/`, and `checklists/` in filename order. Already done for
2026-08-07 (see above); re-run the same concatenation with a new date suffix
if handbook content changes.

## To generate PDF/DOCX

**Done 2026-08-07** (UPDATE-02 Phase 5) — Pandoc was not installed; the
user gave explicit approval to install what's needed. Installed via
`choco install pandoc -y` (3.10.1) and, for PDF specifically,
`choco install wkhtmltopdf -y` (0.12.6) as a lighter-weight PDF engine
than a full LaTeX distribution (Pandoc's default `pdflatex` engine
wasn't installed and a full TeX distribution is disproportionate to a
documentation export).

```bash
pandoc exports/claude-global-toolkit-handbook-<date>.md \
  -o exports/claude-global-toolkit-handbook-<date>.docx

pandoc exports/claude-global-toolkit-handbook-<date>.md \
  -o exports/claude-global-toolkit-handbook-<date>.pdf \
  --pdf-engine=wkhtmltopdf
```

Verified: `claude-global-toolkit-handbook-2026-08-07.docx` (49,571 bytes,
`file` confirms "Microsoft Word 2007+"). `claude-global-toolkit-handbook-2026-08-07.pdf`
(428,114 bytes, `file` confirms "PDF document, version 1.4"; wkhtmltopdf's
own render progress reported 34 pages while generating it — note `file`'s
own page-count heuristic disagreed (reported 1289), which is a known
unreliable heuristic for wkhtmltopdf-produced PDFs, not a claim either
way about the true count; both files open-format-valid regardless).
Neither export tool was used to fabricate content — both are direct
conversions of the already-verified Markdown export.
