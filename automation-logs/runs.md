# Automation Run Ledger

Machine-readable history of scheduled/headless runs — one row per invocation of `run-skill.ps1`. Unlike the verbose per-run `*.log` files in this folder (gitignored, local-only), this ledger is **committed**, so run history is visible from GitHub and survives a machine change. Appended by the wrapper; never hand-edit. Newest at the bottom.

Outcome values: `ok-pushed` (ran, committed, pushed), `ok-noop` (ran, nothing to commit — empty inbox / quiet week), `fail-pull` (git pull --ff-only failed), `fail-claude` (the skill invocation errored), `fail-push` (commit made locally but push failed).

| Timestamp | Skill | Outcome | Commits | Duration | Detail |
|-----------|-------|---------|---------|----------|--------|
| 2026-07-17T11:06:29 | ingest | fail-claude | 0 | 3s | claude is NOT authenticated for headless use — run 'claude setup-token' (see README > Authentication). |
| 2026-07-17T14:28:54 | ingest | fail-claude | 0 | 4s | claude is NOT authenticated for headless use — run 'claude setup-token' (see README > Authentication). |
| 2026-07-17T15:25:02 | ingest | ok-noop | 0 | 31s | Nothing to ingest/synthesize. |
| 2026-07-17T15:30:42 | ingest | fail-claude | 0 | 4m51s | claude exited with code 1. See the log for the transcript. |
