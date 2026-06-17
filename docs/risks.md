# Risks & mitigations

- **"Docs look inconsistent across languages."** Our wrapper navbar helps
  mitigate this. Also, this is just the established pattern for SDK tech refs at
  the companies with the best-regarded DevEx. Native generator "flavor" is
  actually a positive feature that makes the tech refs feel familiar to devs in
  each language.
- **"Main search can't find SDK symbols."** This is on purpose, and also a
  positive. If all 10 tech refs were added to the Fern site, its search index
  would be 85% SDK results. On the other side, each SDK has its own dedicated
  internal search that doesn't include results from the other 9 languages.
- **Generated docs are only as good as docstrings.** We will need to invest
  effort in improving and expanding docstring coverage, and add coverage/lint
  checks in CI to ensure generated pages are useful and not empty templates.
