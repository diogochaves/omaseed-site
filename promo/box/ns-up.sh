#!/bin/sh
# The promo's network: a namespace of its own inside the box, with addresses no one treats as
# local, so a peer connecting from one of them is an incoming connection to qBittorrent.
# Web UIs go out to the box (omaseed) and the swarm's tracker and seeder come in, through socat
# on unix sockets.
S=$HOME/ns; mkdir -p $S; rm -f $S/*.sock $S/pid
unshare -rn sh -c "
  ip link set lo up
  for a in 10 11 12; do ip addr add 203.0.113.\$a/32 dev lo; done
  echo \$\$ > $S/pid
  exec sleep infinity" &
while [ ! -s $S/pid ]; do sleep 0.1; done
P=$(cat $S/pid)
inns() { nsenter --preserve-credentials -U -n -t "$P" "$@"; }
# Out to the box: the Web UIs.
for p in 8090 8091 8092; do
  inns socat UNIX-LISTEN:$S/$p.sock,fork TCP:127.0.0.1:$p &
  socat TCP-LISTEN:$p,bind=127.0.0.1,fork,reuseaddr UNIX-CONNECT:$S/$p.sock &
done
# In from the box: the swarm's tracker and seeder (on the host, through the box's --allow).
for p in 26996 26997; do
  socat UNIX-LISTEN:$S/$p.sock,fork TCP:127.0.0.1:$p &
  inns socat TCP-LISTEN:$p,bind=127.0.0.1,fork,reuseaddr UNIX-CONNECT:$S/$p.sock &
done
inns python3 $HOME/bin/tracker-proxy.py 8099 &
inns qbittorrent-nox --profile=$HOME/.local/share/qbt-pc &
inns qbittorrent-nox --profile=$HOME/.local/share/qbt-nas &
inns qbittorrent-nox --profile=$HOME/.local/share/qbt-leech &
wait
