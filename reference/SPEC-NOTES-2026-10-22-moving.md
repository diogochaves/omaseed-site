# Moving, as v0.3.0 ships it (2026-10-22)

A read-only pass over omaseed at tag `v0.3.0` (main differs from it only in `docs/DECISIONS.md`
and the PKGBUILD) for the page's copy of the move features. The source of truth is the
CHANGELOG's v0.3.0 section; looks and words come from the code. Where the boards and the code
disagree, the code wins, and the place is marked **code ≠ board**. This is a record, not a
source of truth: check omaseed again before changing a replica.

Examples use the boards' made-up names: server `home`; folders under `/srv/media`,
`/mnt/archive`, `/mnt/fast`; torrents like "Tiny Platformers Bundle", "Retro Collection Vol. 2".

## Sources, by piece
- Boards: `docs/42-move-a-folder.html` (folder move, preflight, band, summary),
  `docs/43-better-set-location.html` (Move… for a selection, places, several save paths, move
  back), `docs/45-after-a-move.html` (only D5, D7, D8 shipped; see the last section).
  Rulings: `docs/DECISIONS.md` C15, C16, C18, C19 T3, C20.
- Words: `src/ui/app/MoveControllerSheet.cpp` (sheet, checks, places, history lines),
  `src/ui/app/MoveController.cpp` (band, summary, footer note, quit line, tray line, notices),
  `src/ui/app/MoveWords.hpp` (glyphs, time left), `src/core/ErrorWords.cpp` (left out, stuck,
  full, can't write), `src/core/MoveHistory.hpp` (20 moves / 30 days).
- QML: `src/ui/qml/Views/{MoveSheet,MoveCheckLine,MoveBand,MoveQuitConfirm,MoveRecheckSheet,
  MoveLooseList,DetailsMoveBlock,LogRow,ScopeLine,Rail,MainView,TorrentTable}.qml`,
  `Kit/{Notice,PickList,Field,RailRow}.qml`, `Keymap.qml` (keys, palette).

## Shared look
- Sizes at base 14: caption ≈ 0.833 (12), small ≈ 0.917 (13), body 14. "Tracked" labels are
  caption, UPPERCASE, `--fg-dark` (dim). Fills are the foreground at alpha: idle 4 %, hover
  8 %, selected 18 %.
- Tone of a line (glyph colour): ok `--green`, warn and unknown `--yellow`, bad `--red`, loose
  `--accent`, fact and busy dim. Glyphs: ok `✓`, warn `!`, bad `✕`, unknown `?`, fact `·`,
  busy `…`, loose `▱`.
- Links in move pieces: `--accent`, bright foreground on hover. A folded/unfolded "details"
  link is dim: `details ›` folded, `details ▾` open (**code ≠ board**: boards draw `▸`).
- Sizes: `Format::size`, 1024-based but written KB/MB/GB/TB, three significant figures
  (`312 MB`, `9.60 GB`, `1.18 TB`); speeds the same plus `/s`.
- Plurals are hand-made one/many pairs ("1 torrent" / "2 torrents"), except one QML string
  (see details block).

## Keys
- `m` **move…** (was "set location"; `:` still finds "set location"). In the actions menu
  between `tags t` and `limits L`: `move… m`. The selection bar's location icon is "move…".
- `M` (shift+m) **move folder…**: the folder picked in the rail, or the cursor torrent's.
  With none: footer note "pick a folder in the rail".
- `:` palette rows: "move…" (also "set location"), "move folder…", "undo last move" (also
  "move back"; palette only, no key).
- Neither `m` nor `M` is in the footer's key hints (rank 0). **code ≠ board** 42 F1, which drew
  `shift+m move folder` there.
- In the Move sheet: `enter` move, `tab` next (folder) or `↓` places (selection), `esc`
  cancel, `ctrl+o` browse. In the places list: `↑` `↓` pick, `tab` or `enter` fill in (a second
  `enter` moves), `esc` closes the list and leaves the sheet.

## 1. Rail: the FOLDERS group
- A rail group headed `FOLDERS` (tracked), after CATEGORIES and before TAGS; folds like the
  others (heading chevron `▾`, folded `›` with the count of rows at the right). Hidden when
  the library has no folders.
- Rows are RailRows: left 16 px + 12 px per depth step, glyph column 14 px (dim), 8 px gap, the
  name (cut from the left), count right-aligned 16 px from the edge, `Theme.railRowHeight`.
  Picked row: selected fill, name bright. The rail's cursor fill shows only while the rail has
  the keys (C19 T2).
- Glyph: `▾` open / `›` folded for a row with rows under it (a click on it folds), `·` for a
  leaf. **code ≠ board** (board draws `▸` for folded).
- A drive's top with no torrents of its own is a dim heading row with no count and no menu.
  Its name is the whole path (`/mnt/archive`); rows under it show the path below their parent
  (`games`, then `handheld` under it). A drive top that is itself a save path is a plain row.
- Count: torrents here and below. Hover on a save path with others under it: tooltip
  `/mnt/archive/games: 274 here, 392 with the folders below`.
- During a folder move (F3): the moving folder's count becomes `52 %`; save paths under it
  show `↻` instead. A selection's move marks nothing.
- Example (board 42 F1):
  ```
  FOLDERS
  ▾ /mnt/archive            (dim, no count)
     ▾ games            392
        · handheld      118
  ▾ /mnt/fast
     · downloads         12
  ▾ /srv/media
     · films             96
     · series            44
  ```
- Picking a row filters the table to it and everything below; picking it again clears it.
- **Folder menu** (right-click on a folder row, or the menu key / `shift+F10` on the rail's
  cursor): a Menu 240 px wide, heading = the folder's own name (`games`), one item
  `move this folder…` with key `M`. A torrent's menu no longer offers it (C19 T3).

## 2. The line over the table (scope line)
- Shown in the library while a folder is picked (or during a move's "show"). 16 px gutters,
  12 px from the top of the table area. Box: idle fill, corner radius, 1 px `--accent` rule on
  the left, padding 12 px sides / 7 px top-bottom; an accent `i` in a 10 px column, 8 px gap;
  small text on one line, cut in the middle; at the right the link: dim key, then the accent
  words.
- Folder picked: `games · /mnt/archive/games · 392 torrents · 1.18 TB on disk · 2 save paths ·
  154 files no torrent owns` + `shift+m move this folder…`. "N save paths" only when more than
  one; the loose count only once omaseed has walked the folder (it sees the disks) and found
  some.
- During the band's "show": `the move of games · 387 torrents · 3 with qBittorrent` +
  `esc all torrents`. After the sheet's "show": `6 torrents from the move sheet` (or
  `1 torrent from the move sheet`) + `esc back to the sheet`.
- The table during "show" gets a **Move** column (120 px, second): glyph + word, coloured by
  step: `· waiting` dim, `◌ queued` accent, `↻ moving now` accent, `✓ moved` green,
  `✕ failed` red, `✕ left out` red, `· already there`, `· removed`, `· moved elsewhere` dim.
  The Save path column cuts from the left.

## 3. The Move sheet
The add sheet's Sheet (head: icon square with glyph, title, dim subtitle, `esc`; equal-width
buttons; key-hint row). Glyph `▱`, or `↺` for a move back. Width 640 px (folder), 560 px
(selection), 600 px when it asks about shared data. Title falls back to "Move a folder" /
"Move…".

