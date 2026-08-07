# Release checklist

Before publish/commit/push/deploy (all of which require explicit approval
per `PROJECT_CONSTITUTION.md`'s approval matrix):

- [ ] Full verification suite run and reported (`templates/verification.md`).
- [ ] `CHANGELOG.md` updated with what's actually shipping.
- [ ] `PROJECT_STATUS.md` reflects the state at release, not mid-work state.
- [ ] Repository health check run (`chapters/05-repository-health-check.md`)
      and its findings resolved or explicitly deferred with reason.
- [ ] No uncommitted, unrelated, or accidental changes bundled in.
- [ ] Secrets/credentials scan clean.
- [ ] Rollback path confirmed and stated, not assumed.
- [ ] Explicit user approval obtained for the release action itself — this
      checklist doesn't substitute for asking.
