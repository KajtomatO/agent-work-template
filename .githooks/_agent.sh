# Shared helpers for the git hooks in this directory. Sourced, not executed.
# implements: REQ-BUILD-002
# Rules: docs/GIT-WORKFLOW.md. Humans are never restricted by these hooks.

# SETUP: branches agents may never commit, merge or push to.
PROTECTED_BRANCHES="${PROTECTED_BRANCHES:-main development}"

# SETUP: branch prefix an agent may push in a cloud session (temporary container).
CLOUD_BRANCH_PREFIX="${CLOUD_BRANCH_PREFIX:-claude/}"

# SETUP: commit messages written by an agent must not match this
# (extended regex, case-insensitive) — no references to the agent or tooling.
FORBIDDEN_MSG_RE='claude|anthropic|openai|chatgpt|copilot|gemini|codex|(^|[^[:alnum:]_])(ai|llm|gpt)([^[:alnum:]_]|$)|agent|co-authored-by|generated (with|by)|🤖'

# SETUP: maximum subject line length for agent commits.
MAX_SUBJECT_LEN="${MAX_SUBJECT_LEN:-72}"

# An agent session: Claude Code sets CLAUDECODE=1 for the commands it runs;
# other tools must export AGENT_SESSION=1 (see AGENTS.md).
is_agent() {
    [ "${CLAUDECODE:-}" = "1" ] || [ "${AGENT_SESSION:-}" = "1" ]
}

# A Claude cloud session (temporary container, not the user's machine).
is_cloud() {
    [ "${CLAUDE_CODE_REMOTE:-}" = "true" ]
}

is_protected() {
    for _b in $PROTECTED_BRANCHES; do
        [ "$1" = "$_b" ] && return 0
    done
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

deny() {
    echo "BLOCKED by git hook: $*" >&2
    echo "See docs/GIT-WORKFLOW.md." >&2
    exit 1
}
