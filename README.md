# SDK Docs POC

Side-by-side preview of language-native API docs for the 10 SignalWire SDKs.
Each pane is the unmodified HTML output of that language's canonical generator.

## View

```bash
python3 -m http.server -d . 8000
```

Open <http://localhost:8000>.

## Generators

| Lang | Tool |
|------|------|
| C++ | Doxygen + doxygen-awesome-css |
| C# / .NET | DocFX |
| Go | gomarkdoc → static HTML |
| Java | Javadoc |
| Perl | Pod::Simple::XHTML |
| PHP | Doxygen (PHP mode) |
| Python | MkDocs Material + mkdocstrings |
| Ruby | YARD |
| Rust | rustdoc |
| TypeScript | TypeDoc |

## Layout

```
index.html           shell (vertical tabs → iframe)
assets/              shell CSS + JS
langs/<id>/          generated docs for each SDK
_build/              build configs + toolchains (gitignored)
```
