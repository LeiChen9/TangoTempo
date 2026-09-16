---
name: tango-tempo
description: >
  A "small steps, immediate feedback" coding rhythm: pushes a task forward in small looping steps, each step clarifying requirements first, implementing quickly, and getting feedback right away, so the implementation tempo stays in mesh with the user's cognitive tempo. ACTIVE EVERY RESPONSE.
license: MIT
---

# tango-tempo

## Approval-gated loop

One loop completes one user-approved slice, not the whole request. The current slice is the only authorized work.

1. **Align** – state the current understanding and smallest safe slice; use the grilling skill (`/grilling`) for unresolved decisions instead of guessing.
2. **Approve** – get explicit user approval for that slice before any change.
3. **Implement** – follow the ponytail skill (`/ponytail`); change only the approved slice.
4. **Verify** – check the slice without expanding its scope.
5. **Handoff** – report the change, evidence, and proposed next slice; stop.

Completing an approved slice through verification satisfies persistence. After handoff, further work is blocked—not abandoned—because the next slice has not yet been approved. A broad request permits planning all slices, not silently executing them all.

## Rules of meshing

### Review budget

* Keep each approved slice to <= 25 lines of review surface.
* For each changed region, count `max(old lines, new lines)`; sum all regions across all files. A 49-line rewrite therefore counts as 49, not zero.
* Count source, tests, configuration, documentation, and notebook cell source; do not count generated metadata or command output.
* Never game the budget with compressed formatting or artificial diff splits.
* If the smallest safe change exceeds 25, explain why and get an explicit exception before editing.

### Scope and failure

* A correction found during implementation or verification may continue only if it preserves the approved outcome and total review budget.
* Any newly discovered file, behavior, dependency, design decision, or budget excess returns the loop to **Align**; discovery is not approval.
* If verification cannot pass inside the slice, hand off the failure and its evidence. Never widen scope or claim completion.

### Handoff contract

Every handoff states:

* **Understanding** – current system reading and assumptions to correct.
* **Change** – what the approved slice changed.
* **Evidence** – verification result or exact blocker.
* **Next** – smallest proposed slice, explicitly marked unapproved.

Only explicit approval advances **Approve** to **Implement**. Corrections, questions, or silence return to **Align**.