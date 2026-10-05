# One-time (idempotent) repository setup: enable the versioned git hooks.
# Hooks are POSIX sh scripts; Git for Windows runs them with its bundled sh.
$ErrorActionPreference = 'Stop'

$root = git rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { throw 'not inside a git repository' }

# Push/Pop: a .ps1 shares the caller's location, so do not leave it changed.
Push-Location $root
try {
    git config core.hooksPath .githooks
    if ($LASTEXITCODE -ne 0) { throw 'git config failed' }

    # Keep the executable bit in the index so hooks also run on Linux/macOS
    # clones. The list comes from the index, so hooks added later are covered;
    # _agent.sh is sourced, never executed, and stays 644.
    $exec = git ls-files -- '.githooks/[!_]*' dev 'scripts/*.sh'
    if ($exec) { git update-index --chmod=+x -- $exec }

    Write-Output 'setup: git hooks enabled (core.hooksPath=.githooks)'
} finally {
    Pop-Location
}
