---
created: 2026-07-10
updated: 2026-07-17
---

# Three-Layer Architecture

The structural core of the [[karpathy-llm-wiki-pattern]]: raw sources, the wiki, and the schema, each with a distinct ownership rule. Raw sources are immutable curated inputs — never edited once captured. The wiki is a set of LLM-generated markdown pages (summaries, entity pages, concept pages, synthesis documents) that the LLM owns and continually updates. The schema is a configuration file encoding structural conventions, workflows, and decision rules, which is what turns the LLM into a disciplined maintainer rather than a generic chatbot answering from scratch each time.

## Notes

In [[llm-wiki-repo]], this maps concretely: `sources/` holds date-prefixed immutable files, `wiki/` holds flat, cross-linked concept pages with no subfolders, and `CLAUDE.md` is the schema file. Keeping `wiki/` flat rather than pre-organized into folders is a deliberate choice within this layer — categories live only as headings in the index, since a folder taxonomy decided up front tends to create decision paralysis about where a note belongs and is much harder to reorganize later than a heading.

The [[wiki-maintenance-operations]] (ingest, query, lint) are the verbs that act across these three layers — ingest reads a source and writes to the wiki per the schema; lint audits the wiki against the schema; query reads the wiki to answer questions.

[[harness-handbook]] layers its own representation the same way, for a different kind of source material: an L1 (system overview) → L2 (per-stage overview) → L3 (source-grounded unit) tree that only descends to source detail when a task needs it, with every L3 entry re-validated against the live repository rather than trusted once written — the code equivalent of never editing `sources/` and always re-checking a wiki page's links.

## Related

- [[karpathy-llm-wiki-pattern]] — the overall pattern this architecture implements
- [[wiki-maintenance-operations]] — the operations that act on these three layers
- [[llm-wiki-repo]] — the concrete repo where sources/, wiki/, and CLAUDE.md live
- [[harness-handbook]] — an analogous progressive layering (L1–L3) built for agent harness source code instead of general knowledge

## Sources

- [[sources/2026-07-10-karpathy-llm-wiki-pattern]] — describes the three layers and their ownership rules
- [[sources/2026-07-10-llm-wiki-repo-design]] — describes how this repo maps the layers to concrete folders
