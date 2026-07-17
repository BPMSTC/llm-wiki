<#
.SYNOPSIS
  Regenerate STATUS.md — the one-page health snapshot of the wiki and its automation.

.DESCRIPTION
  Pure, deterministic PowerShell (no LLM, no network). Reads the repo on disk and
  rewrites STATUS.md at the repo root. Safe to run any time; the wrapper calls it
  after every scheduled run so the snapshot is always current. Everything here is
  mechanically computable: run history (from the committed ledger), inbox backlog,
  staleness, missing synthesis weeks, and wiki-graph health (page count, link
  density, orphans, red links, index drift).

  For narrative interpretation of these numbers, use the /report skill, which runs
  this script and then reads STATUS.md.
#>

param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"
$now = Get-Date

function Get-IsoWeekLabel {
    param([datetime]$Date)
    $y = [System.Globalization.ISOWeek]::GetYear($Date)
    $w = [System.Globalization.ISOWeek]::GetWeekOfYear($Date)
    "{0}-W{1:D2}" -f $y, $w
}

# ---------------------------------------------------------------------------
# 1. Wiki graph: pages, links, orphans, red links, index drift
# ---------------------------------------------------------------------------
$wikiDir = Join-Path $RepoRoot "wiki"
$pages = @(Get-ChildItem -Path $wikiDir -Filter *.md -File -ErrorAction SilentlyContinue)
$pageSlugs = @($pages | ForEach-Object { $_.BaseName })
$pageSlugSet = @{}
foreach ($s in $pageSlugs) { $pageSlugSet[$s] = $true }

$linkRegex = '\[\[([^\]]+)\]\]'

# Parse a file's wikilink targets, normalized (alias and .md stripped, trimmed).
function Get-LinkTargets {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @() }
    $text = Get-Content -Path $Path -Raw
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($text, $linkRegex)) {
        $t = $m.Groups[1].Value
        if ($t -match '\|') { $t = $t.Split('|')[0] }
        $t = $t.Trim()
        $t = $t -replace '\.md$', ''
        $out.Add($t)
    }
    return $out
}

# Inbound counts from OTHER wiki pages (index.md excluded — it lists everything, so
# an index entry does not rescue a page from being an orphan).
$inbound = @{}
foreach ($s in $pageSlugs) { $inbound[$s] = 0 }
$totalWikiLinks = 0
$redLinks = @{}   # target -> count
foreach ($p in $pages) {
    $targets = Get-LinkTargets -Path $p.FullName
    foreach ($t in $targets) {
        if ($t -like 'sources/*') { continue }   # source references, not wiki-page links
        $totalWikiLinks++
        if ($pageSlugSet.ContainsKey($t)) {
            if ($t -ne $p.BaseName) { $inbound[$t] = $inbound[$t] + 1 }
        } else {
            if ($redLinks.ContainsKey($t)) { $redLinks[$t] = $redLinks[$t] + 1 } else { $redLinks[$t] = 1 }
        }
    }
}
$orphans = @($pageSlugs | Where-Object { $inbound[$_] -eq 0 } | Sort-Object)
$pageCount = $pages.Count
$linkDensity = if ($pageCount -gt 0) { [math]::Round($totalWikiLinks / $pageCount, 1) } else { 0 }

# Index drift: pages missing from index.md, and index entries with no page file.
$indexPath = Join-Path $RepoRoot "index.md"
$indexTargets = @(Get-LinkTargets -Path $indexPath | Where-Object { $_ -notlike 'sources/*' })
$indexTargetSet = @{}
foreach ($t in $indexTargets) { $indexTargetSet[$t] = $true }
$notInIndex = @($pageSlugs | Where-Object { -not $indexTargetSet.ContainsKey($_) } | Sort-Object)
$danglingIndex = @($indexTargets | Where-Object { -not $pageSlugSet.ContainsKey($_) } | Sort-Object -Unique)

# ---------------------------------------------------------------------------
# 2. Inbox backlog
# ---------------------------------------------------------------------------
$inboxDir = Join-Path $RepoRoot "inbox"
$inboxItems = @(Get-ChildItem -Path $inboxDir -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin @('.gitkeep', '.gitignore') })
$inboxCount = $inboxItems.Count

