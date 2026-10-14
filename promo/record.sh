#!/usr/bin/env bash
# One take of the promo video, in the `promo` box set up by promo/stage.sh (README.md here).
#
#   promo/record.sh OUT_DIR
#
# Puts the box back to the take's starting point (This PC, Tokyo Night, Field Recordings not yet
# added), records the screen with `omabox record` while it drives omaseed, and writes
# OUT_DIR/take.mp4 (the box's own pixels, 3840x2160) and OUT_DIR/captions.tsv (when each
# scene starts, in seconds from the start of the video, and its caption) for promo/cut.sh.
set -euo pipefail
OUT=${1:?OUT_DIR}
mkdir -p "$OUT"
B=(-b promo)
H=$(omabox path -b promo)/home
SEED=${OMASEED_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../omaseed" && pwd)}   # the omaseed checkout
BIN=$SEED/build-release/omaseed

# view SERVER FOLDED SORT ORDER: how that server's table opens (omaseed keeps it in state.json):
# the details pane folded or not, the sort column and order (0 up, 1 down). Clicking would only
# flip whatever the last run left. omaseed must not be running (it writes the file on quit).
view() {
  python3 - "$H/.config/omaseed/state.json" "$@" <<'EOF2'
import json, os, sys
p, server, folded, role, order = sys.argv[1:]
d = json.load(open(p)) if os.path.exists(p) else {"version": 1}
t = d.setdefault("tables", {}).setdefault(server, {})
t.update(detailsFolded=folded == "folded", sortRole=role, sortOrder=int(order))
json.dump(d, open(p, "w"))
EOF2
}
ob() { omabox "$1" "${B[@]}" "${@:2}" >/dev/null; }
still() { omabox wait "${B[@]}" --timeout "${1:-10s}" still >/dev/null || true; }
api() { omabox run "${B[@]}" -- curl -s "http://127.0.0.1:$1/api/v2/$2" "${@:3}"; }
# type TEXT: three characters a key event, a person's pace.
type_() { local s=$1 i; for ((i = 0; i < ${#s}; i += 2)); do ob keys -t "${s:i:2}"; sleep 0.09; done; }

# ---- back to the start ---------------------------------------------------------------------
pid=$(omabox run "${B[@]}" -- pgrep -f "$BIN" || true)
if [ -n "$pid" ]; then
  omabox run "${B[@]}" -- kill $pid
  omabox wait "${B[@]}" --timeout 15s window omaseed --gone >/dev/null || true
fi
field=$(api 8090 torrents/info | python3 -c '
import json,sys
print("|".join(t["hash"] for t in json.load(sys.stdin) if t["name"].startswith(("Field Recordings", "Nested Library"))))')
[ -n "$field" ] && api 8090 torrents/delete -d "hashes=$field" -d deleteFiles=true >/dev/null
T=~/.local/share/omaseed-swarm/torrents
cp "$T/Field Recordings Vol. 3 [FLAC].torrent" "$T/Nested Library Sampler (2026).torrent" "$H/Downloads/"
# The newest is listed first: Field Recordings on top, where the take clicks.
touch -d '-20 min' "$H/Downloads/Nested Library Sampler (2026).torrent"
touch -d '-8 min' "$H/Downloads/Field Recordings Vol. 3 [FLAC].torrent"
view pc open addedOn 0       # details open; oldest first, so a new torrent is the last row
view nas folded ratio 1      # details shut for whole names; the heaviest seeders first
python3 - "$H/.config/omaseed/servers.json" <<'EOF'
import json, sys
p = sys.argv[1]; d = json.load(open(p))
d["defaultId"] = "pc"
for s in d["servers"]: s["isDefault"] = s["id"] == "pc"
json.dump(d, open(p, "w"))
EOF
omabox run "${B[@]}" -- omarchy-theme-set tokyo-night >/dev/null 2>&1 || true
still 15s
omabox run "${B[@]}" --pass QT_FORCE_STDERR_LOGGING -d --wait -- "$BIN" >/dev/null 2>&1
still 15s
ob pointer -- move 640 500
still

# ---- the take ------------------------------------------------------------------------------
: >"$OUT/captions.tsv"
omabox record "${B[@]}" start -o "$OUT/take.mp4" --fps 30 >/dev/null
t0=$(date +%s%N)
scene() { printf '%s\t%s\n' "$(( ($(date +%s%N) - t0) / 1000000 ))" "$1" >>"$OUT/captions.tsv"; }

scene "Torrents, finally at home on Omarchy"
sleep 1.5
for k in j j j k; do ob keys "$k"; sleep 0.35; done
sleep 0.5

scene "See every file before you add it"
ob keys a; sleep 1.0
ob click --steps 14 480 241; sleep 1.4        # Field Recordings, the newest in ~/Downloads
ob scroll 640 620 -60; sleep 0.8             # down its 16 files
ob keys Return
# Off screen: hand it the swarm's seeder now, not at its first announce some seconds on.
api 8090 torrents/addPeers -d hashes=all -d peers=127.0.0.1:26997 >/dev/null
ob click --steps 12 300 266                   # the new row, last (the table keeps qBittorrent's order)
api 8090 torrents/addPeers -d hashes=all -d peers=127.0.0.1:26997 >/dev/null; sleep 0.4
ob click --steps 12 975 208; sleep 2.2        # its Files tab, filling in

scene "Follows your Omarchy theme, live"
for theme in catppuccin-latte kanagawa rose-pine tokyo-night; do
  omabox run "${B[@]}" -- omarchy-theme-set "$theme" >/dev/null 2>&1 || true
  sleep 1.1
done

scene "One server or many: 3,500 torrents on the NAS"
ob click --steps 14 61 618; sleep 0.9         # the rail's NAS
ob keys G; sleep 0.6
ob keys g g; sleep 0.6
ob keys slash; sleep 0.3
type_ "ubuntu"; sleep 1.4
ob keys Escape; sleep 0.3
ob keys Escape; sleep 0.5

scene "A year of seeding, kept by omaseed"
ob keys grave; sleep 2.2
ob keys bracketright; sleep 1.0
ob keys bracketright; sleep 1.0
ob keys bracketright; sleep 1.8

scene "And in your bar"
ob click --steps 16 1253 13; sleep 2.8
ob keys Escape
ob pointer -- move 1100 690 --steps 10; sleep 0.6

scene "omaseed.app"
sleep 2.0
omabox record "${B[@]}" stop
echo "$OUT/take.mp4"
