# Server SDK technical reference: generated docs with injected Fern navbar

Move the 10 Server SDK **technical references** out of the Fern docs site and
generate them directly from source-code docstrings using each language's
canonical doc generator (rustdoc, Javadoc, TypeDoc, Doxygen, mkdocstrings,
YARD, …). Host the output as a branded static subsite wrapped in a navbar
matching Fern's.

The Fern site retains all Server SDK docs *except* the technical references. We
invest heavily in guides, quickstarts, conceptual references, and demos, all
linking prolifically into the generated reference.

## Proof of concept

<https://hey-august.github.io/sdk-docs-library-gen/>

A static site on GitHub Pages: all 10 Server SDK languages as switchable
sections, wrapped in a navbar that closely matches the main Fern site's.

![POC screenshot](https://github.com/user-attachments/assets/2752c225-2072-4361-bfe4-634ab204fe20)

## The target architecture

| Area | Contains |
| :--- | :--- |
| **Main docs site** (Fern) | Quickstarts, guides, conceptual references, demos; unified REST API reference with SDK snippets in language example tabs |
| **Branded subsite** | Generated SDK technical reference |
| **GitHub README** | Install instructions and changelog only |

## Out of scope

- **Browser SDK** — v4 reference docs are already written in MDX for Fern. To
  move it to this model, those reference docs would need to be ported back to
  TSDoc comments.
- **Re-theming generator output** beyond the wrapper navbar. Each generator
  offers at least some theme customization.
