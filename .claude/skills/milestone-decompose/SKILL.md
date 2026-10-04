---
name: milestone-decompose
description: Decompose an ARCHITECTURE.md milestone into workplan steps (rolling wave) per REQUIREMENTS-MANAGEMENT.md §5.3 — propose a step table, stop for approval, then create the step files.
argument-hint: <Mx>
---

Execute REQUIREMENTS-MANAGEMENT.md §5.3 for milestone: $ARGUMENTS

- Step 2: missing coverage → draft REQs first (`/req-draft`), get approval.
- Step 3: propose the table (id, title, implements, depends_on, size) in
  chat, ending with a gate step. **Stop and wait for approval.**
- Step 4 onward only after explicit approval, on a work branch selected per
  AGENTS.md §1 (never `main`/`development`; ask the user for a branch name if
  on one locally).
