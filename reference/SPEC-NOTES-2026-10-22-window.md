# What the v0.3.0 window replicas are drawn from (2026-10-22)

One read-only pass over `~/code/omarchy/omaseed` at tag `v0.3.0` (CHANGELOG "## v0.3.0" is what
shipped; the docs are proposals). Where a doc and the code at the tag disagree, these notes follow
the code and say so (**code wins**). Example names below are the docs' own examples or made up;
paths are neutral. Re-check against omaseed before changing a replica; this is a record, not a
source of truth.

Colour words are Omarchy theme keys as the QML names them: `accent`, `foreground`,
`brightForeground`, `dimForeground`, `background`, `red`, `yellow`, `green`. Fills are
`Theme.fill(alpha)` of the foreground: idle 4 %, hover 8 %, selected 18 %, hairline 12 %, faint
40 % (disabled text). Sizes are `Theme.space(n)` at base 14 (= n px).

## Sources, by piece
- Command palette: `docs/30-command-palette.html`; `src/ui/qml/Views/CommandPalette.qml`,
  `Kit/Palette.qml`, `Keymap.qml` (`commandGroups`, `commandRows`, `whyNot`),
  `src/ui/app/App.cpp` (`kRecentCommands = 5`).
- Log face and failures: `docs/32-log-and-failures.html`; `Views/{LogView,LogRow,DetailsErrorBlock}.qml`,
  `Kit/Hero.qml` (face tabs), `Views/MainView.qml` (views, follow state), `HintModel.qml`
  (`_logHints`), `src/core/{ServerLog,TorrentProblem,ProblemLog,TorrentWebSeedsModel}.cpp`.
- Errored torrents stopped: DECISIONS C20; `src/core/TorrentModel.cpp` (StatusCauseRole),
  `Views/{TorrentTable,DetailsGeneralTab,ActionsMenu,SelectionBar}.qml`, `App.cpp` (`startsOnToggle`).
- Several servers and the band: `docs/33-servers-any-state.html`, `docs/35-error-notice.html`;
  `Views/{Rail,ServerPalette,AddSheet,DisconnectedBanner}.qml`, `Kit/Notice.qml`,
  `src/core/{ServerListModel,ErrorWords}.cpp`, `App.cpp` (`serverRows`).
- Backup, contrast, screen readers: `docs/24-backup-restore.html`, `docs/38-contrast-floor.html`;
  `Views/SettingsModal.qml` (qBittorrent › Backup pane), `App.cpp`, `AppTorrentsBackup.cpp`.

---

## 1. Command palette (`:` or `ctrl+shift+p`)

**Shape** (Kit/Palette, the same panel as the jump palette `ctrl+k`): centred over the window,
max width 480 (min(480, window − 2×16)), `background`, 1 px `accent` border, corner radius, scrim
behind.
- Query row: height controlHeight + 8, side padding 14, gap 10. Glyph `:` in `dimForeground`;
  input in `brightForeground` (caret 1 px `accent`); while empty, the title shows dim in its place;
  counter on the right, `dimForeground`, caption size. Hairline under.
- List: max height 360, scrolls. Row padding 6 top and bottom, 14 sides. Line 1: title (body,
  Medium, `brightForeground`) left; key on the right (small, `dimForeground`). Line 2: detail
  (small, `dimForeground`), elided. 1 px rule between rows. Cursor row: hover fill (8 %) plus a
  1 px outline (`borderHover`).
- Menu-only rows print `via` + the path in the key's place (both small `dimForeground`):
  `via enter s`, `via ctrl+.`.
- **Can't run now:** title dim and normal weight, key and detail faint (40 %), the reason replaces
  the target in line 2. The cursor skips it; enter and click do nothing.
- Footer (padding 6 / 14): hints left, `? lists every key` right.

**Query-row title, nothing typed** (verbatim): `commands for 2 selected` · `commands for <cursor
torrent name>` · `commands` · `commands · the server is lost` · `commands for 3 marked files` ·
`commands for 3 marked` (trackers, peers, HTTP sources) · `commands for the log` /
`commands for 1 marked line` / `commands for N marked lines`.

