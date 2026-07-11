# Wiki Index

The catalog of every page in `wiki/`. Updated on every ingest. One line per page: wikilink, then an em-dash, then a one-line summary. Grouped under `##` category headings; categories emerge from content — create them as needed, merge them when they get thin.

## Pattern & Architecture

- [[karpathy-llm-wiki-pattern]] — Karpathy's LLM-maintained wiki alternative to RAG, and why it doesn't decay the way human wikis do.
- [[three-layer-architecture]] — the sources/wiki/schema structure the pattern is built on.
- [[wiki-maintenance-operations]] — the ingest/query/lint (plus synthesize) operations that keep the wiki alive.
- [[capture-workflow]] — the single-inbox capture convention layered onto the base pattern, plus the Playwright pipeline for gated/JS-heavy web captures.

## Agent Patterns

- [[agent-loops]] — the five-part anatomy of a scheduled agent job (schedule, one change, fixed check, state file, stop) plus risk tiers and cheap-first routing.
- [[agent-goals]] — finish-line agent work: judge-in-the-conversation mechanics and the pasted-proof done contract.
- [[fable-loop-library]] — Machina's 25-workflow library for Fable 5, the source of the loop/goal vocabulary.

## This Repo

- [[llm-wiki-repo]] — BPMSTC/llm-wiki, this repo's implementation of the pattern.
- [[scheduled-automation]] — the Task Scheduler wrapper that runs ingest/synthesize unattended with scoped permissions.
