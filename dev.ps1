# Developer task runner (Windows PowerShell) — mirrors ./dev.
# Thin and optional: the plain commands it echoes keep working.
# implements: REQ-BUILD-001
#
# SETUP: fill in the Invoke-* functions with this project's commands and
# remove the Todo calls. Keep 'ci' mirroring .github/workflows/ci.yml.
param(
    [Parameter(Position = 0)][string]$Command = 'help',
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)][string[]]$Rest
)
$ErrorActionPreference = 'Stop'

function Log($msg)  { Write-Host "==> $msg" -ForegroundColor Blue }
function Warn($msg) { Write-Host "warning: $msg" -ForegroundColor Yellow }
function Die($msg)  { Write-Host "error: $msg" -ForegroundColor Red; exit 1 }
function Run {      # echo, then execute; fail on a non-zero exit or a failed cmdlet/script
    Write-Host "`$ $($args -join ' ')" -ForegroundColor DarkGray
    $rest = @($args | Select-Object -Skip 1)
    $global:LASTEXITCODE = 0    # only native programs set it: never trust a stale value
    & $args[0] @rest
    $ok = $?
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if (-not $ok) { exit 1 }
}
function Todo($what) { Die "'$what' is not configured yet: fill in its command in dev.ps1" }

# Git for Windows puts only <Git>\cmd on PATH by default; sh is in <Git>\bin.
function Get-Sh {
    $sh = Get-Command sh -ErrorAction SilentlyContinue
    if ($sh) { return $sh.Source }
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        $cand = Join-Path (Split-Path (Split-Path $git.Source)) 'bin\sh.exe'
        if (Test-Path $cand) { return $cand }
    }
    Die 'sh not found: install Git for Windows or add <Git>\usr\bin to PATH'
}
function Get-Python {
    foreach ($name in 'python3', 'python', 'py') {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    Die 'python 3 not found (scripts/trace.py needs it)'
}

# Local, git-ignored settings and secrets (see .env.example). Parsed as plain
# KEY=value lines and never executed; ./dev reads the same grammar.
function Import-DotEnv($path) {
    foreach ($line in Get-Content $path) {
        if ($line -notmatch '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$') { continue }
        $name, $value = $Matches[1], $Matches[2]
        if ($value -match '^"(.*)"$' -or $value -match "^'(.*)'$") { $value = $Matches[1] }
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

function Invoke-Setup { Run (Join-Path $PSScriptRoot 'scripts/setup.ps1') }
function Invoke-Build { Todo 'build' }
function Invoke-Test([string]$Tier = 'unit') {
    if ($Tier -notin 'unit', 'integration', 'disruptive', 'all') {
        Die "unknown test tier '$Tier' (unit|integration|disruptive|all)"
    }
    Todo "test $Tier"
}
function Invoke-Check {
    Run (Get-Sh) scripts/check-setup.sh          # template markers all filled in
    Todo 'check'
}
function Invoke-Trace { Run (Get-Python) scripts/trace.py @Rest }
function Invoke-Ci {
    Run (Get-Sh) scripts/test-hooks.sh
    Run (Get-Python) scripts/trace.py --check
    Invoke-Build
    Invoke-Check
    Invoke-Test 'unit'
}
function Invoke-Help {
    @'
usage: ./dev.ps1 <command> [args]

  setup                  enable git hooks (idempotent)
  build                  build the project
  test [tier]            run tests: unit (default) | integration | disruptive | all
  check                  static checks: lint, formatting, documentation gates
  trace [--coverage|--check]
                         regenerate requirements/TRACE.md, report only, or
                         fail if it is stale (needs python 3)
  ci                     run what CI runs, locally
  help                   this text

Loads ./.env (git-ignored) if present.
'@
}

# Push/Pop: a .ps1 shares the caller's location, so do not leave it changed.
Push-Location $PSScriptRoot
try {
    if (Test-Path .env) {
        Log 'loading .env'
        Import-DotEnv .env
    }
    switch ($Command) {
        'setup' { Invoke-Setup }
        'build' { Invoke-Build }
        'test'  { if ($Rest) { Invoke-Test $Rest[0] } else { Invoke-Test } }
        'check' { Invoke-Check }
        'trace' { Invoke-Trace }
        'ci'    { Invoke-Ci }
        'help'  { Invoke-Help }
        default { Invoke-Help; Die "unknown command '$Command'" }
    }
} finally {
    Pop-Location
}
