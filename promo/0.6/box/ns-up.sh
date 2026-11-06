#!/bin/sh
# Runs in the box: a network namespace with addresses no one treats as local (203.0.113.x), so a
# peer from one of them is an incoming connection. This PC (.10), a hidden seeder that feeds
# This PC's ARRIVING torrents (.11) and a leecher that keeps This PC uploading (.12). Their Web
# UIs reach the box (omaseed, Chromium) through socat on unix sockets; the made-up library's
# trackers are answered by tracker-proxy.py. Nothing leaves the box.
S=$HOME/ns; mkdir -p $S; rm -f $S/*.sock $S/pid
unshare -rn sh -c "
  ip link set lo up
  for a in 10 11 12; do ip addr add 203.0.113.\$a/32 dev lo; done
  echo \$\$ > $S/pid
  exec sleep infinity" &
while [ ! -s $S/pid ]; do sleep 0.1; done
P=$(cat $S/pid)
inns() { nsenter --preserve-credentials -U -n -t "$P" "$@"; }
for p in 8090 8091 8092; do
  inns socat UNIX-LISTEN:$S/$p.sock,fork TCP:127.0.0.1:$p &
  socat TCP-LISTEN:$p,bind=127.0.0.1,fork,reuseaddr UNIX-CONNECT:$S/$p.sock &
done
inns python3 $HOME/bin/tracker-proxy.py 8099 &
# This PC without the namespace root's capabilities, so file modes hold for it as on a desktop
inns setpriv --inh-caps=-all --bounding-set=-all qbittorrent-nox --profile=$HOME/.local/share/qbt-pc &
for q in seed leech; do inns qbittorrent-nox --profile=$HOME/.local/share/qbt-$q & done
wait