**Counter:** `44 commands` (nothing typed) · `6 of 44` (typed).

**Hints:** `↑↓ move  enter run  esc close` (esc reads `clear` once something is typed); `enter run`
is dropped when no row can run. No match: `enter jump palette  esc clear`.

**No match (P4):** line `No command matches “ubuntu”.` then one row: title `find torrents matching
“ubuntu”`, key `ctrl+k`, detail `library · opens the jump palette with your text`.

**Row line 2:** `<area word> · <target>[ · now <state>]`. Area words: `torrents`, `selection`,
`library`, `view`, `speed`, `app` (plus `files`, `trackers`, `peers`, `HTTP sources`, `console`,
`log` from those places). Targets: `2 selected`, the cursor torrent's name, `3 marked`. Option rows
add `now off` or, with a selection, `now off on <cursor name>`.

**Why it can't run** (the reason replaces the target, verbatim):
`nothing selected, no torrent under the cursor` · `both already running` / `already running` /
`all 3 already running` (start) · `both already stopped` … (stop) · `no torrent under the cursor`
(rename, open folder) · `nothing selected` (clear the selection) · `details hidden · i shows them`
· `pick a folder in the rail` · `no move to undo` · `moved again since: nothing to move back` ·
`read-only until the server is back` (server lost: only settings, shortcuts, hide, quit, the
palette and switching server run) · `not in error` / `none in error`.

**Order with nothing typed:** the focused area's own commands (Files tab, log face…) first, then
the **last five run** (newest first), then the rest in the `?` sheet's order (torrents, selection,
library, view, speed, app), then every row that can't run. Typed: fuzzy score, then can-run before
can't, then recent. A row's old name still finds it (`also`).

**Rows from the table, in order** (title · key; verbatim, all lowercase in code):
| title | key | needs |
|---|---|---|
| start / stop | `p` shows on the one it would run now | stopped / running |
| retry | `e` | only listed while a target is in error |
| force start | `P` | torrents |
| recheck · reannounce | `c` · `R` | torrents |
| delete · delete with files | `d` · `D` | torrents |
| set category · set tags | `C` · `t` | torrents |
| move… | `m` (typing "set location" finds it) | torrents |
| move folder… | `M` | a folder in the rail, or a cursor row |
| limits · rename · open folder | `L` · `r` · `o` | |
| queue up · queue down | `[` · `]` | |
| copy magnet · copy hash · copy name | `y` · `Y` · `n` | |
| sequential download on · first / last pieces first on · super seeding on · automatic management on | `via enter s` · `via enter f` · `via enter S` · `via enter a` | "off" when the cursor torrent has it on |
| select all visible · clear the selection | `ctrl+a` · `esc` | |
| add a torrent · filter the table · jump to a torrent · sort | `a` · `/` · `ctrl+k` · `s` | |
| undo last move | no key; prints `via :` (typing "move back" finds it) | only listed when a finished move is kept; detail `library · <title> · <when> · <where>` |
| columns · show details (hide details) · place details: right · bottom · auto · show the rail (hide the rail) | `\|` · `i` · `I` · `ctrl+b` | |
| seed console (back to the library) · qBittorrent's log (back from the log) | `` ` `` · `~` | |
| details smaller · details larger | `<` · `>` | details on show |
| alt-speed on (off) | `A` | reads `burst on` / `turtle on` when the alt limits are faster / slower |
| speed limits… · alt-speed limits… | `via ctrl+.` | `burst limits…` / `turtle limits…` |
| switch server… | `ctrl+s` | two servers or more; then one `switch to <name>` row per other server, detail `app · 4 torrents last time` |
| settings · qBittorrent settings · shortcuts · hide the window · quit | `,` · `ctrl+shift+,` · `?` · `q` · `ctrl+q` | |