**Folder** (rail, scope line, `M`, palette):
- Title `Move games`. Subtitle `392 torrents · 1.18 TB on disk (1.64 TB in the torrents: 31 are
  partial) · on home` (the bracket only with partial torrents; `1 is partial`).
- FormRow `NEW PATH OF THE FOLDER`, field prefilled with the folder's path, all selected; at
  its right `browse` (dim, accent on hover) and a `ctrl+o` key cap. Browse picks a parent and
  the folder's name is appended.
- Under it, dim small: `games goes inside /mnt/fast. Each torrent keeps its place below games.`
  or, renamed, `games becomes /mnt/fast/old-games. Each torrent keeps its place below it.`
- Path rows (small, 8 px gaps): from (cut left) · dim `→` · to (bright, cut left) · count
  (40 px, dim, right): `/mnt/archive/games → /mnt/fast/games 274`.
- A red small blocker line when the move can't go (button off): `Type the folder's new path.`
  · `games is already there.` · `That is inside games.` · `Nothing to move: every torrent is
  already there or left out.` · `Not enough room on /mnt/fast.` · `All 3 are already at …`
- `BEFORE ANYTHING MOVES` (tracked, 6 px above), then the check lines (§4).
- `FILES NO TORRENT OWNS · A DRY RUN`, then the loose lines (§4) with `list ▸` links on loose,
  warn and unknown lines, then a toggle `carry the 149 files after the torrents` (on by default
  when offered).
- Buttons: `cancel` | `show the 387` | `move 387 torrents` (primary; `move 1 torrent`; `move`
  when none; `move after games` while another move runs). Hints: `enter move  tab next  esc
  cancel`.

**Selection** (`m`, menu, selection bar):
- Title `Move Open Arena 0.9 (Linux)` for one, `Move 7 torrents` for several. Subtitle
  `1 torrent · 1.24 GB on disk · on home`, `4 torrents from 3 folders · 9.60 GB on disk · on
  home`.
- FormRow `NEW PATH ON HOME`, prefilled with the first torrent's save path (or the destination a
  failed move meant). In the field, before browse: `places ▾` in `--accent` (bright on hover;
  `places ▴` while the list is open). Screen reader: combobox "new path", button "places",
  "9 places".
- The places list (§3a) opens under the field.
- One torrent: no explain line. Several: dim `all 7 go into /mnt/fast/films`.
- Several save paths: a radio choice (SharedChoice: `○`/`●`, picked row with hover fill and a
  border, dot `--accent`): `into one folder` / `all 4 go into /mnt/fast/library`, and
  `keep their places below /srv/media` / `each goes to the same place below
  /mnt/fast/library`. Default: into one folder. With keep places, the path rows show.
- Shared data (unchanged from v0.2): the SharedDataLine and the choice `move both` (or
  `move all 3`) / `they keep sharing one copy in the new folder`, and `move only this one`
  (`move only these 2`) / `the other one loses its files` (`the other 2 lose their files`).
  "Move both" is picked every time.
- `BEFORE ANYTHING MOVES` shows only with more than one line. A quiet sheet is one green line.
- Blockers: `Type the new path.` · `It is already at /srv/media/games.` · `All 4 are already
  at /mnt/fast/films.` · `Nothing to move: …` · `Not enough room on /mnt/usb.`
- Buttons: `cancel` | `show the 6` (only when save paths differ or some are left out) | `move`
  (one torrent) or `move 6 torrents`. Hints: `enter move  ↓ places  esc cancel`.

### 3a. The places list (L4, C18 D5)
- Opens on `places ▾`, `↓`, or typing. A PickList right under the field: idle fill, hairline
  border, corner radius, 4 px padding. Section captions tracked, 10 px in: `RECENT`, `LIBRARY`,
  `CATEGORIES` (**code ≠ board 45**, which says "library folders"). Rows `railRowHeight`, 10 px
  in: path (small, cut from the left, bright on the current row) and a dim detail: nothing for
  recent (**code ≠ board 43**, which showed "yesterday"), the torrent count for a library
  folder, the category's name for a category folder. Hover and current row: hover fill.
- Order: recent destinations (the last 8 per server), the library's save paths with their
  counts, categories' folders that aren't save paths yet; typing narrows all three (contains,
  any case). At most 12 rows, then dim `5 more: type to narrow`.
- Under a hairline: `↑↓ pick  enter fill in  esc close  ctrl+o browse…`.
- Example:
  ```
  RECENT
  /mnt/fast/films
  /mnt/fast/games/handheld
  LIBRARY
  /mnt/fast/downloads                12
  /mnt/fast/games                   212
  CATEGORIES
  /mnt/fast/incoming           incoming
  ```

## 4. Preflight lines
MoveCheckLine: glyph column 12 px (small, tone colour, top), 8 px gap, the words (small,
wrapping), a dim caption note under them, and at the right a link (small, accent): `show` when
the line names torrents (filters the table; `esc` brings the sheet back), or the caller's.
Shown in this order; a selection shows them only when one is warn/bad/unknown/busy, else one
green line.

- `·` `omaseed can't see home's disks. Checked on home, through qBittorrent: files already
  where the torrents go; the first torrent, sent alone, answers for writing. Not checked here:
  room on that drive, writing, the age and size of files no torrent owns.` note `a path map in
  Settings › Servers lets omaseed see them`
- Room: `✓ Room. The same drive: each torrent is renamed, nothing is copied.` ·
  `✓ Room. 1.24 TB to move (torrents and loose files), 1.71 TB free on /mnt/fast. 470 GB left
  after.` note `read on this machine, which sees home's disks` (or `qBittorrent's own figure
  for its default drive`); without loose files `1.24 TB to move`. Several drives:
  `Room. 20 MB to /mnt/a, 30 GB free; 5 MB to /mnt/b, 100 GB free.` · `✕ Not enough room.
  39.5 GB to move, 31.2 GB free on /mnt/usb, and 2.00 GB is kept free.` · `? Room: can't tell.
  512 GB to move. omaseed can't see nas's disks there.` note `a torrent that doesn't fit fails;
  the job pauses at the first "no space" from qBittorrent`
- Writable: `✓ Writable. /mnt/fast/games is writable by the owner of these files.` (or
  `… will be made in /mnt/fast, which the owner of these files can write to.`) note `checked
  here; qBittorrent's own answer comes from the first torrent, which goes alone` ·
  `? Writable: can't tell here. The first torrent goes alone and answers it.` ·
  `! Not writable here: the owner of these files can't write to /mnt/fast.` note `the check can
  be wrong for a container's user; the first torrent goes alone and answers it`
