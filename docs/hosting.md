# Hosting, domain & CI/CD

## Domain

Publish SDK tech refs as static sites on a subdomain like
`reference.signalwire.com/...`.

## Hosting

As these are static sites, hosting with a custom domain on GitHub Pages would be
easy and low-maintenance.

## CI/CD

Each SDK repo regenerates and publishes on release. Then we either:

- **Inject** the Fern navbar onto each generated site, or
- **Host the wrapper separately** and iframe in the 10 sites (this is how the
  [proof-of-concept](https://hey-august.github.io/sdk-docs-library-gen/)
  currently works).

See [wrapper.md](./wrapper.md) for the comparison of these two models.

Coverage/lint checks in CI ensure the generated pages are useful and not empty
templates — see [risks.md](./risks.md).

## Redirects

Add redirects to Fern so current tech ref links go to the appropriate subdomain.
