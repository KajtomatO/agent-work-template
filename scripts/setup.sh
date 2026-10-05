#!/bin/sh
# One-time (idempotent) repository setup: enable the versioned git hooks.
# Runs automatically at the start of every Claude Code session
# (.claude/settings.json → SessionStart), so cloud containers get it too.
set -e

root=$(git rev-parse --show-toplevel)
cd "$root"

git config core.hooksPath .githooks
# Not `.githooks/*`: _agent.sh is sourced, never executed, and tracked as 644.
chmod +x .githooks/[!_]* dev scripts/*.sh 2>/dev/null || true

echo "setup: git hooks enabled (core.hooksPath=.githooks)"