# ---------------------------------------------------------------------------
# 3. Staleness from log.md (last ingest / last synthesis) + first activity
# ---------------------------------------------------------------------------
$logPath = Join-Path $RepoRoot "log.md"
$logLines = @()
if (Test-Path $logPath) { $logLines = Get-Content -Path $logPath }
$logRe = '^- (\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})\s+(\w+):'
$logEntries = foreach ($l in $logLines) {
    $m = [regex]::Match($l, $logRe)
    if ($m.Success) {
        [pscustomobject]@{
            Date = [datetime]::ParseExact("$($m.Groups[1].Value) $($m.Groups[2].Value)", 'yyyy-MM-dd HH:mm', $null)
            Op   = $m.Groups[3].Value
        }
    }
}
$logEntries = @($logEntries)
$lastIngest = ($logEntries | Where-Object { $_.Op -eq 'ingest' } | Select-Object -Last 1).Date
$lastSynth = ($logEntries | Where-Object { $_.Op -eq 'synthesis' } | Select-Object -Last 1).Date
$firstActivity = ($logEntries | Select-Object -First 1).Date

function DaysAgoText {
    param($Date)
    if (-not $Date) { return "never" }
    $d = [math]::Floor(($now - $Date).TotalDays)
    $when = $Date.ToString('yyyy-MM-dd')
    if ($d -le 0) { "today ($when)" } elseif ($d -eq 1) { "1 day ago ($when)" } else { "$d days ago ($when)" }
}

# ---------------------------------------------------------------------------
# 4. Missing synthesis weeks: ISO weeks from first activity to last completed
#    week (weeks strictly before the current one) that have no synthesis file.
# ---------------------------------------------------------------------------
$synthDir = Join-Path $RepoRoot "synthesis"
$synthFiles = @{}
foreach ($f in @(Get-ChildItem -Path $synthDir -Filter *.md -File -ErrorAction SilentlyContinue)) {
    $synthFiles[$f.BaseName] = $true
}
$missingWeeks = New-Object System.Collections.Generic.List[string]
if ($firstActivity) {
    $currentWeekLabel = Get-IsoWeekLabel -Date $now
    $cursor = $firstActivity.Date
    $seen = @{}
    while ($cursor -lt $now) {
        $label = Get-IsoWeekLabel -Date $cursor
        if (-not $seen.ContainsKey($label)) {
            $seen[$label] = $true
            if ($label -ne $currentWeekLabel -and -not $synthFiles.ContainsKey($label)) {
                $missingWeeks.Add($label)
            }
        }
        $cursor = $cursor.AddDays(1)
    }
}

