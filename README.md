# agent-work-template

A language- and platform-neutral repository template for **agent-assisted
development**: requirements with traceability, a folder-based workplan,
architecture and known-issues records, and git rules for coding agents
(Claude Code and others) that are written down and enforced.

> Replace this README with the project's own once adopted — keep the
> "Developer workflow" section and a link to the documentation index,
> [docs/README.md](docs/README.md).

## What you get

- **Agent rules:** [AGENTS.md](AGENTS.md) (any agent),
  [CLAUDE.md](CLAUDE.md) + [.claude/](.claude/) (Claude Code settings and
  skills) and [GEMINI.md](GEMINI.md) (Gemini CLI; imports AGENTS.md).
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
   branch from `main` and push both (or tick *Include all branches* when
   creating it). `.template-version` records the template release you start
   from; [docs/TEMPLATE-UPDATES.md](docs/TEMPLATE-UPDATES.md) shows how to
   pick up later template fixes.
2. Run `sh scripts/setup.sh` (or `scripts/setup.ps1` on Windows) to enable
   the git hooks. Claude Code does this automatically at session start (on
   Windows that hook needs Git Bash, i.e. `sh` on PATH).
   - Windows PowerShell 5.1 runs no scripts by default: use
     `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup.ps1`,
     or allow local scripts once with
     `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.
   - On Windows, git does not record the executable bit: after adding a new
     hook or script, `git add` it and run `scripts/setup.ps1` again (it marks
     every tracked hook and script; `git update-index --chmod=+x <file>` does
     one file), otherwise Linux/macOS clones and CI skip the hook.
   - Agents other than Claude Code and Gemini CLI are recognised only when
     `AGENT_SESSION=1` is set in the tool's environment. Verify it: on a work
     branch, have the agent run `git commit --allow-empty -m "AI test"`. It
     must be refused with "BLOCKED by git hook". If the commit goes through,
     remove it (`git reset --soft HEAD~1`) and fix the tool's environment.
3. Fill in every `SETUP:` marker. `sh scripts/check-setup.sh` lists the ones
   that are left (and the bare `<project-name>`, `<Decision>` and
   `<PROJECT>_` placeholders) and exits 0 when none is; `./dev check` runs it.
   - REQUIREMENTS-MANAGEMENT.md: project name, area codes, code/test roots
     (also the constants at the top of `scripts/trace.py`), ground-truth
     sources (§8).
   - ARCHITECTURE.md: TLDR, decisions, context, components, milestones.
   - `dev` / `dev.ps1`, `.github/workflows/ci.yml`, `.gitignore`,
     `.env.example`, `tests/README.md`, `SECURITY.md`.
   - CI: the `build & unit tests` job is skipped until the repository variable
     `DEV_CONFIGURED` is `true` (Settings → Secrets and variables → Actions →
     Variables). Until then CI is green while `./dev ci` stops at the
     unconfigured build. Set the variable once `./dev build`, `check` and
     `test` work, then delete the `if:` line in `ci.yml`.
   - Optional: the `TUNABLE:` values at the top of `.githooks/_agent.sh`
     (protected branches, cloud branch prefix, message patterns), only if the
     defaults don't fit. They are permanent knobs, not setup markers.
4. Replace the files that describe the template itself: this `README.md`,
   `CHANGELOG.md` and `LICENSE`. The licence file carries the template
   author's copyright: put the project's own licence there and keep the
   template's MIT notice for the template files (for example as
   `LICENSE.template`). `docs/REVIEW-*.md` is the template's own review record
   and can be deleted.
5. Put the original brief in `requirements/start_point/`.
6. Review and approve (or reject) the seed requirements
   `REQ-BUILD-001` and `REQ-BUILD-002`. They are deliberately coarse (each
   bundles several obligations); split them if you want them atomic.
7. Configure branch protection for `main` and `development`
   ([docs/GIT-WORKFLOW.md](docs/GIT-WORKFLOW.md#recommended-server-side-protection-github)),
   and create the `requirement` issue label: GitHub silently drops the label
   of an issue template when it does not exist.
8. Ask the agent to draft requirements and decompose milestone M1.

## Developer workflow

```sh
./dev setup        # enable git hooks
./dev build
./dev test [unit|integration|disruptive|all]
./dev check
./dev trace        # regenerate requirements/TRACE.md (--coverage: report only)
./dev ci           # what CI runs
```

On Windows, use `./dev.ps1` with the same commands. `./dev trace` needs
Python 3 (standard library only). Local settings and secrets go in a
git-ignored `.env` (see `.env.example`).

## Layout

```
AGENTS.md                    rules for any coding agent
CLAUDE.md, GEMINI.md         tool specifics (both import AGENTS.md)
ARCHITECTURE.md              what is built: decisions, components, milestones
REQUIREMENTS-MANAGEMENT.md   how work is tracked (procedures)
KNOWN-ISSUES.md              defects, workarounds, ruled-out causes
CONTRIBUTING.md, SECURITY.md pointers for contributors; vulnerability reports
CHANGELOG.md                 template releases (replace on adoption)
LICENSE                      template licence (replace on adoption)
.template-version            template release this repository started from
.claude/                     Claude Code settings and skills
.githooks/                   agent git-rule enforcement (POSIX sh)
.github/                     CI, Dependabot, PR and issue templates
.env.example                 variables read from the git-ignored .env
.gitattributes, .editorconfig  line endings and indentation
.gitignore                   local settings, secrets, editor and OS files
dev, dev.ps1                 task runner skeleton
docs/                        documentation index; GIT-WORKFLOW.md, TEMPLATE-UPDATES.md
requirements/                REQ files, TEMPLATE.md, generated TRACE.md, start_point/
scripts/                     setup, hook self-test, trace matrix, setup check
tests/                       test tiers (README.md)
workplan/                    TEMPLATE.md, todo/ doing/ done/
```

## License

See [LICENSE](LICENSE).
