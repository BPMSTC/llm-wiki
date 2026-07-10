---
created: 2026-07-10
updated: 2026-07-10
---

# Scheduled Automation

The mechanism that lets [[wiki-maintenance-operations]] run unattended — a wrapper script invoked by Windows Task Scheduler, scoped narrowly enough that no human has to click through a permission prompt.

## Notes

The core design constraint is that a headless, scheduled run must behave identically to Brent triggering a skill by hand — same schema, same commit conventions, just without a person present to approve tool calls. That rules out bypassing permission checks wholesale; instead the wrapper scopes Claude Code's `--allowedTools` to exactly what ingest and synthesize need: file reads/writes and a specific allowlist of git subcommands (`add`, `commit`, `push`, `pull`, `status`, `log`, `mv`). Nothing broader.

The wrapper never force-pulls or force-pushes — a diverged history means Brent touched the repo from elsewhere, which needs a human, not automation. An empty inbox or a quiet week (no new commits produced) is treated as a normal, successful no-op rather than a failure, since daily ingest and weekly synthesis runs will often have nothing to do.

The plan is to run ingest daily and synthesize weekly from local Windows Task Scheduler (not a cloud scheduler), with auto-push enabled only once Brent trusts the output from enough manual runs. This is deliberately being proven out in stages: a manual dry-run sequence first, then registering the Task Scheduler entries.

## Related

- [[wiki-maintenance-operations]] — the ingest/synthesize skills this automates
- [[llm-wiki-repo]] — the repo this automation runs against
- [[capture-workflow]] — the inbox convention that gives scheduled ingest something to check for

## Sources

- [[sources/2026-07-10-automation-test-note]] — describes the wrapper's permission scoping and its Task Scheduler intent
