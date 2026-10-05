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

passed() { pass=$((pass + 1)); echo "  ok    $1"; }
failed() { # failed "description" [file holding the command's output]
    fail=$((fail + 1)); echo "  FAIL  $1"
    [ -n "${2:-}" ] && sed 's/^/        /' "$2"
    # In GitHub Actions the failure is also an annotation on the run, so it
    # can be read without opening the job log.
    if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
        detail=$([ -n "${2:-}" ] && head -n 12 "$2" | tr -d '\r' | sed 's/%/%25/g' | awk '{ printf "%%0A%s", $0 }')
        echo "::error title=hooks self-test::$(printf '%s' "$1" | sed 's/%/%25/g')$detail"
    fi
}

# Environment profiles. Each test runs git with exactly one of them.
clean()    { env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION -u GEMINI_CLI -u AGENT_SESSION -u CLAUDE_CODE_REMOTE -u AGENT_PUSH_APPROVED "$@"; }
human()    { clean "$@"; }
agent()    { clean env CLAUDECODE=1 CLAUDE_CODE_CHILD_SESSION=1 "$@"; }
ide()      { clean env CLAUDECODE=1 "$@"; }   # a human in a Claude Code IDE terminal
other()    { clean env AGENT_SESSION=1 "$@"; }
gemini()   { clean env GEMINI_CLI=1 "$@"; }
cloud()    { clean env CLAUDECODE=1 CLAUDE_CODE_CHILD_SESSION=1 CLAUDE_CODE_REMOTE=true "$@"; }
approved() { clean env CLAUDECODE=1 CLAUDE_CODE_CHILD_SESSION=1 AGENT_PUSH_APPROVED=1 "$@"; }

expect() { # expect ok|blocked "description" command...
    want=$1; desc=$2; shift 2
    if "$@" >"$tmp/out" 2>&1; then got=ok; else got=blocked; fi
    if [ "$got" = "$want" ]; then
        passed "$desc"
    else
        failed "$desc (expected $want, got $got)" "$tmp/out"
    fi
}

expect_out() { # expect_out has|lacks "description" text: output of the last expect
    want=$1; desc=$2
    if grep -qF -- "$3" "$tmp/out"; then got=has; else got=lacks; fi
    if [ "$got" = "$want" ]; then
        passed "$desc"
    else
        failed "$desc (output $got '$3')" "$tmp/out"
    fi
}

xs() { printf 'x%.0s' $(seq 1 "$1"); }   # a string of N characters

echo "hook files"
# Git silently skips non-executable hooks on Linux/macOS; Windows commits
# lose the bit unless it is set with `git update-index --chmod=+x`.
for h in "$hooks"/*; do
    case "$h" in */_*) continue ;; esac
    mode=$(git -C "$hooks" ls-files -s "$(basename "$h")" 2>"$tmp/out" | cut -d' ' -f1)
    if [ "$mode" = "100755" ]; then
        passed "$(basename "$h") is executable in git"
    else
        failed "$(basename "$h") has mode ${mode:-untracked}, not 100755 — run: git update-index --chmod=+x .githooks/$(basename "$h")" "$tmp/out"
    fi
done

# From here on only the throwaway repository is used: the developer's own git
# configuration must not change the outcome. (The check above reads this
# repository and keeps the real configuration, e.g. CI's safe.directory.)
: > "$tmp/gitconfig"
GIT_CONFIG_GLOBAL="$tmp/gitconfig"
export GIT_CONFIG_GLOBAL