- `✓ Shared data. 6 torrents share files with others in the folder; they move together. 1 saved
  outside has all its files inside games: it moves too.` (selection: `… share files with each
  other; they move together.`) + show
- `! Handheld Pack spans games: its files inside would be left without it. It stays.`
- `! Automatic management. 31 torrents use it (category games). Moving turns it off for them, as
  qBittorrent does for any set location, and the category still points at the old folder.` +
  show (one: `1 torrent uses it … turns it off for it, …`)
- `✕ 2 left out: /mnt/fast/games already has a file with their file's name. qBittorrent would
  keep that file and report the move as done.` + show
- Remote server: `✓ Nothing already there. nas listed where the torrents go.` · `… Asking nas
  whether files with these torrents' names are already where they go…` (move button off until
  it answers) · `? Files already there: can't tell. nas didn't answer when asked to list where
  the torrents go.` note `qBittorrent keeps a file already at a torrent's place and reports
  the move done; the torrent then has the wrong data. Look there first.`
- `! 2 were moved since by something else: they stay where they are now.` ·
  `✕ 1 would go inside its own folder: left out.`
- `· 3 already there, at /mnt/fast/games. Skipped.` (always shown) + show
- `· Order: smallest first. Tiny Platformers Bundle (312 MB) goes alone; the rest follow, 3 at a
  time in qBittorrent's queue.` One torrent: `Order: Tiny Platformers Bundle (312 MB) goes
  alone.`
