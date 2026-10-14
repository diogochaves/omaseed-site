# omaseed.app: direction and decisions

The site for [omaseed](https://github.com/diogochaves/omaseed): Torrents for Omarchy, powered by
qBittorrent. Its own folder on purpose, like omabox-site: omaseed's contributors never touch site
code. Built the same way as omabox-site (artifact drafts, then `build.mjs` into `dist/`); the build
is copied across and adapted once the first page exists.

Nothing here is published. Diogo reviews every draft as a private artifact first.

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
8. **What's next:** a few open issue titles from the omaseed repo, read at build time, each linked.
9. **Install**, again.

## Not on the page until it is true

- **Memory and CPU figures.** Nothing in the omaseed docs measures them. Measure first: omaseed on
  the :8081 playground in an omabox, a realistic torrent count, idle and under load, the method
  published next to the numbers. Never touch :8080 (Diogo's real library).
- **"Constantly updated".** Two tags so far (v0.1.0, v0.2.0). Dated releases show it; the words wait.
- **A roadmap page.** Pending work is GitHub issues; the home page's "What's next" (below) reads
  their titles and promises nothing more.
- **Stars, installs, user counts.** None to show yet.

## Decided (2026-10-13)

- **Promise line:** see section 1 above. "Seed from Omarchy." was too narrow (Diogo): the line has
  to say this is the torrent client Omarchy has been missing.
- **Pages:** home plus `/install` and `/changelog`, like omabox-site.
- **Roadmap:** a short "What's next" block, read from omaseed's open GitHub issues at build time.
  No dates, no promises; an issue title is all it says.
- **omabox credit:** its own section (section 6 above), with a link to omabox.app.
