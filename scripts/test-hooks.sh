#!/bin/sh
# Self-test for .githooks: builds a throwaway repo + bare remote and checks
# that the agent rules (docs/GIT-WORKFLOW.md) hold and humans are unaffected.
# verifies: REQ-BUILD-002
set -u

hooks=$(cd "$(dirname "$0")/../.githooks" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

pass=0
fail=0

# Environment profiles. Each test runs git with exactly one of them.
human()  { env -u CLAUDECODE -u AGENT_SESSION -u CLAUDE_CODE_REMOTE -u AGENT_PUSH_APPROVED "$@"; }
agent()  { env -u AGENT_SESSION -u CLAUDE_CODE_REMOTE -u AGENT_PUSH_APPROVED CLAUDECODE=1 "$@"; }
other()  { env -u CLAUDECODE -u CLAUDE_CODE_REMOTE -u AGENT_PUSH_APPROVED AGENT_SESSION=1 "$@"; }
cloud()  { env -u AGENT_SESSION -u AGENT_PUSH_APPROVED CLAUDECODE=1 CLAUDE_CODE_REMOTE=true "$@"; }
approved() { env -u AGENT_SESSION -u CLAUDE_CODE_REMOTE CLAUDECODE=1 AGENT_PUSH_APPROVED=1 "$@"; }

expect() { # expect ok|blocked "description" command...
    want=$1; desc=$2; shift 2
    if "$@" >"$tmp/out" 2>&1; then got=ok; else got=blocked; fi
    if [ "$got" = "$want" ]; then
        pass=$((pass + 1)); echo "  ok    $desc"
    else
        fail=$((fail + 1)); echo "  FAIL  $desc (expected $want, got $got)"
        sed 's/^/        /' "$tmp/out"
    fi
}

echo "hook files"
# Git silently skips non-executable hooks on Linux/macOS; Windows commits
# lose the bit unless it is set with `git update-index --chmod=+x`.
for h in "$hooks"/*; do
    case "$h" in */_*) continue ;; esac
    mode=$(git -C "$hooks" ls-files -s "$(basename "$h")" | cut -d' ' -f1)
    if [ "$mode" = "100755" ]; then
        pass=$((pass + 1)); echo "  ok    $(basename "$h") is executable in git"
    else
        fail=$((fail + 1))
        echo "  FAIL  $(basename "$h") has mode ${mode:-untracked}, not 100755 —" \
             "run: git update-index --chmod=+x .githooks/$(basename "$h")"
    fi
done

n=0
change() { n=$((n + 1)); echo "$n" > f.txt; git add f.txt; }

git init -q --bare "$tmp/remote.git"
git init -q -b main "$tmp/repo"
cd "$tmp/repo" || exit 1
git config user.name "Test"
git config user.email "test@example.com"
git config core.autocrlf false
git config core.hooksPath "$hooks"
git remote add origin "$tmp/remote.git"

echo "commits"
change; expect ok      "human commits on main"                 human git commit -qm "Initial"
change; expect blocked "agent commits on main"                 agent git commit -qm "Change"
human git reset -q
human git checkout -qb development
change; expect blocked "agent commits on development"          agent git commit -qm "Change"
change; expect blocked "other agent (AGENT_SESSION) on development" other git commit -qm "Change"
expect ok              "human commits on development"          human git commit -qm "Dev change"
human git checkout -qb feature/x
change; expect ok      "agent commits on feature branch"       agent git commit -qm "[STEP-M1-010] add skeleton"

echo "commit messages"
change; expect blocked "agent message with Co-Authored-By"     agent git commit -qm "Fix parser" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
expect blocked         "agent message naming the AI"           agent git commit -qm "AI generated fix"
expect blocked         "agent message mentioning agent"        agent git commit -qm "Agent cleanup"
expect blocked         "agent subject over limit"              agent git commit -qm "$(printf 'x%.0s' $(seq 1 80))"
expect ok              "agent short neutral message"           agent git commit -qm "Fix parser off-by-one"
change; expect ok      "human may write anything"              human git commit -qm "Co-Authored-By: Claude via AI agent"

echo "merges"
human git checkout -q development
expect blocked         "agent merges into development"         agent git merge -q --no-ff --no-edit feature/x
human git merge --abort 2>/dev/null
expect ok              "human merges into development"         human git merge -q --no-ff --no-edit feature/x

echo "pushes"
human git checkout -qb claude/step-x
change; agent git commit -qm "Work" >/dev/null 2>&1
expect blocked         "local agent push, not approved"        agent git push -q origin feature/x
expect ok              "local agent push, user approved"       approved git push -q origin feature/x
expect blocked         "approved agent push to main"           approved git push -q origin main
expect blocked         "approved agent push to development"    approved git push -q origin development
expect ok              "cloud agent pushes claude/* branch"    cloud git push -q origin claude/step-x
expect blocked         "cloud agent pushes feature/* branch"   cloud git push -q origin feature/x:feature/y
expect blocked         "cloud agent pushes development"        cloud git push -q origin development
expect blocked         "cloud agent pushes to main via refspec" cloud git push -q origin claude/step-x:main
expect ok              "human pushes main"                     human git push -q origin main
expect ok              "human pushes development"              human git push -q origin development

echo
echo "hooks self-test: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
