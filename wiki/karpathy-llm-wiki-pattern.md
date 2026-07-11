---
created: 2026-07-10
updated: 2026-07-11
---

# Karpathy LLM Wiki Pattern

Andrej Karpathy's proposed alternative to RAG for durable knowledge bases: instead of retrieving and re-synthesizing raw documents on every query, an LLM incrementally maintains a persistent, cross-linked markdown wiki. The core insight is about *why* human-maintained wikis die and LLM-maintained ones don't: people abandon knowledge bases because the ongoing maintenance (cross-referencing, staying current, resolving contradictions) costs more than it returns, while an LLM can sustain that work indefinitely without fatigue.

## Notes

The pattern rests on a [[three-layer-architecture]] — immutable raw sources, an LLM-owned wiki of interlinked pages, and a schema file encoding conventions — combined with a small set of recurring [[wiki-maintenance-operations]] (ingest, query, lint) that keep the wiki both growing and internally consistent.

Karpathy is explicit that the specific directory layout and tooling are a starting point, not a spec: the abstraction is what matters (three layers, three operations, two supporting index/log files), and the concrete implementation should adapt to the domain. [[llm-wiki-repo]] is one such adaptation, built for Brent's own use with an added [[capture-workflow]] on top.

## Related

- [[three-layer-architecture]] — the sources/wiki/schema structure the pattern is built on
- [[wiki-maintenance-operations]] — the ingest/query/lint operations that keep it alive
- [[llm-wiki-repo]] — a concrete implementation of this pattern
- [[capture-workflow]] — an added convention layered on top in this implementation
- [[agent-loops]] — a sibling Karpathy lineage: his agent recipe (objective, metric, boundaries) as cited by the [[fable-loop-library]]

## Sources

- [[sources/2026-07-10-karpathy-llm-wiki-pattern]] — the original description of the pattern and its rationale
