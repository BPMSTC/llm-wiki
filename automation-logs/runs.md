# Automation Run Ledger

Machine-readable history of scheduled/headless runs — one row per invocation of `run-skill.ps1`. Unlike the verbose per-run `*.log` files in this folder (gitignored, local-only), this ledger is **committed**, so run history is visible from GitHub and survives a machine change. Appended by the wrapper; never hand-edit. Newest at the bottom.

Outcome values: `ok-pushed` (ran, committed, pushed), `ok-noop` (ran, nothing to commit — empty inbox / quiet week), `fail-pull` (git pull --ff-only failed), `fail-claude` (the skill invocation errored), `fail-push` (commit made locally but push failed).

| Timestamp | Skill | Outcome | Commits | Duration | Detail |
|-----------|-------|---------|---------|----------|--------|
