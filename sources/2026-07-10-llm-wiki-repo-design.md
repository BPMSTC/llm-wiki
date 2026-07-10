This repo (BPMSTC/llm-wiki) is a direct implementation of Karpathy's LLM wiki pattern, with one addition borrowed from a separate blog post about a capture workflow: a single inbox folder as the only place raw material gets dropped, rather than letting people (or the LLM) decide per-item where something belongs.

The layers map directly: inbox/ is the single inlet, sources/ is the immutable raw layer (files get a date prefix like 2026-07-10-example.md and are never touched again after filing), wiki/ is the LLM-owned layer of interlinked concept pages, and CLAUDE.md is the schema — the rules file that makes ingest behavior repeatable instead of ad hoc.

One deliberate choice: wiki/ is kept flat, with no subfolders. Categories live only in index.md, as headings, because forcing pages into a folder taxonomy up front tends to create decision paralysis about where a given note belongs, and folders are much harder to reorganize later than a heading in one file.

The three operations are implemented as Claude Code skills rather than left as freeform instructions, specifically so that ingest, lint, and synthesize behave identically whether Brent triggers them by hand or a scheduled task triggers them unattended. A skill is deterministic in a way that a remembered convention isn't.

The plan explicitly separates the log (log.md, a semantic history of what the maintainer did and why) from git history (the mechanical diff of what changed), because lint and synthesis passes need both: the log tells you the intent behind a change, git tells you the exact content.
