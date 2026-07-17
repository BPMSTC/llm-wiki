---
created: 2026-07-17
updated: 2026-07-17
---

# Harness Handbook

A behavior-centric representation for [[agent-harness]] codebases, built automatically from source via static analysis plus LLM-assisted organization, that links every runtime behavior directly to the code implementing it. Instead of a repo map organized by files and functions, it's organized around what the system does — so a coding agent can find "everywhere that implements X" before touching any file, then verify those locations against the live source before planning an edit.

## Notes

The representation is a three-level document tree (L1 system overview → L2 per-stage component overview → L3 source-grounded unit detail, each L3 entry pinned to an exact file:line locator) plus a cross-stage state-register view that tracks values written in one execution stage and read in another — the kind of coupling that's easy to miss when tracing code file-by-file. Reading follows **progressive disclosure**: start shallow at L1, only descend to L3 when the task demands it. Construction has two granularity modes depending on the harness: function-as-leaf (used on Terminus-2, a small harness with a trustworthy hand-authored stage skeleton) and file-as-leaf (used on Codex, a large multi-crate Rust monorepo where the stage skeleton has to be inferred rather than seeded).

The navigation workflow, **Behavior-Guided Progressive Disclosure (BGPD)**, is the localization half of the design: it narrows from L1/L2 (which stages match the request), through the state-register view (which other stages are coupled via shared state), to L3 entries and their call-graph neighbors, and only then opens the real repository to verify each candidate site is still current. A locator that can't be revalidated against the live source is frozen and dropped from consideration rather than trusted stale — the repository, not the handbook, stays the authority. After every edit, a resynchronization step updates only the affected handbook entries rather than rebuilding from scratch, so the handbook and the code never drift apart for long.

Evaluated against two harnesses (Terminus-2, Codex) with 30 realistic modification requests each, handbook-guided planning beat unassisted repo exploration on plan quality (overall win rate +10.0 to +18.9 points), localization F1 against reference plans (+5.0 to +18.8 points), and complete-miss rate — all while using *fewer* planner tokens (−8.6% to −12.7%), and it let a weaker planner (DeepSeek-V4-Pro) match stronger models' (Opus 4.8, GPT-5.5) localization quality. The gains were largest on requests with scattered implementation sites, rarely-executed paths, and cross-module interactions — exactly the cases where reading files top-down misses things.

This wiki is a much smaller, much less formal instance of the same bet: [[karpathy-llm-wiki-pattern]] also organizes knowledge around concepts rather than storage location, keeps pages linked to their grounding raw sources rather than paraphrased away from them, and has its own resync-like check — `/lint` auditing that every wikilink still resolves and every page is still current, the same role Harness Handbook's locator revalidation plays for source code. The paper's authors note their own next step is closing this loop autonomously — using the handbook as shared memory so an agent can localize, plan, execute, and resync a harness change end to end, which is close to what [[agent-loops]] already describes for recurring jobs, just applied to the harness's own source instead of a business task.

## Related

- [[agent-harness]] — the class of system this representation targets, and behavior localization as its central evolution bottleneck
- [[karpathy-llm-wiki-pattern]] — a sibling bet on behavior/concept-centric organization over file-centric organization, applied to general knowledge instead of code
- [[three-layer-architecture]] — a structurally similar progressive layering (raw source → curated knowledge → schema) to Harness Handbook's L1–L3 tree
- [[agent-loops]] — the localize→plan→execute→resync loop the paper's authors want to close autonomously is a harness-scoped instance of this loop anatomy
- [[llm-wiki-repo]] — runs on Claude Code, cited in the paper as a production example of harness design mattering

## Sources

- [[sources/2026-07-17-harness-handbook-paper]] — the full paper: representation, construction pipeline, BGPD workflow, and the Terminus-2/Codex evaluation
