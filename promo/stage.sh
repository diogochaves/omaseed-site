#!/usr/bin/env bash
# The stage for promo/record.sh and promo/shots.sh: a box named `promo` with omaseed and two
# qBittorrents of its own, "This PC" (a small library from omaseed's dev swarm) and "NAS" (3,500
# synthetic torrents, promo/biglib.py), both uploading for real to a leecher in the box, and a
# year of seeding history in each ledger. Nothing touches the real library (:8080) or the
# playground (:8081): the box reaches only the swarm's tracker and seeder.
#
#   promo/stage.sh            # takes a few minutes; then promo/record.sh, promo/shots.sh
#   omabox down -b promo      # when done (it has --idle 0: it stays up until then)
#
# Needs: omaseed's Release build (cmake -B build-release -DCMAKE_BUILD_TYPE=Release in the omaseed
# checkout), its dev swarm (scripts/dev/swarm.sh), qbittorrent-nox, socat, ffmpeg, ImageMagick.
#
# The box (3840x2160 at scale 3: laid out as 1280x720, drawn at 4K) runs everything torrent in a
# network namespace of its own, on 203.0.113.x (documentation addresses): qBittorrent counts a
# peer from 127.0.0.1 as local and keeps reading "firewalled", which omaseed shows as "port not
# reachable". The Web UIs reach omaseed, and the swarm reaches the namespace, through socat on
# unix sockets. The NAS's trackers are answered by promo/tracker-proxy.py (HTTP proxy) inside.
set -euo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SEED=${OMASEED_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../omaseed" && pwd)}   # the omaseed checkout
BIN=$SEED/build-release/omaseed
SWARM=$SEED/scripts/dev/swarm.sh
B=(-b promo)
[ -x "$BIN" ] || { echo "no $BIN: build omaseed Release first" >&2; exit 1; }

"$SWARM" start >/dev/null
"$SWARM" rate 8192 >/dev/null
T=~/.local/share/omaseed-swarm/torrents
[ -f "$T/Field Recordings Vol. 3 [FLAC].torrent" ] || "$SWARM" seed >/dev/null

omabox down "${B[@]}" >/dev/null 2>&1 || true
omabox up promo --size 3840x2160,scale=3 --stock-bar --theme tokyo-night --plugin "$SEED/plugin" \
  --ro-bind "$SEED" --net isolated --allow 26996,26997 --idle 0 >/dev/null
H=$(omabox path -b promo)/home
mkdir -p "$H/bin" "$H/Torrents" "$H/Downloads" "$H/leech" "$H/.stash" "$H/.stash-nas"
cp "$HERE/tracker-proxy.py" "$HERE/box/ns-up.sh" "$HERE/box/leech.sh" "$H/bin/"
chmod +x "$H/bin/"*.sh

# qBittorrent profiles: PROFILE WEBUI_PORT BT_PORT SAVE [EXTRA LINES]
qbt_conf() {
  mkdir -p "$H/.local/share/$1/qBittorrent/config"
  cat >"$H/.local/share/$1/qBittorrent/config/qBittorrent.conf" <<EOF
[LegalNotice]
Accepted=true

[BitTorrent]
Session\\Port=$3
Session\\DefaultSavePath=$4
Session\\MultiConnectionsPerIp=true
Session\\QueueingSystemEnabled=false
Session\\DHTEnabled=false
Session\\PeXEnabled=false
Session\\LSDEnabled=false
Session\\ProxyPeerConnections=false
${6:-}

[Preferences]
WebUI\\Enabled=true
WebUI\\Address=127.0.0.1
WebUI\\Port=$2
WebUI\\LocalHostAuth=false
${5:-}
EOF
}
qbt_conf qbt-pc 8090 27100 /home/sbx/Torrents
qbt_conf qbt-nas 8091 27101 /home/sbx/NAS '
[Network]
Proxy\Type=HTTP
Proxy\IP=127.0.0.1
Proxy\Port=8099
Proxy\HostnameLookupEnabled=true
Proxy\Profiles\BitTorrent=true
Proxy\Profiles\Misc=false
Proxy\Profiles\RSS=false'
qbt_conf qbt-leech 8092 27102 /home/sbx/leech '' 'Session\GlobalDLSpeedLimit=12288
Session\InterfaceAddress=203.0.113.12'

echo "making the NAS library"
python3 "$HERE/biglib.py" "$H/.local/share/qbt-nas" "$H/NAS" /home/sbx/NAS 3500

# The ledger's made-up year (OMASEED_LEDGER_DEMO) is sized to what is complete when it is made:
# a fifth of it a day. With 14 TiB that is a petabyte a year, so the NAS starts with ~320 GB of
# it (about 80 GB a day, a believable home NAS), and gets the rest once the year is written.
D=$H/.local/share/qbt-nas/qBittorrent/data
mv "$D/BT_backup" "$D/BT_backup.full"; mkdir "$D/BT_backup"
python3 - "$D" <<'EOF'
import os, random, re, sys
D = sys.argv[1]; full = D + "/BT_backup.full"
size = lambda h: sum(int(m) for m in re.findall(rb"6:lengthi(\d+)e", open(f"{full}/{h}.torrent", "rb").read()))
hashes = sorted({f[:-8] for f in os.listdir(full) if f.endswith(".torrent")})
random.Random(7).shuffle(hashes)
total = 0
for h in hashes:
    s = size(h)
    if total + s > 320 * 1024**3: continue
    total += s
    for ext in (".torrent", ".fastresume"):
        os.link(f"{full}/{h}{ext}", f"{D}/BT_backup/{h}{ext}")
    if total > 315 * 1024**3: break
EOF

# This PC's library: four of the swarm's torrents, downloaded for real; two more wait in
# ~/Downloads for the take to add.
for f in "Open Movie Night (2026)" "distro-2026.09-x86_64.iso" "photo-archive-2019-2025" "Public Domain Sampler"; do
  cp "$T/$f.torrent" "$H/.stash/"
done
cp "$T/Field Recordings Vol. 3 [FLAC].torrent" "$T/Nested Library Sampler (2026).torrent" "$H/Downloads/"

omabox run "${B[@]}" -d -- /home/sbx/bin/ns-up.sh >/dev/null
omabox wait "${B[@]}" --timeout 60s cmd -- sh -c 'curl -sf http://127.0.0.1:8090/api/v2/app/version && curl -sf http://127.0.0.1:8091/api/v2/app/version && curl -sf http://127.0.0.1:8092/api/v2/app/version' >/dev/null
api() { omabox run "${B[@]}" -- curl -s "http://127.0.0.1:$1/api/v2/$2" "${@:3}"; }
omabox run "${B[@]}" -- sh -c 'for f in ~/.stash/*.torrent; do curl -s -F "torrents=@$f" -F savepath=/home/sbx/Torrents http://127.0.0.1:8090/api/v2/torrents/add >/dev/null; done'
echo "downloading This PC's library from the swarm"
omabox wait "${B[@]}" --timeout 300s cmd -- sh -c 'curl -s http://127.0.0.1:8090/api/v2/torrents/info?filter=completed | python3 -c "import json,sys; sys.exit(0 if len(json.load(sys.stdin)) == 4 else 1)"' >/dev/null

# servers.json, and the two tables as the takes want them (state.json; record.sh sets them again)
mkdir -p "$H/.config/omaseed"; chmod 700 "$H/.config/omaseed"
cat >"$H/.config/omaseed/servers.json" <<'EOF'
{"version":1,"defaultId":"nas","servers":[
{"id":"pc","name":"This PC","url":"http://127.0.0.1:8090","authMode":"none","username":"","pathMap":[],"isDefault":false,"addedAt":"2026-09-23T00:00:00Z"},
{"id":"nas","name":"NAS","url":"http://127.0.0.1:8091","authMode":"none","username":"","pathMap":[],"isDefault":true,"addedAt":"2026-09-23T00:00:00Z"}]}
EOF
chmod 600 "$H/.config/omaseed/servers.json"

# The year: NAS fills at its first sync; a switch to This PC writes NAS's ledger and fills This
# PC's; a switch back writes This PC's. (A quit writes nothing that is still in memory.)
echo "writing a year of seeding history"
log=$(QT_FORCE_STDERR_LOGGING=1 OMASEED_LEDGER_DEMO=1 omabox run "${B[@]}" --pass QT_FORCE_STDERR_LOGGING \
  --pass OMASEED_LEDGER_DEMO -d --wait -- "$BIN" 2>&1 | sed -n 's/.*log: \(.*\))$/\1/p' | head -1)
syncs() { grep -c "first sync" "$log" 2>/dev/null || true; }
until_syncs() { for _ in $(seq 150); do [ "$(syncs)" -ge "$1" ] && return; sleep 0.2; done; echo "no sync $1" >&2; exit 1; }
until_syncs 1
omabox wait "${B[@]}" --timeout 10s still >/dev/null || true
omabox scroll "${B[@]}" 90 500 900 >/dev/null              # the rail, down to its servers
omabox wait "${B[@]}" --timeout 5s still >/dev/null || true
omabox click "${B[@]}" 75 635 >/dev/null; until_syncs 2       # This PC
omabox wait "${B[@]}" --timeout 10s still >/dev/null || true
omabox click "${B[@]}" 61 618 >/dev/null; until_syncs 3       # NAS
omabox wait "${B[@]}" --timeout 10s still >/dev/null || true
pids=$(omabox run "${B[@]}" -- pgrep -f "$BIN|qbt-nas" | tr '\n' ' ')
omabox run "${B[@]}" -- kill $pids
omabox wait "${B[@]}" --timeout 20s cmd -- sh -c "for p in $pids; do kill -0 \$p 2>/dev/null && exit 1; done; exit 0" >/dev/null
ls "$H/.local/share/omaseed/ledger/"{nas,pc}.sqlite >/dev/null

rm -rf "$D/BT_backup"; mv "$D/BT_backup.full" "$D/BT_backup"
omabox run "${B[@]}" -d -- nsenter --preserve-credentials -U -n -t "$(cat "$H/ns/pid")" \
  qbittorrent-nox --profile=/home/sbx/.local/share/qbt-nas >/dev/null
omabox wait "${B[@]}" --timeout 120s cmd -- sh -c 'curl -sf http://127.0.0.1:8091/api/v2/torrents/info | python3 -c "import json,sys; sys.exit(0 if len(json.load(sys.stdin)) == 3500 else 1)"' >/dev/null

# The leecher: This PC's four and four NAS talks, again and again.
api 8091 'torrents/info?category=talks&filter=seeding' | python3 -c "
import json,sys
for t in [x for x in json.load(sys.stdin) if 300e6 < x['size'] < 700e6][:4]: print(t['hash'])" |
  while read -r h; do cp "$D/BT_backup/$h.torrent" "$H/.stash-nas/"; done
omabox run "${B[@]}" -d -- /home/sbx/bin/leech.sh >/dev/null
omabox wait "${B[@]}" --timeout 90s cmd -- sh -c 'for p in 8090 8091; do curl -s http://127.0.0.1:$p/api/v2/transfer/info | grep -q "\"connected\"" || exit 1; done' >/dev/null
echo "the stage is up: promo/record.sh OUT_DIR, promo/shots.sh OUT_DIR"