44 rows from the table (45 while a target is in error). **Code wins:** doc 30 says 43 and shows
"set location m"; v0.3.0 titles it `move…`.

Elsewhere: footer right edge pins `: commands` before `? help`; the ⋯ menu's top row is
`commands…`; the `?` sheet's APP section has `: ctrl+shift+p` "Find any command by name and run
it; each row teaches its key", and its subtitle gains a second line `: runs any of them by name`.

---

## 2. qBittorrent's log, the third face (`~`)

**Face tabs** in the hero (Kit/Hero): `library` · `seed` `` ` `` · `log` `~`. Each tab 34 high,
label + 20 px; label body size, `brightForeground` when current else `dimForeground`; the key hint
caption size, `dimForeground` at 70 %, hidden at large base sizes; the current tab has a 2 px
`accent` rule under it. `~` opens the log from anywhere; `~` again, or `esc` with nothing to clear,
goes back. The rail and details are not shown on this face (full width).

**Bar** (padding 16 sides, about 10 top and bottom, items 8 apart, hairline under):
level chips `normal 289` `info 10` `warning 10` `critical 0` with key hints `1`–`4` (toggle chips,
tone: normal `foreground`, info `accent`, warning `yellow`, critical `red`); a torrent chip when
narrowed, `torrent: <name>  ✕` (accent; tooltip `only the lines that name it · esc clears`);
filter field 240 wide, hint `/`, placeholder `filter lines`. Right side, small `dimForeground`:
`since qBittorrent started · 13 Oct 19:52 · 309 lines`, or `the last 20 000 lines it keeps · since
…`, or `3 of 10 lines` while filtering; `reading qBittorrent's log…` / `no lines read` before.
Its tooltip: "qBittorrent's log starts when it started, 13 Oct 19:52: it keeps it in memory. Older
lines are in its log file on the server, in <folder>." (or "It writes no log file (Settings ›
qBittorrent › Advanced).").

**Column heads** (26 high, caption, dim): `time` at x 16, `level` at 148, `message` at 246.