- Selection's single green line instead of all the above: `✓ Same drive: a rename, it lands at
  once. Room and access are fine.` · `✓ Room and access are fine on /mnt/fast: 9.60 GB to move,
  412 GB free.` · `✓ Room and access are fine.`
- While a move runs: `· The move of games is running (212 of 387). These go when it ends. That
  is about 50 min left.`

Loose lines (folder only): `▱ 149 files, 61.2 GB, in games, beside the torrents' folders.
Carried to the same place below /mnt/fast/games after the torrents land: copied, checked, then
removed here. Never deleted.` (tick off: `Left where they are, and listed in the summary.`) ·
`! 4 changed in the last 15 min: left where they are, listed in the summary.` ·
`? 1 couldn't be read (launcher/cache): unknown, so left where it is.` ·
`· 37 never count: *.parts, *.!qB, Thumbs.db, desktop.ini, .DS_Store.` ·
`✓ No files no torrent owns in games.` · `… Looking for files no torrent owns in games…` ·
`· Files no torrent owns: can't see them. They stay where they are. A path map in Settings ›
Servers lets omaseed see them.`
`list ▸` opens a 640 px sheet `Files no torrent owns, in games`, subtitle `a dry run: what
would be carried, and what stays`; columns file / size (70 px) / what (200 px): `carried`,
`changed 3 min ago: stays`-style `REASON: stays`, `unknown: REASON`, `never counts: REASON`;
caption `A file counts as a torrent's when it lies under the torrent's content path, or is one
of the files of a torrent added without a subfolder.`; buttons `copy the list` (`c`) | `back`.

## 5. The band
A Notice under the top bar (above rail and table), full width, for every view. Shown at once
for a folder move; for a selection only once it has run 3 s.
- Box: idle fill; 2 px left rule in the kind colour; hairline on the bottom edge; a 2 px
  progress line along the bottom in the kind colour (job %). Padding 9 px top, 10 px bottom,
  18 px left, 16 px right. Row 1: glyph (12 px column, body, DemiBold, kind colour), 8 px gap,
  headline (body, DemiBold, bright), actions at the right (small, accent, 14 px apart, then dim
  `details ›`). Row 2, 20 px in: the line (small, foreground); failures appended ` · ` + red
  `2 failed`. Under 600 px wide the actions drop under the line. Height animates 120 ms.
- Kinds: running `--accent`; waited on you `--yellow`; first torrent failed `--red`; done
  `--green`.
