# Shared helpers for the git hooks in this directory. Sourced, not executed.
# implements: REQ-BUILD-002
# Rules: docs/GIT-WORKFLOW.md. Humans are never restricted by these hooks.
#
# The tunables below are plain assignments on purpose: edit this file to change
# them. They are not read from the environment (that would be a one-command
# bypass of every rule).

# TUNABLE: branches agents may never commit, merge or push to. Space-separated
# shell patterns, so `release/*` protects every release branch.
PROTECTED_BRANCHES="main development"

# TUNABLE: branch prefix an agent may push in a cloud session (temporary container).
# Used inside an ERE below: no regex metacharacters.
CLOUD_BRANCH_PREFIX="claude/"

# TUNABLE: words an agent commit message may never contain (POSIX ERE, word-bounded,
# case-insensitive). This is the enforced subset of the rule in AGENTS.md §1.
FORBIDDEN_MSG_RE='(^|[^[:alnum:]_])(claude|anthropic|openai|chatgpt|copilot|gemini|codex|ai|llm|gpt|agents?|subagents?|agentic|co-authored-by|generated (with|by))([^[:alnum:]_]|$)|🤖'

# TUNABLE: harmless mentions removed before the scan: this repo's instruction files,
# the .claude/ directory, work-branch names (covers git's default merge subjects) and
# REQ/STEP ids.
ALLOWED_MSG_RE="AGENTS\\.md|CLAUDE\\.md|\\.claude/[^[:space:]]*|${CLOUD_BRANCH_PREFIX}[^[:space:]']+|User-Agent|(REQ|STEP)-[A-Z0-9]+-[0-9]+"

# TUNABLE: maximum subject line length for agent commits, in characters.
MAX_SUBJECT_LEN=72

# An agent session: Claude Code sets CLAUDECODE=1 and Gemini CLI sets
# GEMINI_CLI=1 for the commands they run; other tools need AGENT_SESSION=1 in
# their environment (see AGENTS.md).
is_agent() {
    [ "${CLAUDECODE:-}" = "1" ] || [ "${GEMINI_CLI:-}" = "1" ] || [ "${AGENT_SESSION:-}" = "1" ]
}

# A Claude cloud session (temporary container, not the user's machine).
is_cloud() {
    [ "${CLAUDE_CODE_REMOTE:-}" = "true" ]
}

# set -f: the entries are matched as patterns against the branch name, never
# expanded against the files in the working tree.
is_protected() {
    set -f
    for _b in $PROTECTED_BRANCHES; do
        # shellcheck disable=SC2254  # the entry is meant to be a pattern
        case "$1" in $_b) set +f; return 0 ;; esac
    done
    set +f
    return 1
}

# Current branch name, also during a rebase (where HEAD is detached).
current_branch() {
    _br=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) && { echo "$_br"; return; }
    for _d in rebase-merge rebase-apply; do
        _f=$(git rev-parse --git-path "$_d/head-name" 2>/dev/null)
        if [ -f "$_f" ]; then
            sed 's#^refs/heads/##' "$_f"
            return
        fi
    done
}

# Code points, independent of the caller's locale (wc -m counts bytes under LANG=C).
char_count() { LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' '; }

deny() {
    echo "BLOCKED by git hook: $*" >&2
    echo "See docs/GIT-WORKFLOW.md." >&2
    # Claude Code's IDE extensions export CLAUDECODE=1 in their integrated
    # terminals too; only commands Claude Code itself runs carry the second variable.
    if [ "${CLAUDECODE:-}" = "1" ] && [ -z "${CLAUDE_CODE_CHILD_SESSION:-}" ]; then
        echo "If you are a human in a Claude Code IDE terminal, run 'unset CLAUDECODE' and retry." >&2
    fi
    exit 1
}
