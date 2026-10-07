#!/usr/bin/env bash
# Render store assets, export opaque RGB PNGs and package upload files.
set -euo pipefail
cd "$(dirname "$0")/../.."
: "${FLUTTER_ROOT:?Set FLUTTER_ROOT to your Flutter SDK directory}"
command -v magick >/dev/null
"$FLUTTER_ROOT/bin/flutter" test tool/testing/play_store_assets_test.dart
magick docs/play-store/en-GB/app-icon.png PNG32:docs/play-store/en-GB/app-icon.png
for asset in docs/play-store/en-GB/feature-graphic.png docs/play-store/en-GB/phone/*.png; do
  magick "$asset" -alpha off "PNG24:$asset"
done
python3 - <<'PY'
from pathlib import Path
import zipfile

root = Path('docs/play-store')
with zipfile.ZipFile(root / 'capidock-play-store-assets.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
    for asset in sorted((root / 'en-GB').rglob('*.png')):
        archive.write(asset, asset.relative_to(root))
    archive.write(root / 'README.md', 'README.md')
print('Created docs/play-store/capidock-play-store-assets.zip')
PY
