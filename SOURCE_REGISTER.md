# SOURCE_REGISTER.md

Register of source material this toolkit is derived from, per
`chapters/03-phase0-investigation.md`.

## SRC-001

- **Title:** Claude Global Toolkit — AIO Master Prompt v2.1.0
- **Type:** Supplied reference PDF (reference export; six pages of source
  content described in the PDF's own front matter as the baseline)
- **Location:** `sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf`
- **Date:** Last reviewed 2026-08-07 (per document front matter)
- **Authority tier:** Supplied source material — tier 5 of 8 in the evidence
  priority order (see `chapters/02-evidence-and-uncertainty.md`). Treated as
  reference input, not as an instruction source in its own right.
- **Claims/recommendations extracted:** Mission and authority rules;
  controlled express mode; the eight-step daily operating loop; evidence
  priority, recommendation classes, and confidence labels; Phase 0
  investigation steps; the reusable project file/directory structure;
  project-constitution and global-toolkit content requirements; installation
  script requirements; repository health check criteria; measurable success
  criteria; handbook/prompt/template/checklist inventory; export rules; final
  audit requirements; compatibility/persistence notes; completion report and
  safe resume instruction format.
- **Limitations:** The PDF states Claude Code version compatibility as
  "Unknown — verify installed version" and lists no breaking changes or
  deprecated behavior on record. It is a static export; it does not update
  itself as Claude Code evolves.
- **Outdated risk:** Medium over time — re-verify version-sensitive claims
  (none currently pinned to a specific Claude Code version) against current
  official documentation before relying on them for tool-specific behavior.
- **Version verification performed:** 2026-08-07, this repository's installed
  Claude Code CLI confirmed as `2.1.224` via `claude --version`; no breaking
  changes or deprecated behavior found against this toolkit's assumptions.
  See `chapters/07-compatibility-and-persistence.md` → "Compatibility
  (verified)" for detail and scope. This closes the PDF's "Unknown — verify
  installed version" placeholder for this one version/date/OS combination
  only — it is not a permanent guarantee for future versions.
- **Status:** Fully read and reconciled against this repository's generated
  content on 2026-08-07 (see confirmation in the session that produced this
  repository's initial structure).
- **Traceable location:** Pages 1–9 of the PDF, section headings quoted
  verbatim in `chapters/*.md`.

## SRC-002

- **Title:** "General Project Memory and Decision System" — a domain-agnostic
  memory/context/prompt/decision-management system prompt, supplied by the
  user for application to this toolkit repository.
- **Type:** Supplied reference prompt, provided inline in chat and separately
  saved to disk by the user.
- **Location:** `sources/update.txt`.
- **Date:** Supplied 2026-08-07.
- **Authority tier:** Supplied source material — tier 5 of 8 (same tier as
  SRC-001; see `chapters/02-evidence-and-uncertainty.md`) for its content as
  reference material, but functionally also tier 2 (explicit user
  instruction) in that the user directed it to be implemented in this
  repository — the instruction to act is tier 2, the prescribed file
  structure and wording within it is tier 5 reference content, evaluated
  against and reconciled with this repository's existing tier-3/4 governance
  rather than applied verbatim.
- **Format note:** The on-disk file is UTF-16 encoded (consistent with a
  Windows Notepad "Save as Unicode" default), unlike every other text file in
  this repository (UTF-8). Confirmed readable and byte-faithful to the
  content pasted in chat via direct inspection. Left as supplied per this
  toolkit's own rule against editing `sources/` content — not converted,
  since conversion would modify the source file's bytes even though it
  wouldn't change its meaning.
- **Claims/recommendations extracted:** A required file/directory set
  (`PROJECT_CONTEXT.md`, `PROJECT_RULES.md`, `DECISIONS.md`, `PROMPTS.md`,
  `IDEAS.md`, `OPEN_QUESTIONS.md`, `CHANGELOG.md`, `memory/`, `summaries/`,
  `session_logs/`); explicit instruction to reuse/improve existing
  equivalents rather than duplicate; templates for each file; a session-start
  and session-end procedure; a contradiction-handling algorithm; a prompt
  classification scheme; a decision-quality comparison process.
- **Limitations:** Domain-agnostic by design (explicitly not finance/fintech-
  specific), which is why it was reconciled against — not simply layered
  onto — this repository's existing, more toolkit-specific governance system
  (`PROJECT_CONSTITUTION.md`, `DECISIONS.md`, `PROJECT_STATUS.md`,
  `ROADMAP.md`, `chapters/`). Several of its required files/directories
  overlap in purpose with files this repository already had before SRC-002
  was supplied.
- **Outdated risk:** Low — it's a static, self-contained instruction set with
  no version-sensitive or tool-specific claims.
- **Status:** Fully read and reconciled — see `DECISIONS.md` D-005 for the
  file-by-file reconciliation mapping.
- **Traceable location:** Full text in `sources/update.txt`; also pasted
  verbatim in the chat session that supplied it.

## SRC-003

- **Title:** "UPDATE-02 — Claude Global Toolkit: from internally consistent
  to real-world proven" — a supplied multi-phase update prompt grounded in
  this repository's actual state as of batch 4 (2026-08-07).
- **Type:** Supplied reference prompt, saved to disk by the user as a
  ready-to-paste instruction set.
- **Location:** `sources/UPDATE-02-claude-global-toolkit-prompt.md`.
- **Date:** Supplied 2026-08-07.
- **Authority tier:** Supplied source material — tier 5 of 8 (same tier as
  SRC-001/SRC-002; see `chapters/02-evidence-and-uncertainty.md`) for its
  prescribed content, but functionally also tier 2 (explicit user
  instruction) for the instruction to act on it — the same dual treatment
  SRC-002 received (`DECISIONS.md` D-005).
- **Claims/recommendations extracted:** A restated session-start order
  (already canonical in `CLAUDE.md`); a set of "known repository state"
  claims to re-verify rather than assume; a decision point on bringing this
  repository under Git version control; a six-phase plan — real-world
  validation protocol (Phase 1), adoption-lifecycle completeness (Phase 2),
  open-question closure (Phase 3), reproducible health tooling and
  versioning policy (Phase 4), honest exports (Phase 5), final audit and a
  2.2.0 release (Phase 6).
- **Limitations:** Self-describes as "grounded in the actual repository
  state," so its claims are re-verified against live repository content
  before being acted on, not assumed current — per this repository's
  evidence rules. It is a static document; later repository changes are not
  reflected back into it.
- **Outdated risk:** Low at time of supply (re-verified against live state
  the same session it was registered) — see Phase 0 re-verification in
  `DECISIONS.md`.
- **Status:** Registered 2026-08-07; execution proceeding phase by phase —
  see `PROJECT_STATUS.md` for current progress and `DECISIONS.md` for
  decisions made while executing it.
- **Traceable location:** Full text in
  `sources/UPDATE-02-claude-global-toolkit-prompt.md`.

## SRC-004

- **Title:** "UPDATE-02 ADDITION — Make the toolkit Claude Code's automatic
  global brain" — a supplied requirement that this toolkit load
  automatically in every Claude Code session, in every project, without
  per-repository install.
- **Type:** Supplied reference prompt, appearing directly as a file in
  `sources/` mid-session (not pasted in chat first) while UPDATE-02
  (SRC-003) was being executed; the user then explicitly directed it be
  read and merged into the in-progress UPDATE-02 work.
- **Location:** `sources/update2addition.txt`.
- **Date:** Supplied 2026-08-07 (found mid-session, same day as SRC-003).
- **Authority tier:** Supplied source material — tier 5 of 8 for its
  prescribed content, tier 2 (explicit user instruction) for the
  instruction to act — same dual treatment as SRC-002/SRC-003. Its
  central action (writing `%USERPROFILE%\.claude\CLAUDE.md`) is also a
  `PROJECT_CONSTITUTION.md` approval-matrix item ("installing packages /
  altering global config... never automatic") — the document explicitly
  requires the same approval itself ("Show the proposed change and obtain
  approval before modifying user-level configuration"), so tier 5/2
  content does not override the approval-matrix gate.
- **Claims/recommendations extracted:** Use Claude Code's native
  user-level `CLAUDE.md` + `@path` import mechanism (verified against
  official docs — see `DECISIONS.md` for the entry recording this) rather
  than a background service; keep the toolkit as the canonical,
  live-referenced (not copied) source; preserve per-project `CLAUDE.md`
  precedence; back up before changing; verify via a disposable new project
  and an existing project; document install/verify/update/recovery/
  removal; record architecture and evidence across `DECISIONS.md`,
  `HOW_TO_USE.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, and the UPDATE-02
  final audit.
- **Limitations:** Prescribes an outcome ("automatic global brain") without
  prescribing exact file contents — the exact import syntax/path handling
  was independently verified against official Claude Code documentation
  before being proposed, not assumed from this source's wording.
- **Outdated risk:** Low — mechanism verified same-session against current
  official docs.
- **Status:** Registered 2026-08-07; approval requested before executing
  its core action (global config change) — see `DECISIONS.md`.
- **Traceable location:** Full text in `sources/update2addition.txt`.

## Notes

- Four sources on record: SRC-001 (the original toolkit master prompt),
  SRC-002 (the general memory-system prompt), SRC-003 (UPDATE-02, this
  repository's real-world-validation and lifecycle-completeness update),
  and SRC-004 (UPDATE-02 ADDITION, automatic global loading). No
  unresolved conflict between them — each is additive to what came before;
  see `DECISIONS.md` D-005 (SRC-002) and the UPDATE-02 execution decisions
  (SRC-003/SRC-004).
- Add a new `SRC-NNN` entry for any future source incorporated into this
  toolkit (official Claude Code docs, community guidance, etc.), and record
  any conflict with prior sources in `DECISIONS.md`.
