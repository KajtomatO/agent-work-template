# Tests

Tests are partitioned into three tiers (ARCHITECTURE.md §5). Use the test
framework's own grouping mechanism (labels, markers, tags, directories) to
implement them.

<!-- SETUP: name the environment variables and the commands for this project. -->

| Tier | What | When it runs |
|---|---|---|
| `unit` | Offline, deterministic; fakes for external systems | Every build, every platform, CI |
| `integration` | Real external systems | Only when `<PROJECT>_TEST_URL` (or equivalent) is set; otherwise **skipped**, not failed |
| `disruptive` | Mutates or degrades real/shared systems | Never automatically; needs the integration env **and** `<PROJECT>_ALLOW_DISRUPTIVE=1` |

Rules:

- A plain test run with no environment configured is green: integration and
  disruptive tests report *skipped*.
- Gating lives in one shared helper, not copy-pasted per test.
- Credentials come from the environment or a git-ignored `.env` (`./dev`
  loads it); never commit them.
- Each test that proves a requirement carries a `verifies: REQ-<ID>` comment
  next to the test case; shared infrastructure may carry
  `supports: REQ-<ID>` (REQUIREMENTS-MANAGEMENT.md §4.2).

## Running

```sh
./dev test unit          # default; what CI runs
./dev test integration   # needs the integration environment
./dev test all
```
