---
title: Investigation
use_when: Before making non-trivial changes, to establish ground truth about current behavior
related: chapters/03-phase0-investigation.md, templates/investigation.md
---

# Prompt: Investigation

```
Investigate <area/feature/bug> before proposing any change:

1. Locate and read the relevant files, configuration, and tests. Quote or
   cite exact locations (file:line) for claims you make.
2. Trace actual current behavior — run the code/tests/build if possible
   rather than inferring from reading alone.
3. Identify related prior decisions in DECISIONS.md and any conflicting or
   superseding context in PROJECT_STATUS.md or ROADMAP.md.
4. List what you confirmed, what remains assumed, and the confidence level
   (Confirmed/High/Medium/Low/Unknown) for each open question.
5. Do not propose a fix or change yet — this is investigation only. Write
   findings using templates/investigation.md.
```
