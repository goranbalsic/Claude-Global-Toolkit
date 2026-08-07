---
title: Bug fixing
use_when: A specific defect has been reported and needs a root-cause fix
related: chapters/03-phase0-investigation.md, templates/failure.md
---

# Prompt: Bug fixing

```
Fix <bug>:

1. Reproduce the failure first — do not fix based on a guessed cause. If you
   cannot reproduce it, say so explicitly rather than proceeding as if you
   did.
2. Trace to the actual root cause, not just the first symptom. Note where in
   the code the wrong behavior originates.
3. Consider whether this is a narrow bug or a symptom of a broader design
   issue; if broader, flag it as a separate proposal rather than silently
   expanding this fix's scope.
4. Make the minimal fix that addresses the root cause. Do not add unrelated
   defensive code, refactors, or error handling for scenarios that can't
   occur here.
5. Add or update a regression test that would have caught this bug, if the
   repository has a test suite.
6. Verify the original failure no longer reproduces and that existing tests
   still pass. Report exact verification results — do not claim "fixed"
   without having re-run the reproduction.
```
