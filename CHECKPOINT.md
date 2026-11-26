# Checkpoint (2026-11-25)

Where the work stopped and what comes next. Replace this file as the work moves on.

## Done
- The v0.6.0 site is on main and live (approved 2026-11-05).
- **A v0.17.1 draft, waiting for Diogo's review** (not pushed): private artifact
  <https://claude.ai/artifact/6u89JRdz1zsK2ikEdKc847>, version 2; source `site/omaseed.html` in the
  working tree. It follows DIRECTION's "Decided (2026-11-25)": the page leads with what sets omaseed
  apart, in this order: Views (a live space map, the files by kind), Moving and the drives (ntfs3,
  exFAT and FAT; a tick that waits; files gone, an unmounted drive, `do locate`), Agents (a terminal,
  Settings › Agents, the plan window), the seed console, any engine (qBittorrent, Transmission,
  Deluge; the demo's servers carry engines), Omarchy, then a compact "Also in omaseed" grid. The
  search, create, turtle, adding, skins and careful sections became grid blocks (their replica code
  stays, drawing into nothing through `R()`). The changelog shows only the newest minor line
  (v0.17.x) and links to the full one; "Also in omaseed" is cards, each with a small live copy
  (`.card .thumb`, the old replicas at zoom .55) and pause torrents in the demo's menus; roadmap: layouts (#288, #289), #175, #172, and Beyond Omarchy (#185). No superlatives or
  comparisons (DIRECTION). Checked in an omabox at 1920 and 412 px wide.

## Next (in this order)
1. Diogo reviews the draft; then commit and push (push deploys omaseed.app).
2. At each release: the pill's words, the changelog entry (replace it on a new minor, with its
   heading "New in v0.X."), and the Roadmap by hand.
3. Memory and CPU figures, measured in an omabox on the :8081 playground; `/install` and
   `/changelog` pages after the home page.

## Standing rules
- The repo is public on GitHub (diogochaves/omaseed-site); pushing to main deploys omaseed.app
  (Cloudflare Pages, as omabox.app; AGENTS.md, "Hosting"). Push only what Diogo has seen, and
  nothing private: no notes on other projects or people, no secrets.
- Windows, screenshots, running omaseed: through omabox (load the omabox skill).
- omaseed's design is approved and its spec files are never edited. The site shows it, it does not
  redesign it.
