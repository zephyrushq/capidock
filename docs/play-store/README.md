# Google Play store listings

The `en-GB`, `en-US`, `pt-PT`, `pt-BR` and `es-ES` folders match the five regional
languages currently supported by Capidock. Every folder is a complete listing
for version 0.3.0, with copy and visuals in that locale.

## Upload

Add each language in Play Console's **Main store listing**, select it, then use
its folder or `capidock-play-store-<locale>.zip`:

| File | Play Console field | Limit / dimensions |
| --- | --- | --- |
| `app-name.txt` | App name | 30 characters; Capidock in every language |
| `short-description.txt` | Short description | 80 characters |
| `full-description.txt` | Full description | 4000 characters |
| `app-icon.png` | App icon | 512 × 512; under 1 MB |
| `feature-graphic.png` | Feature graphic | 1024 × 500; under 15 MB |
| `feature-graphic-alt.txt` | Feature graphic alternative text | Under 140 characters |
| `phone/*.png` | Phone screenshots | Six images, 1080 × 1920 |
| `tablet-7/*.png` | 7-inch tablet screenshots | Six images, 1920 × 1080 |
| `tablet-10/*.png` | 10-inch tablet screenshots | Six images, 2560 × 1440 |
| `screenshots-alt.json` | Screenshot alternative text, when available | Per-image descriptions in the selected language |

`listing.md` groups the text for convenient reading and copying. `listing.json`
also stores the localised graphic copy for the renderer. Copy only the contents
of each `.txt` field, without file names or Markdown headings.

Suggested screenshot order: `channels`, `overview`, `coolify`, `languages`,
`welcome`, `connection`. The tablet navigation sidebar is part of the actual
responsive app layout, not a scaled phone screenshot. `overview` and `channels`
show different instance counts in the phone fixtures; on tablets they both
include the persistent navigation sidebar.

The app icon has no text and is identical across languages. Each feature graphic
and screenshot is rendered in its own locale. Example instance names and host
addresses are configuration supplied by a user and intentionally stay unchanged.
Leave **Video** empty: this package does not contain a video or a YouTube URL.

## Capture method

These screenshots are rendered directly from the current Flutter widgets, not
captured from physical Android devices. Phone, 7-inch tablet and 10-inch tablet
layouts use independent viewports. They contain isolated in-memory example
configuration, reserved example.com addresses and dummy credentials. No
connections are attempted and no connected state, server metrics or terminal
output are fabricated. These fixtures do not seed the production app.

Screenshots and feature graphics are opaque 24-bit RGB PNGs. Store icons are
32-bit RGBA PNGs with an opaque square background, no baked-in rounded corners
or outer shadow, and the existing Capidock mascot.

## Regenerate and validate

Requires Flutter, ImageMagick (`magick`) and Python 3:

```bash
FLUTTER_ROOT=/path/to/flutter bash tool/testing/export_play_store_assets.sh
```

The renderer runs 80 widget tests across five locales and three device profiles.
The packaging script validates every text limit, PNG dimensions, colour format
and upload file size. It produces five separate locale ZIPs and the complete
`capidock-play-store-assets.zip` containing all five locale folders.

To validate and rebuild the ZIPs without re-rendering:

```bash
python3 tool/testing/package_play_store_assets.py
```

See [Google Play's preview asset guidelines](https://support.google.com/googleplay/android-developer/answer/9866151).
Branding remains subject to the repository's `LICENSE-TRADEMARKS` and `COPYRIGHT`.
