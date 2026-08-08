---
name: safe-changes
description: "Make minimal reversible changes and stop for approval before consequential actions."
---

# Safe changes

Inspect before editing. Change only files required for the stated acceptance
criteria, preserve local conventions, and prefer small independently
verifiable batches. Do not add dependencies, broad refactors, or new major
components without a stated need and approval.

For each batch, identify a concrete verification command and rollback path.
If evidence shows the plan is wrong, stop and revise it rather than expanding
scope silently.

Require explicit approval before deletion, external publication, commit,
push, tag, deploy, package installation, permission or hook changes, secret
handling, spending, or any irreversible/high-impact action. Never print,
commit, or copy credentials into reports.
