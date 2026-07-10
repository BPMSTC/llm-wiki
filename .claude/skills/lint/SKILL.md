---
name: lint
description: Wiki health check — find contradictions, orphan pages, stale content, index drift, and broken/missing links; fix the mechanical issues and report the judgment calls. Use when Brent says "lint", "health check", or "clean up the wiki".
---

# Lint

Audit the wiki against the schema in CLAUDE.md. Fix what is mechanical; report what needs judgment.

**Check, in order:**

1. **Index drift** — every file in `wiki/` has exactly one `index.md` line and vice versa. Fix silently.
2. **Broken links** — `[[wikilinks]]` pointing at pages that don't exist. Red links to concepts that *deserve* pages are fine (list them as "wanted pages"); links that are typos/renames get fixed.
3. **Orphans** — pages with zero inbound links from other wiki pages. Add genuinely warranted links from related pages; if none exist, report the orphan rather than forcing fake links.
4. **Staleness** — pages whose `updated:` date is old AND whose content plausibly changed (projects, people, ongoing work — not stable concepts). Report; don't guess at updates.
5. **Contradictions** — statements in one page that conflict with another. Report each with both quotes and page links; fix only when one side is clearly a superseded fact.
6. **Duplicates** — near-duplicate pages that should merge. Report; merge only with Brent's ok.

**Then:**

- Append a `lint:` line to `log.md` summarizing what was fixed and what was flagged.
- Commit fixes: `Lint: <short description>`.
- Report to Brent: fixed items in one short list, judgment-call items (contradictions, merges, stale pages, orphans) with enough context to decide.
- Page deletions/merges happen only after Brent confirms, and get their own log line.
