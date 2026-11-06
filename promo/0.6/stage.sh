#!/usr/bin/env bash
# The stage for this video's takes: a box named v06 with omaseed v0.6.0 on "This PC", a made-up
# library that looks lived in (promo/biglib.py, 400 open-content torrents), downloads that are
# really arriving, uploads that are really leaving, and two torrents that need you (one that can't write to its folder, one whose files are gone).
#
#   promo/0.6/stage.sh        # a few minutes; then promo/0.6/take.sh NAME
#   omabox down -b v06        # when done (--idle 0: it stays up until then)
#
# Inside the box, in a network namespace of its own (box/ns-up.sh): This PC's qBittorrent
# (203.0.113.10, Web UI on the box's 127.0.0.1:8090), a hidden seeder (.11, :8091) that seeds five
# of the library's torrents to This PC at capped speeds (ARRIVING), and a leecher (.12, :8092)
# that downloads four of This PC's torrents again and again (GIVING BACK). The trackers are
# answered by promo/tracker-proxy.py. Every file is sparse zeros. The box reaches nothing outside:
# never the real library (:8080), never the playground (:8081).
#
# Needs: omaseed's v0.6.0 Release build in OMASEED_DIR (default: the promo-v060 worktree),
# qbittorrent-nox, socat, nautilus, chromium.
set -euo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROMO=$(cd "$HERE/.." && pwd)
SEED=${OMASEED_DIR:-$HOME/code/omarchy/.worktrees/omaseed/promo-v060}
BIN=$SEED/build-release/omaseed
BOX=v06
B=(-b "$BOX")
[ -x "$BIN" ] || { echo "no $BIN: build omaseed v0.6.0 Release first" >&2; exit 1; }

omabox down "${B[@]}" >/dev/null 2>&1 || true
omabox up "$BOX" --size 3840x2160,scale=2.5 --stock-bar --theme tokyo-night --ro-bind "$SEED" --net isolated --idle 0 >/dev/null
H=$(omabox path "${B[@]}" --home)
mkdir -p "$H/bin" "$H/data" "$H/seedsrc" "$H/leech" "$H/.stash" "$H/.arrive" "$H/.config/gtk-3.0"
cp "$PROMO/tracker-proxy.py" "$HERE/box/ns-up.sh" "$HERE/box/leech.sh" "$H/bin/"
chmod +x "$H/bin/"*.sh

# qBittorrent profiles: NAME WEBUI_PORT BT_PORT SAVE ADDRESS [EXTRA BitTorrent LINES]
qbt_conf() {
  local d=$H/.local/share/qbt-$1/qBittorrent/config
  mkdir -p "$d"
  cat >"$d/qBittorrent.conf" <<EOF
[LegalNotice]
Accepted=true

[BitTorrent]
Session\\Port=$3
Session\\DefaultSavePath=$4
Session\\InterfaceAddress=$5
Session\\MultiConnectionsPerIp=true
Session\\QueueingSystemEnabled=false
Session\\DHTEnabled=false
Session\\PeXEnabled=false
Session\\LSDEnabled=false
Session\\ProxyPeerConnections=false
${6:-}

[Network]
Proxy\\Type=HTTP
Proxy\\IP=127.0.0.1
Proxy\\Port=8099
Proxy\\HostnameLookupEnabled=true
Proxy\\Profiles\\BitTorrent=true
Proxy\\Profiles\\Misc=false
Proxy\\Profiles\\RSS=false

[Preferences]
WebUI\\Enabled=true
WebUI\\Address=127.0.0.1
WebUI\\Port=$2
WebUI\\LocalHostAuth=false
EOF
}
# This PC uploads 1.5 MB/s at most outside a burst; the leecher takes 12 MB/s at most.
qbt_conf pc 8090 27100 /home/sbx/data 203.0.113.10 'Session\GlobalUPSpeedLimit=1536'
qbt_conf seed 8091 27101 /home/sbx/seedsrc 203.0.113.11
qbt_conf leech 8092 27102 /home/sbx/leech 203.0.113.12 'Session\GlobalDLSpeedLimit=12288'

