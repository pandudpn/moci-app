#!/usr/bin/env bash
# Membuat font statis Fredoka dan Nunito (subset Latin) dari font variabel Google Fonts.
# Hasil: assets/fonts/*.ttf dan OFL-*.txt. Unduhan dan venv ada di build/fonts/ (tidak masuk git).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK="$ROOT/build/fonts"
OUT="$ROOT/assets/fonts"
BASE="https://github.com/google/fonts/raw/main/ofl"
UNICODES="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD"

mkdir -p "$WORK" "$OUT"

curl -fsSL -o "$WORK/Fredoka-var.ttf" "$BASE/fredoka/Fredoka%5Bwdth,wght%5D.ttf"
curl -fsSL -o "$WORK/Nunito-var.ttf" "$BASE/nunito/Nunito%5Bwght%5D.ttf"
curl -fsSL -o "$WORK/OFL-Fredoka.txt" "$BASE/fredoka/OFL.txt"
curl -fsSL -o "$WORK/OFL-Nunito.txt" "$BASE/nunito/OFL.txt"

if [ ! -x "$WORK/venv/bin/fonttools" ]; then
  python3 -m venv "$WORK/venv"
  "$WORK/venv/bin/pip" install --quiet fonttools
fi
FT="$WORK/venv/bin/fonttools"
SUBSET="$WORK/venv/bin/pyftsubset"

# make_static <var.ttf> <nama-berkas> <wght> [wdth]
make_static() {
  local src="$1" name="$2" wght="$3" wdth="${4:-}"
  local tmp="$WORK/$name-instance.ttf"
  local axes=("wght=$wght")
  if [ -n "$wdth" ]; then axes+=("wdth=$wdth"); fi
  "$FT" varLib.instancer "$src" "${axes[@]}" -o "$tmp"
  "$SUBSET" "$tmp" --unicodes="$UNICODES" --layout-features='*' --output-file="$OUT/$name.ttf"
  rm -f "$tmp"
}

make_static "$WORK/Fredoka-var.ttf" Fredoka-Regular 400 100
make_static "$WORK/Fredoka-var.ttf" Fredoka-Medium 500 100
make_static "$WORK/Fredoka-var.ttf" Fredoka-SemiBold 600 100
make_static "$WORK/Fredoka-var.ttf" Fredoka-Bold 700 100
make_static "$WORK/Nunito-var.ttf" Nunito-SemiBold 600
make_static "$WORK/Nunito-var.ttf" Nunito-Bold 700
make_static "$WORK/Nunito-var.ttf" Nunito-ExtraBold 800
make_static "$WORK/Nunito-var.ttf" Nunito-Black 900

cp "$WORK/OFL-Fredoka.txt" "$OUT/OFL-Fredoka.txt"
cp "$WORK/OFL-Nunito.txt" "$OUT/OFL-Nunito.txt"
