#!/usr/bin/env python3
"""Validate Google Play listing exports and package each supported locale."""
import json
import struct
import zipfile
from pathlib import Path

ROOT = Path('docs/play-store')
LOCALES = ('en-GB', 'en-US', 'pt-PT', 'pt-BR', 'es-ES')
VIEWS = ('welcome', 'languages', 'connection', 'overview', 'channels', 'coolify')
PROFILES = {'phone': (1080, 1920), 'tablet-7': (1920, 1080), 'tablet-10': (2560, 1440)}


def validate_png(path, dimensions, colour_type, limit):
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    width, height, depth, colour = struct.unpack('>IIBB', data[16:26])
    assert (width, height) == dimensions, (path, width, height)
    assert (depth, colour) == (8, colour_type), (path, depth, colour)
    assert len(data) <= limit, (path, len(data))


def main():
    files = []
    for locale in LOCALES:
        folder = ROOT / locale
        listing = json.loads((folder / 'listing.json').read_text())
        for key, stem, limit in [('appName', 'app-name', 30), ('short', 'short-description', 80), ('full', 'full-description', 4000), ('alt', 'feature-graphic-alt', 140)]:
            assert 0 < len(listing[key]) <= limit, (locale, key)
            assert (folder / f'{stem}.txt').read_text().strip() == listing[key]
        validate_png(folder / 'app-icon.png', (512, 512), 6, 1024 * 1024)
        validate_png(folder / 'feature-graphic.png', (1024, 500), 2, 15 * 1024 * 1024)
        for profile, size in PROFILES.items():
            for view in VIEWS:
                validate_png(folder / profile / f'{view}.png', size, 2, 8 * 1024 * 1024)
        # Explicit locale roots keep extracted older downloads out of the packages.
        local_files = sorted(p for p in folder.rglob('*') if p.is_file())
        with zipfile.ZipFile(ROOT / f'capidock-play-store-{locale}.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
            for path in local_files:
                archive.write(path, path.relative_to(folder))
            archive.write(ROOT / 'README.md', 'UPLOAD-GUIDE.md')
        files.extend(local_files)
        print(f'{locale}: text limits, 20 PNGs and ZIP verified')
    with zipfile.ZipFile(ROOT / 'capidock-play-store-assets.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in files:
            archive.write(path, path.relative_to(ROOT))
        archive.write(ROOT / 'README.md', 'README.md')
    print('Created complete multilingual capidock-play-store-assets.zip')


if __name__ == '__main__':
    main()
