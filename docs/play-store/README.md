# Google Play listing assets

Upload the files from `en-GB` to the appropriate fields in Play Console:

| File | Field | Dimensions |
| --- | --- | --- |
| `app-icon.png` | App icon | 512 × 512 |
| `feature-graphic.png` | Feature graphic | 1024 × 500 |
| `phone/channels.png` | Phone screenshots: workspace navigation | 1080 × 1920 |
| `phone/overview.png` | Phone screenshots: SSH connection | 1080 × 1920 |
| `phone/coolify.png` | Phone screenshots: Coolify connection | 1080 × 1920 |
| `phone/languages.png` | Phone screenshots: language selection | 1080 × 1920 |
| `phone/welcome.png` | Phone screenshots: first workspace | 1080 × 1920 |
| `phone/connection.png` | Phone screenshots: SSH configuration | 1080 × 1920 |

The banner and screenshots use the app's British English localisation.
They are rendered directly from the current Flutter widgets at a phone viewport,
rather than captured from a physical Android device. They contain only isolated
in-memory example configuration, reserved example.com addresses and dummy
credentials. No connections are attempted and no connected state, server metrics
or terminal output are fabricated. These fixtures do not seed the production app.

All screenshots and the feature graphic are opaque 24-bit RGB PNGs. The store
icon is a 32-bit RGBA PNG, with an opaque square background and no baked-in
rounded corners or outer shadow. It reuses the existing Capidock mascot.

## Regenerate

Requires Flutter, ImageMagick (`magick`) and Python 3:

```bash
FLUTTER_ROOT=/path/to/flutter bash tool/testing/export_play_store_assets.sh
```

The export creates `capidock-play-store-assets.zip` with the eight upload images
and this guide. The archive is a convenience download; upload each image to its
matching Play Console field.

Suggested feature graphic alt text:

> Capidock: Your servers. Your pocket. A purple workspace card groups SSH and Coolify instances.

Branding remains subject to the repository's `LICENSE-TRADEMARKS` and `COPYRIGHT`.
