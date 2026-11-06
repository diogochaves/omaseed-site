# The acts of take.sh, one per storyboard group (sourced, not run). Coordinates are the box's
# logical pixels (1536x864, the window full screen at 0,0).

# shots 1-2: what needs me is on top, then every row says it in words. The keyboard moves the
# cursor (a click would select the row and bring up the action bar); the details pane follows.
stage_rows() {
  tails_broken; app; pause 12s; k Escape; cursor_on "tails-7.4"; glide 1300 700 300ms; still 1s
}
act_rows() {
  mark start; hold 3.2s
  k j; still; mark readonly; hold 2.4s
  k j; still; mark arriving; hold 2.4s
  k j; hold 0.35s; k j; hold 0.35s; k j; hold 0.35s; k j; still; mark noseed; hold 2s
  k j; still; mark giving; hold 2.8s
}

# a workspace of its own for Files and Chromium, so each is alone and full screen there
ws() { omabox keys -b "$BOX" --wait "super+$1" >/dev/null 2>&1 || true; still; }

# This PC's qBittorrent stopped and started again in the namespace (it finds missing files at start)
qbt_restart() {
  api app/shutdown -X POST >/dev/null || true
  omabox -b "$BOX" wait --timeout 30s until -- sh -c '! pgrep -f "profile=/home/sbx/.local/share/qbt-pc"' >/dev/null 2>&1 || true
  omabox run -b "$BOX" -d -- sh -c 'nsenter --preserve-credentials -U -n -t $(cat /home/sbx/ns/pid) setpriv --inh-caps=-all --bounding-set=-all qbittorrent-nox --profile=/home/sbx/.local/share/qbt-pc' >/dev/null
  omabox -b "$BOX" wait --timeout 60s until -- curl -sf http://127.0.0.1:8090/api/v2/app/version >/dev/null 2>&1 || true
  pause 6s
}
radio_home() {  # radio back on the seeding drive (data), wherever the last take left it
  omabox run -b "$BOX" -- sh -c '[ -d /tmp/archive/radio ] && [ ! -d /home/sbx/data/radio ] && mv /tmp/archive/radio /home/sbx/data/; true'
}

# shot 3: before, I moved the folder in Files
stage_before_files() {
  radio_home
  omabox run -b "$BOX" -- pkill -x nautilus || true
  ws 2
  omabox run -b "$BOX" -d --wait -- nautilus --new-window /home/sbx/data >/dev/null
  W=Nautilus; omabox click -b "$BOX" 1100 650 >/dev/null 2>&1; full; still 1s; glide 900 600 300ms
}
act_before_files() {
  mark start; hold 1.4s
  omabox click -b "$BOX" 1288 121 --glide 700ms >/dev/null 2>&1; still; mark picked; hold 0.6s
  W=Nautilus; k ctrl+x; hold 0.4s
  omabox click -b "$BOX" 69 311 --glide 600ms >/dev/null 2>&1; still 1s; mark archive; hold 0.6s
  k ctrl+v; mark paste
  omabox -b "$BOX" wait --timeout 60s until -- sh -c '[ -d /tmp/archive/radio ] && [ ! -e /home/sbx/data/radio ]' >/dev/null 2>&1 || echo "warn: radio did not move" >&2
  still 1s; mark moved; hold 2.2s
}

# shot 4: ...and qBittorrent lost every torrent in it (its own Web UI, the box's qBittorrent)
stage_before_web() {
  omabox run -b "$BOX" -- pkill -x nautilus || true
  # radio on the archive drive, as the Files take left it (again, on a retake)
  omabox run -b "$BOX" -- sh -c '[ -d /home/sbx/data/radio ] && mv /home/sbx/data/radio /tmp/archive/; true'
  qbt_restart
  pause 14s   # omaseed's toast for the read-only torrent comes and goes
  omabox run -b "$BOX" -- pkill -f 'user-data-dir=/tmp/webui' || true
  ws 2
  omabox run -b "$BOX" -d --wait -- chromium --user-data-dir=/tmp/webui --no-first-run --no-default-browser-check \
    --ozone-platform=wayland --force-dark-mode --app=http://127.0.0.1:8090 >/dev/null
  W=chromium; omabox click -b "$BOX" 900 600 >/dev/null 2>&1; full; pause 3s; still 1s; glide 1400 800 300ms
}
act_before_web() {
  mark start; hold 1.6s
  omabox click -b "$BOX" 53 697 --glide 800ms --wait >/dev/null 2>&1 || true   # CATEGORIES › radio (10)
  still 1s; mark radio; hold 4s
}
after_before_web() {
  omabox run -b "$BOX" -- pkill -f 'user-data-dir=/tmp/webui' || true
  radio_home; qbt_restart
  ws 1; W=omaseed
}

