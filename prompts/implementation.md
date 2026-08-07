---
title: Implementation
use_when: Executing an already-agreed plan
related: chapters/01-daily-operating-loop.md (step 6, Implement)
---

# Prompt: Implementation

```
Implement the agreed plan for <task>:

1. Make the minimal coherent change that satisfies the acceptance criteria —
   no unrequested refactors, abstractions, or extra features bundled in.
2. Follow existing conventions in the surrounding code/docs rather than
   introducing a new style.
3. Do not create a new major component (service, module, dependency,
   pipeline) beyond what the plan called for without pausing to propose it
   first.
4. After each bounded step, verify per the plan's verification commands
   before moving to the next step.
5. If you discover the plan was wrong or incomplete mid-implementation,
   pause, state what changed, and get the plan corrected rather than
   silently improvising a larger change.
```
