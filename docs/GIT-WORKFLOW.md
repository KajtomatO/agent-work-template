# Git workflow

## Branch model

```
main          ← releases only; updated by a human from development (PR)
development   ← integration branch; updated by a human merging work branches (PR)
<work branch> ← where all changes are made, by humans or agents
```

- Work branches start from `development`. Agents in a cloud session name them
  `claude/<STEP-ID>-<slug>`; locally the agent uses the current non-protected
  branch, or asks the user for a name.
- A work branch may cover one step or several; its PR into `development`
  carries the step's evidence (see the PR template).
- Step bookkeeping (`git mv` between `workplan/todo|doing|done`, the
  `[STEP-<ID>] start` / `done` commits) happens on the work branch and lands
  in `development` with the merge.

## Rules for agents

| | `main`, `development` | other branches |
|---|---|---|
| commit | never | allowed |
| merge into / rebase / reset / force-update | never | allowed |
| push | never | only on explicit user request; in a cloud session, own `claude/*` branches without asking |

Commit messages: short (subject ≤ 72 characters), no reference to the agent or
tooling (no "Claude"/"AI"/"agent", no `Co-Authored-By`, no "Generated with").
Prefixes per REQUIREMENTS-MANAGEMENT.md §4.2.

**Cloud session** means the agent runs in a temporary container rather than on
a user's machine. It is detected by `CLAUDE_CODE_REMOTE=true` (set by Claude
Code on the web). Pushing is what makes work in such a container survive.

## Enforcement layers

| Layer | Covers | Where |
|---|---|---|
| Instructions | everything above | `AGENTS.md`, `CLAUDE.md` |
| Agent settings | no attribution; confirm each `git push`; no `--no-verify` / hooksPath changes | `.claude/settings.json` |
| Git hooks (client) | agent commit/merge on protected branches, agent message content and length, agent push rules | `.githooks/` |
| Branch protection (server) | everything a client hook cannot see — the authoritative backstop | GitHub settings, below |

### Git hooks

Enabled by `scripts/setup.sh` / `scripts/setup.ps1`
(`git config core.hooksPath .githooks`); Claude Code runs the setup
automatically at session start. Hooks only act when an agent is detected —
`CLAUDECODE=1` (set by Claude Code) or `AGENT_SESSION=1` (export it for other
agents). **Humans are never restricted.**

| Hook | Blocks (agents only) |
|---|---|
| `pre-commit` | commits on protected branches (also mid-rebase) |
| `pre-merge-commit` | merge commits on protected branches |
| `commit-msg` | subject > 72 chars; message matching the forbidden pattern |
| `pre-push` | any push to a protected branch; any other push unless `AGENT_PUSH_APPROVED=1`, or cloud + `claude/*` |

Tunables (protected list, cloud prefix, forbidden pattern, subject length)
are at the top of `.githooks/_agent.sh`. Self-test: `sh scripts/test-hooks.sh`
(also run in CI).

**Known client-side gaps:** fast-forward merges, `reset`, `branch -f` and
`update-ref` do not run hooks; an agent could also unset the environment
variables. Treat hooks as guard rails against mistakes, and server-side
protection as the real boundary.

### Recommended server-side protection (GitHub)

Settings → Rules → Rulesets (or Branches → Branch protection), targeting
`main` and `development`:

- Require a pull request before merging (≥ 1 approval for `main`; consider
  the same for `development`).
- Block force pushes; restrict deletions.
- Require status checks: the `ci` workflow.
- Optionally: require linear history; restrict who may push to `main`.
- Do not grant agent tokens/apps bypass permissions. If an agent pushes with
  its own token (e.g. Claude Code on the web via a GitHub app), restrict that
  identity to `claude/*` branches if your plan supports push restrictions.

### Human bypass

Humans are not affected by the hooks. If one is ever in the way,
`git commit --no-verify` / `git push --no-verify` skips it — agents must never
do this.