**Row** (LogRow; all small size): time 118 wide, `dimForeground`; level 84 wide, coloured: info
`accent`, warning `yellow`, critical `red`, normal `dimForeground`; message `foreground`, wrapped,
with each "quoted" part in `brightForeground` (so the torrent's name stands out). Row padding 3
top, +6 height. Oldest at top, newest at bottom. Time is `HH:mm:ss` today, `d MMM HH:mm:ss` this
year, `d MMM yyyy HH:mm:ss` older. Cursor line: hover fill + 1 px edge; marked line: selected fill.
omaseed's own move lines end with `move back…` (`accent`).
**Code wins:** doc 32 says the normal chip is `dimForeground`; the chip is `foreground`, the row's
level word is `dimForeground`.

**Example lines** (doc 32's real wording, names and paths made neutral):
```
09:39:24  normal   Torrent removed. Torrent: "Public Domain Sampler"
09:40:00  normal   Added new torrent. Torrent: "field-recordings-03.flac"
09:40:00  warning  Received error message from URL seed. Torrent: "field-recordings-03.flac". URL: "http://mirror.example.org/pub/field-recordings-03.flac". Message: "404 File not found"
09:40:08  warning  File rename failed. Torrent: "Dawn Chorus", file: "Dawn Chorus/b.txt", reason: "Permission denied"
09:41:36  normal   Start moving torrent. Torrent: "Dawn Chorus". Destination: "/mnt/media/music"
09:41:36  warning  Failed to move torrent. Torrent: "Dawn Chorus". Source: "/mnt/downloads/incoming". Destination: "/mnt/media/music". Reason: "45857c storage move failed. file_rename (/mnt/downloads/incoming/Dawn Chorus): Permission denied"
13 Oct 19:52:44  info  Successfully listening on IP. IP: "127.0.0.1". Port: "TCP/26999"
```

**Keys:** `1`–`4` levels on/off (remembered per server) · `/` filter, every word must match ·
`j k g G` move (`G` newest and follow again) · `w` / `W` next / previous warning or critical ·
`f` follow on/off · `space` `v` `ctrl+a` mark, range, all shown · `y` copy marked or cursor line
(as `yyyy-MM-dd HH:mm:ss level message`, one per line) · `enter` show the line's torrent in the
library with General open · `t` only that torrent's lines · `esc` clears marks, then the torrent,
then the filter, then goes back.

**Footer:** left, `● following` in `green` or `○ paused` in `dimForeground` (small). Hints:
`1–4 levels  / filter  w next warning  y copy  enter show torrent  f follow  ~ library`
(`G newest, follow again` replaces `f follow` while paused). With lines marked:
`y copy 1 marked line` / `y copy 3 marked lines  esc clear`. Footer notes: `copied 3 lines`,
`nothing to copy`, `no warning below` / `no warning above`, `this line names no torrent in the
library`.

**Paused pill:** over the bottom edge, `background`, 1 px `accent` border, padding 12 / 4:
`G` (accent) + `3 new lines below · follow is paused` (foreground, small).
**Empty:** `qBittorrent's log is empty` · `no line matches · esc clears`.

**Palette rows on this face** (`log` area, listed first): show normal lines `1`, show info lines
`2`, show warnings `3`, show critical lines `4` (hide … when on), filter the log `/`, newest line,
and follow `G`, next warning `w`, previous warning `W`, follow new lines `f` (stop following),
mark every line shown `ctrl+a`, copy lines `y`, show the line's torrent `enter`, only this
torrent's lines `t`, clear, then back `esc`.

### The yellow failure block (General, top)
Same block as v0.2.0's red error block, always yellow for a failure: idle fill (4 %), a 1 px
`yellow` rule on the left, glyph `!` (`yellow`, body) at 12 px in, text column 8 px after it,
lines 3 apart, padding 6 top/bottom.
- Headline: body, Medium, `brightForeground`.
- Detail (qBittorrent's reason, then what it was doing): small, `foreground`.
- Folder: small, `dimForeground`.
- Meta: small, `dimForeground`: `qBittorrent's log · today 09:41 · 2 times` (adds `may be about the
  other torrent named this` when two torrents share the name).
- Actions as clickable key hints (small): per kind, then `copy the line`, `its lines in the log`,
  and `x dismiss` last.

Headlines and lines (verbatim templates):
| kind | headline | detail | folder | actions |
|---|---|---|---|---|
| move | `The move to <last two folders> didn't happen` | `Permission denied, moving <file>` | `Its files are still in <source>` | `m move…` `o open folder` |
| rename | `A file kept its old name` / `3 files kept their old names` | `Permission denied, renaming <path> and 2 more` | the file's folder | `2 rename in Files` `o open folder` |
| part file | `Its part file couldn't be removed` | `Directory not empty` | `<save path> · the .parts file holds pieces of files you skipped` | `o open folder` |

Example:
```
!  The move to media/music didn't happen
   Permission denied, moving Dawn Chorus
   Its files are still in /mnt/downloads/incoming
   qBittorrent's log · today 09:41 · 2 times
   m move…   o open folder   copy the line   its lines in the log   x dismiss
```
**Code wins:** doc 32's F1 shows `m set location`; v0.3.0 reads `m move…`. The block goes away when
the save path (or file name) changes, or on `x`. An errored torrent keeps its red block first.
Web seeds: the HTTP sources tab's status per URL, e.g. `404 File not found · today 09:40`,
`host not found · 10 times, last 3 Oct 22:59`, `no errors logged`. Settings › qBittorrent ›
Downloads: `The last copy failed: Permission denied, writing <name>.torrent`.
Footer note when omaseed asked for it: `<name> didn't move: “Permission denied”.`

---

## 3. Errored torrents can be stopped

- `p`, the actions menu's first row and the selection bar's stop button all **stop** an errored
  torrent that is running (it reads `stop`), and **start** (retry) one that is stopped.
- `e` = `retry` (palette row `retry`, only while a target is in error; footer label `retry`).
- **Status cell:** running errored: `!` in `red` + the short cause in the row's text colour
  (`! no access`, `! disk full`…, as v0.2.0). Stopped errored: `! stopped`, glyph **and word** in
  `red` (the state colour). Stopped from qBittorrent's own Web UI reads the same.
- **General › Status row:** `error · stopped`, then the cause dim after it (e.g.
  `error · stopped · no access`).
- **Actions menu** (cursor torrent errored): `stop p` (or `start p` once stopped), then a new row
  `retry e` directly under it, then `force start P`, … The location row is now `move… m`.
- **Error block hints:** `e retry` (was `p try again` in v0.2.0), `m move…`, `c recheck`,
  `o open folder`, `copy the line`, `its lines in the log`.
- **Selection bar:** unchanged buttons (start, stop | recheck, reannounce | category, tags, move…,
  limits | open folder, all actions ⋯ | delete); stop now stops errored ones too. Its location
  button's text is `move…` (tooltip `move… · m`).

---

## 4. Several servers

**Rail bottom block** (only with two servers or more): pinned under the rail's scroll, outside it,
on a band of its own: idle fill (4 %) under a 12 % hairline. Heading `servers · 3` with a fold
chevron. One row per server (Settings' order, 5 at most, then `2 more · ctrl+s`): a `●` dot, the
name, a count on the right. The current server's row is selected (18 % fill).
- Dot colour: current live `green`, syncing `yellow`, down `yellow` while retrying (else `red`),
  refused / certificate / last try failed `red`; any other server last seen fine: faint (40 %).
- Count: the current one live (`4`), `down` while unreachable (yellow while retrying), `!` (red)
  when refused or its last try failed; others: what omaseed last saw (`0`, `4`), dim.
- Folded: one line `● private ▴` with `3 servers` on the right. Click or `enter` switches.
Example: `public 0` · `private 4` (selected, green dot) · `seedbox !` (red).

**Server palette** `ctrl+s` (also a click on the hero's server name, `: switch server…`, tray, bar
widget): title `switch server`, counter `3 servers`. Current row first: meta `on it now`, detail
`127.0.0.1:8091 · 4 torrents · qBittorrent 5.2.3`. Others: meta `4 torrents`, detail `<address> ·
last seen today 21:04`; failed: meta `sign-in refused` / `didn't answer`, detail `<address> · last
try yesterday 09:12`; never: `not seen yet`. Hints `↑↓ move  enter switch  , manage servers  esc
close`. Empty: `No server matches “x”.`

**Add sheet** (two servers or more): title `Add torrent to` + a chip: 7 px dot (`green`; `yellow`
while down, `red` if refused), the server name (bright, DemiBold), `▾` (dim, caption); chip border
idle/hover, radius. Batch: `Add 3 torrents to`. One server: plain `Add torrent`. Save-to
placeholder `private's default`. Hints gain `ctrl+s server`. After a switch from the sheet, one
yellow line: `Moved to public: save path back to its default, tag “keep” is new there and will be
created.`
Server down while the sheet is open: a yellow notice under the head, `private isn't answering`,
body `“add when back” holds the torrent until it answers. omaseed tries again in 9 s.`, action
`switch server`, `details ▸`. The add button reads `add when back` (enter hint too); once pressed:
`The torrent is held: it goes as soon as private answers.`

**Server-down band** (Kit/Notice, docs/35 option A): full window width under the hero, over rail,
table and details; idle fill (4 %), a 2 px rule in the kind's colour on the left, hairline under;
padding 9 top, 10 bottom, 16 sides (≈ 60 px at base 14).
- Row 1: glyph (12 wide, body, kind colour) · headline (body, 600, `brightForeground`) · actions
  on the right (small, `accent`), then `details ▸` (`dimForeground`, last).
- Row 2: the line (small, `foreground`), aligned with the headline, wraps; the countdown sits in a
  fixed-width slot.
- Details open: a further 4 % block, caption, `dimForeground`, copy link at its bottom right.
- Yellow `!` while omaseed retries by itself; red `✕` when it needs you.
Words (ErrorWords, verbatim templates):
| state | headline | line | actions |
|---|---|---|---|
| didn't answer (yellow) | `private didn't answer` | `Nothing is listening at 127.0.0.1:8091. omaseed tries again in 7 s.` + ` The list below is from 23:26.` | `retry now` · `switch server` |
| not found (yellow) | `private couldn't be found` | `<address> doesn't resolve on this computer. omaseed tries again in 7 s.` | same |
| too slow (yellow) | `private is taking too long` | `No answer in 10 s. omaseed tries again in 7 s.` | same |
| sign-in refused (red) | `seedbox refused the sign-in` | `The username or password omaseed has for it is wrong. It won't try again until you change them.` (API key: `The API key omaseed has for it is wrong. It won't try again until you change it.`) | `edit login` · `switch server` |
| banned (red) | `private refused omaseed` | `Too many failed sign-ins, or this computer's address is banned in its Web UI settings.` | `edit login` · `switch server` |
| certificate (red) | `private's certificate isn't trusted` / `private's certificate changed` | `Review it in Settings › Servers before omaseed trusts it.` | `review certificate` · `switch server` |
`switch server` only with two servers or more. Details text: `network error · GET sync/maindata ·
Connection refused · 127.0.0.1:8091`. Footer hints while lost: `R retry  ctrl+s server  ,
settings` (no `R retry` after a refused sign-in). A refused sign-in is no longer called
"unreachable" and is not retried by itself. **Code wins:** doc 33's mocks draw "didn't answer"
red; docs/35 and the code make it yellow `!`.
Settings › Servers: the current server's status reads `in use` (was `default`).

---

## 5. Backup, contrast floor, screen readers

**Backup** (Settings › qBittorrent › Backup): a scope line `private's own settings and torrents,
read from and sent to private only.` (+ `public has its own:` and a `switch server` link with `s`).
Sections `settings` and `torrents`, rows with ↓/↑ glyphs and buttons:
`Export private's settings` [`export…`] "Preferences, 4 categories, 7 tags, 2 RSS feeds and 5
rules. Passwords are left out. Saved as …" · `Import settings into private` [`import…`] "From a
qBittorrent export or an omaseed backup. Every change is shown first; paths, ports and the Web UI
login stay as they are unless you tick them." · `Copy settings from another server` [`copy…`] "Read
from that server just now, then shown as an import into private. Nothing changes on the other
server." · `Export private's torrents` [`export…`] "312 torrents with their save paths, categories,
tags and limits. The 2.4 TB of files stay where they are. Saved as …" · `Import torrents into
private` [`import…`] "Adds them, lets qBittorrent check the files on disk, then starts the complete
ones. Torrents already on private are skipped." Disconnected: `Connect to private to export.`
One sentence: one private file holds every torrent with its save path, category, tags, limits,
state, renamed files and priorities; a readable settings file holds the rest with no password.

**Contrast floor** (docs/38): every text and glyph colour (`dimForeground`, `accent`, `red`,
`yellow`, `orange`, `green`, `cyan`, `blue`, `magenta`) is lifted towards `foreground` in 1/256
steps until it reads 4.5:1 (WCAG AA) on the window background; a colour that already reads is
kept byte for byte. `omaseed --theme-roles` prints the colours as drawn. For the page: if the
replica's theme keys are copied raw, some themes' dim/red/yellow text will be lower contrast than
the app draws it.

**Screen readers:** every row, control and text is reachable; controls are named by what they do
(not a glyph or key), the key goes in the description as `shortcut ~`, and pressing one acts as a
click (e.g. the face tabs are page tabs named `library` / `seed` / `log`; the follow state is read
`following` / `paused` without the ● ○). The bar widget follows on Quickshell 0.3.2 or later.
