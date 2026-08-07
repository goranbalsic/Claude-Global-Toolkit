# CHANGELOG.md

## 2.2.0 — 2026-08-07

Minor release per `HOW_TO_BUILD.md`'s versioning policy (new capability,
no change to `GLOBAL_CLAUDE.md`'s ten rules or the install scripts'
contract — see `reviews/UPDATE-02-FINAL-AUDIT.md`). Consolidates batches
2–4 and the UPDATE-02/SRC-004 batch, all previously logged as
"Unreleased" below.

- **UPDATE-02 (SRC-003) Phases 0–5, executed with SRC-004 folded in
  mid-batch:** Git version control adopted (D-008); real-world validation
  gap closed via a new `checklists/adoption-validation.md` run against
  `salary-currency-pro`, passed (D-010, D-011, user-approved); adoption
  lifecycle completed in `HOW_TO_USE.md` §6 (drift/update/recovery/
  removal, D-012); both open questions closed (`OPEN_QUESTIONS.md`);
  automatic global loading via `%USERPROFILE%\.claude\CLAUDE.md` + native
  `@import`, approved and verified in two disposable scenarios (D-013,
  SRC-004, `HOW_TO_USE.md` §7); `scripts/health-check.ps1`/`.sh` added
  plus an explicit versioning policy (D-014); Markdown export
  regenerated, PDF/DOCX generated for the first time with approved
  Pandoc/wkhtmltopdf installation (D-015). Full phase-by-phase status:
  `reviews/UPDATE-02-FINAL-AUDIT.md`.
- **Batch 4:** Implemented `IDEAS.md` IDEA-001 — folded SRC-002's
  memory-system additions into this toolkit's reusable offering (six new
  generalized templates, `HOW_TO_USE.md` §3, `DECISIONS.md` D-007).
- **Batch 3:** Implemented SRC-002 ("General Project Memory and Decision
  System"), reconciled against existing governance (`DECISIONS.md` D-005,
  D-006) — new `PROJECT_CONTEXT.md`, `PROJECT_RULES.md`, `PROMPTS.md`,
  `IDEAS.md`, `OPEN_QUESTIONS.md`, `memory/README.md`, `session_logs/`.
- **Batch 2:** Full final audit (`reviews/FINAL_AUDIT.md`,
  `reviews/PRINCIPAL_ENGINEER_REVIEW.md`); Claude Code `2.1.224`
  compatibility verified; real target-repository install confirmed
  (`DECISIONS.md` D-004); first Markdown handbook export generated.

## Unreleased

_Nothing pending — this file's contents are moved into a dated release
section, per `HOW_TO_BUILD.md`'s versioning policy, once a batch of work
warrants a version bump._

## 2.1.0 — 2026-08-07

- Initial generation of the full reusable project structure from
  `sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf`: root governance
  files, `chapters/`, `prompts/`, `templates/`, `checklists/`, `scripts/`
  (install scripts), and scaffolding for `reviews/`, `summaries/`,
  `exports/`.
- Version number carried forward from the source PDF's own
  "Toolkit Version: 2.1.0" front matter; no independent version bump applied
  in this initial build.
