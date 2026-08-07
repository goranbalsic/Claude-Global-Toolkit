# Security checklist

Before shipping a security-relevant change (see `prompts/security-review.md`):

- [ ] Input at trust boundaries validated; no unsafe string-built commands,
      queries, or templates (injection risk).
- [ ] No hardcoded secrets, keys, or credentials; none logged.
- [ ] Authentication/authorization checked on every new/changed path that
      needs it, including indirect ones.
- [ ] Dependency changes checked for known-vulnerable versions.
- [ ] Error messages don't leak sensitive internals to untrusted users.
- [ ] File/path handling checked for traversal risk if user input reaches a
      filesystem path.
- [ ] Findings labeled by real exploitability, with a concrete failure
      scenario — not generic pattern-matching.
- [ ] Nothing installed, no permissions/hooks/MCP servers altered, without
      explicit approval.
