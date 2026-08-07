# Performance checklist

Before claiming a change improves performance, or when performance is a
stated acceptance criterion:

- [ ] Baseline measured before the change, not assumed.
- [ ] Same measurement re-run after the change, same conditions.
- [ ] Claimed improvement backed by the actual before/after numbers, not
      theoretical reasoning alone.
- [ ] No premature optimization introduced without a measured problem to
      justify it (see engineering principles in `PROJECT_CONSTITUTION.md`).
- [ ] Any added caching/memoization/complexity weighed against
      maintainability cost, not just raw speed.
- [ ] Token/execution efficiency considered only after correctness and
      safety are already satisfied, per `chapters/02-evidence-and-uncertainty.md`.
