---
name: trace-regenerate
description: Regenerate requirements/TRACE.md from a fresh scan of requirements, steps and implements/verifies tags, applying evidence-based status transitions (REQUIREMENTS-MANAGEMENT.md §4.3).
---

Execute REQUIREMENTS-MANAGEMENT.md §4.3 literally, steps 1–7.

- Scan roots come from §4.2 (code root, test root, "also scanned").
- Only apply the transitions §3.2 marks "during §4.3"; disappeared evidence
  → `needs-reverify`, flagged loudly.
- Keep only the last 5 generation stamps in TRACE.md.
- Run the test suite (`./dev test` or the project's command) before marking
  anything `verified`; if tests cannot run, say so and do not promote.
- Report the summary in chat. Commit only on a non-protected branch
  (AGENTS.md §1).
