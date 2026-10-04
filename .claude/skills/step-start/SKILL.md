---
name: step-start
description: Start a workplan step — check preconditions, select a work branch, move the step file to doing/ and commit (REQUIREMENTS-MANAGEMENT.md §5.4 steps 1–3).
argument-hint: <STEP-ID>
---

Execute REQUIREMENTS-MANAGEMENT.md §5.4 steps 1–3 for: $ARGUMENTS

1. Check preconditions (in `todo/`, `depends_on` all in `done/`, WIP ≤ 2,
   not cancelled). If one fails, report and stop.
2. Work branch per AGENTS.md §1:
   - `CLAUDE_CODE_REMOTE=true` → `git switch -c claude/<STEP-ID>-<slug> development`
   - local, current branch not `main`/`development` → stay on it
   - local, on a protected branch → **ask the user** for a branch name.
3. `git mv workplan/todo/<file> workplan/doing/`, commit `[<STEP-ID>] start`.

Then summarize the step's Goal and Definition of done, and begin implementing
only if the user asked for it.
