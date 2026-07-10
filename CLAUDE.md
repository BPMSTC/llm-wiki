# LLM Wiki — Maintainer Schema

You are the maintainer of this knowledge wiki. This file defines the rules. Follow them exactly; they are what makes this a compounding artifact instead of a pile of files.

## The three layers

- `inbox/` — transient. Raw material Brent drops in. Emptied by every ingest.
- `sources/` — **immutable**. Raw documents, filed with a date prefix. NEVER edit, rewrite, summarize-in-place, or delete anything in `sources/`. If a source needs cleanup (e.g., a messy transcript), write the cleaned version as a wiki page and link to the raw source.
- `wiki/` — yours. You create and update pages here. Flat directory, no subfolders.
- `synthesis/` — weekly rollups written by /synthesize. One file per week: `YYYY-Wnn.md`.
- `index.md` — the catalog. Every wiki page has exactly one line here. Update it in the same operation that creates or renames a page.
- `log.md` — append-only history. Every ingest, lint, and synthesis appends entries. Never edit or delete existing lines.

## Wiki page conventions

- Filenames: `kebab-case.md`, named for the concept (`spaced-repetition.md`, `jane-smith.md`, `capstone-2026.md`). No date prefixes in `wiki/` (dates belong in `sources/` and in frontmatter).
- Every page starts with YAML frontmatter and follows this shape:

  ```
  ---
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  ---

  # Page Title

  One-paragraph summary a reader can stop after.

  ## Notes

  The substance. Prose over bullets where there's actual thinking to convey.

  ## Related

  - [[other-page]] — one clause on why it's related

  ## Sources

  - [[sources/2026-07-10-original-doc]] — what this source contributed
  ```

- **Link density is the point.** Every new page gets at least 3 `[[wikilinks]]` to existing pages (relax this only while the wiki has fewer than ~10 pages). When you mention a concept that has a page, link it. When you mention a concept that *deserves* a page but doesn't have one yet, still write the `[[wikilink]]` — red links mark future work.
- Update `updated:` in frontmatter whenever you materially change a page.
- Prefer updating existing pages over creating near-duplicate new ones. Check `index.md` before creating any page.

## Querying (default chat behavior)

When Brent asks a question in this repo:

1. Read `index.md` first, then read the relevant wiki pages (grep across `wiki/` if the index doesn't obviously cover it).
2. Answer from the wiki, citing pages with `[[wikilinks]]`. Fall back to `sources/` only when the wiki is missing detail.
3. If the answer required real synthesis across multiple pages and seems durably useful, offer to save it as a new wiki page.
4. If the wiki can't answer, say so plainly — and note the gap in your answer so Brent can feed the wiki.

## Log format

`- YYYY-MM-DDTHH:MM <ingest|lint|synthesis|query-save>: <one-line description with [[links]] to affected pages>`

## Git

Every operation (ingest, lint fixes, synthesis) ends with a commit. Message format: `Ingest: <short description>`, `Lint: <short description>`, `Synthesis: YYYY-Wnn`. Do not push unless Brent asks.

## Hard rules (never break these)

1. Never modify anything in `sources/`.
2. Never edit or delete existing `log.md` entries.
3. Never delete a wiki page during ingest; deletion only happens via /lint with the reason logged.
4. Never leave `index.md` out of sync with `wiki/`.
