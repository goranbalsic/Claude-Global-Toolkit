# DECISIONS.md

Log of significant choices for this repository. Newest first. Each entry:
context, options considered, decision, rejected alternatives, confidence,
reversibility.

## D-009 — Re-verification found salary-currency-pro's CLAUDE.md has diverged from byte-identical; treat as evidence, don't dig further without approval

- **Date:** 2026-08-07
- **Context:** UPDATE-02 (SRC-003) Phase 0 requires re-verifying its
  "known repository state" claims rather than assuming them. One claim,
  carried from D-004, was that `C:\salary-currency-pro\CLAUDE.md` is
  byte-identical to this repository's `GLOBAL_CLAUDE.md`. Re-running the
  same `diff` D-004 used found this is **no longer true**: the target file
  now has an appended "Start or resume (repository-specific addition)"
  section (the universal ten-rule baseline above it is untouched) that
  references `PROJECT_CONTEXT.md`, `PROJECT_RULES.md`, `PROMPTS.md`,
  `session_logs/`, and its own `DECISIONS.md` D-005 — i.e. content
  consistent with that repository having adopted this toolkit's optional
  memory-system bundle (`HOW_TO_USE.md` §3) on its own, since D-004 was
  recorded. This is potentially significant: Phase 1's whole premise is
  that the toolkit has never been used end-to-end in an adopting
  repository, and this is the first direct evidence it may have been.
- **Options considered:**
  1. Immediately read further into `C:\salary-currency-pro` (its
     `PROJECT_CONTEXT.md`, `DECISIONS.md`, `session_logs/`) to confirm and
     characterize this usage.
  2. Record the discrepancy and the single confirmed fact (the `diff`
     output itself) here, without reading further into that repository,
     and raise it as part of Phase 1's required approval question rather
     than as a unilateral investigation.
  3. Ignore the discrepancy and proceed as if D-004's byte-identical state
     still held.
- **Decision:** Option 2. `PROJECT_CONSTITUTION.md`'s approval matrix and
  UPDATE-02's own non-negotiables both require fresh explicit approval
  before touching (which this repository's practice treats as including
  deliberate multi-file reading of) any repository other than this one.
  The single `diff` re-run is consistent with D-004's own precedent (a
  read-only verification check, not an investigation) and is reported
  honestly; anything further is deferred to Phase 1's approval question.
- **Rejected alternatives:** Option 1 rejected — would exceed a
  verification check and become an unapproved investigation of another
  repository. Option 3 rejected — SRC-002/SRC-003 both forbid proceeding
  on an unverified assumption once a re-check contradicts it; restating a
  now-false claim would itself be a fabricated-verification risk this
  toolkit exists to prevent.
- **Confidence:** Confirmed for the `diff` output itself (directly
  observed). Unknown for what produced the change or when — not guessed.
- **Reversibility:** Fully reversible; read-only, no files changed in
  either repository by this decision.

## D-008 — Bring this repository under Git version control now, per UPDATE-02 Phase 0

