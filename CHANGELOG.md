# Changelog (template)

Releases of `agent-work-template`. A project created from the template
records the release it started from in `.template-version`;
[docs/TEMPLATE-UPDATES.md](docs/TEMPLATE-UPDATES.md) shows how to carry later
releases over. On adoption, replace this file with the project's own
changelog.

## 0.2.0 (2026-10-04)

Implements the repository review in `docs/REVIEW-2026-10-04.md`.

- **Hooks:** word-bounded message pattern with an allow-list; tunables are no
  longer read from the environment; only branches can be pushed, and unasked
  cloud pushes only create or fast-forward; new `pre-rebase`,
  `prepare-commit-msg` and `pre-applypatch`; protected-branch patterns;
  self-test grows from 28 to 79 cases.
- **Process:** `scripts/trace.py` generates and checks
  `requirements/TRACE.md`; work branches are created from
  `origin/development`; the scan covers `.githooks/` and `scripts/`;
  `scripts/check-setup.sh` lists the markers still to fill in.
- **Task runner and CI:** `dev.ps1` fixes; `.env` is parsed, not executed;
  read-only CI token, pinned checkout, Windows job, Dependabot.
- **Claude Code settings:** no session-URL trailer, wider deny list, `.env`
  read deny, prompts for edits to enforcement files, unattended cloud pushes
  of work branches.
- **Adoption:** `.template-version`, this changelog, the update recipe,
  `CONTRIBUTING.md`, `SECURITY.md`, `.editorconfig`, `GEMINI.md`.

## 0.1.0 (2026-10-04)

First draft of the template.
