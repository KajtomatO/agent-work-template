# One-time (idempotent) repository setup: enable the versioned git hooks.
# Hooks are POSIX sh scripts; Git for Windows runs them with its bundled sh.
$ErrorActionPreference = 'Stop'

$root = git rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { throw 'not inside a git repository' }
Set-Location $root

git config core.hooksPath .githooks
if ($LASTEXITCODE -ne 0) { throw 'git config failed' }

# Keep the executable bit in the index so hooks also run on Linux/macOS clones.
git update-index --chmod=+x .githooks/pre-commit .githooks/pre-merge-commit `
    .githooks/commit-msg .githooks/pre-push dev scripts/setup.sh scripts/test-hooks.sh 2>$null

Write-Output 'setup: git hooks enabled (core.hooksPath=.githooks)'
