#!/usr/bin/env bash
# The stills for the posts, from the `promo` box (promo/stage.sh): a screen laid out as 1280x720
# and drawn at 3840x2160 (scale 3), so the window reads like a 720p screen and stays sharp.
#
#   promo/shots.sh OUT_DIR
#
# 1-seed-console.png  NAS, the seed console, 30 days of tide                 (3840x2160)
# 2-library.png       NAS, largest first, one torrent selected and its details;
#                     the rail's categories, tags and trackers folded, so its servers show
# 3-library-light.png the same in Catppuccin Latte
# 4-bar-widget.png    NAS: the bar and the Omaseed widget's popup, cropped to them
# 5-add-torrent.png   This PC: the add sheet on Field Recordings, cropped to the sheet
#
# The window is opaque here: omaseed's own translucency off (Appearance's window opacity at
# 100 %) and its Hyprland rule installed, as its README says, so Omarchy's default opacity does
# not apply either. The wallpaper stays out of the app.
set -euo pipefail
OUT=${1:?OUT_DIR}
mkdir -p "$OUT"
B=(-b promo)
H=$(omabox path -b promo)/home
SEED=${OMASEED_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../omaseed" && pwd)}   # the omaseed checkout
BIN=$SEED/build-release/omaseed
ob() { omabox "$1" "${B[@]}" "${@:2}" >/dev/null; }
still() { omabox wait "${B[@]}" --timeout "${1:-10s}" still >/dev/null || true; }
api() { omabox run "${B[@]}" -- curl -s "http://127.0.0.1:$1/api/v2/$2" "${@:3}"; }
# shot NAME: the whole screen at full size (3x the layout), whatever shot-fit says.
shot() { omabox shot "${B[@]}" --fit 0 -o "$OUT/$1" >/dev/null 2>&1; echo "$OUT/$1"; }

# state KEY=JSON...: omaseed's state.json, edited while omaseed is not running (it writes the
# file on quit). Clicking would only flip whatever the last run left.
state() {
  python3 - "$H/.config/omaseed/state.json" "$@" <<'EOF'
import json, os, sys
p = sys.argv[1]
d = json.load(open(p)) if os.path.exists(p) else {"version": 1}
for kv in sys.argv[2:]:
    path, value = kv.split("=", 1)
    node = d
    keys = path.split(".")
    for k in keys[:-1]:
        node = node.setdefault(k, {})
    node[keys[-1]] = json.loads(value)
json.dump(d, open(p, "w"))
EOF
}
quit_app() {
  local pid
  pid=$(omabox run "${B[@]}" -- pgrep -f "$BIN" || true)
  if [ -n "$pid" ]; then
    omabox run "${B[@]}" -- kill $pid
    omabox wait "${B[@]}" --timeout 15s window omaseed --gone >/dev/null || true
  fi
}
# open_app SERVER: omaseed, fresh, on that server; back once its first sync is in.
open_app() {
  python3 - "$H/.config/omaseed/servers.json" "$1" <<'EOF'
import json, sys
p = sys.argv[1]; d = json.load(open(p))
d["defaultId"] = sys.argv[2]
for s in d["servers"]: s["isDefault"] = s["id"] == sys.argv[2]
json.dump(d, open(p, "w"))
EOF
  local log
  log=$(omabox run "${B[@]}" --pass QT_FORCE_STDERR_LOGGING -d --wait -- "$BIN" 2>&1 | sed -n 's/.*log: \(.*\))$/\1/p' | head -1)
  for _ in $(seq 100); do grep -q "first sync" "$log" 2>/dev/null && break; sleep 0.2; done
  still 20s
}
# theme NAME: a theme change reloads Hyprland, which shows the pointer again.
theme() {
  omabox run "${B[@]}" -- omarchy-theme-set "$1" >/dev/null 2>&1 || true
  still 15s
  omabox lua "${B[@]}" 'hl.config({ cursor = { invisible = true } }) return 1' >/dev/null
  still
}

# omaseed's window rule (no default opacity on it), in the box's own Hyprland config
cp "$SEED/data/hyprland/omaseed.lua" "$H/.config/hypr/omaseed.lua"
grep -q 'require("hypr.omaseed")' "$H/.config/hypr/hyprland.lua" ||
  echo 'require("hypr.omaseed")' >>"$H/.config/hypr/hyprland.lua"

quit_app
state appearance.windowAlphaOverride=100 \
  'tables.nas.detailsFolded=false' 'tables.nas.sortRole="size"' 'tables.nas.sortOrder=1' \
  'tables.nas.railFolded=["categories","tags","trackers"]' \
  'tables.pc.detailsFolded=false' 'tables.pc.sortRole="addedOn"' 'tables.pc.sortOrder=0'
theme tokyo-night                                  # also reloads Hyprland: the rule is in

# Field Recordings and Nested Library in ~/Downloads, not in This PC's library: the widget's Add
# list and the add sheet show them.
field=$(api 8090 torrents/info | python3 -c '
import json,sys
print("|".join(t["hash"] for t in json.load(sys.stdin) if t["name"].startswith(("Field Recordings", "Nested Library"))))')
[ -n "$field" ] && api 8090 torrents/delete -d "hashes=$field" -d deleteFiles=true >/dev/null
T=~/.local/share/omaseed-swarm/torrents
cp "$T/Field Recordings Vol. 3 [FLAC].torrent" "$T/Nested Library Sampler (2026).torrent" "$H/Downloads/"
touch -d '-20 min' "$H/Downloads/Nested Library Sampler (2026).torrent"
touch -d '-8 min' "$H/Downloads/Field Recordings Vol. 3 [FLAC].torrent"

# crop IN OUT X0 Y0 X1 Y1 [bar]: IN cut to the box its accent border draws inside that search
# region (image pixels): its first and last long columns, and how far they run. "bar"
# keeps everything above it too, up to the top of the screen (the bar the popup hangs from).
crop() {
  python3 - "$@" <<'EOF'
import sys
from PIL import Image
src, dst, x0, y0, x1, y1 = sys.argv[1:7]; x0, y0, x1, y1 = map(int, (x0, y0, x1, y1))
im = Image.open(src).convert("RGB"); px = im.load()
acc = (0x7a, 0xa2, 0xf7)
near = lambda p: all(abs(a - b) < 45 for a, b in zip(p, acc))
cols = [x for x in range(x0, x1) if sum(near(px[x, y]) for y in range(y0, y1, 3)) * 3 >= (y1 - y0) * 0.6]
# Top and bottom: the left border's first unbroken run (a line under the box can cross it).
rows = [y for y in range(y0, y1) if near(px[cols[0], y])]
rows = rows[:next((i for i in range(1, len(rows)) if rows[i] != rows[i - 1] + 1), len(rows))]
box = (cols[0], 0 if len(sys.argv) > 7 else rows[0], cols[-1] + 1, rows[-1] + 1)
im.crop(box).save(dst)
print(dst, box)
EOF
}

# NAS
open_app nas
ob keys grave; still                               # the seed console, every torrent (before a
ob keys bracketright; still; ob keys bracketright; still   # selection scopes it): 24h → 7d → 30d
shot 1-seed-console.png
ob keys grave; still
ob click 1253 13                                   # the bar widget, NAS's
ob pointer -- move 640 690; still
shot full-bar-widget.png
crop "$OUT/full-bar-widget.png" "$OUT/4-bar-widget.png" 2400 90 3840 2160 bar
ob keys Escape; still
ob click 300 150                                   # the largest torrent: selected, its details
ob pointer -- move 90 650; still                   # off the row: no tooltip
shot 2-library.png
theme catppuccin-latte
shot 3-library-light.png
theme tokyo-night

# This PC: the add sheet
quit_app
open_app pc
ob keys a; still
ob click 480 241                                   # Field Recordings
ob pointer -- move 1200 690; still
shot full-add-torrent.png
crop "$OUT/full-add-torrent.png" "$OUT/5-add-torrent.png" 600 140 3300 2140
ob click 447 627; still                            # cancel
rm -f "$OUT"/full-*.png
