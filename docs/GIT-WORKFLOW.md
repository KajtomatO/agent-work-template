# Git workflow

## Branch model

```
main          ← releases only; updated by a human from development (PR)
development   ← integration branch; updated by a human merging work branches (PR)
<work branch> ← where all changes are made, by humans or agents
```

- Work branches start from `development`. Agents in a cloud session name them
  `claude/<STEP-ID>-<slug>`; locally the agent uses the current non-protected
  branch, or asks the user for a name. A fresh clone has `development` only
  as `origin/development`, so a new work branch is created with
  `git fetch origin development:refs/remotes/origin/development && git switch -c <branch> --no-track origin/development`.
  If that fetch fails, `development` does not exist yet (README step 1): the
  agent stops and says so instead of branching from `main`.
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
| push | never | only on explicit user request; in a cloud session, own `claude/*` branches without asking (create or fast-forward only) |

Commit messages: short (subject ≤ 72 characters), no reference to the agent or
tooling. The word list is in AGENTS.md §1; the `commit-msg` hook enforces the
subset in `FORBIDDEN_MSG_RE`. Prefixes per REQUIREMENTS-MANAGEMENT.md §4.2.

Pull requests: an agent opens one only when the user asks, and never merges,
approves or enables auto-merge.

**Cloud session** means the agent runs in a temporary container rather than on
a user's machine. It is detected by `CLAUDE_CODE_REMOTE=true` (set by Claude
Code on the web). Pushing is what makes work in such a container survive.

How a push is gated in Claude Code:

- Every `git push` raises Claude Code's permission prompt (`permissions.ask`);
  that prompt is the user's confirmation.
- In a cloud session a `PermissionRequest` hook answers the prompt for a
  plain push, so nobody has to be present. The `pre-push` hook then allows it
  only if it creates or fast-forwards a `claude/*` branch.
- A push carrying `AGENT_PUSH_APPROVED=1` (a force-push, a deletion, another
  branch) is never answered automatically: it waits for the user, also in a
  cloud session.
- A cloud session that spans several repositories reads no project settings,
  so neither the prompt nor the hook above exists there and
  `scripts/setup.sh` has to be run by hand; the `pre-push` hook is then the
  only gate.

## Enforcement layers

| Layer | Covers | Where |
|---|---|---|
| Instructions | everything above | `AGENTS.md`, `CLAUDE.md` |
| Agent settings (Claude Code only) | no attribution or session trailer; confirm each `git push`, PR creation and edit to an enforcement file; deny the usual hook-bypass spellings, API writes to the repository and `.env` reads | `.claude/settings.json` |
| Git hooks (client) | agent commit, merge, rebase, cherry-pick, revert and `am` on protected branches; agent message content and length; agent push rules | `.githooks/` |
| Branch protection (server) | everything a client hook cannot see — the authoritative backstop | GitHub settings, below |

### Git hooks

Enabled by `scripts/setup.sh` / `scripts/setup.ps1`
(`git config core.hooksPath .githooks`); Claude Code runs the setup
automatically at session start. Hooks only act when an agent is detected:
`CLAUDECODE=1` (set by Claude Code), `GEMINI_CLI=1` (set by Gemini CLI) or
`AGENT_SESSION=1` (set in the environment of any other agent, see AGENTS.md).
**Humans are never restricted.**

| Hook | Blocks (agents only) |
|---|---|
| `pre-commit` | commits on protected branches (also `git commit` during a rebase stop) |
| `prepare-commit-msg` | the same for `cherry-pick`, `revert` and `commit --no-verify`, which skip `pre-commit` |
| `pre-applypatch` | the same for `git am` |
| `pre-merge-commit` | merge commits on protected branches |
| `pre-rebase` | rebasing a protected branch |
| `commit-msg` | subject > 72 characters; message matching the forbidden pattern |
| `pre-push` | any ref that is not a branch (tags); any push to a protected branch; any other push unless `AGENT_PUSH_APPROVED=1`, or cloud + creating or fast-forwarding a `claude/*` branch |

Tunables (protected list, cloud prefix, forbidden and allowed patterns,
subject length) are plain assignments at the top of `.githooks/_agent.sh`.
Edit the file to change them; they are deliberately not read from the
environment. Entries of the protected list are shell patterns (`release/*`).
Self-test: `sh scripts/test-hooks.sh` (also run in CI).

