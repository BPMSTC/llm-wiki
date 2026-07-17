<#
.SYNOPSIS
  Manage the llm-wiki Windows Scheduled Tasks — register, inspect, remove, or run a
  preflight doctor. One place for the whole automation lifecycle.

.DESCRIPTION
  Two tasks drive the wiki unattended:
    LLM-Wiki-Daily-Ingest     — daily 07:00, runs run-skill.ps1 -Skill ingest
    LLM-Wiki-Weekly-Synthesis — Sunday 20:00, runs run-skill.ps1 -Skill synthesize

  Both run under the current user, only when logged on, via pwsh.exe (PowerShell 7 —
  required by build-status.ps1). Registration is idempotent (-Force), so re-running
  'register' safely updates existing tasks.

.EXAMPLE
  pwsh -File scripts/setup-tasks.ps1                 # status (default, read-only)
.EXAMPLE
  pwsh -File scripts/setup-tasks.ps1 -Action doctor  # preflight: pwsh, claude, auth, git push, toast
.EXAMPLE
  pwsh -File scripts/setup-tasks.ps1 -Action register
.EXAMPLE
  pwsh -File scripts/setup-tasks.ps1 -Action remove
#>

param(
    [ValidateSet("status", "register", "remove", "doctor")]
    [string]$Action = "status"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Runner = Join-Path $PSScriptRoot "run-skill.ps1"

$Tasks = @(
    @{ Name = "LLM-Wiki-Daily-Ingest";     Skill = "ingest";     Trigger = { New-ScheduledTaskTrigger -Daily -At 7:00AM } },
    @{ Name = "LLM-Wiki-Weekly-Synthesis"; Skill = "synthesize"; Trigger = { New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 8:00PM } }
)

function Resolve-Pwsh {
    $p = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
    if (-not $p) { $p = "C:\Program Files\PowerShell\7\pwsh.exe" }
    if (-not (Test-Path $p)) { throw "pwsh.exe (PowerShell 7) not found. Install it — the wiki scripts require it." }
    return $p
}

function Decode-Result {
    param($Code)
    switch ($Code) {
        0 { "OK (0)" }
        1 { "FAILED (1)" }
        267009 { "currently running (267009)" }
        267011 { "never run (267011)" }
        267014 { "last run terminated by user (267014)" }
        default { "code $Code" }
    }
}

switch ($Action) {

    "register" {
        $pwshExe = Resolve-Pwsh
        Write-Host "Registering tasks with: $pwshExe" -ForegroundColor Cyan
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
        $settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable `
            -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)
        foreach ($t in $Tasks) {
            $taskArgs = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$Runner`" -Skill $($t.Skill)"
            $taskAction = New-ScheduledTaskAction -Execute $pwshExe -Argument $taskArgs -WorkingDirectory $RepoRoot
            $taskTrigger = & $t.Trigger
            Register-ScheduledTask -TaskName $t.Name -Action $taskAction -Trigger $taskTrigger -Settings $settings `
                -Principal $principal -Description "llm-wiki unattended $($t.Skill) (see scripts/run-skill.ps1)" -Force | Out-Null
            Write-Host "  registered $($t.Name) -> $($t.Skill)" -ForegroundColor Green
        }
        Write-Host "`nDone. Run with -Action status to verify, or -Action doctor to preflight auth/push." -ForegroundColor Cyan
    }

    "remove" {
        foreach ($t in $Tasks) {
            if (Get-ScheduledTask -TaskName $t.Name -ErrorAction SilentlyContinue) {
                Unregister-ScheduledTask -TaskName $t.Name -Confirm:$false
                Write-Host "  removed $($t.Name)" -ForegroundColor Yellow
            } else {
                Write-Host "  $($t.Name) not present" -ForegroundColor DarkGray
            }
        }
    }

    "status" {
        foreach ($t in $Tasks) {
            $task = Get-ScheduledTask -TaskName $t.Name -ErrorAction SilentlyContinue
            Write-Host "=== $($t.Name) ===" -ForegroundColor Cyan
            if (-not $task) { Write-Host "  NOT REGISTERED — run: setup-tasks.ps1 -Action register`n" -ForegroundColor Yellow; continue }
            $info = $task | Get-ScheduledTaskInfo
            $act = $task.Actions | Select-Object -First 1
            $runner = ($act.Execute -split '\\')[-1]
            Write-Host ("  state       : {0}" -f $task.State)
            Write-Host ("  runs via    : {0}" -f $runner)
            Write-Host ("  last run    : {0}" -f $info.LastRunTime)
            $res = Decode-Result $info.LastTaskResult
            $col = if ($info.LastTaskResult -eq 0) { "Green" } elseif ($info.LastTaskResult -in 267011,267009) { "DarkGray" } else { "Red" }
            Write-Host ("  last result : {0}" -f $res) -ForegroundColor $col
            Write-Host ("  next run    : {0}`n" -f $info.NextRunTime)
        }
        Write-Host "Health snapshot: STATUS.md   |   run history: automation-logs/runs.md" -ForegroundColor DarkGray
    }

    "doctor" {
        Write-Host "Preflight for unattended runs:`n" -ForegroundColor Cyan
        $ok = $true

        # pwsh
        try { $p = Resolve-Pwsh; Write-Host "  [ OK ] PowerShell 7 : $p" -ForegroundColor Green }
        catch { $ok = $false; Write-Host "  [FAIL] PowerShell 7 : $($_.Exception.Message)" -ForegroundColor Red }

        # claude on PATH
        $claudeExe = (Get-Command claude -ErrorAction SilentlyContinue).Source
        if (-not $claudeExe) { $fb = Join-Path $env:USERPROFILE ".local\bin\claude.exe"; if (Test-Path $fb) { $claudeExe = $fb } }
        if ($claudeExe) { Write-Host "  [ OK ] claude found  : $claudeExe" -ForegroundColor Green }
        else { $ok = $false; Write-Host "  [FAIL] claude not found on PATH or ~/.local/bin" -ForegroundColor Red }

        # claude authenticated (the usual culprit) — tiny headless probe
        if ($claudeExe) {
            $probe = "" | & $claudeExe -p "reply with the single word: ok" --model sonnet 2>&1 | Out-String
            if ($LASTEXITCODE -eq 0 -and $probe -notmatch 'Not logged in|/login|not authenticated') {
                Write-Host "  [ OK ] claude auth   : headless invocation succeeded" -ForegroundColor Green
            } else {
                $ok = $false
                Write-Host "  [FAIL] claude auth   : headless 'claude -p' is NOT logged in." -ForegroundColor Red
                Write-Host "         Fix (you must do this): run  claude setup-token  in a terminal to mint a" -ForegroundColor Yellow
                Write-Host "         long-lived token for automation, then re-run this doctor." -ForegroundColor Yellow
            }
        }

        # git push reachability (non-destructive dry run)
        Push-Location $RepoRoot
        try {
            $dry = git push --dry-run 2>&1 | Out-String
            if ($LASTEXITCODE -eq 0) { Write-Host "  [ OK ] git push      : remote reachable and authenticated" -ForegroundColor Green }
            else { $ok = $false; Write-Host "  [FAIL] git push      : $($dry.Trim())" -ForegroundColor Red }
        } finally { Pop-Location }

        # BurntToast (failure notifications)
        if (Get-Module -ListAvailable -Name BurntToast) { Write-Host "  [ OK ] BurntToast    : installed (failure toasts enabled)" -ForegroundColor Green }
        else { Write-Host "  [warn] BurntToast    : not installed — failures fall back to a balloon tip" -ForegroundColor Yellow }

        Write-Host ""
        if ($ok) { Write-Host "All required checks passed — automation is ready to run unattended." -ForegroundColor Green }
        else { Write-Host "One or more required checks FAILED — fix the items above before trusting the schedule." -ForegroundColor Red }
    }
}
