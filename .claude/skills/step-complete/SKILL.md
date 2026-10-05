---
name: step-complete
description: Complete a workplan step — run tests, fill evidence, check the definition of done, move to done/, regenerate the trace matrix (REQUIREMENTS-MANAGEMENT.md §5.4 steps 5–9).
argument-hint: <STEP-ID>
disable-model-invocation: true
---

Execute REQUIREMENTS-MANAGEMENT.md §5.4 steps 5–9 for: $ARGUMENTS

- Run the tests; a failing or unrun suite blocks completion unless
  `evidence.notes` states why the step is untestable.
- `evidence.commits`: short SHAs of the `[<STEP-ID>]` commits
  (`git log --oneline --grep '^\[<STEP-ID>\]'`).
- Every Definition-of-done box must be genuinely satisfied — do not tick
  boxes you have not verified; report what is missing instead.
- `git mv` to `workplan/done/`, commit `[<STEP-ID>] done`, then run §4.3.
- Do not push unless the user asks (or cloud session on your `claude/*`
  branch). Merging into `development` is the human's.
