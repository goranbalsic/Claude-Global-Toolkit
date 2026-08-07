# ROADMAP.md

Planned work, not yet done. Move items to `CHANGELOG.md` once actually
completed and verified.

## Open — UPDATE-02 (SRC-003) plan

Bounded plan for `sources/UPDATE-02-claude-global-toolkit-prompt.md`
(`PROMPTS.md` PROMPT-003), written 2026-08-07 at the start of Phase 0.
Priorities per UPDATE-02's own phase structure:

- **P0 — false claims, broken references, safety issues found in
  re-verification.** One found already: `salary-currency-pro/CLAUDE.md` is
  no longer byte-identical to `GLOBAL_CLAUDE.md` (`DECISIONS.md` D-009) —
  D-004's "Confirmed byte-identical" claim is now stale and needs
  correcting wherever it's restated as current fact.
- ~~**P1 — the real-world validation gap (Phase 1).**~~ Done 2026-08-07 —
  `checklists/adoption-validation.md` created (D-010) and run against
  `salary-currency-pro` with user approval; passed (D-011).
- ~~**P2a — adoption lifecycle completeness (Phase 2).**~~ Done 2026-08-07
  — `HOW_TO_USE.md` §6 (drift/update/recovery/removal); D-012 (version
  anchor, install scripts re-verified against D-003's four scenarios).
- ~~**P2b — open-question closure (Phase 3).**~~ Done 2026-08-07 —
  QUESTION-001 resolved with default (c); QUESTION-002 resolved via
  `prompts/README.md` + `PROMPTS.md` cross-reference. Both moved to
  `OPEN_QUESTIONS.md`'s new Resolved section. `IDEAS.md` swept — nothing
  new to add.
- ~~**P3a — reproducible health tooling, release discipline (Phase 4).**~~
  Done 2026-08-07 — `scripts/health-check.ps1`/`.sh` (D-014), versioning
  policy in `HOW_TO_BUILD.md`.
- **P3b — exports (Phase 5).** Regenerated Markdown export; PDF/DOCX only
  if tooling exists or is approved (Pandoc confirmed not installed).

~~**SRC-004 — automatic global loading.**~~ Done 2026-08-07 — implemented
and verified with user approval mid-batch (D-013); see
`HOW_TO_USE.md` §7. Folded into UPDATE-02's scope per the user's explicit
instruction to merge SRC-004 into the in-progress UPDATE-02 work.

Phase 6 (final audit, summaries, session log, status rewrite, 2.2.0
version bump if genuinely earned) closes out the batch once P0–P3 (and
SRC-004) are done — see `reviews/UPDATE-02-FINAL-AUDIT.md` when written.

## Open

## Done

- ~~**Verify Claude Code version compatibility.**~~ Done 2026-08-07 —
  installed Claude Code CLI confirmed as `2.1.224` via `claude --version` on
  Windows 11; no breaking changes or deprecated behavior found against this
  toolkit's assumptions. See `chapters/07-compatibility-and-persistence.md`
  → "Compatibility (verified)" and `SOURCE_REGISTER.md`. Scope: this one
  version/date/OS only — re-verify after future Claude Code upgrades.
- ~~**Disposable-repo install script test.**~~ Done 2026-08-07 — both
  scripts were exercised end to end against disposable test repositories
  (create-when-absent, no-op-when-identical, safe-abort-when-unconfirmed,
  backup-then-overwrite) and all four cases passed for both `install.ps1`
  and `install.sh`. See `summaries/BATCH-01-initial-toolkit-build.md`. (This
  item was previously mislabeled "Real install run" here while
  `PROJECT_STATUS.md` correctly still listed a real-target install as an
  open risk — see the next item, which resolves that inconsistency.)
- ~~**Real (non-disposable) install run.**~~ Confirmed present 2026-08-07 —
  `C:\salary-currency-pro\CLAUDE.md` was found to be byte-identical to this
  repository's `GLOBAL_CLAUDE.md` (verified via `diff`, exit 0, no
  differences). No `.bak.*` file exists there, consistent with either a
  fresh `install.ps1`/`install.sh` create-when-absent run or an equivalent
  manual copy — the exact mechanism is Unknown confidence, but the resulting
  state (a real, non-disposable target repository carrying this toolkit's
  baseline) is Confirmed. See `DECISIONS.md` D-004. **Superseded same day:**
  a later re-verification (UPDATE-02 Phase 0) found the file has since
  diverged from byte-identical — see `DECISIONS.md` D-009 and
  `PROJECT_STATUS.md`.
- ~~**Full final audit.**~~ Done 2026-08-07 — see `reviews/FINAL_AUDIT.md`
  and `reviews/PRINCIPAL_ENGINEER_REVIEW.md`.
- ~~**Markdown export bundle.**~~ Done 2026-08-07 — see
  `exports/claude-global-toolkit-handbook-2026-08-07.md`.

## Explicitly out of scope unless requested

- Anything requiring package installation, global configuration changes, or
  network access — per `PROJECT_CONSTITUTION.md`'s approval matrix.
