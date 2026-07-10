<#
.SYNOPSIS
  Headless runner for the llm-wiki ingest/synthesize skills, for use from Windows Task Scheduler.

.DESCRIPTION
  Syncs the repo, invokes Claude Code non-interactively to run the named skill with a
  permission scope narrow enough to need no human approval, and pushes only if the
  skill produced new commits. Never force-pulls or force-pushes; an empty inbox (no
  new commits) is treated as a normal, successful no-op.
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("ingest", "synthesize")]
    [string]$Skill,

    [string]$Model = "sonnet"
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

$LogDir = Join-Path $RepoRoot "automation-logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogFile = Join-Path $LogDir "$Timestamp-$Skill.log"

function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Add-Content -Path $LogFile -Value $line
}

Write-Log "=== run-skill.ps1 starting: skill=$Skill model=$Model repo=$RepoRoot ==="

# 1. Sync before doing anything. Never force — a diverged history means Brent
#    touched this repo from elsewhere and it needs a human, not automation.
$pullOutput = git pull --ff-only 2>&1
$pullExit = $LASTEXITCODE
Add-Content -Path $LogFile -Value $pullOutput
if ($pullExit -ne 0) {
    Write-Log "FATAL: git pull --ff-only failed (exit $pullExit). Aborting without touching the wiki. Resolve manually."
    exit 1
}

# 2. Invoke Claude Code headlessly, scoped to exactly what ingest/synthesize need.
$allowedTools = "Read Write Edit Bash(git add:*) Bash(git commit:*) Bash(git push:*) Bash(git pull:*) Bash(git status:*) Bash(git log:*) Bash(git mv:*)"
$prompt = "/$Skill"

Write-Log "Invoking: claude -p `"$prompt`" --model $Model --permission-mode acceptEdits --allowedTools `"$allowedTools`""

$claudeOutput = & claude -p $prompt --model $Model --permission-mode acceptEdits --allowedTools $allowedTools 2>&1
$claudeExit = $LASTEXITCODE
Add-Content -Path $LogFile -Value $claudeOutput

if ($claudeExit -ne 0) {
    Write-Log "FATAL: claude exited with code $claudeExit. Not pushing."
    exit 1
}

# 3. No new commits (e.g. empty inbox, quiet week) is success, not failure.
$newCommits = git log "origin/main..HEAD" --oneline 2>&1
if (-not $newCommits) {
    Write-Log "Nothing to push (no new commits — likely an empty inbox or quiet week). Treating as success."
    Write-Log "=== run-skill.ps1 finished OK (no-op) ==="
    exit 0
}

Add-Content -Path $LogFile -Value "New commits:`n$newCommits"

# 4. Push. On failure, leave the commit local for Brent to resolve by hand — never force.
$pushOutput = git push 2>&1
$pushExit = $LASTEXITCODE
Add-Content -Path $LogFile -Value $pushOutput

if ($pushExit -ne 0) {
    Write-Log "FAILURE: git push failed (exit $pushExit). Commit(s) remain local — resolve manually, do not force-push."
    exit 1
}

Write-Log "=== run-skill.ps1 finished OK (pushed) ==="
exit 0
