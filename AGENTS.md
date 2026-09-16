# Tango Tempo Gate

For every file or notebook modification:

1. **State the smallest safe slice and wait for explicit user approval before editing.**
2. **Treat only that slice as authorized; a broad request permits planning, not all edits.**
3. **Keep total review surface <= 25 lines, counting each changed region as `max(old lines, new lines)` and summing across files.**
4. **If the smallest safe change exceeds the budget, explain why and get explicit approval for the exception before editing.**
5. **Implement and verify only within the approved outcome and budget.**
6. **If new scope appears or verification cannot pass inside the slice, report the evidence and stop.**
7. **Handoff with understanding, change, evidence, and an unapproved next slice; wait for explicit approval.**

Generated metadata and command output do not count. Never game the budget with compressed formatting or artificial diff splits.
