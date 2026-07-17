<#
.SYNOPSIS
  Headless runner for the llm-wiki ingest/synthesize skills, for use from Windows Task Scheduler.

.DESCRIPTION
  Syncs the repo, invokes Claude Code non-interactively to run the named skill with a
  permission scope narrow enough to need no human approval, and pushes only if the
  skill produced new commits. Never force-pulls or force-pushes; an empty inbox (no
  new commits) is treated as a normal, successful no-op.

  Every run — success, no-op, or failure — is recorded two ways: a verbose transcript
  in automation-logs/<timestamp>-<skill>.log (gitignored, local-only) and one row in
  the committed ledger automation-logs/runs.md. After each run STATUS.md is regenerated
  from disk, and any failure raises a desktop toast so a broken schedule announces
  itself instead of waiting to be discovered.
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("ingest", "synthesize")]
    [string]$Skill,

    [string]$Model = "sonnet",

    # Run everything except the git push — for local testing without touching origin.
    [switch]$NoPush
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

. (Join-Path $PSScriptRoot "notify.ps1")

$StartTime = Get-Date
$LogDir = Join-Path $RepoRoot "automation-logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogFile = Join-Path $LogDir "$Timestamp-$Skill.log"
$Ledger = Join-Path $LogDir "runs.md"
$BuildStatus = Join-Path $PSScriptRoot "build-status.ps1"

function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Add-Content -Path $LogFile -Value $line
}

function Get-DurationText {
    $secs = [int]((Get-Date) - $StartTime).TotalSeconds
    if ($secs -lt 60) { "${secs}s" } else { "{0}m{1:D2}s" -f [int]($secs / 60), ($secs % 60) }
}

# Finalize a run: append the ledger row, regenerate STATUS.md, and (on failure) toast.
# $PushStatus controls whether the ledger/STATUS commit is pushed — skipped when the
# remote is unreachable or diverged (fail-pull / fail-push), where pushing can't work.
function Complete-Run {
    param(
        [string]$Outcome,
        [int]$Commits = 0,
        [string]$Detail = "",
        [bool]$PushStatus = $false
    )
    $ts = $StartTime.ToString("yyyy-MM-ddTHH:mm:ss")
    $dur = Get-DurationText
    $safeDetail = ($Detail -replace '\|', '/').Trim()
    Add-Content -Path $Ledger -Value "| $ts | $Skill | $Outcome | $Commits | $dur | $safeDetail |"

    try { & $BuildStatus | Out-Null } catch { Write-Log "WARN: build-status.ps1 failed: $($_.Exception.Message)" }

    if ($PushStatus -and $NoPush) {
        Write-Log "NoPush set — skipping the status commit/push (ledger + STATUS.md updated locally only)."
    }
    if ($PushStatus -and -not $NoPush) {
        git add automation-logs/runs.md STATUS.md 2>&1 | Out-Null
        # Only commit if those two files actually changed.
        $staged = git diff --cached --name-only 2>&1
        if ($staged) {
            git commit -m "Status: $Skill $Outcome ($ts)" 2>&1 | Add-Content -Path $LogFile
            $sp = git push 2>&1
            Add-Content -Path $LogFile -Value $sp
            if ($LASTEXITCODE -ne 0) { Write-Log "WARN: pushing the status commit failed; it remains local." }
        }
    }

    if ($Outcome -like 'fail-*') {
        Send-WikiNotification -Level error `
            -Title "LLM-Wiki: $Skill FAILED" `
            -Message "$Outcome. $safeDetail  See automation-logs\$Timestamp-$Skill.log"
    }
}

Write-Log "=== run-skill.ps1 starting: skill=$Skill model=$Model repo=$RepoRoot ==="

# 1. Sync before doing anything. Never force — a diverged history means Brent
#    touched this repo from elsewhere and it needs a human, not automation.
$pullOutput = git pull --ff-only 2>&1
$pullExit = $LASTEXITCODE
Add-Content -Path $LogFile -Value $pullOutput
if ($pullExit -ne 0) {
    Write-Log "FATAL: git pull --ff-only failed (exit $pullExit). Aborting without touching the wiki. Resolve manually."
    # Diverged/unreachable remote: record locally, do not attempt to push.
    Complete-Run -Outcome "fail-pull" -Detail "git pull --ff-only failed (exit $pullExit); history may have diverged." -PushStatus $false
    exit 1
}