- **Date:** 2026-08-07
- **Context:** UPDATE-02 (SRC-003) Phase 0 flags that this repository was
  not under Git version control and frames adopting it as a local,
  reversible, in-repo action (no approval needed per
  `PROJECT_CONSTITUTION.md`'s approval matrix) that upgrades
  "reversible" from file-level backups (`PROJECT_CONTEXT.md`'s prior
  wording) to commit-level rollback, and makes every subsequent UPDATE-02
  change auditable.
- **Options considered (decision-quality table):**

  | Option | Benefits | Costs | Risks | Reversibility | Fit |
  |---|---|---|---|---|---|
  | (a) `git init` now, minimal `.gitignore`, one initial commit of current state before further UPDATE-02 edits | Commit-level rollback from this point forward; auditable diff per phase; near-zero cost (no remote, no CI, no packages) | One-time setup; requires a commit author identity | None beyond normal local git use — no remote, nothing pushed | Fully reversible (delete `.git/`) | High — directly matches UPDATE-02's own suggestion and this repo's stated risk ("file-level backups only") |
  | (b) Defer git adoption, keep file-level backups | Zero setup cost now | Continues the exact risk UPDATE-02 flags; no rollback finer than manual backups | Larger, harder-to-audit diffs across UPDATE-02's many phases | N/A | Low — UPDATE-02 explicitly asks this be weighed now |
  | (c) `git init` plus immediately configure a remote/push | Same as (a) plus off-machine backup | Publishing/pushing requires explicit approval per the approval matrix; not asked for | Could expose repository content externally without authorization | Harder to reverse (shared state) | Rejected — exceeds what was authorized |

- **Decision:** (a). Ran `git init`, added a minimal `.gitignore` (OS
  cruft, editor dirs, `*.bak.*`, `*.tmp`), and committed the current
  state — which by this point already included the SRC-003/PROMPT-003
  registration edits, since UPDATE-02's own step 2 required those before
  Phase 0's git decision runs; the commit message says so explicitly
  rather than presenting an artificially clean split. No remote was
  configured; nothing was pushed or published, per the approval matrix.
  Git author identity: the user was asked (blocked without it — Git
  Safety Protocol forbids configuring git config unprompted) and chose a
  **local, repo-scoped** `user.name`/`user.email` (not `--global`), using
  their known email.
- **Rejected alternatives:** (b) rejected — directly contradicts the
  premise UPDATE-02 itself states for raising this decision. (c) rejected
  — publishing/pushing is a separate approval-matrix action not requested
  here; scope stays local-only until asked.
- **Confidence:** High — mechanical, low-risk, directly requested by the
  governing prompt, reversible by deleting `.git/`.
- **Reversibility:** Fully reversible; `.git/` can be deleted with no
  effect on working-tree file contents.

## D-007 — Implement IDEA-001 via templates/ + HOW_TO_USE.md, not via GLOBAL_CLAUDE.md

- **Date:** 2026-08-07
- **Context:** The user asked to fold `IDEAS.md` IDEA-001 (make SRC-002's
  memory-system additions available to *other* adopting repositories, not
  just this one) into the toolkit's templates now.
- **Options considered:**
  1. Add the new files' content directly into `GLOBAL_CLAUDE.md`, so every
     repository that installs the baseline gets them automatically.
  2. Add six new generalized templates under `templates/`
     (`project-context.md`, `project-rules.md`, `prompt-library.md`,
     `ideas-backlog.md`, `open-questions.md`, `session-log.md`) and document
     them as an opt-in bundle in `HOW_TO_USE.md`, copied manually like every
     other template already is.
  3. Add them as a second install-script mode (e.g.
     `install.ps1 -WithMemorySystem`).
- **Decision:** Option 2. Matches how every other template in this
  repository already works (on-demand, copied manually, not auto-installed)
  and does not touch `GLOBAL_CLAUDE.md`.
- **Rejected alternatives:** Option 1 rejected — directly contradicts D-002
  ("GLOBAL_CLAUDE.md contains only the ten universal rules, nothing else"),
  and would force the memory-system bundle on every adopting repository
  whether wanted or not, including ones that already have their own context/
  decision system. Option 3 rejected as unnecessary complexity — the install
  scripts' whole design (D-003's testing, `chapters/04`) is scoped to one
  job, copying `GLOBAL_CLAUDE.md`; adding a second mode/flag increases the
  scripts' blast radius for a feature that's just as well served by copying
  a template file, the same way every other template already works.
- **Confidence:** High — directly requested by the user, and the chosen
  approach reuses this repository's own established pattern rather than
  inventing a new one.
- **Reversibility:** Fully reversible; six new template files and additive
  documentation, no existing file's meaning changed.

## D-006 — Merge SRC-002's session-start order into CLAUDE.md's, rather than keeping two

- **Date:** 2026-08-07
- **Context:** SRC-002 prescribes its own session-start read order (read
  `PROJECT_CONTEXT.md`, `PROJECT_RULES.md`, `DECISIONS.md`, `PROMPTS.md`,
  latest session log, latest summary, inspect state, identify next action).
  `CLAUDE.md` already had its own "Start or resume" order from SRC-001
  (`CLAUDE.md`, `PROJECT_CONSTITUTION.md`, `PROJECT_STATUS.md`,
  `DECISIONS.md`, `ROADMAP.md`, then `summaries/`). Two different
  authoritative-sounding orders in the same repository is exactly the kind
  of contradiction `chapters/05-repository-health-check.md` and this
  repository's own new `PROJECT_RULES.md` (Contradiction Handling section)
  exist to catch, so this was resolved using that same process rather than
  left for a future session to trip over.
- **Options considered:**
  1. Keep both lists as written, one in `CLAUDE.md`, one restated in
     `PROJECT_RULES.md`.
  2. Merge into a single ordered list covering every file both sources
     care about, kept in `CLAUDE.md` (the file SRC-001's own daily
     operating loop step 1 already designates as the read-order source),
     with `PROJECT_RULES.md` pointing to it instead of duplicating it.
  3. Replace `CLAUDE.md`'s order with SRC-002's verbatim, dropping the
     SRC-001-derived files.
