# What the replicas on the page are drawn from (2026-10-13)

Three read-only passes over `~/code/omarchy/omaseed` (docs and the shipped QML) gathered the look and
the exact words of each piece the page copies. Where the spec and the code disagreed, the page
follows the code (what shipped). Re-check against omaseed before changing a replica; this is a
record, not a source of truth.

## Sources, by piece
- Add sheet, In Downloads, files match, duplicate sheet, free-space line, drop overlay, first run:
  `docs/25-add-sheet-knows-the-library.html`, `docs/05-ui-spec-v2.html` §3, `docs/14-first-run.html`;
  `src/ui/qml/Views/{AddSheet,AddDownloadsList,AddFilesTree,FileTick,AddMatchLine,AddFreeLine,DuplicateSheet,DropOverlay,FirstRunPage}.qml`, `Keymap.qml`.
- Actions menu, selection bar, delete confirm (shared files, last seed), why it errored, rename
  many, help sheet: `docs/05` (`.actions`, `.confirm`), docs 17, 18, 26, 28;
  `src/ui/qml/Views/{ActionsMenu,SelectionBar,DeleteConfirm,SharedDataLine,SharedChoice,DetailsErrorBlock,RenameFilesSheet,HelpSheet}.qml`, `src/core/TorrentProblem.cpp`.
- Bar widget and popup, notifications, servers, certificate, settings nav, backup: docs 19, 20,
  21, 24, `docs/05` §5–6; `plugin/{Popup,Mark,Widget,SettingsPage}.qml`, `plugin/Status.js`,
  `src/integration/Notifier.cpp`, `src/ui/qml/Views/{SettingsModal,ServerSheet,CertificateTrust,SettingsServerRow}.qml`.
- The window itself (hero, rail, table, details, footer): `docs/05-ui-spec-v2.html` §1 and
  `docs/screenshots/`.

## Facts the page relies on
- **Keys:** `a` add (pre-fills from the clipboard when it holds a magnet or URL; no separate
  clipboard key, no Downloads key); `enter` actions menu; `p P` stop/start, force start; `d D`
  delete, with files; `c R` recheck, reannounce; `` ` `` library ⇄ seed console; `?` shortcuts.
  In the add sheet: `ctrl+o` browse, `enter` add, `shift+enter` add stopped, `alt+s` save there.
- **Actions menu, shipped order:** start|stop p · force start P — recheck c · reannounce R —
  category C · tags t · set location m · limits L · rename r — sequential download s · first /
  last pieces first f · super seeding S · automatic management a (✓ when on, for the cursor
  torrent) — queue up [ · queue down ] · copy magnet y · copy hash Y · copy name n · open folder o
  — delete d (red). Reads "start" for stopped and errored torrents. "N selected" heading when the
  selection is more than the cursor row. 280 px, accent border, scrim behind; right-click opens at
  the pointer and selects only that row if it was outside the selection.
- **Selection bar:** count, "selected", ✕ (clear · esc), summary (size, given, ratio green when
  given ≥ taken), then line icons start, stop | recheck, reannounce | category, tags, location,
  limits | open folder, ⋯ | delete (red). SVG paths are in the spec agent's notes and in the page.
- **Add sheet, top to bottom:** head (`+`, "Add torrent" / "Add N torrents", subtitle `name · size
  · from file|clipboard|magnet link|drop|link`, `esc`) · MAGNET, URL OR FILE (placeholder
  `magnet:?xt=urn:btih:…`, `browse ctrl+o`) · files match banner · IN DOWNLOADS (5 newest, tick
  column, `in library`, size, age like `today 14:02`) · NAME · CATEGORY / TAGS chips ending `…` ·
  SAVE TO (`the server's default`) and the free line · LAYOUT Original / Subfolder / No subfolder,
  DOWNLOAD LIMIT and UPLOAD LIMIT `∞ KB/s` · toggles sequential download, first and last pieces
  first, skip hash check · FILES tree (✓ – ·, priorities normal / high / maximal yellow / skip) ·
  buttons cancel | add stopped | add · hints `tab fields  enter add  shift+enter add stopped` and
  `server: <name>`.
