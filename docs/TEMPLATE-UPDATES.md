# Updating from the template

A repository created with "Use this template" shares no history with
`agent-work-template`, so template fixes cannot be pulled or merged. This page
shows how to carry them over.

## What the project records

`.template-version` holds the template release the project was created from,
or last synced to. Template releases are tagged `v<version>` in the template
repository and described in its `CHANGELOG.md`.

## Sync recipe

Only the template's infrastructure is synced. Requirements, the workplan,
`ARCHITECTURE.md` and the README are the project's own.

```sh
# once
git remote add template https://github.com/KajtomatO/agent-work-template.git

# each time, on a work branch
git fetch --no-tags template \
    '+refs/heads/main:refs/remotes/template/main' \
    '+refs/tags/*:refs/tags/template/*'
git diff "template/v$(cat .template-version)" template/main -- \
    .githooks scripts .claude AGENTS.md CLAUDE.md GEMINI.md docs/GIT-WORKFLOW.md \
    | git apply -3
```

The template's tags are fetched as `template/v…` so that they cannot collide
with the project's own release tags. `git apply -3` merges each change with
the project's version of the file and leaves conflict markers where both
changed the same lines.

Then:

1. Resolve any conflicts and read the whole diff: these are the files that
   enforce the git rules.
2. Run `sh scripts/setup.sh` and `sh scripts/test-hooks.sh`.
3. Set `.template-version` to the release you synced to and commit.

`REQUIREMENTS-MANAGEMENT.md`, `dev`, `dev.ps1` and `.github/workflows/ci.yml`
carry the project's own setup edits. Add them to the path list when a
template release changes them (the changelog says so) and expect conflicts.
