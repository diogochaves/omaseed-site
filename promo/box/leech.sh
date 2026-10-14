#!/bin/sh
# Keeps both servers uploading for real: the box's leecher downloads This PC's torrents and four
# of the NAS's, deletes each one when it is done and adds it again. Its connections come from
# 203.0.113.12, so each server sees an incoming peer (and reads "connected", not firewalled).
L=http://127.0.0.1:8092/api/v2
add() { curl -s -F "torrents=@$1" -F savepath=/home/sbx/leech "$L/torrents/add" >/dev/null; }
peers() {
  curl -s "$L/torrents/info" | python3 -c '
import json,sys
for t in json.load(sys.stdin): print(t["hash"], t["tracker"] or "-")' | while read -r h tr; do
    case " $NAS " in *" $h "*) p=203.0.113.11:27101 ;; *) p=203.0.113.10:27100 ;; esac
    curl -s "$L/torrents/addPeers" -d hashes=$h -d peers=$p >/dev/null
  done
}
NAS=$(for f in ~/.stash-nas/*.torrent; do basename "$f" .torrent; done | tr '\n' ' ')
while :; do
  curl -s "$L/torrents/info?filter=completed" | python3 -c '
import json,sys
for t in json.load(sys.stdin): print(t["hash"])' | while read -r done; do
    curl -s "$L/torrents/delete" -d hashes=$done -d deleteFiles=true >/dev/null
  done
  for f in ~/.stash/*.torrent ~/.stash-nas/*.torrent; do add "$f"; done
  sleep 2
  peers
  sleep 8
done