# 2. Invoke Claude Code headlessly, scoped to exactly what ingest/synthesize need.
#    Resolve claude's full path — Task Scheduler's PATH may not include ~/.local/bin.
$claudeExe = (Get-Command claude -ErrorAction SilentlyContinue).Source
if (-not $claudeExe) {
    $fallback = Join-Path $env:USERPROFILE ".local\bin\claude.exe"
    if (Test-Path $fallback) { $claudeExe = $fallback }
}
if (-not $claudeExe) {
    Write-Log "FATAL: 'claude' not found on PATH or at ~/.local/bin. Cannot run the skill."
    Complete-Run -Outcome "fail-claude" -Detail "claude executable not found — check PATH / install location." -PushStatus $true
    exit 1
}

$allowedTools = "Read Write Edit Bash(git add:*) Bash(git commit:*) Bash(git push:*) Bash(git pull:*) Bash(git status:*) Bash(git log:*) Bash(git mv:*)"
$prompt = "/$Skill"

Write-Log "Invoking: $claudeExe -p `"$prompt`" --model $Model --permission-mode acceptEdits --allowedTools `"$allowedTools`""

$claudeOutput = "" | & $claudeExe -p $prompt --model $Model --permission-mode acceptEdits --allowedTools $allowedTools 2>&1
$claudeExit = $LASTEXITCODE
Add-Content -Path $LogFile -Value $claudeOutput

if ($claudeExit -ne 0) {
    Write-Log "FATAL: claude exited with code $claudeExit. Not pushing wiki content."
    # Give a targeted reason when the failure is authentication — the #1 cause of a
    # broken unattended run, and one only Brent can fix (see README 'Authentication').
    $joined = ($claudeOutput | Out-String)
    if ($joined -match 'Not logged in|/login|not authenticated|Invalid API key|authentication') {
        $detail = "claude is NOT authenticated for headless use — run 'claude setup-token' (see README > Authentication)."
    } else {
        $detail = "claude exited with code $claudeExit. See the log for the transcript."
    }
    # Pull succeeded, so recording the failure to the remote is safe and useful.
    Complete-Run -Outcome "fail-claude" -Detail $detail -PushStatus $true
    exit 1
}

# 3. Did the skill produce content commits? No new commits (empty inbox, quiet week)
#    is success, not failure.
$newCommits = git log "origin/main..HEAD" --oneline 2>&1
$commitCount = @($newCommits | Where-Object { $_ -match '\S' }).Count

if (-not $newCommits) {
    Write-Log "No content commits (empty inbox or quiet week)."
    Complete-Run -Outcome "ok-noop" -Commits 0 -Detail "Nothing to ingest/synthesize." -PushStatus $true
    Write-Log "=== run-skill.ps1 finished OK (no-op) ==="
    exit 0
}

Add-Content -Path $LogFile -Value "New commits:`n$newCommits"

# 4. Push the content. On failure, leave the commit local for Brent — never force.
$pushOutput = git push 2>&1
$pushExit = $LASTEXITCODE
Add-Content -Path $LogFile -Value $pushOutput

if ($pushExit -ne 0) {
    Write-Log "FAILURE: git push failed (exit $pushExit). Commit(s) remain local — resolve manually, do not force-push."
    # Remote push is failing, so don't try to push the status commit either.
    Complete-Run -Outcome "fail-push" -Commits $commitCount -Detail "git push failed (exit $pushExit); $commitCount commit(s) remain local." -PushStatus $false
    exit 1
}

Complete-Run -Outcome "ok-pushed" -Commits $commitCount -Detail "$commitCount commit(s) pushed." -PushStatus $true
Write-Log "=== run-skill.ps1 finished OK (pushed) ==="
exit 0
