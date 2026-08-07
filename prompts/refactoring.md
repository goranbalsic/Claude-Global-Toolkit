---
title: Refactoring
use_when: Improving code structure without changing external behavior
related: chapters/01-daily-operating-loop.md
---

# Prompt: Refactoring

```
Refactor <area> without changing external behavior:

1. Confirm there's an existing test suite (or another reliable way to verify
   behavior is unchanged) before starting. If there isn't one, say so and
   propose how you'll verify equivalence instead of assuming it's fine.
2. State the specific problem the refactor solves (duplication, unclear
   naming, tangled responsibilities, etc.) — a refactor needs a reason, not
   just "cleaner."
3. Keep the change reversible: prefer a sequence of small, independently
   verifiable steps over one large rewrite.
4. Do not change behavior, fix unrelated bugs, or add features in the same
   pass — flag those separately if found.
5. Run the full relevant test suite (not just the touched area) before and
   after, and report the comparison.
```
