#!/usr/bin/env bash
# Re-bake + re-encrypt the brand kit and overwrite ./index.html.
#
#   ./scripts/encrypt.sh <password>
#
# Source-of-truth for the plaintext kit is the `webprofits-brand` skill in
# `webprofits/wp-skills`. This repo holds ONLY the encrypted output, so
# encrypt.sh expects a local checkout of wp-skills at one of these paths
# (set $WP_SKILLS to override):
#   $WP_SKILLS                                     (if set)
#   ../wp-skills                                   (sibling of this repo)
#   ../../skills/wp-skills                         (under a Webprofits workspace tree)
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

# Locate wp-skills checkout
candidates=("${WP_SKILLS:-}" "$ROOT/../wp-skills" "$ROOT/../../skills/wp-skills")
WP_SKILLS_DIR=""
for c in "${candidates[@]}"; do
  if [[ -n "$c" && -d "$c/global/webprofits-brand" ]]; then WP_SKILLS_DIR="$c"; break; fi
done
if [[ -z "$WP_SKILLS_DIR" ]]; then
  echo "ERROR: couldn't find wp-skills/global/webprofits-brand." >&2
  echo "       checkout webprofits/wp-skills locally and either:" >&2
  echo "       - place it next to this repo (../wp-skills), OR" >&2
  echo "       - export WP_SKILLS=/path/to/wp-skills" >&2
  exit 2
fi

SKILL="$WP_SKILLS_DIR/global/webprofits-brand"
SRC="$SKILL/examples/brand-kit.html"
CSS="$SKILL/assets/design-system.css"
FONTS_B64="$SKILL/assets/fonts/gellix-base64.css"
TEMPLATE="$ROOT/scripts/encrypt/template.html"

for f in "$SRC" "$CSS" "$FONTS_B64" "$TEMPLATE"; do
  [[ -f "$f" ]] || { echo "missing: $f" >&2; exit 1; }
done

echo "wp-skills: $WP_SKILLS_DIR"

# Bake: inline the two linked CSS files (fonts FIRST so @font-face is declared
# before any rule that uses Gellix).
BAKED="$ROOT/.brand-kit-baked.html"
python3 - <<PY
from pathlib import Path
import sys
src   = Path("$SRC").read_text()
ds    = Path("$CSS").read_text()
faces = Path("$FONTS_B64").read_text()
src = src.replace(
    '<link rel="stylesheet" href="../assets/fonts/gellix-base64.css">',
    f'<style id="gellix-faces-base64">\n{faces}\n</style>',
)
src = src.replace(
    '<link rel="stylesheet" href="../assets/design-system.css">',
    f'<style id="design-system">\n{ds}\n</style>',
)
if "../assets" in src:
    print("ERROR: ../assets refs still present after bake", file=sys.stderr); sys.exit(2)
Path("$BAKED").write_text(src)
print(f"baked: {len(src)//1024} KB")
PY

# Encrypt
TMPDIR="$(mktemp -d)"
staticrypt "$BAKED" --password "$PASS" \
  --template "$TEMPLATE" --short --noremember \
  -d "$TMPDIR" >/dev/null
mv "$TMPDIR/$(basename "$BAKED")" "$ROOT/index.html"
rm -rf "$TMPDIR" "$BAKED"

echo "encrypted -> $ROOT/index.html ($(wc -c < "$ROOT/index.html") bytes)"
echo "next: git commit -am 'Refresh brand kit' && git push"
