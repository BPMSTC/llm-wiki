---
created: 2026-07-11
updated: 2026-07-11
---

# Agent Loops

A loop is a job an LLM agent repeats on a schedule — every morning, or every time something new lands — with a structure that makes each run comparable to and smarter than the last. The anatomy is always the same five parts: a schedule (when it wakes), one change per round (fix the single most important thing found, never everything), the same check every time (so this week's score compares against last week's), a state file (plain text memory of what was done and what's queued), and a stop (a hard cap on rounds plus explicit definitions of "done" and "blocked").

## Notes

The state file is the part almost everyone skips and the part that compounds: the model reads its own history before every round, so it never redoes finished work. This is the same shape as experimental method — change one thing, test it, keep it only if it improved, write it down, repeat. The [[fable-loop-library]] applies this anatomy 25 times over across marketing, product, ops, and research jobs.

Loops carry a risk tier that decides how much autonomy they get:

- **Green** — runs alone: only reads things and writes to its own files.
- **Yellow** — drafts, a human approves: replies, page edits, PRs, anything a human ships.
- **Red** — never runs alone: money, production, outbound messages, anything a customer sees.

Two operating rules keep loops from becoming a "token bonfire": run any loop once by hand before scheduling it, and route cheap — a smaller model runs routine rounds, the expensive model steps in only where the cheap one failed (with the failure logged, so escalation is earned rather than default). A model that never tires never stops on its own, so budget and stop rule are load-bearing, not decoration.

This repo already runs a green-tier loop without calling it that: [[scheduled-automation]]'s daily ingest / weekly synthesize, where `log.md` plays the state-file role and "empty inbox = successful no-op" is the stop condition. The counterpart shape — a finish line instead of a cadence — is [[agent-goals]].

## Related

- [[agent-goals]] — the other shape of autonomous work: a finish line instead of a schedule
- [[fable-loop-library]] — 25 worked examples of this anatomy, each with a full prompt
- [[scheduled-automation]] — this repo's own instance of the loop pattern
- [[wiki-maintenance-operations]] — ingest/synthesize, the recurring jobs this repo loops on

## Sources

- [[sources/2026-07-11-fable-loop-library]] — defines the five-part anatomy, risk tiers, and cheap-first routing
