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
Set-Location $PSScriptRoot

function Log($msg)  { Write-Host "==> $msg" -ForegroundColor Blue }
function Warn($msg) { Write-Host "warning: $msg" -ForegroundColor Yellow }
function Die($msg)  { Write-Host "error: $msg" -ForegroundColor Red; exit 1 }
function Run {      # echo, then execute; fail on non-zero exit
    Write-Host "`$ $($args -join ' ')" -ForegroundColor DarkGray
    $rest = @($args | Select-Object -Skip 1)
    & $args[0] @rest
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
function Todo($what) { Die "'$what' is not configured yet - edit dev.ps1 (SETUP)" }

# Local, git-ignored settings and secrets (see .env.example).
if (Test-Path .env) {
    Log 'loading .env'
    Get-Content .env | Where-Object { $_ -match '^\s*[^#\s][^=]*=' } | ForEach-Object {
        $name, $value = $_ -split '=', 2
        [Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim().Trim('"', "'"), 'Process')
    }
}

function Invoke-Setup { Run powershell -NoProfile -File scripts/setup.ps1 }
function Invoke-Build { Todo 'build' }
function Invoke-Test([string]$Tier = 'unit') {
    if ($Tier -notin 'unit', 'integration', 'disruptive', 'all') {
        Die "unknown test tier '$Tier' (unit|integration|disruptive|all)"
    }
    Todo "test $Tier"
}
function Invoke-Check { Todo 'check' }
function Invoke-Ci {
    Run sh scripts/test-hooks.sh
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
  ci                     run what CI runs, locally
  help                   this text

Loads ./.env (git-ignored) if present.
'@
}

switch ($Command) {
    'setup' { Invoke-Setup }
    'build' { Invoke-Build }
    'test'  { if ($Rest) { Invoke-Test $Rest[0] } else { Invoke-Test } }
    'check' { Invoke-Check }
    'ci'    { Invoke-Ci }
    'help'  { Invoke-Help }
    default { Invoke-Help; Die "unknown command '$Command'" }
}
