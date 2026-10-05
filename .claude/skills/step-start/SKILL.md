---
name: step-start
description: Start a workplan step — check preconditions, select a work branch, move the step file to doing/ and commit (REQUIREMENTS-MANAGEMENT.md §5.4 steps 1–3).
argument-hint: <STEP-ID>
disable-model-invocation: true
---

Execute REQUIREMENTS-MANAGEMENT.md §5.4 steps 1–3 for: $ARGUMENTS

1. Check preconditions (in `todo/`, `depends_on` all in `done/`, WIP ≤ 2
   counted across `development` and the open work branches, not cancelled).
   If one fails, report and stop.
2. Work branch per AGENTS.md §1:
   - `CLAUDE_CODE_REMOTE=true` → create `claude/<STEP-ID>-<slug>` (command below)
   - local, current branch not `main`/`development` → stay on it
   - local, on a protected branch → **ask the user** for a branch name, then
     create it with the same command.

   ```sh
   git fetch origin development:refs/remotes/origin/development && \
   git switch -c <branch> --no-track origin/development
   ```

   If the fetch fails, stop and tell the user that `development` (README
   step 1) does not exist yet; do not fall back to `main`.
3. `git mv workplan/todo/<file> workplan/doing/`, commit `[<STEP-ID>] start`.

Then summarize the step's Goal and Definition of done, and begin implementing
only if the user asked for it.
