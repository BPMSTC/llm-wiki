---
created: 2026-07-10
updated: 2026-07-10
---

# Capture Workflow

A convention layered on top of the [[karpathy-llm-wiki-pattern]] in [[llm-wiki-repo]]: a single inbox folder is the only place raw material gets dropped, rather than leaving it to per-item judgment where something belongs. The reasoning mirrors a common failure mode in personal note systems — when there are many possible places to file a new note, people spend the decision budget on filing instead of capturing, and often the note goes nowhere.

## Notes

Concretely, this means `inbox/` is the single inlet; everything else (`sources/`, `wiki/`) is built out of it by the ingest operation, never filed there directly by hand. This is additive to Karpathy's original description, which defines the [[three-layer-architecture]] and [[wiki-maintenance-operations]] but doesn't specify a capture convention — the single-inbox rule is specific to this implementation's design goals.

## Related

- [[llm-wiki-repo]] — the repo that implements this convention
- [[karpathy-llm-wiki-pattern]] — the base pattern this convention is layered onto
- [[wiki-maintenance-operations]] — ingest is the operation that empties the inbox into the other layers

## Sources

- [[sources/2026-07-10-llm-wiki-repo-design]] — describes the single-inbox rationale
