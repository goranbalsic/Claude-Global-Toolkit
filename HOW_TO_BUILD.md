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

## Versioning policy

Added by UPDATE-02 (`PROMPTS.md` PROMPT-003, Phase 4) — this toolkit
carried a version number (`GLOBAL_CLAUDE.md`/`CLAUDE.md`/
`PROJECT_CONSTITUTION.md` frontmatter, `README.md`'s plain-text line) from
day one without ever stating what triggers which kind of bump. Semantic
versioning (`MAJOR.MINOR.PATCH`), scoped to what actually matters for an
adopting repository:

- **Patch** — fixes, clarifications, typo/broken-link corrections, or
  internal-only reorganization that changes no adopting repository's
  behavior (e.g. a chapter rewording, a corrected cross-reference, a
  `DECISIONS.md` entry).
- **Minor** — new capability an adopting repository can opt into without
  anything breaking: a new prompt/template/checklist, a new optional
  bundle (like the memory-system templates, IDEA-001), a new lifecycle
  capability (like `HOW_TO_USE.md` §6/§7's drift-check and global-loading
  additions), or install-script behavior that adds capability without
  changing existing behavior for repositories not using it (e.g. D-012's
  version-in-output-line addition).
- **Major** — a change to `GLOBAL_CLAUDE.md`'s ten universal rules
  themselves (adding, removing, or changing the meaning of a rule — the
  content every adopting repository actually inherits), or a change to the
  install scripts' *contract* (flags, exit codes, or backup/confirm
  behavior an existing automation might depend on) that isn't purely
  additive.

Apply the bump once, at the end of a batch of work, covering everything
accumulated in `CHANGELOG.md`'s "Unreleased" section(s) since the last
release — not per individual change. Update all four version-carrying
locations together in the same commit (`CLAUDE.md`, `GLOBAL_CLAUDE.md`,
`PROJECT_CONSTITUTION.md` frontmatter, `README.md`'s "Toolkit version"
line); `scripts/health-check.ps1`/`.sh` check 3 verifies they stay
consistent. Per this policy, UPDATE-02's work (a real-world-validation
checklist, lifecycle documentation, a health-check script, automatic
global loading) is a **minor** bump to 2.2.0 once its Phase 6 definition
of done is genuinely met — see `ROADMAP.md`.

## Definition of done for a build pass

See `PROJECT_CONSTITUTION.md` → Definition of done, and
`chapters/05-repository-health-check.md` → Measurable success criteria. Do
not declare a build pass complete until both are satisfied or exceptions are
explicitly recorded with reasons.
