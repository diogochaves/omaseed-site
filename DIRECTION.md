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
- ~~**Focus is seeding**, not downloading.~~ Replaced 2026-11-25: seeding is one of the pillars
  (see Decided, 2026-11-25).

## What the page says (since 2026-11-25, v0.17)

1. **Promise:** "Torrents, finally at home on Omarchy." in white; under it in grey, "A native
   client for qBittorrent, Transmission or Deluge, on this PC or a NAS. Your theme, your keys,
   your drives, and your coding agent, as far as you let it." Library mock under it, the try
   buttons, the skin and theme switches, install pill with the one-line install.
2. **Views:** "See where your disk went." Rows, table and space, with space first: the map of
   which folders and torrents hold the room. The window's other parts (details as the story, the
   action bar, the title's sentence, alt, the omaseed menu) as short blocks under it.
3. **Moving and the drives:** a whole folder onto another drive, with the files no torrent owns,
   checked before anything is sent, followed by the band, moved back later; then the drives
   themselves: ntfs3, exFAT and FAT take a ticked file's whole size at once (the room is checked
   first, a big tick waits with Undo, FAT32's 4 GiB limit named), a drive that isn't mounted is
   said, `locate` points a torrent at files you moved yourself, skipped files that still take room.
4. **Agents, as far as you let them:** `omaseed status`, `errors`, `log`, `moves` for any coding
   agent; the skill linked where agents look; Settings › General › Agents (Reads, Fixes, Moves,
   Remove: off, ask, allow; moves and removes always ask); the window that asks you; plans,
   dry runs, "by an agent", add back for 30 days; deny rules for the agent's own settings. Skins
   an agent makes, checked under every theme. Pitched by its limits, not by the AI.
5. **The seed console:** the history the engines don't keep, in `~/.local/share/omaseed/ledger/`.
6. **Any engine, any server:** qBittorrent, Transmission, Deluge; this PC, a NAS, several at
   once; each engine's own settings; a Transmission library moved to a qBittorrent.
7. **Omarchy:** the live theme, the bar widget, Trigger › Torrents in the Omarchy menu, adds that
   open on the workspace you're on, notices, keyboard-first, the palette that finds commands,
   servers, torrents and settings.
8. **Also in omaseed:** a compact grid: search, create a torrent, turtle and burst, the add sheet
   that knows your library, careful deletes, why it errored, backups, the Console skin.
9. **Built with omabox**, the **changelog** (dated), the **roadmap**, **install** again.

## Not on the page until it is true

- **Memory and CPU figures.** Nothing in the omaseed docs measures them. Measure first: omaseed on
  the :8081 playground in an omabox, a realistic torrent count, idle and under load, the method
  published next to the numbers. Never touch :8080 (Diogo's real library).
- **"Constantly updated".** Dated releases show it (v0.1.0 to v0.17.1 in six weeks); the words wait.
- **A roadmap page** of its own, or dates on the roadmap. The home page's Roadmap section names the
  open milestones and promises nothing more.
- **Stars, installs, user counts.** None to show yet.

## Decided (2026-11-25)

- **The page leads with what sets omaseed apart, not with a tour of the window** (Diogo): the
  views (space above all), moving a folder (a section of its own, with the drives), agents, the
  seed console, any engine. The rest goes in a compact grid. Replaces "focus is seeding": seeding
  is one pillar of five.
- **No superlatives, no comparisons** (Diogo): never "only", "best", "first", "no other client",
  "unlike X". The page says what omaseed does. Saying what an engine doesn't keep (qBittorrent
  keeps no upload history) explains a feature and is fine; naming other clients is not.
- **Agents are pitched by their limits**: what an agent may do is off until you turn it on,
  moves and removes always ask, no command deletes a file. Not "AI-powered".
- **NTFS is said exactly**: omaseed knows that ntfs3, exFAT and FAT take a ticked file's whole
  size at once and acts on it. Never "NTFS support".
- **Hero is engine-neutral.** "Powered by qBittorrent" alone is no longer true (v0.8.0).

## Decided (2026-11-05)

- **Roadmap: "Being drawn" and Engines** (Diogo). omaseed's "next" milestone is empty under C33
  (releases ship what is ready), so the roadmap shows the work waiting on a design (#172, #175,
  #163, #199) beside the engines milestone. Change it when one is built or released.

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