**Message scan.** `commit-msg` checks the message as git will store it
(comment lines and the `commit -v` diff are dropped first). Harmless mentions
are removed before the scan: `AGENTS.md`, `CLAUDE.md`, `.claude/…` paths,
`claude/*` branch names, `User-Agent` and REQ/STEP ids, so git's default merge
subject (`Merge branch 'development' into claude/…`) passes. A `fixup!`,
`squash!` or `amend!` subject repeats another commit's subject and is not
checked; the body is. `merge --squash` and `merge --log` copy other people's
subjects into the message: if that text trips the scan, write the message by
hand with `-m`.

**Known client-side gaps.** The hooks are guard rails against mistakes, not a
boundary:

- No hook runs for fast-forward merges and pulls, `reset`, `switch -C`,
  `branch -f`, `update-ref` and other plumbing.
- `cherry-pick` and `revert` skip `commit-msg`, so their messages (also with
  `-e`) are not scanned.
- A message line passed with `-m` that starts with the comment character
  (`-m "# …"`) is stored by git but not scanned.
- A linked worktree checked out at a commit without `.githooks/` runs no hooks
  and prints no warning.
- An agent could leave the rules behind: unset the detection variables
  (`unset`, `env -u`), point git elsewhere (`git -c core.hooksPath=…`,
  `GIT_CONFIG_*`), or edit the hooks. `.claude/settings.json` denies the usual
  spellings and asks before a hook is edited, but a Bash rule matches the
  command text, not what the command does; a `PreToolUse` hook that inspects
  the whole command is the stricter client-side option. The hook self-test in
  CI is what detects an edited hook.
- Writes through the hosting API (GitHub MCP tools, `gh api`) never run a
  client hook; only server-side rules apply to them. The settings deny the
  file-writing and merge tools for Claude Code.
- The cloud push approval covers the whole shell command: anything chained
  after `git push` in the same command runs without a prompt too.

A `reference-transaction` hook could close the first gap, but it also aborts
`git gc`, `pack-refs` and `maintenance` for agents and blocks recovery
commands, so it is not shipped; add one only with those caveats in mind.
Server-side protection is the real boundary.

### Recommended server-side protection (GitHub)

**Check the plan first.** In a private repository, protected branches need a
paid plan (GitHub Pro for a personal account, Team for an organization; see
[GitHub's plans](https://docs.github.com/en/get-started/learning-about-github/githubs-plans)),
and rulesets follow the same limits. A private repository on GitHub Free
therefore has no server-side layer: the instructions, agent settings and
client hooks above are all there is.

Settings → Rules → Rulesets → New branch ruleset, targeting `main` and
`development`:

- **Require a pull request before merging** (≥ 1 approval for `main`; consider
  the same for `development`).
- **Block force pushes** and **Restrict deletions**.
- **Require status checks to pass**, selected by *job* name:
  `git hooks self-test` and `build & unit tests`. The workflow name `ci` is
  not a check.
  - `git hooks self-test` must be required: it is what detects an edited hook.
  - A job skipped by `if:` reports success and satisfies a required check
    ([GitHub docs](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/using-conditions-to-control-job-execution)),
    so `build & unit tests` protects nothing until the `DEV_CONFIGURED` gate
    is removed from `ci.yml` (README step 3).
- Optionally **Require linear history**, and **Restrict updates** on `main` so
  that only chosen people can push to it.
- **Bypass list: humans only.** Never add the Claude GitHub App, Copilot or
  any other agent identity. If an agent pushes with its own identity, restrict
  that identity to `claude/*` branches where the plan allows.
- Consider a tag ruleset (**Restrict creations** and **Restrict deletions**)
  as well: the hooks refuse agent tag pushes on the client only.

CI runs on pushes to `main` and `development` and on pull requests, so a work
branch is checked once its pull request exists.

### Human bypass

Humans are not affected by the hooks. If one is ever in the way,
`git commit --no-verify` / `git push --no-verify` skips it — agents must never
do this.

Claude Code's IDE extensions export `CLAUDECODE=1` in their integrated
terminals, so a human typing git commands there is treated as an agent. The
hook message says so; run `unset CLAUDECODE` in that terminal.