n=0
change() { n=$((n + 1)); echo "$n" > f.txt; git add f.txt; }
add_file() { echo "$1" > "$1"; git add "$1"; }   # a change that never conflicts

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
expect_out lacks       "agent session gets no opt-out hint"    "unset CLAUDECODE"
expect blocked         "agent amends on main"                  agent git commit -q --amend -m "Change"
expect blocked         "agent commit --no-verify on main"      agent git commit -qn -m "Change"
expect blocked         "tunables are not read from the environment" agent env PROTECTED_BRANCHES=x git commit -qm "Change"
expect blocked         "IDE terminal counts as an agent session" ide git commit -qm "Change"
expect_out has         "IDE terminal is told how to opt out"   "unset CLAUDECODE"
human git reset -q
human git checkout -qb development
change; expect blocked "agent commits on development"          agent git commit -qm "Change"
expect blocked         "other agent (AGENT_SESSION) on development" other git commit -qm "Change"
expect blocked         "Gemini CLI (GEMINI_CLI) on development" gemini git commit -qm "Change"
expect ok              "human commits on development"          human git commit -qm "Dev change"
human env GIT_SEQUENCE_EDITOR='sed -i.bak s/^pick/edit/' git rebase -q -i HEAD~1 >/dev/null 2>&1
expect blocked         "test setup: the rebase stopped with HEAD detached" human git symbolic-ref -q HEAD
expect blocked         "agent amends during a rebase of development" agent git commit -q --amend -m "Change"
human git rebase --abort
human git checkout -qb feature/x
change; expect ok      "agent commits on feature branch"       agent git commit -qm "[STEP-M1-010] add skeleton"

echo "commit messages"
change; expect blocked "agent message with Co-Authored-By"     agent git commit -qm "Fix parser" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
expect blocked         "agent message with a session trailer"  agent git commit -qm "Fix parser" -m "Claude-Session: https://example.invalid/session_01"
expect blocked         "agent message with Generated with"     agent git commit -qm "Fix parser" -m "Generated with Claude Code"
printf 'Fix parser \360\237\244\226\n' > "$tmp/robot-msg"   # U+1F916 as exact bytes
expect blocked         "agent message with the robot emoji"    agent git commit -qF "$tmp/robot-msg"
expect blocked         "agent message naming the AI"           agent git commit -qm "AI generated fix"
expect blocked         "agent message with AI as a word"       agent git commit -qm "Add AI model config"
expect blocked         "agent message mentioning agent"        agent git commit -qm "Agent cleanup"
expect blocked         "agent empty message"                   agent git commit -q --allow-empty-message -m ""
expect blocked         "agent subject over limit"              agent git commit -qm "$(xs 80)"
expect blocked         "agent subject of 73 characters"        agent git commit -qm "$(xs 73)"
change; expect ok      "agent subject of 72 characters"        agent git commit -qm "$(xs 72)"
change; expect ok      "subject length counts characters, not bytes" agent env LC_ALL=C git commit -qm "$(xs 69)—→"
change; expect ok      "agent short neutral message"           agent git commit -qm "Fix parser off-by-one"
change; expect ok      "instruction file names are allowed"    agent git commit -qm "Clarify push rule in AGENTS.md"
change; expect ok      ".claude/ paths are allowed"            agent git commit -qm "Update .claude/settings.json deny list"
change; expect ok      "User-Agent is allowed"                 agent git commit -qm "Fix User-Agent header parsing"
change; expect ok      "REQ ids are allowed"                   agent git commit -qm "[REQ] draft REQ-AI-001"
change; expect ok      "forbidden words match whole words only" agent git commit -qm "Add reagent lookup table"
# Git's own template and verbose diff mention the staged file names; neither
# is part of the stored message.
add_file agent.txt
expect ok              "editor commit: comments and -v diff are ignored" agent env GIT_EDITOR=true git commit -qev -m "Add notes"
add_file ai.txt
expect ok              "editor commit with another comment character" agent env GIT_EDITOR=true git -c core.commentChar=';' commit -qev -m "Add more notes"
change; expect ok      "human may write anything"              human git commit -qm "Co-Authored-By: Claude via AI agent, in a subject far longer than the limit"
theirs=$(git rev-parse HEAD)
change; expect ok      "fixup of a human commit keeps its subject" agent git commit -q --fixup="$theirs"
change; expect blocked "squash body is still scanned"          agent git commit -q --squash="$theirs" -m "Generated with Claude"
human git reset -q --hard

