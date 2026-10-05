---
id: REQ-BUILD-002
title: Agent git rules are enforced by versioned hooks
status: draft
priority: must
revision: 2
source: ARCHITECTURE.md §1 (Branching)
depends_on: []
supersedes: null
superseded_by: null
traces:
  architecture: ["ARCHITECTURE.md#1-decisions-fixed"]
---

# Agent git rules are enforced by versioned hooks

The repository SHALL ship git hooks that, when an agent session is detected,
reject the agent operations listed in the acceptance criteria while leaving
human operations unaffected.

**Rationale:** written rules alone are easy to miss; client hooks catch
mistakes early. They see only the operations git runs a hook for
(docs/GIT-WORKFLOW.md, "Known client-side gaps"), so server-side branch
protection remains the authoritative backstop.

**Acceptance criteria:**
- [ ] Agent commits, merge commits, rebases, cherry-picks, reverts and applied
      patches (`git am`) on `main`/`development` are rejected.
- [ ] Agent commit messages referring to the agent/tooling, or with a subject
      over 72 characters, are rejected.
- [ ] Agent pushes to `main`/`development`, and of refs that are not branches
      (tags), are rejected in every session.
- [ ] Other agent pushes are rejected unless `AGENT_PUSH_APPROVED=1`, or the
      session is a cloud session and the push creates or fast-forwards a
      `claude/*` branch.
- [ ] Human commits, merges and pushes are unaffected.
- [ ] `scripts/test-hooks.sh` verifies all of the above and runs in CI.
