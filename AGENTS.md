# Agent instructions

Rules for any coding agent working in this repository (Claude Code, Copilot,
Codex, Cursor, …). Tool-specific additions live in their own files
(`CLAUDE.md`, …) and never contradict this one. **Explicit user instructions
always override this file — except the hard git rules in §1, which only a
human acting directly may bypass.**

## 1. Git rules (hard)

Full rationale and enforcement: [docs/GIT-WORKFLOW.md](docs/GIT-WORKFLOW.md).

| | `main`, `development` | any other branch |
|---|---|---|
| commit | **never** | yes |
| merge into / rebase / reset / force-update | **never** | yes, on branches you work on |
| push | **never** | only when the user explicitly asks — or in a cloud session (below) |

- **Choosing a branch.**
  - *Local (user's machine):* work on the current branch if it is not
    protected. If it is `main` or `development`, **ask the user** for a branch
    name before changing anything; never invent one silently.
  - *Cloud session* (Claude Code on the web / a temporary container,
    `CLAUDE_CODE_REMOTE=true`): create `claude/<STEP-ID>-<slug>` (or
    `claude/<slug>` when not working on a step) from `development`.
  - *Creating it.* A fresh clone has `development` only as
    `origin/development`, so branch from the remote-tracking ref:
    `git fetch origin development:refs/remotes/origin/development && git switch -c <branch> --no-track origin/development`.
    If the fetch fails, stop and tell the user that `development` does not
    exist yet (README step 1); do not fall back to `main`.
- **Pushing.** Never push unless the user explicitly asked for that push in
  the current conversation. Approval covers that one request, not later ones.
  When asked, push with `AGENT_PUSH_APPROVED=1 git push …` so the pre-push hook
  lets it through. *Exception:* in a cloud session you may push the
  `claude/*` branches you created, without asking, as long as the push only
  creates or fast-forwards the branch. A force-push or a branch deletion
  needs an explicit request like any other push. Push branches only, never
  tags.
- **Commit messages.**
  - Short: subject ≤ 72 characters, imperative mood; a body only when the
    *why* is not obvious.
  - Never refer to the agent or tooling: no tool or vendor names (Claude,
    Anthropic, OpenAI, ChatGPT, Copilot, Gemini, Codex, Cursor), no "AI",
    "LLM", "GPT", "agent", "assistant", no `Co-Authored-By:` or session
    trailer, no "Generated with/by" lines, no emoji signatures. Write it as
    the engineer would. The `commit-msg` hook enforces the subset in
    `FORBIDDEN_MSG_RE` (`.githooks/_agent.sh`); "assistant" and "Cursor" are
    ordinary words in many codebases and are left out of the pattern, not out
    of the rule. File names (`AGENTS.md`, `CLAUDE.md`, `.claude/…`), `claude/*`
    branch names and REQ/STEP ids may be mentioned.
  - Prefixes per [REQUIREMENTS-MANAGEMENT.md](REQUIREMENTS-MANAGEMENT.md) §4.2:
    `[STEP-<ID>] subject` for step work, `[Mx] …` for milestone records,
    `[plan] …` for ARCHITECTURE / plan edits, `[REQ] …` for
    requirement-only edits.
- **Never bypass hooks** (`--no-verify`, changing `core.hooksPath`). If a hook
  blocks you, stop and tell the user why.
- Tags, releases, and PR merges are the user's. Open a PR only when the user
  asks; never merge, approve or enable auto-merge.

**Agent detection.** The git hooks recognise Claude Code (`CLAUDECODE=1`) and
Gemini CLI (`GEMINI_CLI=1`) from the variables those tools set for the
commands they run. Other tools (Codex, Copilot, Cursor, …) are not detected
on their own: the person configuring the tool sets `AGENT_SESSION=1` in the
tool's environment (README step 2 shows how to verify it). Run
`scripts/setup.sh` (or `scripts/setup.ps1`) once per clone if hooks are not
active (`git config --get core.hooksPath` should print `.githooks`).

## 2. Process

This repo follows a requirements-driven, step-based process. Read before
acting:

- [ARCHITECTURE.md](ARCHITECTURE.md) — **what** is built: decisions, components, milestones.
- [REQUIREMENTS-MANAGEMENT.md](REQUIREMENTS-MANAGEMENT.md) — **how** work is tracked:
  requirements, traceability tags, workplan, change management. Sections
  marked **PROCEDURE** are executed literally.
- [KNOWN-ISSUES.md](KNOWN-ISSUES.md) — open defects and workarounds; check
  before debugging something that "should work".
- [tests/README.md](tests/README.md) — test tiers and gating.

**Stop points** — produce, then wait for a human decision:

- approving, rejecting or superseding a requirement (never self-approve);
- a milestone decomposition (propose the step table, then stop);
- an impact analysis (present the report, then stop);
- anything that would touch a protected branch, push, tag or release.

When the user makes a decision in conversation that constrains the
implementation, propose capturing it as a requirement (draft) or as an
ARCHITECTURE decision.

## 3. Working style

- Think before acting. Read the relevant files before writing code.
- Prefer small, focused edits over rewriting whole files.
- Match the surrounding code's style, naming and comment density.
- Run the tests (`./dev test` or the project's commands) before declaring
  something done; report failures honestly, with output.
- Claims about external systems cite a ground-truth source
  (REQUIREMENTS-MANAGEMENT.md §8) — never memory or plausibility.
- Keep solutions simple and direct. Concise output, no filler.
- Secrets live in a git-ignored `.env`; never commit them or print them.
