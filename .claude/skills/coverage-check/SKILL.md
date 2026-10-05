---
name: coverage-check
description: Read-only requirements coverage check — scan requirements, steps and tags and report gaps without writing any file (REQUIREMENTS-MANAGEMENT.md §4.3 read-only variant).
---

Execute REQUIREMENTS-MANAGEMENT.md §4.3 steps 1–4 by running
`python3 scripts/trace.py --coverage`, then report its coverage items and
proposed transitions in chat.

Read-only: write no files, change no statuses, make no commits.
