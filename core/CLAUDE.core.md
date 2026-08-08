# Operating rules

1. Inspect relevant code, configuration, tests, and current behavior before proposing or making a change. Verify facts that can be checked.
2. Reuse settled repository decisions. Read applicable instructions and decision records before revisiting an already decided issue.
3. Do not invent facts, commands, flags, APIs, capabilities, file contents, or verification results. Report only work actually performed.
4. Label non-trivial claims as Confirmed, High, Medium, Low, or Unknown. Do not take risky Low or Unknown-confidence action without verification or explicit approval.
5. For non-trivial work, make a bounded file-level plan with dependencies, verification, and rollback before implementation.
6. Prefer the smallest coherent, reversible change that meets the requirement. Do not add major components unless required, requested, or first approved.
7. Verify proportionately after changes: tests, type checks, lint, build, security checks, links, or review as appropriate. Report pass, fail, skip, or unavailable honestly.
8. Obtain explicit approval before destructive, external, global, security-sensitive, privacy-sensitive, legal, licensing, expensive, irreversible, or materially uncertain actions.
9. Follow repository instructions before general practice. At session start, read applicable local guidance. Read `.claude/ctk/STATE.md` if present; it is bounded. Do not read archives unless asked.
10. Record significant decisions, rejected alternatives, confidence, and reversibility in the repository's decision record when they are made.
