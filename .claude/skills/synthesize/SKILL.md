---
name: synthesize
description: Write the weekly synthesis — read everything ingested/changed in the past 7 days plus recent log entries, and write synthesis/YYYY-Wnn.md covering themes, contradictions, and open threads. Use when Brent says "synthesize", "weekly rollup", or "what happened this week".
---

# Synthesize

Write `synthesis/YYYY-Wnn.md` for the current ISO week (overwrite if it exists — one file per week, latest run wins).

1. Establish the window: the past 7 days. Use `log.md` and `git log` to find what was ingested and which pages changed.
2. Read the changed pages and new sources from that window.
3. Write the synthesis with these sections:
   - **Themes** — recurring topics across this week's material; what's getting attention.
   - **Connections** — new links between previously unrelated areas of the wiki; things that clicked together.
   - **Contradictions & tensions** — places where this week's input conflicts with existing pages or with itself. Quote both sides.
   - **Open threads** — questions raised but not answered; half-made commitments; obvious gaps worth feeding the wiki next week.
   - Keep it under a page. This is the one file Brent will actually reread — density over completeness.
4. Wikilink every page and source you reference.
5. Append a `synthesis:` line to `log.md`; commit as `Synthesis: YYYY-Wnn`.
6. If nothing was ingested this week, write a two-line synthesis saying so rather than padding.
