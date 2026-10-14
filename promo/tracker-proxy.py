#!/usr/bin/env python3
"""An HTTP proxy that answers every tracker announce itself, for the promo box.

The box has no internet, so the big library's trackers (archive.org, linuxtracker.org...) can't
be reached. qBittorrent sends its tracker requests through this proxy (proxy type HTTP, hostname
lookups at the proxy), and it answers each announce as the tracker would: an interval, how many
seeds and peers the torrent has (a fixed made-up number per torrent, most healthy, some kept
alive by a handful), and no peer addresses, so no connection is ever tried.

    tracker-proxy.py PORT
"""
import hashlib
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlsplit


def bencode(x):
    if isinstance(x, int):
        return b"i%de" % x
    if isinstance(x, str):
        x = x.encode()
    if isinstance(x, bytes):
        return b"%d:%s" % (len(x), x)
    if isinstance(x, dict):
        return b"d" + b"".join(bencode(k) + bencode(v) for k, v in sorted(x.items())) + b"e"
    raise TypeError(type(x))


def swarm(info_hash: bytes):
    h = hashlib.sha256(info_hash).digest()
    r = h[0] / 255
    if r < 0.06:
        seeds = 1  # only you
    elif r < 0.16:
        seeds = 2 + h[1] % 3  # a handful
    elif r < 0.6:
        seeds = 5 + h[1] % 40
    else:
        seeds = 40 + (h[1] << 8 | h[2]) % 900
    peers = h[3] % 4 if seeds < 5 else h[3] % 60
    return seeds, peers


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlsplit(self.path)
        q = parse_qs(url.query, encoding="latin-1")
        ih = q.get("info_hash", [""])[0].encode("latin-1")
        if "scrape" in url.path:
            seeds, peers = swarm(ih)
            body = bencode({"files": {ih: {"complete": seeds, "incomplete": peers, "downloaded": seeds * 7}}})
        else:
            seeds, peers = swarm(ih)
            body = bencode({"interval": 1800, "min interval": 900, "complete": seeds, "incomplete": peers,
                            "downloaded": seeds * 7, "peers": b""})
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), Handler).serve_forever()