# shots 5-8: the same folder in omaseed: the rail's menu, the checks, the band, done
rail_bottom() { omabox pointer -b "$BOX" -- move 100 650 >/dev/null 2>&1; omabox pointer -b "$BOX" -- scroll 8 >/dev/null 2>&1; still; }
stage_move() { radio_home; tails_broken; app; pause 12s; rail_bottom; glide 700 450 300ms; still 1s; }
act_move() {
  mark start; hold 1.6s
  on "data/radio" right --glide 800ms; still; mark menu; hold 1s
  on "move this folder…"; still; mark sheet; hold 0.6s
  k ctrl+a; type_slow /home/sbx/archive/radio
  see "Writable"; still 1s; glide 1300 700 500ms; mark checks; hold 3.2s
  k Return; mark send; hold 2.5s; mark band
  see "radio moved" 240s; still 1s; mark done; hold 4s
}
after_move() {
  has "radio moved" || { k Escape; return; }
  on "move back…" --index 1; see "back"; still 1s
  on "move 10 back"; see "moved back" 240s; on "close"; still
}

# shot 9: when one stops, it says why, and the fix is beside it
TAILS_HOME=/home/sbx/data/locked
# tails back on the read-only disk, erroring; omaseed's move history for it dropped (a retake must
# not show the last take's move in its story)
tails_broken() {
  local h m; h=$(omabox run -b "$BOX" -- cat /home/sbx/.arrive/locked); m=$(omabox run -b "$BOX" -- cat /home/sbx/.arrive/missing)
  omabox run -b "$BOX" -- pkill -x omaseed || true
  omabox -b "$BOX" wait window omaseed --gone --timeout 10s >/dev/null 2>&1 || true
  python3 -I - "$(omabox path -b "$BOX" --home)/.config/omaseed/state.json" "$h" <<'PY'
import json, sys
p, h = sys.argv[1], sys.argv[2]
d = json.load(open(p))
for srv in d.get("moves", {}).values():
    srv["history"] = [m for m in srv.get("history", []) if h not in json.dumps(m)]
json.dump(d, open(p, "w"))
PY
  python3 -I - "$(omabox path -b "$BOX" --home)/.config/omaseed/state.json" "$m" <<'PY'
import json, sys
p, h = sys.argv[1], sys.argv[2]
d = json.load(open(p))
for srv in d.get("moves", {}).values():
    srv["history"] = [m for m in srv.get("history", []) if h not in json.dumps(m)]
json.dump(d, open(p, "w"))
PY
  api torrents/delete -d hashes="$h" -d deleteFiles=true >/dev/null
  pause 2s
  omabox run -b "$BOX" -- sh -c 'rm -f /home/sbx/data/linux-isos/tails-7.4-amd64.iso /home/sbx/data/linux-isos/.tails-7.4-amd64.iso.parts'
  api torrents/add -F "torrents=@/home/sbx/.arrive/$h.torrent" -F savepath=$TAILS_HOME -F category=linux-isos >/dev/null
  pause 2s; api torrents/setForceStart -d hashes="$h" -d value=true >/dev/null
  omabox -b "$BOX" wait --timeout 60s until -- sh -c "curl -s 'http://127.0.0.1:8090/api/v2/torrents/info?hashes=$h' | grep -q '\"state\":\"error\"'" >/dev/null 2>&1 || echo "warn: tails is not in error" >&2
}
# the cursor on the row whose details are NAME's (the order of a group can change)
cursor_on() {
  local i; k g
  for i in 1 2 3 4 5 6; do
    omabox tree -b "$BOX" --window omaseed 2>/dev/null | grep -q "heading \"$1" && return 0
    k j
  done
  echo "warn: the cursor never reached $1" >&2; return 1
}
stage_fix() { tails_broken; app; pause 12s; cursor_on tails-7.4; still 1s; glide 1300 700 300ms; still 1s; }
act_fix() {
  mark start; hold 3.2s
  k m; see "new path"; still; mark sheet; hold 0.5s
  k ctrl+a; type_slow /home/sbx/data/linux-isos; still 1s; hold 0.8s
  k Return; still 1s; mark moved; hold 1.2s
  k e; mark retry
  see "Nothing" 3s || true
  omabox -b "$BOX" wait --timeout 20s until -- sh -c "! curl -s 'http://127.0.0.1:8090/api/v2/torrents/info?filter=errored' | grep -q tails" >/dev/null 2>&1 || true
  still 1.5s; mark fixed; hold 3.5s
}

# shot 10: made for private trackers
stage_create() {
  omabox run -b "$BOX" -- sh -c 'rm -f /home/sbx/Downloads/Harbour*.torrent'
  app; glide 1300 700 300ms; still 1s
}
act_create() {
  mark start; hold 1.2s
  k ctrl+n; see "Create a torrent"; still; mark sheet; hold 0.6s
  has "A private tracker" && on "A private tracker"; still; mark private; hold 1s
  on "folder or file to share"
  omabox keys -b "$BOX" --window omaseed -t "/home/sbx/data/music/" >/dev/null; type_slow "Harbour Field Recordings (2026)"
  see "7 files"; still 1s; glide 1300 760 500ms; mark filled; hold 3.4s
  on "create .torrent"; mark create
  see "ready to upload" 30s; still 1s; glide 900 600 500ms; mark ready; hold 3.5s
}
after_create() { on "close" || true; k Escape; }

