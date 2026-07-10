---
created: 2026-07-10
updated: 2026-07-10
---

# Wiki Maintenance Operations

Three recurring operations keep a [[karpathy-llm-wiki-pattern]]-style wiki both growing and coherent. Ingest reads a new source, writes or updates roughly 10-15 existing pages, maintains cross-references, and logs the activity. Query searches the wiki and synthesizes an answer with citations, occasionally saving a good answer back into the wiki as a new page. Lint is a periodic health pass that looks for contradictions, stale claims, orphaned pages, and missing cross-references.

## Notes

In [[llm-wiki-repo]], these three operations are implemented as Claude Code skills (`/ingest`, `/lint`, `/synthesize` — synthesize being a weekly-rollup variant not present in Karpathy's original description, added from the [[capture-workflow]] idea) rather than left as freeform conventions. The reasoning: a skill behaves identically whether triggered by hand or by an unattended scheduled task, whereas a remembered convention drifts session to session.

Two supporting files anchor these operations across both the original pattern and this implementation: an index (`index.md`) cataloging every wiki page with a one-line summary, and a log (`log.md`) that is an append-only, timestamped record of every ingest, query-save, and lint pass — distinct from git history, since the log captures intent ("why") while git captures the mechanical diff ("what").

## Related

- [[karpathy-llm-wiki-pattern]] — the pattern these operations belong to
- [[three-layer-architecture]] — the layers these operations act across
- [[llm-wiki-repo]] — where these operations are implemented as skills
- [[capture-workflow]] — contributed the synthesize/weekly-rollup operation

## Sources

- [[sources/2026-07-10-karpathy-llm-wiki-pattern]] — describes ingest, query, and lint
- [[sources/2026-07-10-llm-wiki-repo-design]] — describes the skills implementation and the log-vs-git distinction
