# promo: the launch video and stills

Made in an omabox box (never on the desktop), from omaseed's Release build, on a demo library.
Nothing here talks to the real library (:8080) or the playground (:8081).

The scripts use the omaseed checkout beside this repo (`../omaseed`), or `OMASEED_DIR`. They need
its Release build (`cmake -B build-release -DCMAKE_BUILD_TYPE=Release && cmake --build
build-release` there), its dev swarm (`scripts/dev/swarm.sh`), omabox, qbittorrent-nox, socat,
ffmpeg, ImageMagick and Python's Pillow. Nothing they generate is kept: the library, the
seeding year and the swarm's torrents come out the same on every `stage.sh`.

```bash
promo/stage.sh                 # the `promo` box: This PC (swarm torrents) + NAS (3,500 made up), ~3 min
promo/record.sh OUT            # one take: OUT/take.mp4 (3840x2160) and OUT/captions.tsv
promo/cut.sh OUT               # captions + end card: OUT/omaseed-4k.mp4, OUT/omaseed-1080p.mp4
promo/shots.sh OUT             # the stills: three whole screens (3840x2160), the bar widget and the add sheet cropped
omabox down -b promo           # when done (the box has --idle 0)
```

- `biglib.py`: 3,500 torrents (films, Linux images, talks, audiobooks, radio, datasets,
  software, music, lectures) written straight into a qBittorrent profile, with upload totals,
  categories and tags. The files are sparse zeros and the piece hashes are those of zeros, so
  the data is real and a peer can download it, at no disk cost.
- `tracker-proxy.py`: answers the NAS's tracker announces inside the box (it has no internet),
  with seed and peer counts per torrent.
- `box/ns-up.sh`, `box/leech.sh`: run in the box. The torrent clients live in a network namespace
  on 203.0.113.x so a leecher's connections count as incoming (from 127.0.0.1 qBittorrent stays
  "firewalled" and omaseed says "port not reachable"); the leecher keeps both servers uploading.
- The seeding year is omaseed's dev fill (`OMASEED_LEDGER_DEMO`), made while the NAS holds only
  ~320 GB so a day comes to ~80 GB (`stage.sh` says why).
- omaseed keeps each server's table (sort, details folded) in `state.json`; the scripts set it
  there before a launch, since `i` and a header click only flip what the last run left.

## The README's screenshots (omaseed `docs/screenshots/`, 2026-11-25)

Taken by hand in the `promo` stage (v0.17.1 installed: a worktree whose `build-release/omaseed`
links to `/usr/bin/omaseed`, given as `OMASEED_DIR`), each the window cut out of the 3840x2160
screen (`-crop 3768x2010+36+114`) and halved, so no wallpaper shows:

- The NAS's "needs you" and "arriving": stop the NAS's qBittorrent, move two films' folders to
  `NAS/old-drive/films` and start it again (on a running one a recheck only makes them 0 %
  downloads, not missing files); truncate one film's file and recheck it (arriving, no seed).
- `library.png` rows; `space.png` the films folder only (the whole library in space froze the
  window for about two minutes); `move-folder.png` films to `/home/sbx/Archive/films`, after
  adding loose files dated 12 days back (newer ones are left out of a move).
- `agent-plan.png`: Settings' agent lines set to ask in `state.json` (`agents.fixes`,
  `agents.moves`), then `omaseed do --plan` with two locates and two moves, run from a script
  named `claude` so the window says who asked; refused with esc.
- `seed-console.png` (30 days), `shortcuts.png` (`?`), `library-light.png` (Catppuccin Latte),
  `console-skin.png` (`omaseed skin use console`), `add-sheet.png` (This PC, Field Recordings,
  cut to the sheet) and `widget.png` (cut as `shots.sh` does, after ten minutes running, so its
  hour of upload has filled).
- The seed console's GIVEN tile reads qBittorrent's all-time counter, which starts again when the
  stage's qBittorrent does, while the tide is the made-up year: on this stage the two disagree.