echo "making the library (This PC) and the seeder's copy of it"
python3 -I "$PROMO/biglib.py" "$H/.local/share/qbt-pc" "$H/data" /home/sbx/data 400 >/dev/null
python3 -I "$PROMO/biglib.py" "$H/.local/share/qbt-seed" "$H/seedsrc" /home/sbx/seedsrc 400 >/dev/null
python3 -I "$HERE/box/pick.py" "$H"

# The second drive: a tmpfs in the box, so a move copies real bytes; Files has both as places.
omabox run "${B[@]}" -- sh -c 'mkdir -p /tmp/archive && ln -sfn /tmp/archive /home/sbx/archive &&
  mkdir -p /home/sbx/data/locked && chmod 555 /home/sbx/data/locked'
printf 'file:///home/sbx/data data\nfile:///home/sbx/archive archive\n' >"$H/.config/gtk-3.0/bookmarks"

omabox run "${B[@]}" -d -- /home/sbx/bin/ns-up.sh >/dev/null
omabox wait "${B[@]}" --timeout 90s until -- sh -c 'for p in 8090 8091 8092; do curl -sf http://127.0.0.1:$p/api/v2/app/version >/dev/null || exit 1; done' >/dev/null
omabox run "${B[@]}" -- sh -c '
  P=http://127.0.0.1:8090/api/v2; S=http://127.0.0.1:8091/api/v2
  # ARRIVING: added on This PC (their files are not there), fed by the seeder at capped speeds.
  while read -r h cat save limit; do
    curl -s -F "torrents=@/home/sbx/.arrive/$h.torrent" -F "savepath=$save" -F "category=$cat" "$P/torrents/add" >/dev/null
    [ "$limit" = 0 ] || curl -s "$S/torrents/setUploadLimit" -d hashes=$h -d limit=$limit >/dev/null
  done < /home/sbx/.arrive/list
  sleep 3
  curl -s "$P/torrents/setForceStart" -d hashes=$(cat /home/sbx/.arrive/locked) -d value=true >/dev/null
  # the leecher'"'"'s torrents seed even if the library had them stopped
  for f in /home/sbx/.stash/*.torrent; do h=$(basename "$f" .torrent); curl -s "$P/torrents/start" -d hashes=$h >/dev/null; done'
omabox run "${B[@]}" -d -- /home/sbx/bin/leech.sh >/dev/null
# private albums from a made-up tracker, for the create take (box/private.py)
python3 -I "$HERE/box/private.py" "$H" >/dev/null
omabox run "${B[@]}" -- sh -c 'for f in /home/sbx/.private/*.torrent; do curl -s -F "torrents=@$f" -F savepath=/home/sbx/data/music/private -F category=music -F skip_checking=true http://127.0.0.1:8090/api/v2/torrents/add >/dev/null; done'

# servers.json: This PC alone. The rows view, as a new install shows it.
mkdir -p "$H/.config/omaseed"; chmod 700 "$H/.config/omaseed"
printf '%s' '{"version":1,"defaultId":"pc","servers":[{"id":"pc","name":"This PC","url":"http://127.0.0.1:8090","authMode":"none","username":"","pathMap":[],"isDefault":true,"addedAt":"2026-09-23T00:00:00Z"}]}' \
  >"$H/.config/omaseed/servers.json"
chmod 600 "$H/.config/omaseed/servers.json"
omabox wait "${B[@]}" --timeout 90s until -- sh -c 'curl -s http://127.0.0.1:8090/api/v2/transfer/info | grep -q "\"connected\""' >/dev/null ||
  echo "warn: This PC does not read connected yet" >&2
echo "the stage is up (box $BOX): promo/0.6/take.sh NAME"
