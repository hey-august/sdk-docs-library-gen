# Rationale

## Status quo

Until now, DevEx has generated the Server SDK tech refs ***from source code***
with a shared Claude skill. That approach has the following issues:

- **Expensive, time-consuming, and non-deterministic:** Every release requires
  long, token-intensive sessions with a lot of hand-holding to validate (and
  re-validate) every line of output against the source code.
- **Overwhelms Fern:** Each SDK tech ref is thousands of individual pages. If we
  scale up to all 10 languages, our Fern site would be **86%+** SDK tech refs
  alone.
  - In testing, our production Fern deployment starts choking at ~10k pages and
    breaks entirely at ~15k. All 10 SDK tech refs combined would push the site
    past **16k**, which would break the site entirely.
  - This can be partially mitigated by combining individual reference pages into
    long single pages. But that makes individual pages very difficult for LLMs
    to effectively ingest.
- **Pollutes search and SEO:** Dumping bulk generated reference content into the
  main site degrades discoverability of everything else through sheer dilution,
  since 86% of the site would then be SDK tech refs.

## Why use language-native HTML generators?

### 1. Single canonical source of truth

- The technical reference lives in docstrings adjacent to the code it documents.
- CI regenerates docs on every SDK release, automatically keeping the tech refs
  in sync.

### 2. This is the industry gold standard

We surveyed how a selection of companies with excellent DevEx reputations handle
their SDK technical reference docs: Stripe, OpenAI, Anthropic, Plaid, Datadog,
Supabase, Sentry, Twilio, Algolia, and AWS.

Supabase is the only company on this list that includes its SDK technical
reference in its main docs — and even then it's a smaller curated version, not
the complete tech ref.

| Company | Main docs site | SDK tech ref location |
|:---|:---|:---|
| **Stripe** | SDK hub linking out to GitHub repos: [docs.stripe.com/sdks](https://docs.stripe.com/sdks) | Doc-gen output on stripe.dev: [Android (Dokka)](https://stripe.dev/stripe-android/index.html), [iOS (DocC)](https://stripe.dev/stripe-ios/documentation/stripe). Server SDKs only documented on GitHub. |
| **Twilio** | Library guides: [twilio.com/docs/libraries](https://www.twilio.com/docs/libraries) | Static generated hub on main domain: [twilio.com/docs/libraries/reference/](https://www.twilio.com/docs/libraries/reference/) — Go links to [pkg.go.dev](https://pkg.go.dev/github.com/twilio/twilio-go) |
| **AWS** | Developer guides on [docs.aws.amazon.com](https://docs.aws.amazon.com) | Sphinx subsites: [boto3.amazonaws.com](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html), mirrored under [docs.aws.amazon.com/boto3](https://docs.aws.amazon.com/boto3/latest/reference/services/s3vectors/client/create_index.html) |
| **Datadog** | REST reference w/ client-library tabs: [docs.datadoghq.com/api](https://docs.datadoghq.com/api/latest/) | Sphinx on own subdomain: [datadoghq.dev/datadog-api-client-python](https://datadoghq.dev/datadog-api-client-python/) |
| **Plaid** | REST reference + [libraries list](https://plaid.com/docs/api/libraries/) → GitHub | None hosted — OpenAPI-generated libraries, GitHub READMEs only |
| **OpenAI** | [Library page in API Reference](https://developers.openai.com/api/reference/python) (≈ rendered README) | Full surface = [api.md in repo](https://github.com/openai/openai-python/blob/main/api.md) |
| **Anthropic** | [Per-language SDK config pages](https://platform.claude.com/docs/en/cli-sdks-libraries/sdks/python) + [client SDKs hub](https://docs.anthropic.com/en/api/client-sdks) | Full surface = api.md in [GitHub repos](https://github.com/anthropics/anthropic-sdk-python) |
| **Sentry** | Platform guides: [docs.sentry.io/platforms/](https://docs.sentry.io/platforms/) + curated [JS APIs pages](https://docs.sentry.io/platforms/javascript/apis/) | No comprehensive generated reference anywhere |
| **Algolia** | [Versioned per-language client method reference inlined](https://www.algolia.com/doc/api-client/methods/settings/) | Method-level reference is on the main site; no separate doc-gen subsite |
| **Supabase** | [Full per-language reference inlined](https://supabase.com/docs/reference/javascript/insert) (JS, Swift, Dart, …) | On the main site — the known outlier |

The gold standard is to heavily integrate SDKs into the main docs, but let the
canonical doc generator handle the technical reference. Supabase is the lone
outlier that inlines SDK reference into its main docs.

### 3. Canonical generators are what developers expect

Devs in each specific language are already very familiar with these generators
(including their navigation, theming, and built-in search), and view them as the
standard for technical reference docs.

### 4. Search experiences are intentionally separate

- Each tech ref has its own search solution optimized by/for its generator.
- The SDK tech refs are *not* indexed by the main Fern docs, which protects
  discoverability of the rest of the site. (Tech ref docs for all 10 languages
  would represent over 85% of the content.)
