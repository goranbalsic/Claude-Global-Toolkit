# HOW_TO_BUILD.md

How this toolkit itself is built and maintained.

## Source of truth

`sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf` is the original
reference export. It states plainly that the PDF is a reference export and
that Markdown/repository files are authoritative. Do not edit the PDF; if the
source content needs to change, that happens by adding a new dated source to
`SOURCE_REGISTER.md` and reconciling differences in `DECISIONS.md`, not by
silently diverging from what the register says was extracted.

## Batching (per `chapters/03-phase0-investigation.md`)

Work on this toolkit proceeds in these batches:

1. Initialization and governance (root files, `GLOBAL_CLAUDE.md`).
2. Investigation and source evaluation (`SOURCE_REGISTER.md`).
3. Bounded chapter batches (`chapters/`).
4. Prompts, templates, checklists.
5. Reviews and final audit.
6. Export preparation.

After each batch: review changed files and cross-references, remove
duplication, check links and filenames, update `PROJECT_STATUS.md`, and write
`summaries/BATCH-<n>.md`.

## Adding a new chapter, prompt, template, or checklist

1. Confirm it doesn't already exist (`chapters/`, `prompts/`, `templates/`,
   `checklists/` — check for near-duplicates, not just exact filename
   matches).
2. Follow the existing frontmatter and structure conventions in that
   directory.
3. Cross-reference it from `README.md` and any chapter that describes its
   category (e.g. a new prompt gets listed in
   `chapters/06-handbook-templates-and-exports.md`).
4. Run the repository health check before considering the addition done.

## Changing GLOBAL_CLAUDE.md

Treat this as high blast-radius — every repository that has installed it
inherits the change on next install/update. Before changing it:

1. Confirm the change is universal (applies to every repository), not
   project-specific — project-specific rules belong in a chapter, checklist,
   or prompt instead.
2. Record the change in `DECISIONS.md` with rationale.
3. Bump the version in this toolkit's frontmatter and `CHANGELOG.md`.

## Definition of done for a build pass

See `PROJECT_CONSTITUTION.md` → Definition of done, and
`chapters/05-repository-health-check.md` → Measurable success criteria. Do
not declare a build pass complete until both are satisfied or exceptions are
explicitly recorded with reasons.
