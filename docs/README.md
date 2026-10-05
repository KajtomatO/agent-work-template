# Documentation

| Document | Purpose |
|---|---|
| [GIT-WORKFLOW.md](GIT-WORKFLOW.md) | Branch model, agent git rules, enforcement, server-side protection |
| [TEMPLATE-UPDATES.md](TEMPLATE-UPDATES.md) | Carrying later template fixes into a project created from it |
| [../ARCHITECTURE.md](../ARCHITECTURE.md) | What is built |
| [../REQUIREMENTS-MANAGEMENT.md](../REQUIREMENTS-MANAGEMENT.md) | How work is tracked |
| [../KNOWN-ISSUES.md](../KNOWN-ISSUES.md) | Open defects and workarounds |
| [../tests/README.md](../tests/README.md) | Test tiers and how to run them |

Add user-facing documentation here (usage guides, API references).

## Patterns worth adopting

- **Conformance ledger** (`COVERAGE.md`): when building against an external
  specification, keep one row per spec item with a disposition from a fixed
  vocabulary, e.g. `IMPLEMENTED`, `DEFERRED-<Mx>`, `UNSUPPORTED-DELIBERATE`,
  `ABSENT-UPSTREAM`, plus a reason. It makes "did we cover everything?"
  answerable by reading one file.
- **Documentation gate**: a check (run as a unit test or in `./dev check`)
  that fails when a public symbol/endpoint/command lacks documentation.
- **Interface baseline**: a committed list of the public interface (exported
  symbols, API schema, CLI flags) and a check that flags unintended changes.
