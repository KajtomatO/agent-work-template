# Known issues

Defects and limitations that affect development or users — especially ones
outside our control (upstream libraries, external systems, platforms) — with
what is known, what was ruled out, and how to work around them. Check here
before debugging something that "should work". Code, CI and requirements may
reference entries by title.

**Format.** One `##` entry per issue, newest open issues first, resolved ones
kept at the bottom (never deleted):

```markdown
## OPEN — <short title>

**Status:** open (<owner / where it must be fixed>; <mitigation shipped YYYY-MM-DD?>).
**Affected:** <components, tests, platforms>.

### Symptom
<What is observed, how often, how to reproduce.>

### What it is NOT (ruled out by <method>, YYYY-MM-DD)
<Hypotheses eliminated, with evidence — keeps others from re-testing them.>

### Mitigation
<What the project does about it (code, CI, retries), with REQ/STEP refs.>

### Workaround
<What a developer/user can do meanwhile.>

### Upstream fixes to file
<Issue to report to the owning party, with a link once filed.>

### Update (YYYY-MM-DD)
<New data points; append, don't rewrite.>
```

When resolved, change the heading to `## RESOLVED — <title>` and add
`### Actual root cause`, `### Fix (YYYY-MM-DD)` and, if any,
`### Residual notes`.

---

_No known issues yet._