- Running: `↻ Moving games to /mnt/fast/games` (same drive: `Renaming games to …`; move back:
  `Moving games back`; after a restart `…, resumed`) · line `212 of 387 · 610 GB of 1.18 TB ·
  52 % · about 50 min left at 190 MB/s · now Retro Collection Vol. 2 (39.5 GB)`; with a move
  queued `· next: 2 torrents to /mnt/fast/films`. Actions `pause` `show` `details ›`. Time
  words: `less than a minute left`, `about 50 min left`, `about 2 h 10 min left`.
  Selection title: the torrent's name, or `6 torrents`.
- One torrent across drives: no pause. With a local view: `23.4 GB of 39.5 GB · 59 % · about
  2 min left at 188 MB/s · measured at /mnt/fast`. Without: `39.5 GB · moving for 3 min ·
  qBittorrent doesn't report a single move's progress, and omaseed can't see nas's disks`, no
  progress line.
- Pausing: `‖ Pausing the move of games` · `214 of 387 · 2 still with qBittorrent, which
  finishes them · nothing more is sent` · `resume` `end the move` `details`.
  Paused: `‖ The move of games is paused` · `214 of 387 · 171 waiting · nothing is sent until you
  resume` · `resume` `end the move` `details`.
- First failed (red): `✕ qBittorrent can't write to /mnt/fast/games` · `The first torrent, Tiny
  Platformers Bundle, didn't move: “Permission denied”. Nothing else was sent; everything is
  still at /mnt/archive/games.` · `change the folder…` `end the move` `details`.
- Full (yellow): `! The move of games is paused: /mnt/fast is nearly full` · `Big Box Scans
  would leave 1.40 GB free, under what you keep free. The move is paused. 301 moved, 84
  waiting.` · `resume` `end the move`. Stuck (yellow): `! qBittorrent stopped moving` ·
  `Freeware Classics has been moving for 38 min and nothing has landed since 14:02 (at this
  move's speed it needs 5 min). Restarting qBittorrent usually frees it. omaseed has stopped
  sending.` · `keep waiting` `end the move`.
- Ending: `‖ Ending the move of games`. Carrying (folder): `↻ Carrying 149 loose files to
  /mnt/fast/games` · `61 of 149 · 22.0 GB of 61.2 GB · about 4 min left · now
  games/disk-images/arena-gold.iso (copying, then checking)` · `pause` `details`.
- Details (unfolded): a caption block (idle fill, 8 px padding): the headline and line, `started
  2 min ago`, `from /mnt/archive/games to /mnt/fast/games`, then one line per torrent
  `moved · NAME · FROM → TO`; queued moves as rows `waiting: 2 torrents` with `cancel`; a `copy`
  link at the right.
- Tray tooltip while it runs: `Moving games: 52 %, about 50 min left` (`paused at 52 %`,
  `ending`, `carrying the loose files`).

## 6. The footer line (quick moves)
A selection move that lands before the band's 3 s shows no band and no summary. The footer's
note, after the facts, for 6 s: a green `✓` (caption) then accent small text:
`Open Arena 0.9 (Linux) moved to /srv/media/games/shooters` (one) or `2 moved to
/srv/media/games/shooters`; move back: `… moved back`. A quick move that failed: yellow text,
no mark, until the next key: `Open Arena 0.9 (Linux) didn't move: qBittorrent can't write to
/srv/locked` or `1 of 2 didn't move: …`, plus ` · i details` while the details pane is hidden.
Nothing to send: `games wasn't moved: nothing in it can move any more`.

## 7. The queue
One move per server. A sheet opened while one runs adds the dim line `The move of games is
running (212 of 387). These go when it ends. That is about 50 min left.` and its button reads
`move after games`. The band's line ends `· next: 2 torrents to /mnt/fast/films`; `details`
lists `waiting: 2 torrents` with `cancel`. When the first ends, its summary stays and the next
starts under it.

## 8. The summary (same band, green)
- `✓ games moved to /mnt/fast/games` · `385 of 387 in 1 h 52 min · 2 failed · 3 were already
  there · 2 left out (a different file at the destination)` (also: `1 removed during the move`,
  `1 moved elsewhere by qBittorrent`, `1 added during the move is still at /mnt/archive/games`).
  Actions: `recheck the 2…` `retry the 2` (only with failures) `move back…` (when anything
  moved) `show` `details ›` `close`.
