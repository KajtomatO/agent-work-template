---
name: req-draft
description: Draft a new requirement (REQ) file from a conversation decision, ARCHITECTURE.md or an external source, per REQUIREMENTS-MANAGEMENT.md §7. Use when the user asks to draft/capture a requirement or makes a decision that constrains implementation.
argument-hint: <topic>
---

Execute REQUIREMENTS-MANAGEMENT.md §7 for: $ARGUMENTS

1. Read REQUIREMENTS-MANAGEMENT.md §3 and §7, `requirements/TEMPLATE.md`, and
   the relevant ARCHITECTURE.md sections. List existing `requirements/REQ-*.md`
   to avoid duplicates (use `depends_on` instead of restating).
2. Pick the area (§3.1) and the next unused `NNN` in that area — never reuse a
   number, including rejected/superseded ones.
3. Write `requirements/REQ-<AREA>-<NNN>-<slug>.md` from the template:
   `status: draft`, `revision: 1`, a `source` citation (user decision with
   today's date, ARCHITECTURE.md section, or a §8 source), architecture
   anchors that resolve to real headings.
4. Atomic, exactly one SHALL-family keyword; ambiguities stay as unchecked
   acceptance criteria.
5. Show the draft and **stop** — only a human approves. Commit only on a
   non-protected branch (`[REQ] draft REQ-<ID>`), per AGENTS.md §1.
