# llm-wiki

A Karpathy-style LLM-maintained knowledge wiki. Raw material goes in `inbox/`; Claude files it into `sources/` (immutable) and writes/updates interlinked pages in `wiki/`.

- **Add knowledge:** drop any text/markdown/PDF into `inbox/`, then run `/ingest` in Claude Code.
- **Ask questions:** just chat in this repo — Claude consults `index.md` and the wiki.
- **Maintain:** `/lint` finds contradictions, orphans, and stale pages. `/synthesize` writes weekly rollups.

Pattern: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

Open the repo as an Obsidian vault to browse the graph (optional).
