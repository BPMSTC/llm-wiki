---
created: 2026-07-17
updated: 2026-07-17
---

# Agent Harness

The runtime software layer around a foundation model that turns raw model capability into a working agent: it constructs prompts, manages state, invokes tools, and controls execution across system components. The model decides what to do; the harness decides how that decision becomes prompts, tool calls, retries, and state transitions. Industrial coding agents like Claude Code and Codex are cited as production examples where harness design, not just model choice, is treated as the key factor in reliability.

## Notes

As models, APIs, execution environments, and application requirements change, the harness has to keep changing with them — this recurring engineering problem is called harness evolution. The bottleneck isn't writing the edit, it's finding every place in the harness that implements the behavior being changed (**behavior localization**): production harnesses distribute a single behavior across many files, functions, execution stages, and shared state, while a change request describes the desired behavior in plain language, not a file path. [[harness-handbook]] is one proposed answer: a representation that reorganizes a harness codebase around behavior instead of files, specifically to make localization tractable for both human developers and coding agents.

This repo's own automation ([[scheduled-automation]], the `/ingest` and `/synthesize` skills under [[wiki-maintenance-operations]]) runs on top of Claude Code, making it — at a small scale — a consumer of an agent harness rather than a harness itself. The wiki's own layered structure ([[three-layer-architecture]]) and its instinct to organize by concept rather than by file ([[karpathy-llm-wiki-pattern]]) turns out to rhyme with how Harness Handbook organizes source code: both bet that an LLM navigates and maintains knowledge better when it's structured around "what this is for" rather than "where this lives."

## Related

- [[harness-handbook]] — a behavior-centric representation built to solve behavior localization in agent harnesses
- [[karpathy-llm-wiki-pattern]] — a structurally similar bet (concept-centric organization over file/location-centric) applied to general knowledge instead of code
- [[llm-wiki-repo]] — this repo, itself built and run on top of an agent harness (Claude Code)
- [[agent-loops]] — the scheduled-job pattern that runs inside an agent harness like Claude Code

## Sources

- [[sources/2026-07-17-harness-handbook-paper]] — introduces the harness abstraction and harness evolution as the motivating problem
