#!/usr/bin/env python3
"""Private torrents for the create take, made in the box's HOME from this side.

    private.py BOX_HOME

Three made-up albums in ~/data/music/private, sparse zeros, each with a private .torrent
announcing to https://tracker.example/announce/<a made-up passkey> (tracker.example is reserved
and answers nobody); and the folder to share, ~/data/music/Harbour Field Recordings (2026), seven
made-up files. Writes ~/.private/*.torrent for stage to add (skip checking: the files are there).
"""
import hashlib
import os
import secrets
import sys

H = sys.argv[1]
KEY = secrets.token_hex(16)
PIECE = 256 * 1024


def bencode(x):
    if isinstance(x, int):
        return b"i%de" % x
    if isinstance(x, str):
        x = x.encode()
    if isinstance(x, bytes):
        return b"%d:%s" % (len(x), x)
    if isinstance(x, list):
        return b"l" + b"".join(bencode(i) for i in x) + b"e"
    if isinstance(x, dict):
        return b"d" + b"".join(bencode(k) + bencode(v) for k, v in sorted(
            ((k.encode() if isinstance(k, str) else k), v) for k, v in x.items())) + b"e"
    raise TypeError(type(x))


def album(base, name, tracks):
    d = os.path.join(base, name)
    os.makedirs(d, exist_ok=True)
    files, total = [], 0
    for i, (title, size) in enumerate(tracks, 1):
        fn = f"{i:02d} - {title}.flac"
        with open(os.path.join(d, fn), "wb") as f:
            f.truncate(size)
        files.append({"length": size, "path": [fn]})
        total += size
    zero = hashlib.sha1(bytes(PIECE)).digest()
    n = -(-total // PIECE)
    last = total - (n - 1) * PIECE
    pieces = zero * (n - 1) + hashlib.sha1(bytes(last)).digest()
    return {"announce": f"https://tracker.example/announce/{KEY}", "created by": "made up for a demo",
            "info": {"name": name, "files": files, "piece length": PIECE, "pieces": pieces, "private": 1}}


M = 1024 * 1024
base = os.path.join(H, "data/music/private")
os.makedirs(os.path.join(H, ".private"), exist_ok=True)
for name, tracks in [
    ("Lowland Choir - Winter Hymns (2024) [FLAC]", [("Kyrie", 31 * M), ("Nocturne", 28 * M), ("Lantern", 36 * M)]),
    ("Paper Boats - Tidewater (2025) [FLAC]", [("Tidewater", 41 * M), ("Salt", 33 * M), ("Gulls", 29 * M), ("Ebb", 38 * M)]),
    ("Marsh Quartet - Reed Studies (2023) [FLAC]", [("Study I", 22 * M), ("Study II", 27 * M)]),
]:
    t = album(base, name, tracks)
    open(os.path.join(H, ".private", name + ".torrent"), "wb").write(bencode(t))

share = os.path.join(H, "data/music/Harbour Field Recordings (2026)")
os.makedirs(share, exist_ok=True)
for i, title in enumerate(["Harbour at Dawn", "Rope and Pulley", "Fog Signal", "Ferry Ramp",
                           "Net Mending", "Low Tide", "Harbour at Dusk"], 1):
    with open(os.path.join(share, f"{i:02d} - {title}.flac"), "wb") as f:
        f.truncate((24 + 3 * i) * M)
print("private: 3 albums; to share:", share)
