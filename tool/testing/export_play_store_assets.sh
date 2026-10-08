#!/usr/bin/env bash
# Render localised store assets, export opaque PNGs and package upload files.
set -euo pipefail
cd "$(dirname "$0")/../.."
: "${FLUTTER_ROOT:?Set FLUTTER_ROOT to your Flutter SDK directory}"
command -v magick >/dev/null
"$FLUTTER_ROOT/bin/flutter" test tool/testing/play_store_assets_test.dart
for locale in en-GB en-US pt-PT pt-BR es-ES; do
  magick "docs/play-store/$locale/app-icon.png" "PNG32:docs/play-store/$locale/app-icon.png"
  for asset in "docs/play-store/$locale/feature-graphic.png" "docs/play-store/$locale/phone/"*.png "docs/play-store/$locale/tablet-7/"*.png "docs/play-store/$locale/tablet-10/"*.png; do
    magick "$asset" -alpha off "PNG24:$asset"
  done
done
python3 tool/testing/package_play_store_assets.py
