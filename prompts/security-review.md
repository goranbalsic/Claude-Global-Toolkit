---
title: Security review
use_when: Reviewing changes or an area of code for security issues
related: checklists/security.md
---

# Prompt: Security review

```
Review <change/area> for security issues:

1. Check for injection risks (command, SQL, template, XSS), unsafe
   deserialization, path traversal, and unchecked external input at trust
   boundaries.
2. Check secrets handling: no hardcoded credentials/keys/tokens, no secrets
   logged or committed.
3. Check authentication/authorization logic for bypasses, especially around
   changed code paths.
4. Check dependency changes for known-vulnerable versions if a manifest
   changed.
5. Distinguish exploitable findings from theoretical/defense-in-depth
   suggestions — label severity and give a concrete failure scenario for
   each exploitable finding, not just a description of the pattern.
6. Do not fabricate a "no issues found" conclusion without having actually
   inspected the relevant code paths — list exactly what was checked.
```
