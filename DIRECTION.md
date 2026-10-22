# omaseed.app: direction and decisions

The site for [omaseed](https://github.com/diogochaves/omaseed): Torrents for Omarchy, powered by
qBittorrent. Its own folder on purpose, like omabox-site: omaseed's contributors never touch site
code. Built the same way as omabox-site (artifact drafts, then `build.mjs` into `dist/`); the build
is copied across and adapted once the first page exists.

Live at omaseed.app since 2026-10-13. Diogo reviews every change as a private artifact first.

## Decisions (2026-10-14)

- **Main references: Raycast and Linear** (Diogo). Floating top bar with one light "Install" pill;
  one short promise; the real product large; two-tone statements (white, then dim grey); features as
  short blocks, a title and one sentence; a dated changelog on the home page; the same install call
  to action at the end. Not borrowed: Raycast's fixed neon glow (each Omarchy theme's own accent
  instead), customer logos and testimonials (omaseed has none).
- **Interactive mock from herdr.dev** (Diogo): a replica of the app in the page, not a screenshot,
  with demo data (labelled as such), click-to-select, the real keys, and a theme switch. The look
  comes from the approved spec `omaseed/docs/05-ui-spec-v2.html` and the real screenshots, read
  only. No redesign happens on the site.
- **Focus is seeding**, not downloading. The seed console is the proof point.

## What the page says

1. **Promise:** "Torrents, finally at home on Omarchy." in white; under it in grey, "A native
   client for one server or many. Your theme, your keys, your seeding history. Powered by
   qBittorrent." "Finally" carries the point: no existing torrent client fits Omarchy, this one
   does. "A native torrent client for Omarchy" is the `<title>` and link-card description. Library
   mock under it, Dark/Light and per-theme switch, install pill with the `makepkg` line.
2. **The seed console, big:** upload over time (an hour to a year), ratios, a cell per day of the
   last year, torrents few people still seed, ratio ladder, trackers. The history qBittorrent does
   not keep; omaseed keeps it itself in `~/.local/share/omaseed/ledger/`, so it does not depend on
   the server.
2b. **Moving** (since v0.3.0): a whole folder onto another drive, with the files no torrent owns,
   checked before anything is sent, followed by the band, and moved back later. Move… for a
   selection. A playable copy in the window (the rail's folders, `m`, `M`) and replicas of the
   sheet, the band, the places list and move back.
3. **Any server:** this PC, a NAS, a machine on the network, several at once. API key, user and
   password, or none for localhost. Secrets in the system keyring. Magnet links and `.torrent`
   files open in it.
4. **Full Omarchy integration:** follows the theme live (every bundled theme, light ones too), the
   bar widget (a playable copy), the Omarchy menu row, the window rule, keyboard-first (`?` shows
   every key). First run finds a server for you.
5. **Powered by qBittorrent:** one honest line. omaseed has no engine of its own.
6. **Built with omabox:** omaseed was developed with omabox; every window, scale and multi-monitor
   check ran in a box, so the agent never touched the desktop. Links to omabox.app. True today:
   see `omaseed/scripts/dev/*-walk.sh` and `docs/CHECKPOINT.md`.
7. **New in:** the latest releases, dated, read from the omaseed repo (as omabox-site does).
8. **Roadmap:** omaseed's open milestones in plain words, hand-written from their issues: the next
   release (v0.4.0) and "engines", marked planned, with no version and no date. Each card links
   to its milestone; the heading links to the issues.
9. **Install**, again.

## Not on the page until it is true

- **Memory and CPU figures.** Nothing in the omaseed docs measures them. Measure first: omaseed on
  the :8081 playground in an omabox, a realistic torrent count, idle and under load, the method
  published next to the numbers. Never touch :8080 (Diogo's real library).
- **"Constantly updated".** Three tags so far (v0.1.0 to v0.3.0). Dated releases show it; the words wait.
- **A roadmap page** of its own, or dates on the roadmap. The home page's Roadmap section names the
  open milestones and promises nothing more.
- **Stars, installs, user counts.** None to show yet.

## Decided (2026-10-22)

- **Roadmap section** (Diogo): from omaseed's GitHub milestones, read by hand, not by the build:
  their descriptions use board numbers. v0.4.0 as the next release; engines as planned, "starting
  with Transmission", no dates. It replaces "What's next" (issue titles read at build time), which
  Diogo dropped the same day: the roadmap says it better, and the titles carried board numbers.
- **The window shows v0.3.0:** the log face (`~`), the command palette (`:`), the rail's folders
  and servers, Move… and moving a folder with its band, move back, errored torrents that stop.
  Board 45's outcome strip, row marks and mouse ticks are v0.4.0: not on the page until they ship.
- **The replicas read 4.5:1** like the app (docs/38): the page lifts dim and coloured text in the
  window and the section copies the same way, so a theme never looks worse here than in omaseed.

## Decided (2026-10-13)

- **Promise line:** see section 1 above. "Seed from Omarchy." was too narrow (Diogo): the line has
  to say this is the torrent client Omarchy has been missing.
- **Pages:** home plus `/install` and `/changelog`, like omabox-site.
- **Roadmap:** a short "What's next" block, read from omaseed's open GitHub issues at build time.
  No dates, no promises; an issue title is all it says. (Replaced by the Roadmap section on
  2026-10-22.)
- **omabox credit:** its own section (section 6 above), with a link to omabox.app.
