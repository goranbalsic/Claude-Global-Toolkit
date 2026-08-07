---
title: Adversarial review
use_when: Independently stress-testing a change or decision before it ships
related: chapters/00-mission-and-authority.md, checklists/completion.md
---

# Prompt: Adversarial review

```
Adversarially review <change/decision> — try to find where it breaks, not
confirm that it works:

1. Assume the implementation is wrong until you find evidence it isn't. Look
   for edge cases, boundary conditions, concurrent/race scenarios, and
   inputs the author likely didn't consider.
2. Check claims against actual evidence: re-read the diff, re-run the
   verification, don't take a prior "tests pass" claim at face value if you
   can re-check it yourself.
3. Check for scope drift: does the change do more, or less, than what was
   requested?
4. Check for silently-dropped error handling, swallowed exceptions, or
   removed validation.
5. State findings as concrete failure scenarios (input/state → wrong
   output/crash), ranked by severity — not vague concerns.
6. If nothing survives scrutiny as a real issue, say so plainly rather than
   inventing a minor finding to seem thorough.
```
