@AGENTS.md

# Claude Code specifics

- `.claude/settings.json` disables commit/PR attribution, asks before every
  `git push`, forbids hook bypasses, and runs `scripts/setup.sh` at session
  start so the git hooks are active (also in cloud containers).
- Cloud session = `CLAUDE_CODE_REMOTE=true`. Only there may you push your own
  `claude/*` branches without being asked. Everywhere else, push only on an
  explicit request, as `AGENT_PUSH_APPROVED=1 git push …`.
- Standing commands are available as skills (each executes a PROCEDURE in
  REQUIREMENTS-MANAGEMENT.md):

  | Skill | Does |
  |---|---|
  | `/req-draft <topic>` | draft a requirement (§7) |
  | `/trace-regenerate` | regenerate `requirements/TRACE.md` (§4.3) |
  | `/coverage-check` | read-only coverage check (§4.3 variant) |
  | `/milestone-decompose <Mx>` | propose and create steps (§5.3) |
  | `/step-start <STEP-ID>` | start a step (§5.4 steps 1–3) |
  | `/step-complete <STEP-ID>` | close a step with evidence (§5.4 steps 5–9) |
  | `/impact-analysis <REQ-ID or section>` | impact report, then stop (§6.2) |

- Personal, machine-specific settings go in `.claude/settings.local.json`
  (git-ignored).
