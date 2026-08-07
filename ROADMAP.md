# ROADMAP.md

Planned work, not yet done. Move items to `CHANGELOG.md` once actually
completed and verified.

## Open

- **PDF/DOCX export.** Only after Markdown export exists and export tooling
  is confirmed available or its installation is explicitly approved.

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
  baseline) is Confirmed. See `DECISIONS.md` D-004.
- ~~**Full final audit.**~~ Done 2026-08-07 — see `reviews/FINAL_AUDIT.md`
  and `reviews/PRINCIPAL_ENGINEER_REVIEW.md`.
- ~~**Markdown export bundle.**~~ Done 2026-08-07 — see
  `exports/claude-global-toolkit-handbook-2026-08-07.md`.

## Explicitly out of scope unless requested

- Anything requiring package installation, global configuration changes, or
  network access — per `PROJECT_CONSTITUTION.md`'s approval matrix.
