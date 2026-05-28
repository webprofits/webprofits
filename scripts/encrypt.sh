#!/usr/bin/env bash
# Re-bake source/brand-kit.html + source/{design-system,gellix-base64}.css into a
# self-contained file, then encrypt it with StatiCrypt using the team brand password.
#
#   ./scripts/encrypt.sh <password>
#
# Output: index.html (overwritten in repo root). Commit + push to redeploy.
#
# Requires: python3, staticrypt (npm i -g @robinmoisson/staticrypt).

set -euo pipefail

PASS="${1:-}"
if [[ -z "$PASS" ]]; then
  echo "usage: $0 <password>" >&2
  echo "       password is the shared team brand password (1Password: WP Brand Kit)" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/source/brand-kit.html"
CSS="$ROOT/source/design-system.css"
FONTS_B64="$ROOT/source/gellix-base64.css"
TEMPLATE="$ROOT/scripts/encrypt/template.html"
BAKED="$ROOT/.brand-kit-baked.html"
OUT="$ROOT/index.html"

for f in "$SRC" "$CSS" "$FONTS_B64" "$TEMPLATE"; do
  [[ -f "$f" ]] || { echo "missing: $f" >&2; exit 1; }
done

# Inline the two linked CSS files (replace <link rel="stylesheet" href="../assets/...">
# with a <style> block containing the file's contents).
python3 - <<PY
from pathlib import Path
import sys

src   = Path("$SRC").read_text()
ds    = Path("$CSS").read_text()
faces = Path("$FONTS_B64").read_text()

# Fonts MUST come before design-system so @font-face is declared before any rule using Gellix.
src = src.replace(
    '<link rel="stylesheet" href="../assets/fonts/gellix-base64.css">',
    f'<style id="gellix-faces-base64">\n{faces}\n</style>',
)
src = src.replace(
    '<link rel="stylesheet" href="../assets/design-system.css">',
    f'<style id="design-system">\n{ds}\n</style>',
)

# Sanity: no remaining ../assets paths.
if "../assets" in src:
    print("ERROR: ../assets refs still present after bake", file=sys.stderr)
    sys.exit(2)

Path("$BAKED").write_text(src)
print(f"baked: {len(src)//1024} KB")
PY

# Encrypt the baked file with the team password.
TMPDIR="$(mktemp -d)"
staticrypt "$BAKED" --password "$PASS" \
  --template "$TEMPLATE" \
  --short --noremember \
  -d "$TMPDIR" >/dev/null
mv "$TMPDIR/$(basename "$BAKED")" "$OUT"
rm -rf "$TMPDIR" "$BAKED"

echo "encrypted -> $OUT ($(wc -c < "$OUT") bytes)"
echo "next: git commit -am 'Refresh brand kit' && git push"
