---
name: trace-regenerate
description: Regenerate requirements/TRACE.md from a fresh scan of requirements, steps and implements/verifies tags, applying evidence-based status transitions (REQUIREMENTS-MANAGEMENT.md §4.3).
---

Execute REQUIREMENTS-MANAGEMENT.md §4.3 literally, steps 1–7.

- Steps 1–4: `python3 scripts/trace.py --coverage`. It also lists the
  transitions the evidence supports; it never edits a REQ.
- Step 5: only apply the transitions §3.2 marks "during §4.3"; disappeared
  evidence → `needs-reverify`, flagged loudly.
- Step 6: `python3 scripts/trace.py` writes TRACE.md. Never edit it by hand.
- Run the test suite (`./dev test` or the project's command) before marking
  anything `verified`; if tests cannot run, say so and do not promote.
- Report the summary in chat. Commit only on a non-protected branch
  (AGENTS.md §1).
