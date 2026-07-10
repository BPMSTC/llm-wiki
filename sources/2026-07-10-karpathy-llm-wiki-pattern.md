Andrej Karpathy posted a gist describing an alternative to RAG for building durable personal or team knowledge bases. His core observation: humans start knowledge bases and abandon them because the maintenance burden (cross-referencing, keeping things current, resolving contradictions) exceeds the payoff. LLMs don't get tired of that maintenance work, so an LLM can sustain a wiki in a way a person can't.

The architecture has three layers. Raw sources are the immutable inputs — papers, articles, screenshots, transcripts — and they're never edited once captured. The wiki itself is a set of LLM-written and LLM-maintained markdown pages: summaries, entity pages, concept pages, synthesis documents. The schema is a configuration file (he uses something like CLAUDE.md) that encodes the conventions and decision rules, turning the LLM from a generic chatbot into a disciplined maintainer with consistent behavior across sessions.

Three operations recur: ingest (read a new source, write a summary, update roughly 10-15 existing pages, maintain cross-references, log the activity), query (search the wiki and synthesize an answer with citations — and sometimes save a good answer back into the wiki as a new page), and lint (a periodic health pass that looks for contradictions, stale claims, orphaned pages, and missing cross-references).

Two supporting files hold it together: an index.md that catalogs every page with a one-line summary, and a log.md that's an append-only timestamped record of ingests, queries, and maintenance passes.

He's explicit that the exact directory structure and tooling should be considered a starting point, not a spec — the abstraction (three layers, three operations, two supporting files) is what matters, and the concrete choices should adapt to the domain.
