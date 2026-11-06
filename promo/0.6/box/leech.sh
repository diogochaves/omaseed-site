#!/bin/sh
# Runs in the box: the leecher downloads This PC's torrents in ~/.stash again and again (each
# deleted when done, then added back), so This PC gives back for real; it also keeps pointing
# This PC's ARRIVING torrents at the hidden seeder.
L=http://127.0.0.1:8092/api/v2
add() { curl -s -F "torrents=@$1" -F savepath=/home/sbx/leech "$L/torrents/add" >/dev/null; }
while :; do
  curl -s "$L/torrents/info?filter=completed" | python3 -c '
import json,sys
for t in json.load(sys.stdin): print(t["hash"])' | while read -r h; do
    curl -s "$L/torrents/delete" -d hashes=$h -d deleteFiles=true >/dev/null
  done
  for f in ~/.stash/*.torrent; do add "$f"; done
  sleep 2
  curl -s "$L/torrents/addPeers" -d hashes=all -d peers=203.0.113.10:27100 >/dev/null
  # and This PC's ARRIVING torrents find the hidden seeder
  [ -s ~/.arrive/peers ] && curl -s http://127.0.0.1:8090/api/v2/torrents/addPeers \
    -d hashes="$(cat ~/.arrive/peers)" -d peers=203.0.113.11:27101 >/dev/null
  sleep 8
done
