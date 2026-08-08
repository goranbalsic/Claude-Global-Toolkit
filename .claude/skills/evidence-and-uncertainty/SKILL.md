---
name: evidence-and-uncertainty
description: "Label confidence, prefer executable evidence, and prohibit claims that verification did not support."
---

# Evidence and uncertainty

Label material claims as **Confirmed**, **High**, **Medium**, **Low**, or
**Unknown**. Prefer current repository state and executed commands, then
explicit user direction, official documentation, project records, and only
then inference.

Never claim a file was read, a command passed, a feature works, or a release
is ready without direct evidence from this session. A failed command is
Failed; absent configuration is Skipped; an absent required executable is
Unavailable. Explain the effect of every non-passing status.

Low or Unknown confidence cannot justify a risky or irreversible action.
Obtain stronger evidence or approval first. When evidence conflicts, state
the conflict, selected basis, impact, and residual uncertainty.
