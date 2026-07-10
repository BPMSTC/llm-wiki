---
name: ingest
description: Process everything in inbox/ — file raw material into sources/, create/update wiki pages with backlinks, update index.md, append to log.md, and commit. Use when Brent says "ingest", "process the inbox", or drops new material and asks to file it.
---

# Ingest

Process every item currently in `inbox/`. Follow the schema in CLAUDE.md throughout. If `inbox/` is empty, say so and stop.

For EACH item in `inbox/`, in turn:

1. **Read it fully.** PDFs and images included (read images visually; extract PDF text).
2. **File the raw copy.** Move it to `sources/YYYY-MM-DD-<kebab-case-descriptive-name>.<ext>` (today's date; keep the original extension; pick a name from the content, not the original filename if it's junk like `Untitled(3).md`). This file is now immutable.
3. **Decide what it touches.** Read `index.md` and identify: (a) which existing wiki pages this source updates, (b) what new pages it justifies. A source typically touches 3–15 pages. New pages are for durable concepts/entities/projects — not one page per source.
4. **Write.** Update the existing pages (integrate the new information, don't append a "new stuff" section; resolve or flag contradictions with the previous content). Create the new pages per the conventions in CLAUDE.md. Add `[[wikilinks]]` in BOTH directions — when page A links B, ensure B's Related section links A if the relationship matters from B's side too.
5. **Index.** Add/adjust the `index.md` lines for every page you created or materially changed.
6. **Log.** Append one `ingest:` line to `log.md` naming the source and the pages created/updated.

After all items:

7. **Verify:** `inbox/` is empty (except `.gitkeep`); every new page is in `index.md`; every new page has ≥3 wikilinks (unless wiki has <10 pages).
8. **Commit:** `Ingest: <n> items — <short description>`.
9. **Report to Brent:** what came in, what pages were created/updated (as a readable summary, not a file listing), and any contradictions or gaps you noticed.