# ---------------------------------------------------------------------------
# 5. Run ledger: last run overall + per skill, and trailing failure streak
# ---------------------------------------------------------------------------
$ledgerPath = Join-Path $RepoRoot "automation-logs\runs.md"
$runRows = New-Object System.Collections.Generic.List[object]
if (Test-Path $ledgerPath) {
    foreach ($l in Get-Content -Path $ledgerPath) {
        # data rows look like: | 2026-07-17T14:30:00 | ingest | ok-pushed | 1 | 47s | ... |
        if ($l -match '^\|\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})\s*\|') {
            $cols = ($l.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
            if ($cols.Count -ge 5) {
                $runRows.Add([pscustomobject]@{
                    Timestamp = $cols[0]; Skill = $cols[1]; Outcome = $cols[2]
                    Commits = $cols[3]; Duration = $cols[4]
                    Detail = if ($cols.Count -ge 6) { $cols[5] } else { "" }
                })
            }
        }
    }
}
function Is-Failure { param($Outcome) return ($Outcome -like 'fail-*') }
$lastRun = if ($runRows.Count -gt 0) { $runRows[$runRows.Count - 1] } else { $null }
$lastIngestRun = ($runRows | Where-Object { $_.Skill -eq 'ingest' } | Select-Object -Last 1)
$lastSynthRun = ($runRows | Where-Object { $_.Skill -eq 'synthesize' } | Select-Object -Last 1)
# Trailing failure streak (most recent consecutive failures, any skill)
$failStreak = 0
for ($i = $runRows.Count - 1; $i -ge 0; $i--) {
    if (Is-Failure $runRows[$i].Outcome) { $failStreak++ } else { break }
}

# ---------------------------------------------------------------------------
# 6. Render STATUS.md
# ---------------------------------------------------------------------------
$L = New-Object System.Collections.Generic.List[string]
$L.Add("# Wiki Status")
$L.Add("")
$L.Add("_Auto-generated by ``scripts/build-status.ps1`` — do not hand-edit. Last built: $($now.ToString('yyyy-MM-dd HH:mm')) (local)._")
$L.Add("")

# Health banner
$problems = New-Object System.Collections.Generic.List[string]
if ($failStreak -gt 0) { $problems.Add("last $failStreak automation run(s) FAILED") }
if ($danglingIndex.Count -gt 0) { $problems.Add("$($danglingIndex.Count) dangling index entr(y/ies)") }
if ($notInIndex.Count -gt 0) { $problems.Add("$($notInIndex.Count) page(s) missing from index") }
if ($missingWeeks.Count -gt 0) { $problems.Add("$($missingWeeks.Count) missing synthesis week(s)") }

if ($problems.Count -gt 0) {
    $L.Add("> ⚠️ **Attention needed:** " + ($problems -join "; ") + ".")
} else {
    $L.Add("> ✅ **All green.** Automation healthy, index in sync, synthesis up to date.")
}
$L.Add("")

# Automation section
$L.Add("## Automation")
$L.Add("")
$L.Add("| Task | Last run | Outcome | Commits | Duration |")
$L.Add("|------|----------|---------|---------|----------|")
function RunCell { param($r) if ($r) { "$($r.Timestamp)" } else { "_never_" } }
$ingOut = if ($lastIngestRun) { $lastIngestRun.Outcome } else { "—" }
$ingCom = if ($lastIngestRun) { $lastIngestRun.Commits } else { "—" }
$ingDur = if ($lastIngestRun) { $lastIngestRun.Duration } else { "—" }
$synOut = if ($lastSynthRun) { $lastSynthRun.Outcome } else { "—" }
$synCom = if ($lastSynthRun) { $lastSynthRun.Commits } else { "—" }
$synDur = if ($lastSynthRun) { $lastSynthRun.Duration } else { "—" }
$L.Add("| ingest | $(RunCell $lastIngestRun) | $ingOut | $ingCom | $ingDur |")
$L.Add("| synthesize | $(RunCell $lastSynthRun) | $synOut | $synCom | $synDur |")
$L.Add("")
if ($failStreak -gt 0 -and $lastRun) {
    $L.Add("**Most recent run failed** — ``$($lastRun.Skill)`` at $($lastRun.Timestamp): $($lastRun.Outcome). $($lastRun.Detail)")
    $L.Add("Check the newest ``automation-logs/*.log`` for the full transcript.")
    $L.Add("")
}
$L.Add("Full run history: [automation-logs/runs.md](automation-logs/runs.md).")
$L.Add("")

# Content health
$L.Add("## Content")
$L.Add("")
$L.Add("- **Inbox backlog:** $inboxCount item(s) waiting to be ingested.")
$L.Add("- **Last ingest:** $(DaysAgoText $lastIngest)")
$L.Add("- **Last synthesis:** $(DaysAgoText $lastSynth)")
if ($missingWeeks.Count -gt 0) {
    $L.Add("- **Missing synthesis weeks:** " + (($missingWeeks | ForEach-Object { $_ }) -join ", "))
}
$L.Add("")

# Wiki graph
$L.Add("## Wiki graph")
$L.Add("")
$L.Add("- **Pages:** $pageCount")
$L.Add("- **Wiki-to-wiki links:** $totalWikiLinks (density $linkDensity per page)")
$L.Add("- **Orphan pages (no inbound links):** $($orphans.Count)" + $(if ($orphans.Count -gt 0) { " — " + (($orphans | ForEach-Object { "[[$_]]" }) -join ", ") } else { "" }))
$redCount = ($redLinks.Keys).Count
$L.Add("- **Red links (targets with no page yet):** $redCount" + $(if ($redCount -gt 0) { " — " + (($redLinks.Keys | Sort-Object | ForEach-Object { "[[$_]] (x$($redLinks[$_]))" }) -join ", ") } else { "" }))
$L.Add("- **Pages missing from index:** $($notInIndex.Count)" + $(if ($notInIndex.Count -gt 0) { " — " + (($notInIndex | ForEach-Object { "[[$_]]" }) -join ", ") } else { "" }))
$L.Add("- **Dangling index entries (no page file):** $($danglingIndex.Count)" + $(if ($danglingIndex.Count -gt 0) { " — " + (($danglingIndex | ForEach-Object { "[[$_]]" }) -join ", ") } else { "" }))
$L.Add("")
$L.Add("_Red links are intentional future-work markers, not errors (see CLAUDE.md). Orphans and index drift are worth a look._")
$L.Add("")

$statusPath = Join-Path $RepoRoot "STATUS.md"
Set-Content -Path $statusPath -Value $L -Encoding UTF8
Write-Output "STATUS.md regenerated ($pageCount pages, inbox=$inboxCount, failStreak=$failStreak)."
