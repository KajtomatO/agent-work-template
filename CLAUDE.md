@AGENTS.md

# Claude Code specifics

- `.claude/settings.json`:
  - disables commit/PR attribution and the session-URL trailer;
  - asks before every `git push`, before opening a PR, and before an edit to
    an enforcement file (`.githooks/`, `scripts/setup.*`,
    `scripts/test-hooks.sh`, `.github/workflows/`);
  - blocks the usual hook-bypass spellings, repository writes and PR merges
    through GitHub API tools, and reading `.env`;
  - runs `scripts/setup.sh` when a session starts or resumes, so the git hooks
    are active (also in cloud containers).
- Cloud session = `CLAUDE_CODE_REMOTE=true`. Only there may you push your own
  `claude/*` branches without being asked: the push prompt is answered for
  you, and the pre-push hook lets such a push create or fast-forward the
  branch, nothing else. Everywhere else, and for a force-push or a branch
  deletion anywhere, push only on an explicit request, as
  `AGENT_PUSH_APPROVED=1 git push …`; that form always waits for the user.
- A cloud session that spans several repositories reads none of this
  repository's permission rules or hooks: run `sh scripts/setup.sh` yourself
  there before the first commit.
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

  `/step-start` and `/step-complete` run only when the user types them;
  never start or close a step on your own initiative.

- Personal, machine-specific settings go in `.claude/settings.local.json`,
  personal instructions in `CLAUDE.local.md` (both git-ignored).