- **Files match:** "These files are already on disk. Same N files and sizes as **X**, seeding from
  tracker…" / sub `path · nothing to download if it's saved there` / `save there`; after: "Saving
  beside **X**. qBittorrent will check the N files and start seeding." / `undo`; free line green
  `needs nothing new · the files are already there · … free`.
- **Duplicate:** "Already on <server>"; yellow "This infohash is already in your list, seeding
  since <date>."; "This source lists N trackers it doesn't have." with `+ new` rows; close | show
  it | merge N trackers. Private torrents get no merge.
- **Free line tones:** dim; yellow `… free on /mnt/media · leaves 1.7 GB`; red `only … free on …
  · untick files or pick another folder`; magnet `size known once the metadata arrives`.
- **Delete:** "Delete this torrent?" / "Delete N torrents?", names then `… on disk`, toggle "also
  delete files from disk", cancel (cursor) / delete (red). Shared files: "Its files are also seeded
  by 1 torrent you're not deleting." with keep the files / delete the files and that torrent too,
  button "delete, keep files" or "delete 2 with files". Last seed: "You are its only seed. N
  waiting for it. Deleting it takes it out of the swarm." + `stop instead`.
- **Why it errored (v0.2.0):** table status `! no access` (short causes: no access, disk full,
  read-only, disk error, name too long, bad name, missing, error); General opens with a red-ruled
  block: headline ("Can't write to its save folder"), qBittorrent's words, folder, "qBittorrent's
  log · today 19:00 · 2 times", hints `m set location  p try again  copy the line`.
- **Bar widget:** the mark is the readout (down arrow blue while downloading, up arrow green while
  seeding, unlit at 30 %; square yellow outline for alternative speeds, solid red for errors, red
  outline when unreachable). Speed in the bar is optional (off by default). Popup: head with mark,
  "omaseed ↗", `HOME · QBITTORRENT 5.2.3`, alt-speed / open / settings buttons; speeds with
  sparkline "upload · last hour"; folding sections ADD, YOUR SHARE, KEEPING ALIVE, IN FLIGHT,
  LATELY (badges `paid back`, `ratio 2.0`, `ratio 5.0`); hint footer. No start/stop, no drag and
  drop in the popup.
- **Notifications (shipped titles):** "Download complete" (`name · size · category`, open folder /
  show); "<server> is unreachable" (`127.0.0.1:8080 · connection refused · retrying every 10 s`,
  settings); "<server> is back" (`connected again`); "Disk almost full"; "<name> stopped with an
  error". Styles drawn in the spec: completion accent ✓, error red !, server lost yellow ◌; others
  not specified.
- **Settings nav, shipped:** General, Servers, Notifications, Keybindings, Appearance, Backup,
  About; then qBittorrent: Speed, Discovery and privacy, Connection, Proxy, Seeding, Queue,
  Downloads and files, Web UI, Advanced. Server rows: dot, name, `url · auth · version · N
  torrents`, status `default` / `retrying` (red). Auth words: API key, cookie, none.
- **Certificate:** "untrusted certificate"; "The system does not trust this server's certificate,
  as with a self-signed one. If the fingerprint matches the server's, trust it: omaseed then
  accepts this certificate only."; SHA-256 as two lines of 16 pairs; `trust this certificate`.
- **Shortcuts sheet:** "Shortcuts", subtitle "single letters act on the table · capitals are the
  stronger variant · ctrl is app-level", filter field, sections MOVE, SELECT, VIEW, ACT ON
  TORRENTS, APP with one sentence per key (rows on the page are copied from `Keymap.qml`).
- **First run (not on the page yet):** "looking for qBittorrent on this machine…" → green "✓ found
  127.0.0.1:8080"; steps server · sign in · links (· bar); auth chips API key | username and
  password | none; done screen "You're connected to <server>."

## Real screenshots worth having
`docs/25` embeds two real shots (add sheet at base 14, theme frieren; the "Already on" sheet). The
page's replicas were checked against the add sheet one. `docs/screenshots/` has only the library
and the seed console.
