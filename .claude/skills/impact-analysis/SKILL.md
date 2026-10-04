---
name: impact-analysis
description: Impact analysis for a change to a requirement or ARCHITECTURE.md section — build the affected set and report, then stop for human approval (REQUIREMENTS-MANAGEMENT.md §6.2). Use also before making any §6.1 change yourself.
argument-hint: <REQ-ID or ARCHITECTURE section>
---

Execute REQUIREMENTS-MANAGEMENT.md §6.2 for: $ARGUMENTS

Steps 1–3: identify changed items, build the affected set (anchors,
transitive `depends_on`, steps, tagged code and tests, which steps are
done), write the report with a proposed action per item.

**Step 4: stop.** Apply nothing until a human approves (possibly a trimmed
version). Then steps 5–6 on a non-protected branch (AGENTS.md §1).
