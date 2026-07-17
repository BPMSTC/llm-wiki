---
created: 2026-07-10
updated: 2026-07-17
---

# llm-wiki Repo

BPMSTC/llm-wiki, Brent's implementation of the [[karpathy-llm-wiki-pattern]], built with a [[three-layer-architecture]] plus an added [[capture-workflow]] convention (a single `inbox/` folder as the only capture point).

## Notes

The three [[wiki-maintenance-operations]] (ingest, lint, and an added synthesize) are implemented as Claude Code skills in `.claude/skills/`, chosen specifically so behavior is identical whether Brent triggers a skill by hand or a scheduled task triggers it unattended. `CLAUDE.md` is the schema file; `wiki/` is intentionally kept flat with no subfolders, with categories living only as headings in `index.md`.

[[scheduled-automation]] is the piece that makes the "unattended" half real: a wrapper script meant to run daily/weekly from Windows Task Scheduler, with Claude Code's tool permissions scoped narrowly rather than bypassed.

This page itself was created during the first-ever ingest of this repo, from two seed sources: a note describing Karpathy's pattern and a note describing this repo's own design decisions — a deliberately self-referential first test of the pipeline.

The `/ingest`, `/lint`, and `/synthesize` skills all run on Claude Code, an [[agent-harness]] — the paper behind [[harness-handbook]] names Claude Code specifically as a production system where harness design is treated as a first-class factor in reliability, which is exactly the runtime this repo's own automation depends on.

## Related

- [[karpathy-llm-wiki-pattern]] — the pattern this repo implements
- [[three-layer-architecture]] — the structural layers used here
- [[wiki-maintenance-operations]] — implemented here as Claude Code skills
- [[capture-workflow]] — the single-inbox convention added in this repo
- [[scheduled-automation]] — the Task Scheduler wrapper that runs these skills unattended
- [[agent-harness]] — Claude Code, the runtime this repo's skills execute inside of

## Sources

- [[sources/2026-07-10-karpathy-llm-wiki-pattern]] — background on the pattern being implemented
- [[sources/2026-07-10-llm-wiki-repo-design]] — the design decisions specific to this repo
- [[sources/2026-07-10-automation-test-note]] — the scheduled-automation wrapper's permission scoping