- With loose files: `✓ games moved, loose files too` · `385 torrents and 149 files at
  /mnt/fast/games · stayed at /mnt/archive/games: 4 recent files, 1 unreadable · 6 empty
  folders removed there · in 1 h 52 min`, plus `show what stayed`.
- Move back done: `✓ games moved back`. Ended early: `■ The move of games ended early` ·
  `216 moved to /mnt/fast/games · 171 not moved, still at /mnt/archive/games · every torrent is
  whole on one side or the other` (selection: `216 moved · 171 not moved, still where they
  were · …`) · `move the rest…` `move back…` `show` `close`.
- `recheck the 2…` sheet (520 px, recheck icon): `Recheck 2 torrents` / `smallest first, one at
  a time`; rows name (fill) · size (70 px, dim, right) · then (190 px, dim) `starts if complete`
  or `stays stopped`; caption `The ones running before the move start again once they come out
  complete. The others stay stopped and are listed.`; buttons `cancel` | `move…` | `recheck 2`.
- One desktop notice: title `games moved` (`games moved back`, `The move of games ended
  early`), body `385 moved, 2 failed, 149 loose files carried`. A selection gets one only when
  its band showed and it ran past a minute or the window was hidden.
- Quit while a move runs: a 560 px sheet, glyph `↻`, `A move is running on home`, line `212 of
  387 moved. Quitting pauses it: the 3 with qBittorrent finish, and the rest wait until omaseed
  runs again.`; buttons `cancel` | `keep running` | `pause and quit` (primary). Closing the
  window only hides it.

## 9. Move back
History: the last 20 moves or 30 days per server, whichever ends first; a move back removes
the record. A torrent goes back only if it is still where that move put it.
- **Sheet** (`↺`, no field): title `Move games back` / `Move 6 torrents back` / `Move Arcade
  Set 01 back`; subtitle `each to where it was before 14:02 · 84.1 GB on disk · on home`; path
  rows `/mnt/fast/films → /srv/media/films 4`. Lines: `! 3 were moved again since, by the move
  to /mnt/usb (16:40): they stay where they are now.` note `Moving that one back first puts them
  where this move left them.` link `move that one back first` (opens that move's sheet) ·
  `! 2 were moved since outside omaseed: they stay where they are now.` · `· 1 is no longer in
  the library.` · `! Automatic management stays off for the 3 that had it. Turning it on again
  is up to you (the torrent's menu).` · `· The 149 loose files carried stay at
  /mnt/fast/games.` Button `move 46 back · 3 stay`, or `move 6 back`. No "show".
- **Details, General** (top, where the error block sits): idle fill, 1 px `--accent` rule,
  12 px padding. Headline (body, Medium, bright) `Moved today 16:24` or `Moved 20 Oct 16:24`;
  `from /mnt/archive/games to /mnt/fast/games` (small, foreground); dim small meta `with 47
  other torrent(s) · games moved, loose files too` (or `moved again since: nothing to move
  back`); clickable hints `move back…` `this one only` `show the move`.
- **Log** (`~`): one line per finished move, level `info` (accent), time `16:24:10`, message
  `omaseed moved the folder "games", 48 torrents, to /mnt/fast/games and 149 loose files`,
  `omaseed moved "Arcade Set 01" to /srv/media/archive`, `omaseed moved 6 torrents to
  /mnt/fast/films` (keep places: `to their places`). The quoted part is bright. `move back…`
  (small, accent) at the right of the line.
- **Palette**: `undo last move` (newest move only), second line `games · 16:24 ·
  /mnt/fast/games`. Off with `no move to undo` or `moved again since: nothing to move back`.

## Board 45: what shipped and what didn't
- Shipped in v0.3.0: D5 (`places ▾`), D7 (move back from details, log, palette; "undo last
  move"; `move N back · M stay`; "move that one back first"), D8 (20 moves / 30 days).
- Not shipped (v0.4.0): D1–D4 (the outcome strip where the selection bar sits, the row's
  `✓ moved · archive` / `✕ didn't move` mark, the strip's timings), D6 (□/■ ticks on hover, the
  mouse block in `?`, the selection-bar hint). Don't put them on the page.
- Board 45 draws differ from the code: `library folders` → `LIBRARY`; places hints
  `↑↓ choose / enter fill / esc close the list` → `↑↓ pick  enter fill in  esc close  ctrl+o
  browse…`; log lines drawn with `✓` glyphs → no glyph, level `info`, qBittorrent-style words;
  palette rows `move back: games, 48 torrents` → `undo last move` + `games · 16:24 · PATH`.
