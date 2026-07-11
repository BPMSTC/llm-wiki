---
created: 2026-07-11
updated: 2026-07-11
---

# Fable Loop Library

"The Fable Loop Library: 25 Workflows on Autopilot" — an X Article by Machina (@EXM7777, weeklyaiops.com), published 2026-07-04, cataloging 25 scheduled-agent workflows for Claude Fable 5 in Claude Code. Each workflow is a fully specified [[agent-loops|loop]] or [[agent-goals|goal]]: a name, the exact tool it plugs into (hosted MCP or API key), a risk tier, a budget/stop rule, and a complete copy-paste prompt. The library's framing is Karpathy's agent recipe — "here's an objective, here's a metric, here's your boundaries... and go."

## Notes

The 25 workflows are grouped into four business areas:

- **Marketing + content (1–9):** answer-engine gap loop (Exa MCP), programmatic-page quality gate (Search Console MCP), share-of-model brand watch (Perplexity API), competitor-content watch (DataForSEO + Firecrawl), content-brief backlog (Search Console), X content-idea miner (twitterapi.io + Typefully), ad-creative fatigue drafting (Meta Marketing API), expectation-gap audit (Zendesk MCP), presale questions loop.
- **Product (10–12):** brand-mention feature radar (Reddit API + HN Algolia + Exa), review-mine to roadmap (app store review APIs), drop-point copy loop (PostHog MCP).
- **Business ops (13–18):** inbox-to-decision triage (Gmail MCP), month-close reconciliation prep (QuickBooks API), SOP-drift catcher (Notion MCP), proposal/RFP backlog drafter, KPI anomaly watch (PostHog + Stripe), unpaid-invoice chaser (Stripe API).
- **Research + decisions (19–25):** overnight intel refresh (Exa + Firecrawl), regulatory/source digest (Firecrawl MCP), hard-question escalation queue, kill-criteria loop, pre-mortem loop, repeat-offender digest, shadow prompt loop.

The design vocabulary is consistent across all 25 and is the durable part: every workflow carries a schedule, a one-change-per-round rule, a fixed rubric so runs compare week over week, a state file as memory between runs, and a hard stop — the anatomy detailed in [[agent-loops]]. Workflows that end at a finish line rather than a cadence use the [[agent-goals]] contract instead. Each diagram also encodes safety posture: risk tier (green/yellow/red), what the tool connection is *not* granted (e.g., Gmail MCP with send/delete withheld), and "the send button stays human."

Two cost arguments recur: Fable 5 is priced as the most expensive model on the market (moving off subscription to pay-as-you-go credits on 2026-07-07), so cheap-first routing — a smaller model runs routine rounds, Fable takes only logged failures — and hard round caps are framed as billing survival, not style. The article promises a part 2 with 25 more workflows.

The full prompts live in the 25 diagram images, not the article body text — the captured source bundle has both.

## Related

- [[agent-loops]] — the loop anatomy every workflow in this library instantiates
- [[agent-goals]] — the finish-line contract used for non-recurring work
- [[scheduled-automation]] — this repo's own (green-tier) instance of the same pattern
- [[karpathy-llm-wiki-pattern]] — same author-cited lineage: Karpathy patterns for LLM-run systems

## Sources

- [[sources/2026-07-11-fable-loop-library]] — full article text, capture notes, and all 26 diagram images (hero + one per workflow, each with its complete prompt)
