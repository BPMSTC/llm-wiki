# Build Plan: Karpathy-Style LLM Wiki

This document is the complete implementation plan for this repository. It is written to be executed by Claude (Sonnet) in Claude Code, working in this repo. Follow it in order. Where exact file content is given, use it verbatim unless it conflicts with something you observe in the repo — in that case, stop and ask Brent.

**Do not improve, extend, or reorganize beyond what this plan specifies.** The design decisions here are deliberate (rationale in the Appendix). Scope creep is the failure mode.

---

## What we're building

A persistent, self-maintaining markdown knowledge wiki, per Andrej Karpathy's "LLM Knowledge Bases" pattern (https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), with a capture workflow layered on top (single inbox, immutable raw sources, scheduled processing).

Three layers:

1. **Sources** (`sources/`) — immutable raw documents. Never edited by anyone after ingest.
2. **Wiki** (`wiki/`) — LLM-written and LLM-maintained markdown pages, densely cross-linked with `[[wikilinks]]`. This is the compounding artifact.
3. **Schema** (`CLAUDE.md`) — the conventions and workflows that make Claude a disciplined maintainer instead of a generic chatbot.

Three operations, implemented as skills:

- **`/ingest`** — process everything in `inbox/`: file raw material into `sources/`, create/update wiki pages, update the index, log the activity, commit.
- **`/lint`** — health check: contradictions, orphans, stale pages, missing links.
- **`/synthesize`** — weekly rollup of what changed and what themes emerged.

No database, no embeddings, no server. Grep + `index.md` is the retrieval system. Obsidian can open the repo as a vault but is optional.

---

## Phase 1: Repository scaffold

Create this structure:

```
llm-wiki/
├── CLAUDE.md              # the schema (content in Phase 2)
├── PLAN.md                # this file (already exists)
├── README.md              # brief human-facing overview
├── index.md               # catalog of all wiki pages
├── log.md                 # append-only activity log
├── .gitignore
├── inbox/
│   └── .gitkeep
├── sources/
│   └── .gitkeep
├── wiki/
│   └── .gitkeep
├── synthesis/
│   └── .gitkeep
└── .claude/
    └── skills/
        ├── ingest/SKILL.md
        ├── lint/SKILL.md
        └── synthesize/SKILL.md
```

### `index.md` (initial content)

```markdown
# Wiki Index

The catalog of every page in `wiki/`. Updated on every ingest. One line per page: wikilink, then an em-dash, then a one-line summary. Grouped under `##` category headings; categories emerge from content — create them as needed, merge them when they get thin.

*No pages yet. Run /ingest with something in inbox/ to start.*
```

### `log.md` (initial content)

```markdown
# Activity Log

Append-only. Newest entries at the bottom. Never edit or delete existing entries.

Format: `- YYYY-MM-DDTHH:MM <operation>: <description>`

---

```

### `README.md` (initial content)

```markdown
# llm-wiki

A Karpathy-style LLM-maintained knowledge wiki. Raw material goes in `inbox/`; Claude files it into `sources/` (immutable) and writes/updates interlinked pages in `wiki/`.

- **Add knowledge:** drop any text/markdown/PDF into `inbox/`, then run `/ingest` in Claude Code.
- **Ask questions:** just chat in this repo — Claude consults `index.md` and the wiki.
- **Maintain:** `/lint` finds contradictions, orphans, and stale pages. `/synthesize` writes weekly rollups.

Pattern: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

