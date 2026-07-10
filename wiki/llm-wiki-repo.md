---
created: 2026-07-10
updated: 2026-07-10
---

# llm-wiki Repo

BPMSTC/llm-wiki, Brent's implementation of the [[karpathy-llm-wiki-pattern]], built with a [[three-layer-architecture]] plus an added [[capture-workflow]] convention (a single `inbox/` folder as the only capture point).

## Notes

The three [[wiki-maintenance-operations]] (ingest, lint, and an added synthesize) are implemented as Claude Code skills in `.claude/skills/`, chosen specifically so behavior is identical whether Brent triggers a skill by hand or a scheduled task triggers it unattended. `CLAUDE.md` is the schema file; `wiki/` is intentionally kept flat with no subfolders, with categories living only as headings in `index.md`.

This page itself was created during the first-ever ingest of this repo, from two seed sources: a note describing Karpathy's pattern and a note describing this repo's own design decisions — a deliberately self-referential first test of the pipeline.

## Related

- [[karpathy-llm-wiki-pattern]] — the pattern this repo implements
- [[three-layer-architecture]] — the structural layers used here
- [[wiki-maintenance-operations]] — implemented here as Claude Code skills
- [[capture-workflow]] — the single-inbox convention added in this repo

## Sources

- [[sources/2026-07-10-karpathy-llm-wiki-pattern]] — background on the pattern being implemented
- [[sources/2026-07-10-llm-wiki-repo-design]] — the design decisions specific to this repo
