# agent-work-template

A language- and platform-neutral repository template for **agent-assisted
development**: requirements with traceability, a folder-based workplan,
architecture and known-issues records, and git rules for coding agents
(Claude Code and others) that are written down and enforced.

> Replace this README with the project's own once adopted — keep the
> "Documentation" and "Developer workflow" sections.

## What you get

- **Agent rules:** [AGENTS.md](AGENTS.md) (any agent) and
  [CLAUDE.md](CLAUDE.md) + [.claude/](.claude/) (Claude Code settings and
  skills).
- **Git rules, enforced:** agents never commit, merge or push on `main` /
  `development`. Agent commit messages are short and never mention the agent.
  Agents push only on explicit request, except their own `claude/*` branches
  in cloud sessions. See [docs/GIT-WORKFLOW.md](docs/GIT-WORKFLOW.md).
- **Process:** [REQUIREMENTS-MANAGEMENT.md](REQUIREMENTS-MANAGEMENT.md) —
  requirements (`requirements/`), workplan steps (`workplan/todo|doing|done`),
  `implements:` / `verifies:` tags, a generated trace matrix, and impact
  analysis.
- **Skeletons:** [ARCHITECTURE.md](ARCHITECTURE.md),
  [KNOWN-ISSUES.md](KNOWN-ISSUES.md), [tests/README.md](tests/README.md),
  the `./dev` / `dev.ps1` task runner, CI, and PR/issue templates.

## Adopting the template

1. Create the repository from this template, then create a `development`
   branch from `main` and push both.
2. Run `sh scripts/setup.sh` (or `scripts/setup.ps1` on Windows) to enable
   the git hooks. Claude Code does this automatically at session start.
   On Windows, git does not record the executable bit: when adding a new
   hook or script, run
   `git update-index --chmod=+x <file>` before committing (`scripts/setup.ps1`
   does this for the shipped ones), otherwise Linux/macOS clones and CI
   skip the hook.
3. Fill in every `SETUP` marker: `grep -rn SETUP --exclude-dir=.git .`
   - REQUIREMENTS-MANAGEMENT.md: project name, area codes, code/test roots,
     ground-truth sources (§8).
   - ARCHITECTURE.md: TLDR, decisions, context, components, milestones.
   - `dev` / `dev.ps1`, `.github/workflows/ci.yml`, `.gitignore`,
     `.env.example`, `tests/README.md`.
   - `.githooks/_agent.sh`: protected branches, cloud branch prefix,
     forbidden-message pattern (only if the defaults don't fit).
4. Put the original brief in `requirements/start_point/`.
5. Review and approve (or reject) the seed requirements
   `REQ-BUILD-001` and `REQ-BUILD-002`.
6. Configure branch protection for `main` and `development`
   ([docs/GIT-WORKFLOW.md](docs/GIT-WORKFLOW.md#recommended-server-side-protection-github)).
7. Ask the agent to draft requirements and decompose milestone M1.

## Developer workflow

```sh
./dev setup        # enable git hooks
./dev build
./dev test [unit|integration|disruptive|all]
./dev check
./dev ci           # what CI runs
```

On Windows, use `./dev.ps1` with the same commands. Local settings and
secrets go in a git-ignored `.env` (see `.env.example`).

## Layout

```
AGENTS.md                    rules for any coding agent
CLAUDE.md                    Claude Code specifics (imports AGENTS.md)
ARCHITECTURE.md              what is built: decisions, components, milestones
REQUIREMENTS-MANAGEMENT.md   how work is tracked (procedures)
KNOWN-ISSUES.md              defects, workarounds, ruled-out causes
.claude/                     Claude Code settings and skills
.githooks/                   agent git-rule enforcement (POSIX sh)
.github/                     CI, PR and issue templates
dev, dev.ps1                 task runner skeleton
docs/                        documentation; GIT-WORKFLOW.md
requirements/                REQ files, TEMPLATE.md, generated TRACE.md, start_point/
scripts/                     setup and hook self-test
tests/                       test tiers (README.md)
workplan/                    TEMPLATE.md, todo/ doing/ done/
```

## License

See [LICENSE](LICENSE).
