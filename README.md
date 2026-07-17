# llm-wiki

A Karpathy-style LLM-maintained knowledge wiki. Raw material goes in `inbox/`; Claude files it into `sources/` (immutable) and writes/updates interlinked pages in `wiki/`. It can run itself on a schedule — a daily ingest and a weekly synthesis — and report its own health.

Pattern: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

## Daily use

- **Add knowledge:** drop any text/markdown/PDF into `inbox/`, then run `/ingest` in Claude Code.
- **Ask questions:** just chat in this repo — Claude consults `index.md` and the wiki.
- **Maintain:** `/lint` finds contradictions, orphans, drift, and stray files. `/synthesize` writes the weekly rollup. `/report` gives you a one-glance health read.
- **Browse the graph:** open the repo as an Obsidian vault (optional).

## Run it unattended

Two Windows Scheduled Tasks drive the wiki hands-off: **LLM-Wiki-Daily-Ingest** (07:00 daily) and **LLM-Wiki-Weekly-Synthesis** (Sunday 20:00). Both call [`scripts/run-skill.ps1`](scripts/run-skill.ps1) via PowerShell 7.

```powershell
# One-time: preflight, then register the tasks
pwsh -File scripts\setup-tasks.ps1 -Action doctor      # check PS7, claude, auth, git push, toasts
pwsh -File scripts\setup-tasks.ps1 -Action register    # (idempotent — safe to re-run)

# Anytime
pwsh -File scripts\setup-tasks.ps1 -Action status      # last run / result / next run per task
pwsh -File scripts\setup-tasks.ps1 -Action remove      # unregister both tasks

# Test a run locally without pushing to origin
pwsh -File scripts\run-skill.ps1 -Skill ingest -NoPush
```

### Authentication (required — only you can do this)

Unattended runs invoke `claude -p` headlessly, which needs its **own** authentication — an interactive `/login` is **not** enough, and this is the single most common reason a scheduled run fails. Mint a long-lived token once:

```powershell
claude setup-token
```

Then confirm with `pwsh -File scripts\setup-tasks.ps1 -Action doctor` — the **claude auth** check should read `[ OK ]`. Until it does, every scheduled run will fail fast (and now say so loudly — see Reporting).

## Reporting

Nothing fails silently. Every run — success, no-op, or failure — is recorded three ways:

- **[STATUS.md](STATUS.md)** — the one page to glance at. Health banner, per-task last run/outcome, inbox backlog, staleness, missing synthesis weeks, wiki-graph health (pages, link density, orphans, red links, index drift), and any uncommitted work a failed run left in the tree. Regenerated on every run by [`scripts/build-status.ps1`](scripts/build-status.ps1) (pure PowerShell, no LLM). Run `/report` for a narrative read.
- **[automation-logs/runs.md](automation-logs/runs.md)** — the committed ledger, one row per run (timestamp, skill, outcome, commits, duration). Visible from GitHub; survives a machine change.
- **A desktop toast** fires on any failure, so a broken schedule announces itself.
- Verbose per-run transcripts land in `automation-logs/*.log` (local-only, gitignored).

## Layout

| Path | What it is |
|------|-----------|
| `inbox/` | transient drop zone; emptied by every ingest |
| `sources/` | **immutable** raw documents, date-prefixed — never edited |
| `wiki/` | the LLM-owned pages (flat, kebab-case) |
| `synthesis/` | weekly rollups, `YYYY-Wnn.md` |
| `index.md` | the catalog — one line per wiki page |
| `log.md` | append-only semantic history |
| `STATUS.md` | auto-generated health snapshot (do not hand-edit) |
| `scripts/` | automation: run-skill, build-status, setup-tasks, notify |

The rules the maintainer follows live in [CLAUDE.md](CLAUDE.md).
