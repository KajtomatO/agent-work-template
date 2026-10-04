---
id: REQ-BUILD-001
title: Developer task runner mirrors CI
status: draft
priority: should
revision: 1
source: template default (agent-work-template)
depends_on: []
supersedes: null
superseded_by: null
traces:
  architecture: ["ARCHITECTURE.md#5-testing-policy"]
---

# Developer task runner mirrors CI

The repository SHOULD provide a `./dev` task runner (with a Windows
equivalent) whose `ci` command runs the same checks, in the same order, as
the CI workflow.

**Rationale:** one entry point for humans and agents; "green locally" then
means "green in CI". The runner stays thin and optional — it echoes every
command it executes so the plain commands remain discoverable.

**Acceptance criteria:**
- [ ] `./dev help` and `./dev.ps1 help` list `setup`, `build`, `test`, `check`, `ci`.
- [ ] `./dev ci` runs the same steps as `.github/workflows/ci.yml`.
- [ ] Each executed command is echoed before it runs; exit codes propagate.
- [ ] A git-ignored `.env` is loaded when present.
