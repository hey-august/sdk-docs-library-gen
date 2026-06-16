#!/usr/bin/env bash
# Perl pane: Pod::Simple::XHTML over each .pm in lib/. One flat HTML file per
# module (SignalWire::Relay::Action -> signalwire-relay-action.html). The
# landing page is the SDK README rendered to HTML, followed by the module list.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PKG="$ROOT/_build/sdks/signalwire-perl"
SRC="$PKG/lib"
OUT="$ROOT/langs/perl"
MANIFEST="$ROOT/_build/out/perl-modules.tsv"

rm -rf "$OUT"; mkdir -p "$OUT" "$(dirname "$MANIFEST")"

# Per-module pages; emit "module<TAB>file" lines for the index.
perl - "$SRC" "$OUT" <<'PERL' > "$MANIFEST"
use strict; use warnings;
use File::Find;
use Pod::Simple::XHTML;
my ($src, $out) = @ARGV;
my @mods;
find(sub {
    return unless /\.pm$/;
    my $path = $File::Find::name;
    (my $mod = $path) =~ s{^\Q$src\E/}{};
    $mod =~ s{\.pm$}{}; $mod =~ s{/}{::}g;
    (my $slug = lc $mod) =~ s{::}{-}g;
    my $p = Pod::Simple::XHTML->new;
    $p->html_doctype('<!DOCTYPE html>');
    $p->index(1);
    my $html; $p->output_string(\$html);
    $p->parse_file($path);
    return unless $p->content_seen;
    open my $fh, '>:encoding(UTF-8)', "$out/$slug.html" or die $!;
    print $fh $html; close $fh;
    push @mods, [$mod, "$slug.html"];
}, $src);
print "$_->[0]\t$_->[1]\n" for sort { $a->[0] cmp $b->[0] } @mods;
PERL

# Landing page: rendered README + module list.
python - "$PKG/README.md" "$MANIFEST" "$OUT/index.html" <<'PY'
import sys, os, html
from markdown_it import MarkdownIt
readme, manifest, out = sys.argv[1], sys.argv[2], sys.argv[3]
# markdown-it (CommonMark) renders the markdown inside the README's centered
# header HTML, which Python-Markdown would otherwise pass through raw.
body = (MarkdownIt("commonmark", {"html": True}).enable(["table", "strikethrough"])
        .render(open(readme).read())) if os.path.exists(readme) else "<h1>SignalWire Perl SDK</h1>"
rows = [l.rstrip("\n").split("\t") for l in open(manifest) if l.strip()]
mods = "\n".join(f'<li><a href="{f}">{html.escape(m)}</a></li>' for m, f in rows)
open(out, "w").write(
    '<!DOCTYPE html><html><head><meta charset="utf-8">'
    '<title>SignalWire Perl SDK</title></head><body>'
    f'{body}<h2>Modules</h2><ul>{mods}</ul></body></html>'
)
print("perl modules:", len(rows))
PY
bash "$ROOT/build/scripts/embed-readme-logo.sh" "$OUT"
echo "perl -> $OUT ($(find "$OUT" -name '*.html' | wc -l) pages)"
