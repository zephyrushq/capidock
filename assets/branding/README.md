# Capidock branding

The original robot-capybara logo was created with the built-in `image_gen` tool
with a transparent background. The PNG is shared by the Flutter app and the
Android launcher icon. The README banner was also created with the built-in
tool, using the existing logo and the maintainer's Zephyrus banner as references.
The GitHub social preview uses the same visual identity and the supplied GitHub
repository-card template as a safe-area guide. All artwork was generated with
the built-in tool; no fallback CLI/API was used.

- App logo: `assets/branding/capidock-mark.png`.
- Launcher copy: `android/app/src/main/res/drawable-nodpi/capidock_mark.png`.
- README banner: `assets/branding/capidock-banner.png`.
- GitHub social preview: `assets/branding/capidock-social-preview.png` (1280 × 640 px).
- The `DockLogo` widget displays the PNG against the theme's purple background.
- The Android icon separates the purple background from the foreground and keeps padding for adaptive masks.
- When replacing the branding, update both logo PNGs, the README banner, and the social preview.
- The banner and social preview are repository assets; neither is included in the app's asset bundle.

## Rights and usage

Use of the name, logo, and icon as trademarks follows the
[trademark policy](../../LICENSE-TRADEMARKS) of
**ZEPHYRUS PROSPERITY - UNIPESSOAL LDA**. Any copyright the company holds in
these assets is licensed under GPL-3.0-only, as described in
[COPYRIGHT](../../COPYRIGHT) and [LICENSE](../../LICENSE); this license does not
grant trademark rights.

When distributing a modified version, use your own identity as required by the
policy while preserving the project's attribution and legal notices. AI
generation alone does not guarantee exclusivity or copyright protection.

## Logo prompt

```text
Use case: logo-brand.
Asset type: original mascot logo mark for Capidock, an Android app for managing servers.
Primary request: a minimalist robot capybara FACE, instantly readable as a capybara and as a friendly robot.
Subject: front-facing head only, calm and friendly, symmetrical. Distinctive capybara anatomy: small rounded ears high at the two corners, a broad gently rectangular head, a long wide blunt rounded-rectangular muzzle occupying the lower half. Two tiny nostril marks and a restrained straight mouth. No big triangular bear nose. Give it just two simple horizontal LED eyes and one subtle geometric panel seam so it reads robotic without becoming busy.
Style: crisp flat vector-like mascot symbol, chunky simple geometry, smooth rounded corners, bold silhouette, very few shapes. A professional minimal app identity, legible at 24 and 48 pixels.
Palette: light lavender/off-white #EDE5FF for the head, vivid violet #8B5CF6 for limited robotic accents, deep purple #241335 for features and a clean bold outline. Three flat colors only.
Composition: exactly ONE centered logo on a square canvas; entire head and ears visible; mark occupies about 78 percent of canvas width; even transparent padding around all sides. Genuine transparent background with preserved alpha, including any space around the face. The face itself is solid, not translucent.
Constraints: no words, letters, wordmark, border tile, background, badge, body, neck, hands, antenna, extra objects, gradients, shadows, bevels, 3D, metallic rendering, fur texture, tiny circuit clutter, mockup or watermark. Make the muzzle unmistakably capybara-like rather than a generic bear, cat, pig, dog or square robot.
```

## Banner prompt

The requested dimensions below are generation guidance; the saved image keeps
the tool's original output dimensions.

