# Discoverability: llms.txt, links, SEO

## llms.txt

Emit markdown alongside HTML where generators support it; add the generated
pages to the docs `llms.txt` index so the reference is discoverable for agents.

See the [open question](./open-questions.md) on which generators can emit
markdown and what workarounds exist for those that can't.

## Cross-links

Guides will link into the tech ref every time the API is mentioned.

## Search

Search experiences are intentionally separate (see
[rationale.md](./rationale.md#4-search-experiences-are-intentionally-separate)):

- Each tech ref has its own search solution optimized by/for its generator.
- The SDK tech refs are *not* indexed by the main Fern docs. This is on purpose:
  if all 10 tech refs were added to the Fern site, its search index would be 85%
  SDK results. Each SDK instead has its own dedicated internal search that
  doesn't include results from the other 9 languages.