echo "rebase, cherry-pick, revert, am"
add_file pick.txt; human git commit -qm "Add pick file"
pick=$(git rev-parse HEAD)
human git format-patch -1 --stdout "$pick" > "$tmp/pick.patch"
human git checkout -q development
expect blocked         "agent rebases development"             agent git rebase -q feature/x
expect blocked         "agent cherry-picks onto development"   agent git cherry-pick "$pick"
human git cherry-pick --abort 2>/dev/null; human git reset -q --hard
expect blocked         "agent reverts on development"          agent git revert --no-edit HEAD
human git revert --abort 2>/dev/null; human git reset -q --hard
expect blocked         "agent applies a patch (am) on development" agent git am -q "$tmp/pick.patch"
human git am --abort 2>/dev/null; human git reset -q --hard
expect ok              "human cherry-picks onto development"   human git cherry-pick "$pick"
human git checkout -q feature/x
expect blocked         "agent rebases development from a work branch" agent git rebase -q feature/x development
expect ok              "agent rebases a work branch"           agent git rebase -q development
human git checkout -q development
add_file dev.txt; human git commit -qm "Dev file"
devfile=$(git rev-parse HEAD)
human git checkout -q feature/x
expect ok              "agent cherry-picks onto a work branch" agent git cherry-pick "$devfile"

echo "merges"
human git checkout -q development
expect blocked         "agent merges into development"         agent git merge -q --no-ff --no-edit feature/x
human git merge --abort 2>/dev/null
expect blocked         "other agent (AGENT_SESSION) merges into development" other git merge -q --no-ff --no-edit feature/x
human git merge --abort 2>/dev/null
expect ok              "human merges into development"         human git merge -q --no-ff --no-edit feature/x
human git checkout -qb claude/step-x
change; agent git commit -qm "Work" >/dev/null 2>&1
human git checkout -q development
add_file dev2.txt; human git commit -qm "Dev file 2"
human git checkout -q claude/step-x
expect ok              "default merge message on a claude/* branch" agent git merge -q --no-edit development

echo "pushes"
expect blocked         "local agent push, not approved"        agent git push -q origin feature/x
expect blocked         "other agent (AGENT_SESSION) push"      other git push -q origin feature/x
expect ok              "local agent push, user approved"       approved git push -q origin feature/x
expect blocked         "approved agent push to main"           approved git push -q origin main
expect blocked         "approved agent push to development"    approved git push -q origin development
expect ok              "cloud agent pushes claude/* branch"    cloud git push -q origin claude/step-x
expect blocked         "cloud agent pushes feature/* branch"   cloud git push -q origin feature/x:feature/y
expect blocked         "cloud agent pushes development"        cloud git push -q origin development
expect blocked         "cloud agent pushes to main via refspec" cloud git push -q origin claude/step-x:main
expect blocked         "cloud push rules are not read from the environment" cloud env CLOUD_BRANCH_PREFIX=m PROTECTED_BRANCHES=x git push -q origin claude/step-x:main
change; agent git commit -qm "More work" >/dev/null 2>&1
expect ok              "cloud agent fast-forwards its branch"  cloud git push -q origin claude/step-x
agent git commit -q --amend -m "More work, reworded" >/dev/null 2>&1
expect blocked         "cloud agent force-pushes a branch"     cloud git push -q --force origin claude/step-x
expect blocked         "cloud agent deletes a branch"          cloud git push -q origin :claude/step-x
expect ok              "approved agent force-pushes a branch"  approved git push -q --force origin claude/step-x
expect ok              "approved agent deletes a branch"       approved git push -q origin :claude/step-x
human git tag v1
expect blocked         "approved agent pushes a tag"           approved git push -q origin v1
expect blocked         "cloud agent pushes a tag"              cloud git push -q origin v1
expect ok              "human pushes a tag"                    human git push -q origin v1
expect ok              "human pushes main"                     human git push -q origin main
expect ok              "human pushes development"              human git push -q origin development

echo "protected-branch patterns"
# The tunables are edited in the file, so this runs a copy with a pattern entry.
cp -Rp "$hooks" "$tmp/hooks-pattern"
sed 's#^PROTECTED_BRANCHES=.*#PROTECTED_BRANCHES="main development release/*"#' \
    "$hooks/_agent.sh" > "$tmp/hooks-pattern/_agent.sh"
git config core.hooksPath "$tmp/hooks-pattern"
human git checkout -qb release/2.0
mkdir release; echo x > release/1.0   # a matching path must not replace the pattern
change; expect blocked "agent commits on a branch matching a pattern" agent git commit -qm "Change"
human git reset -q --hard
human git checkout -q feature/x
change; expect ok      "a pattern leaves other branches alone" agent git commit -qm "Change"
git config core.hooksPath "$hooks"

echo
echo "hooks self-test: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
