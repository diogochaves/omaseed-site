# The link card

`card.html` draws the 1280×640 card: the site's headline and subline, the 22 bundled Omarchy theme
accents, and omaseed's real seed console (`seed.png`, copied unchanged from
`omaseed/docs/screenshots/seed-tokyo-night.png`). It is `site/media/og.png` (the site's link card,
which `build.mjs` links with a version taken from its bytes) and omaseed's GitHub social preview.

Render it in a box, never on the desktop:

```bash
omabox up -b og --ro-bind "$PWD/og"
omabox run -b og -- chromium --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=5000 \
  --screenshot=/home/sbx/og.png --window-size=1280,640 "file://$PWD/og/card.html"
cp "$(omabox path -b og)/home/og.png" site/media/og.png
omabox down -b og
```
