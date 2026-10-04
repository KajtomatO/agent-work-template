# <project-name> — Architecture

This document defines **what** is built. How the work is tracked is defined in
[REQUIREMENTS-MANAGEMENT.md](REQUIREMENTS-MANAGEMENT.md). Requirements and
steps cite sections here by anchor (e.g. `ARCHITECTURE.md#1-decisions-fixed`),
so **do not renumber or rename headings** once referenced — append new
sections instead, and run an impact analysis (§6.2 of the process doc) when
changing a decision or a referenced section.

<!-- SETUP: replace every <placeholder>. Delete these SETUP comments when done. -->

## [TLDR]

<Three to ten lines: what the project is, who uses it, the main technical
choices, and where it stands (current milestone).>

## 1. Decisions (fixed)

<!-- Decisions already made and not up for re-litigation. REQs cite these.
     Each entry: what was decided, short why, and who/when. -->

- **<Decision>** — <rationale>. (user decision YYYY-MM-DD)
- **Branching:** `main` (releases) ← `development` (integration) ← work
  branches; agents never commit to or push `main`/`development`
  ([docs/GIT-WORKFLOW.md](docs/GIT-WORKFLOW.md)). (template default)

## 2. Context & constraints

<Users and consumers, external systems integrated with, target platforms,
language/toolchain choices, licensing, performance/security constraints.
Mark anything unverified as *needs verification*.>

## 3. Component overview

<Components and their responsibilities; a small diagram helps.>

```
<component A> ──> <component B> ──> <external system>
```

## 4. <Domain section>

<!-- Add domain-specific sections here (4, 4.1, 4.2 … or new top-level
     numbers *after* the last existing section). Examples: public API &
     conventions, data model, protocol, CLI behavior, security model. -->

<content>

## 5. Testing policy

See [tests/README.md](tests/README.md) for the mechanics. Policy:

- **unit** — offline, deterministic, no network or real external systems;
  runs on every build and in CI.
- **integration** — talks to real external systems; runs only when its
  environment (e.g. a target URL / credentials) is configured, and *skips*
  (not fails) otherwise.
- **disruptive** — mutates or degrades shared/real systems; never runs
  automatically; needs the integration environment **and** an explicit
  second opt-in.

## 6. Directory layout

```
<fill in as the project takes shape>
src/            code root (REQUIREMENTS-MANAGEMENT.md §4.2)
tests/          test root
docs/           user-facing and process documentation
scripts/        setup and helper scripts
requirements/   requirements and the generated trace matrix
workplan/       steps: todo/ doing/ done/
```

## 7. Milestones

<!-- Format: one bullet per milestone with a demonstrable **Gate**. Later
     additions are appended in italics with the decision date. The first
     decomposition (§5.3) creates STEP-<Mx>-000 placeholders for the rest. -->

- **M1 — <name> (MVP):** <scope>. **Gate:** <demonstrable criterion>.
- **M2 — <name>:** <scope>. **Gate:** <demonstrable criterion>.

## 8. Risks & open questions

<!-- Numbered; each states how it will be resolved. When resolved, append
     inline: **RESOLVED (<STEP-ID / gate>, YYYY-MM-DD):** <outcome>. -->

1. **<Risk or question>** — <impact>. *Resolved by:* <experiment / step / decision>.
