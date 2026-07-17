---
name: report
description: Wiki health report — regenerate STATUS.md and give Brent a plain-English read on automation health, backlog, staleness, and wiki-graph drift, flagging anything that needs a human. Use when Brent says "report", "status", "how's the wiki doing", or "health check the automation".
---

# Report

Produce the one-glance health picture of the wiki and its automation, then interpret it.

1. Run the deterministic generator: `pwsh -File scripts/build-status.ps1` (or `powershell -ExecutionPolicy Bypass -File scripts\build-status.ps1`). This rewrites `STATUS.md` from disk — run history (from `automation-logs/runs.md`), inbox backlog, staleness, missing synthesis weeks, and wiki-graph health (pages, link density, orphans, red links, index drift). It is pure PowerShell — no commits, no network.
2. Read the freshly written `STATUS.md`.
3. Give Brent a short narrative in chat — not a re-dump of the table. Lead with the single most important thing (a failing schedule, a growing backlog, an all-clear). Then, only if they matter:
   - **Automation:** is it running on schedule and succeeding? Call out any failure streak by name and point at the newest `automation-logs/*.log`.
   - **Backlog & staleness:** inbox depth, days since last ingest/synthesis, any missing synthesis weeks.
   - **Graph drift:** orphans and index drift are worth acting on. Red links are intentional future-work markers (per CLAUDE.md) — mention them as opportunities, not defects.
4. Distinguish what you can fix mechanically from what needs Brent's judgment. Offer to run `/lint` (for graph/index issues), `/synthesize` (to backfill a missing week), or `/ingest` (to clear a backlog) — but don't do it unless asked; `/report` is read-only.
5. Do **not** commit anything. `STATUS.md` is committed by the automation wrapper on its next run; a manual `/report` just refreshes it locally. If Brent wants the refreshed `STATUS.md` on GitHub now, offer to commit it as `Status: manual report` — but only on request.

`/report` is diagnosis, not repair. It never edits wiki pages, never touches `sources/`, and never pushes.