# shot 11: burst when I'm not using the connection. This PC uploads 1.5 MB/s at most; the burst
# preset has no upload cap and lasts 1 h (set once in Settings › qBittorrent › Speed).
burst_off() {
  if omabox tree -b "$BOX" --window omaseed 2>/dev/null | grep -q 'button "burst'; then
    on "burst"; on "off"; still
  fi
}
stage_burst() { app; burst_off; glide 1300 600 300ms; pause 8s; still 1s; }
act_burst() {
  mark start; hold 2.6s
  on "turtle" --glide 800ms; still; mark menu; hold 1.2s
  on "burst" --index 1; still; glide 1180 30 700ms; mark burst; hold 8s
}
after_burst() { burst_off; }

# shot 12: an experiment, a second skin: Settings › Appearance › Skin, live
skin() { on "settings" --index 1; see "Appearance"; still; on "Appearance"; still; on "$1"; still 1s; k Escape; still; }
stage_console() {
  burst_off; app
  omabox tree -b "$BOX" --window omaseed 2>/dev/null | grep -q 'heading "LIBRARY' && skin Omarchy
  app; full; still 1s   # windowed for this one: Settings needs more height than full screen gives, and
  # leaves full screen when it opens, so the take starts windowed and the edit crops to the window
  glide 1300 600 300ms; still 1s
}
act_console() {
  mark start; hold 1.2s
  on "settings" --index 1 --glide 700ms; see "Appearance"; on "Appearance" --glide 500ms; still; mark settings; hold 0.8s
  on "Console" --glide 500ms; still 1s; mark switch; hold 2.2s
  k Escape; glide 1300 600 500ms; still 1s; mark library; hold 3s
}
after_console() { skin Omarchy; }

# chapter 02: rows, a table or a space map (the display tool). From the space view the menu's
# rows are not in the accessibility tree (omaseed#228), so the way back is by position.
display_rows() {
  if omabox tree -b "$BOX" --window omaseed 2>/dev/null | grep -q 'button "display: space'; then
    on "display: space"; omabox click -b "$BOX" 1252 60 --wait >/dev/null 2>&1
  elif ! omabox tree -b "$BOX" --window omaseed 2>/dev/null | grep -q 'button "display: rows'; then
    on "display:"; on "rows" --index 1
  fi
  k Escape
}
stage_space() { app; display_rows; k 0; k g; glide 1300 600 300ms; still 1s; }
act_space() {
  mark start; hold 1.6s
  on "display:" --glide 700ms; still; mark menu; hold 0.9s
  on "table" --index 1 --glide 400ms; still 1s; glide 900 500 600ms; mark table; hold 2.4s
  on "display:" --glide 600ms; still; hold 0.5s
  on "space" --index 1 --glide 400ms; still 1s; mark space; hold 0.8s
  glide 600 300 900ms; hold 0.6s; glide 1400 250 1200ms; hold 0.6s; glide 1450 600 800ms; hold 1.4s
}
after_space() { display_rows; }

# chapter 08: the small things, one after another, each with its mark
stage_small() { app; display_rows; k 0; k g; glide 1300 600 300ms; still 1s; }
act_small() {
  mark start; hold 0.8s
  mark fold; k ctrl+b; still; hold 1.4s; k ctrl+b; still; hold 0.6s
  mark title; hold 2s
  mark alt; omabox keys -b "$BOX" --window omaseed down:alt >/dev/null; still; hold 1.8s
  omabox keys -b "$BOX" --window omaseed up:alt >/dev/null; still
  mark menu; on "omaseed menu" --glide 600ms; still; hold 1.8s; k Escape; still
  mark palette; k shift+semicolon; still; hold 0.4s; type_slow mov; still; hold 1.4s; k Escape; k Escape; still
  mark selection; k g; k j; k space; k j; k space; k j; k space; still; hold 1.6s; k Escape; still
  mark torrentmenu; on "archlinux-2026.09.01-x86_64.iso" right --glide 600ms; still
  on "transfer" --glide 500ms; still; hold 1.8s; k Escape; k Escape; still
  mark search; k ctrl+f; still; type_slow sampler; k Return
  omabox -b "$BOX" wait for 4.5s >/dev/null 2>&1; still 1s; hold 1.2s
  k Escape; k Escape; k Escape; still
  mark log; on "log" --index 1 --glide 600ms; still 1s; hold 2.4s
  k 0; still; hold 0.6s
}
