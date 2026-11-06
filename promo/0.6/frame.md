# House design

What every director video starts from. A project copies this as its `frame.md` and changes what its
product needs (its palette, its wordmark); the rules at the end stay.

## Canvas and pacing

- Author at **1080 on the short side**: 1080x1080 (X feed, the default), 1920x1080 (sites, READMEs),
  1080x1920 (vertical). HyperFrames only scales by whole numbers, so 1080 renders 2160 (`director
  render --4k`) and 1440 could not.
- 30 fps. 20-45 s for a launch, under 10 s for a sting. Under 100 MB (they come out at 1-5 MB).
- Pace to the music when there is a track: the drop lands on the reveal line, later beats sit on
  the beat grid (`director.beats(bpm, drop)`). Silent: reveals land on named times, and the pacing
  stays deliberate.
- A text stays on screen long enough to read: about 3 words a second, plus 1 s once it has settled.

## Type

- Statements: Montserrat 900, -0.035 em, line-height 0.98. 64-100 px at 1080 (`--u` scales them).
- Labels, data, captions, URLs: JetBrains Mono 700, labels letter-spaced 0.14 em. At least 24 px at
  1080: it has to read in a phone's feed.
- Recreated UI uses the product's own font.

## Palette

- Tokyo Night by default, Omarchy's own: ground #16161e with a #1f2335 lift, ink #c0caf5, muted
  #a9b1d6, edge #292e42; accent #7aa2f7, warn #f7768e, good #9ece6a.
- One accent per statement. A bigger moment gets bigger by scale, weight or inversion, not a new hue.
- A product with its own colours brings them here, as the CSS variables in `index.html`.

## Footage

- Every shot of a desktop comes from **omabox**, never the real desktop: `take.sh` stages and records it.
- Record 4K (`omabox up --size 3840x2160,scale=2`), so a zoom has pixels to spend. Keep a zoom's
  magnification (`director.magnification`) at 1.5 or under: past it the take looks soft. A small
  thing to show big: a bigger font or a smaller box in the take, not more zoom.
- Zoom and pan with the **untimed wrapper** around the `<video>`, never the video itself; the video
  carries the timing (`data-start`, `data-media-start` from the take's marks).
- No hostnames, user names, hardware lines (fastfetch's), tokens or real accounts on screen.
- Staged data is fine, and says so if asked; invented numbers are not.
- Rebuild a piece of UI in HTML only when it must animate part by part or be readable at a zoom no
  take can give (a bar widget lighting cell by cell). Everything that shows behaviour stays footage.

## Motion

- Name each frame's motion in the storyboard (`whip`, `kinetic-beat-slam`, `coordinate-target-zoom`,
  `logo-assemble-lockup`...: `skill/hyperframes/product-launch-video/references/motion-language.md`).
- Different motion for different jobs: not every element fading up 40 px with the same ease.
- Small things on the beat (a word, a stroke), the whole frame only at a few cuts.
- Carry an element across a cut when you can (a match cut), and keep a world continuous.

## Copy

- Write it the way a person says it. No "Introducing", "Unleash", "Seamless", "Next-level", no
  three-word taglines ("Fast. Simple. Powerful."). British English unless the brief says otherwise.
- Little text, each line earning its place.

## Close

The icon or wordmark, one line of what it is, "free · MIT" (or its licence), the repo URL, then
credits and handles. Credit an original or upstream on screen at the open and the close.