```text
Use case: logo-brand.
Asset type: GitHub README banner for the Capidock mobile app.
Primary request: create a Capidock version of the supplied Zephyrus banner, preserving its restrained, minimal graphic layout.
Input images: Image 1 is the composition/style reference to adapt; Image 2 is the existing Capidock robot-capybara logo to preserve as the brand motif.
Composition: a very wide, shallow horizontal banner, approximately 4.6:1, ideally 1840 by 400 pixels. Flat near-black background, clean dot grids in the upper-left and lower-right corners matching the reference. A large low-contrast dark-purple robot-capybara face watermark sits behind the centered wordmark, replacing the reference's Z monogram. Use the supplied capybara's recognizable face, ears, forehead panel and eyes; do not invent a different mascot.
Text (verbatim): "CAPIDOCK".
Typography: one centered line in bold, crisp, uppercase geometric sans serif, pale lavender-white, visually dominant and readable at README width. No other text.
Color palette: nearly black #08070C, dark purple #241335 for the watermark, vivid violet #8B5CF6 for a thin bottom edge and restrained dot accents, lavender-white #EDE5FF for the wordmark.
Style: flat, polished, minimal developer-project branding; ample negative space like the reference. No UI mockup, no device, no server illustration, no extra slogans, no new logos, no 3D, no glow, no textures. Opaque background.
```

## Social preview prompt

The built-in generator returned a 1774 × 887 px image. It was proportionally
resampled with ImageMagick to the requested 1280 × 640 px PNG, without cropping
or changing the composition. Important content stays within an 80 px safe inset.
The GitHub template's guide lines and example text are not part of the artwork.

```text
Use case: logo-brand.
Asset type: GitHub repository social preview for Capidock.
Output requirement: the FINAL image must be exactly 1280 x 640 pixels, landscape 2:1, opaque PNG.
Input images: Image 1 (white GitHub Repo Card Template) is a safe-area and canvas guide only. Do not copy its GitHub logo, text, red guides, or white background. Image 2 is the existing Capidock robot-capybara logo: preserve its distinctive broad face, rounded ears, violet LED eyes, forehead panel, and minimal lavender-and-purple shapes. Image 3 is the existing dark Capidock banner: use its branding, bold typography, purple palette and restrained dot-grid details as the visual style reference.
Create a polished minimal social card for the same project. Near-black background #08070C. A large crisp existing capybara logo on the left, and an elegantly spaced text block on the right. The logo should be recognizable and in full color, not a faint watermark. Strong geometric bold sans-serif wordmark, with generous negative space. Subtle violet dot grids can decorate opposite corners outside the content area, and a restrained violet edge accent can echo the reference.
Text, exact and in English:
"CAPIDOCK"
"One dock for your servers."
"ANDROID · FLUTTER · OPEN SOURCE"
"BY ZEPHYRUS PROSPERITY"
Hierarchy: CAPIDOCK dominates. The descriptive line is secondary. The technology line and company attribution are small but readable. Keep the full logo and EVERY text line inside an 80-pixel safe inset from all four edges; the entire important composition must fit within x=80..1200 and y=80..560. Do not print the safe-area guides.
Palette: lavender-white #EDE5FF for primary text and logo, vivid violet #8B5CF6 for accents, deep purple #241335 for outlines, near-black backdrop.
Constraints: exactly one capybara mark; no extra mascots, no UI screenshots, no phone or laptop mockup, no glossy 3D, no busy circuitry, no fake metrics, no GitHub/Octocat logo, no gradients on the lettering, no watermark. Keep text spelled exactly as supplied. Finish at precisely 1280 x 640 pixels.
```

### Final social preview wording

The final feature line is `WORKSPACES · OPEN SOURCE · LOCAL-FIRST`. Copy revisions
were made with the built-in image generator, preserving the composition. The
last edit used the prompt below; the final PNG was then exported at 1280 × 640 px.

```text
Use case: text-localization.
Asset type: Capidock GitHub social preview.
Make just one precise text edit to the supplied image:
Change the small violet line "WORKSPACES · INSTANCES · LOCAL-FIRST" to exactly:
"WORKSPACES · OPEN SOURCE · LOCAL-FIRST"
Keep the violet uppercase styling, the baseline, spacing, alignment and legibility. All text must stay within the existing safe content area.
Preserve every other part of the supplied image: capybara logo, CAPIDOCK title, "One dock for your servers." tagline, "BY ZEPHYRUS PROSPERITY" attribution, dark background, dots, purple bottom rule, composition and colors.
Do not add any reference to Android or Flutter.
Opaque PNG, 2:1 landscape; requested final dimensions exactly 1280 x 640 pixels.
```