Open the repo as an Obsidian vault to browse the graph (optional).
```

### `.gitignore`

```
.obsidian/
*.tmp
Thumbs.db
.DS_Store
```

(`.obsidian/` is ignored so Obsidian UI state doesn't pollute the repo. If Brent later wants to share Obsidian config, he'll un-ignore it.)

Commit: `Scaffold wiki structure`

---

## Phase 2: CLAUDE.md — the schema

Create `CLAUDE.md` with exactly this content:

```markdown
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
```

Commit: `Add maintainer schema (CLAUDE.md)`

---

## Phase 3: Skills

Claude Code skills live at `.claude/skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`). Create these three.

### `.claude/skills/ingest/SKILL.md`

```markdown
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
```

### `.claude/skills/lint/SKILL.md`

```markdown
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
```

### `.claude/skills/synthesize/SKILL.md`

```markdown
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
```

Commit: `Add ingest, lint, and synthesize skills`

---

## Phase 4: Verification (required — do not skip)

Prove the pipeline works end-to-end with real material:

1. Create two small test documents in `inbox/` yourself (e.g., a short note about the Karpathy LLM-wiki pattern, and a short note about this repo's own design). Real prose, a few paragraphs each — not lorem ipsum.
2. Run the `/ingest` skill.
3. Verify against this checklist:
   - [ ] `inbox/` is empty
   - [ ] Both raw files are in `sources/` with today's date prefix, unmodified
   - [ ] Wiki pages exist, follow the template (frontmatter, summary paragraph, Notes, Related, Sources)
   - [ ] Pages link to each other with `[[wikilinks]]` in both directions
   - [ ] `index.md` lists every page with a one-line summary
   - [ ] `log.md` has an ingest entry with a parseable timestamp
   - [ ] A commit exists with the `Ingest:` prefix
4. Run `/lint` — it should come back clean or nearly clean on a two-source wiki.
5. Ask a question the test documents can answer (plain chat, no skill) and confirm the answer cites wiki pages.
6. Fix whatever the checklist catches by amending the *skills/schema* (the process), not just the output — then re-verify.
7. Final commit, then push everything to `origin main`.

**Deliverable:** report the checklist results to Brent, including anything that needed a schema/skill fix.

---

## Phase 5: Automation (local Windows Task Scheduler)

**Gate:** don't turn this on until manual `/ingest` has been run for a week or two and the output is trusted. Automating a process you haven't tuned just automates the flaws — the mechanics below can be built and dry-run tested at any time, but the two Scheduled Tasks at the end shouldn't be registered until that gate is met.

Chosen shape, per Brent's answers: capture stays manual (files dropped into local `inbox/` by hand — no voice pipeline yet), execution is a local Windows Task Scheduler job driving headless Claude Code against the local clone at `C:\Users\Brent\Documents\claudecode\llm-wiki`, cadence is daily ingest / weekly synthesis, and once trusted the job auto-pushes to `origin main` with no human in the loop.

Two things make unattended execution safe: **scoped permissions** (so headless Claude Code can act without a human approving prompts, but only for the specific tools this needs) and **a wrapper script that treats "nothing to do" as success and never force-pushes.**

### 5.1 Scoped permissions — CLI flags, not a repo-wide settings file

Verified against the installed CLI (`claude --help`): headless mode is `-p/--print`, and `--allowedTools <tools...>` pre-approves specific tool patterns without prompting (e.g. `"Read Write Edit Bash(git add:*)"` — space-separated inside one string, per the CLI's own example). `--permission-mode` also exists (`acceptEdits`, `auto`, `bypassPermissions`, `manual`, `dontAsk`, `plan`).

Decision: scope permissions **on the invocation itself** (`--allowedTools`, per-call) rather than writing a project `.claude/settings.json`. A repo-wide settings file would also loosen permissions for Brent's own interactive sessions in this repo — unnecessary, since CLAUDE.md's "don't push unless asked" rule already governs interactive behavior, and the automation's scope should live with the automation, not the repo. Do **not** use `--dangerously-skip-permissions`/`bypassPermissions` — `--allowedTools` scoped to exactly what ingest/synthesize need is sufficient and much narrower:

```
--allowedTools "Read Write Edit Bash(git add:*) Bash(git commit:*) Bash(git push:*) Bash(git pull:*) Bash(git status:*) Bash(git log:*) Bash(git mv:*)"
--permission-mode acceptEdits
```

### 5.2 Wrapper script — `scripts/run-skill.ps1`

One parameterized PowerShell script (`-Skill ingest|synthesize`, `-Model` default `sonnet`), responsible for:

1. Resolve the repo root from `$PSScriptRoot` and `Set-Location` there (so it works regardless of what directory Task Scheduler launches from).
2. `git pull --ff-only` — if this fails (diverged history, e.g. Brent committed from elsewhere), abort loudly before touching anything. Never force-pull or force-push.
3. Invoke headless Claude Code: `claude -p "/$Skill" --model $Model --permission-mode acceptEdits --allowedTools "<scoped list>"`.
4. Capture all stdout/stderr to a timestamped file under `automation-logs/` (gitignored — operational run history, separate from `log.md`, which stays the semantic record the wiki maintainer writes about itself).
5. Treat "inbox was empty, nothing to ingest" as success: check `git log origin/main..HEAD` after the skill runs — no new commits means nothing to push, exit 0.
6. If there are new commits, `git push`. If push fails for any reason, log it clearly and exit non-zero (so Task Scheduler's history shows a failure) — leave the local commit intact rather than retrying destructively or force-pushing.
7. Exit 0 only when the whole sequence succeeded (including push, when there was something to push).

### 5.3 Task Scheduler entries

Two tasks, both "run only when user is logged on" (simplest and avoids any headless-credential complications on a personal desktop), both set to not start a new instance if the previous run is still in progress:

- **LLM-Wiki-Daily-Ingest** — trigger: daily, 7:00 AM. Action: `powershell.exe -ExecutionPolicy Bypass -File "C:\Users\Brent\Documents\claudecode\llm-wiki\scripts\run-skill.ps1" -Skill ingest`.
- **LLM-Wiki-Weekly-Synthesis** — trigger: weekly, Sunday, 8:00 PM. Action: same script with `-Skill synthesize`.

### 5.4 Dry-run sequence before trusting it unattended

Do not register the Scheduled Tasks until these pass, in order:

1. Run `scripts\run-skill.ps1 -Skill ingest` by hand from a PowerShell prompt with a real test item sitting in `inbox/` — confirm headless invocation, scoped permissions, and push all work end-to-end without any interactive prompt hanging.
2. Run it again with `inbox/` empty — confirm it exits 0 and logs "nothing to ingest" rather than erroring.
3. Register the two Scheduled Tasks.
4. For the first real week, check `automation-logs/` and `git log` each morning before fully trusting it to run unattended — this is Brent's own judgment call on when to stop checking, not a step to automate away.

---

## Appendix: Design rationale (context for the builder — don't relitigate)

- **Flat `wiki/`, categories only in `index.md`.** Folders force premature taxonomy and create "14 places to put a note." Links and the index do the organizing. (Karpathy's gist + capture-workflow rule 2.)
- **`sources/` immutability** preserves the unfiltered original as a geological layer. Cleaned versions are wiki pages, so nothing is lost when the LLM's interpretation is wrong.
- **Wikilinks everywhere, no database.** `[[links]]` are greppable, Obsidian-native, diff-friendly, and survive any tooling change. Retrieval is `index.md` + grep; at thousands of pages we can add local search, not before.
- **Ingest updates many pages, not one-page-per-source.** This is the core Karpathy move — integration into the existing graph, not accumulation of summaries. A wiki where each source became one note is a warehouse, not a brain.
- **Log + git both exist** because they answer different questions: `log.md` is the semantic history ("what did the maintainer do and why"), git is the mechanical history ("what exactly changed"). Lint and synthesis consume both.
- **Skills over prose instructions** because the operations must run identically every time, including from scheduled tasks.
```