- **Decision:** Option 2. `CLAUDE.md`'s "Start or resume" section now reads:
  this file → `PROJECT_CONTEXT.md`/`PROJECT_RULES.md` → `PROJECT_CONSTITUTION.md`/
  `DECISIONS.md` → `PROMPTS.md` → `PROJECT_STATUS.md`/`ROADMAP.md` →
  `session_logs/` → `summaries/` → inspect actual state → health check if
  stale → resume at next action.
- **Rejected alternatives:** Option 1 rejected as the literal contradiction
  being resolved. Option 3 rejected — `PROJECT_STATUS.md` and `ROADMAP.md`
  hold build-progress detail (verification results, exact resume points)
  that SRC-002's own files don't replace; dropping them would lose real
  information, which SRC-002 itself forbids ("preserve useful existing
  information").
- **Confidence:** High — this is a mechanical merge of two lists with no
  information lost from either.
- **Reversibility:** Fully reversible; a plain-text edit to `CLAUDE.md`.

## D-005 — Reconcile SRC-002's memory-system prompt against existing governance instead of duplicating it

- **Date:** 2026-08-07
- **Context:** SRC-002 (`sources/update.txt`) asks for
  `PROJECT_CONTEXT.md`, `PROJECT_RULES.md`, `DECISIONS.md`, `PROMPTS.md`,
  `IDEAS.md`, `OPEN_QUESTIONS.md`, `CHANGELOG.md`, `memory/`, `summaries/`,
  `session_logs/` — but explicitly instructs: "If similar files already
  exist, use and improve them instead of creating confusing duplicates,"
  and "Do not restart, replace, or casually rewrite the existing project."
  This repository already had `DECISIONS.md`, `CHANGELOG.md`, `summaries/`,
  `PROJECT_STATUS.md`, `PROJECT_CONSTITUTION.md`, `CLAUDE.md`/
  `GLOBAL_CLAUDE.md`, `ROADMAP.md`, and `chapters/` before SRC-002 arrived,
  several of which overlap in purpose with what SRC-002 asks for under
  different names.
- **Options considered:**
  1. Create every file SRC-002 lists exactly as specified, even where an
     existing file already serves the same purpose (e.g. a second
     decision-log file alongside `DECISIONS.md`).
  2. For each required file/directory, compare it against this repository's
     existing files; reuse-as-is where purpose matches, add net-new content
     to an existing file where it partially overlaps, and create a new file
     only where a genuine gap exists.
  3. Ignore SRC-002 and keep the repository as it was.
- **Decision:** Option 2. File-by-file mapping:

  | SRC-002 asks for | Resolution |
  |---|---|
  | `DECISIONS.md` | **Reuse as-is.** Already exists, same purpose, compatible format (this repo's Context/Options/Decision/Rejected/Confidence/Reversibility carries the same information as SRC-002's Context/Options/Selected/Reasoning/Consequences/Trigger). No change. |
  | `CHANGELOG.md` | **Reuse as-is.** Already exists, same purpose. |
  | `summaries/` | **Reuse as-is.** Already exists, same purpose (batch milestones); naming convention already matches SRC-002's own example pattern (`BATCH-NN-topic.md`). |
  | `PROJECT_CONTEXT.md` | **Create — genuine gap.** `PROJECT_STATUS.md` covers build-progress state but not "why this project exists / what the user wants / user preferences" — nothing in this repo currently holds that. |
  | `PROJECT_RULES.md` | **Create, but thin.** Most of its required content already exists (`GLOBAL_CLAUDE.md`'s ten rules, `PROJECT_CONSTITUTION.md`'s authority/approval matrix, `chapters/01`'s operating loop). Only the genuinely new procedural content is written out in full: the contradiction-handling algorithm, prompt classification scheme, decision-quality comparison criteria, and evidence/verification-status vocabulary. Everything already covered elsewhere is a pointer, not a restatement. |
  | `PROMPTS.md` | **Create — genuine gap, different purpose from `prompts/`.** The existing `prompts/` directory holds generic, reusable *task-execution* prompts (resume, investigate, plan...) usable in any repository. SRC-002's `PROMPTS.md` is a project-specific log of *actual large prompts this project's user has supplied* (SRC-001, SRC-002 themselves), with active/reference/superseded status — a different axis, not a duplicate. |
  | `IDEAS.md` | **Create — genuine gap.** `ROADMAP.md` tracks committed, planned work; `IDEAS.md` is for not-yet-committed ideas, including ones explicitly rejected with reasons — a backlog `ROADMAP.md` doesn't hold. |
  | `OPEN_QUESTIONS.md` | **Create — genuine gap.** Nothing currently tracks unresolved questions with a default-if-unanswered. |
  | `memory/` | **Create, with an honest caveat.** SRC-002 lists this directory in the required structure but never defines its contents anywhere in the prompt body (unlike `summaries/` and `session_logs/`, which get explicit instructions). Its README says so plainly rather than inventing a purpose, and proposes a narrow interpretation (holding structured extracts from large prompts too detailed for `PROJECT_CONTEXT.md`/`PROJECT_RULES.md`). Logged as `QUESTION-001` in `OPEN_QUESTIONS.md`. |
  | `session_logs/` | **Create — genuine gap.** Distinct from `summaries/`: per-session and dated, vs. per-batch and milestone-based. |

- **Rejected alternatives:** Option 1 rejected — SRC-002 itself forbids it
  ("use and improve them instead of creating confusing duplicates"), and a
  second `DECISIONS.md`/`CHANGELOG.md` would immediately produce exactly the
  kind of contradiction risk `chapters/05-repository-health-check.md` exists
  to catch. Option 3 rejected — the user explicitly directed this prompt to
  be implemented ("this is an update for toolkit project"), and several of
  its required additions (`IDEAS.md`, `OPEN_QUESTIONS.md`, `session_logs/`,
  `PROJECT_CONTEXT.md`'s user-goals/preferences framing) are genuine,
  reasonable gaps in what this repository already had.
- **Scope note:** This decision applies SRC-002 directly to this repository
  only, per its own "Implement this... directly in the current repository"
  instruction. Whether to also fold the net-new pieces (`IDEAS.md`,
  `OPEN_QUESTIONS.md`, `session_logs/`, `PROJECT_RULES.md`'s new procedural
  content) into this toolkit's own reusable offering for *other* adopting
  repositories was not asked for and is logged as `IDEA-001` in `IDEAS.md`
  rather than done unilaterally, per the no-silent-scope-expansion rule
  (`chapters/01-daily-operating-loop.md`).
- **Confidence:** High — the mapping is derived directly from comparing
  SRC-002's stated purpose for each file against this repository's existing
  files' actual content, not inferred.
- **Reversibility:** Fully reversible; all additions are new files, and the
  only edits to existing files are additive (new sections/entries), not
  rewrites of prior content.

## D-004 — Treat the salary-currency-pro finding as confirmed install evidence, not a re-run

- **Date:** 2026-08-07
- **Context:** While resuming this toolkit's build, a health check found
  `C:\salary-currency-pro\CLAUDE.md` byte-identical to this repository's
  `GLOBAL_CLAUDE.md` (confirmed via `diff`, exit 0), with no `.bak.*` file
  present at that path. `ROADMAP.md` had previously marked "Real install
  run" done citing only disposable-repo test evidence, while
  `PROJECT_STATUS.md`'s risk section separately and correctly still said no
  real (non-disposable) target repository had been used — an internal
  contradiction a health check is supposed to catch
  (`chapters/05-repository-health-check.md`).
- **Options considered:**
  1. Run `scripts/install.ps1` again against `C:\salary-currency-pro` to
     generate fresh, directly-observed install evidence.
  2. Treat the existing byte-identical file as sufficient evidence that a
     real target repository now carries the baseline, without re-running the
     installer, and record the mechanism's confidence honestly as Unknown
     (could be this toolkit's script, an earlier session's manual copy, or
     another means) while the resulting state is Confirmed.
  3. Leave the contradiction as still-open in `ROADMAP.md`.
- **Decision:** Option 2. `scripts/install.ps1` is a no-op when the target
  file is already byte-identical to the source (see its own no-op branch) —
  re-running it would print "no change needed" and produce no new evidence
  beyond what `diff` already confirmed. Re-running was therefore unnecessary
  duplicate work for the same conclusion, and installing into a *different*
  fresh target repo wasn't requested and would be scope expansion
  (`chapters/01-daily-operating-loop.md`'s no-silent-scope-expansion rule)
  plus would touch a repository outside this one without it being asked for.
- **Rejected alternatives:** Option 1 rejected as redundant per the no-op
  reasoning above. Option 3 rejected because leaving a known, resolvable
  contradiction open in `ROADMAP.md` after finding the resolving evidence
  would itself violate the health check's own purpose.
- **Confidence:** Confirmed for the resulting state (file is byte-identical,
  verified directly). Unknown for exactly how/when it got there — stated as
  such rather than guessed, per `chapters/00-mission-and-authority.md`.
- **Reversibility:** Fully reversible; this decision only changed
  documentation (`ROADMAP.md`, `chapters/04-reusable-project-structure.md`)
  to reflect verified reality, and touched no files outside this repository.

## D-001 — Build the toolkit as generated Markdown/scripts, not by editing the PDF

- **Date:** 2026-08-07
- **Context:** The only artifact available was a 9-page reference PDF
  (`sources/Claude_Global_Toolkit_AIO_Master_Prompt_v2.1.pdf`) describing a
  "reusable project structure" the toolkit should have, but the structure
  itself did not exist as files yet.
- **Options considered:**
  1. Treat the PDF as the deliverable and stop there.
  2. Generate the full file/directory structure described on page 6 of the
     PDF (`CLAUDE.md`, `GLOBAL_CLAUDE.md`, chapters/, prompts/, templates/,
     checklists/, scripts/, reviews/, summaries/, exports/), using the PDF's
     own text as source content, reorganized into the modular layout it
     specifies.
  3. Generate the structure but leave most files as stub placeholders.
- **Decision:** Option 2 — generate the full structure with real content
  drawn directly from the PDF's text, expanded only where the PDF explicitly
  calls for a category of artifact (e.g., "create checklists for startup,
  investigation, editing...") without dictating exact wording.
- **Rejected alternatives:** Option 1 rejected because the PDF explicitly
  states the PDF is a reference export and Markdown/repository files are
  authoritative — stopping at the PDF would not satisfy the toolkit's own
  stated intent. Option 3 rejected because stub files would violate the
  toolkit's own rule against "empty or corrupt planned deliverable[s]"
  (measurable success criteria, `chapters/05-repository-health-check.md`).
- **Confidence:** High — the PDF is unambiguous about the intended structure
  and content categories.
- **Reversibility:** Fully reversible; all output is plain Markdown/text
  files under version control candidacy, nothing destructive or external was
  touched.

## D-002 — GLOBAL_CLAUDE.md contains only the ten universal rules, nothing else

- **Date:** 2026-08-07
- **Context:** The PDF specifies "GLOBAL_CLAUDE.md contains only universal
  rules... Copying it into a repository as CLAUDE.md applies the baseline to
  that project." There was a temptation to fold in more operational detail
  (batching, health checks, export rules) for convenience.
- **Options considered:** (a) keep `GLOBAL_CLAUDE.md` minimal, per the PDF's
  explicit "only universal rules" instruction; (b) make it a fuller
  operational guide so target repos need fewer follow-up reads.
- **Decision:** (a) — minimal file, ten rules, with pointers to this
  toolkit's handbook for rationale and to on-demand prompts/checklists for
  anything repository-specific.
- **Rejected alternatives:** (b) rejected as direct contradiction of the
  source material's explicit scope constraint for this file.
- **Confidence:** Confirmed against source text.
- **Reversibility:** Fully reversible.

## D-003 — Verify install scripts against disposable repos, not the toolkit's own repo

- **Date:** 2026-08-07
- **Context:** `scripts/install.ps1` / `scripts/install.sh` needed to be
  proven to actually work (create, no-op-when-identical, backup-before-
  overwrite, safe-abort-when-unconfirmed) before `PROJECT_STATUS.md` could
  honestly claim they were verified, per this toolkit's own rule against
  claiming verification that didn't happen.
- **Options considered:** (a) run the scripts against this toolkit's own
  repository; (b) run them against disposable test directories under the
  session scratchpad, outside this repository, deleted afterward; (c) skip
  execution and rely on syntax-checking alone.
- **Decision:** (b) — ran all four scenarios (create, no-op, declined/
  unconfirmed abort, backup+overwrite) against disposable scratch
  directories for both the PowerShell and POSIX shell versions, then deleted
  the test directories.
- **Rejected alternatives:** (a) rejected — running an install script that
  overwrites `CLAUDE.md` against this repository's own `CLAUDE.md` would
  self-modify the very repository under construction, an unnecessary and
  confusing risk for a test. (c) rejected — syntax-checking alone (which was
  also done, via PowerShell AST parsing and `bash -n`) does not verify
  runtime behavior like the backup-then-overwrite logic or the confirmation
  gate, so a claim of "verified" based on syntax-check alone would overstate
  what was actually checked.
- **Confidence:** Confirmed — all four scenarios observed to behave as
  specified, for both scripts.
- **Reversibility:** Fully reversible; test artifacts were outside this
  repository and were deleted after verification.
