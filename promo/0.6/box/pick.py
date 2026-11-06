#!/usr/bin/env python3
"""Picks the stage's special torrents out of the made-up library (promo/biglib.py, 400).

    pick.py BOX_HOME

- ARRIVING: five torrents taken out of This PC's library (their files deleted) and added back by
  stage.sh to download from the hidden seeder, each at its own capped speed (one has no seeder:
  "no seed online"). The seeder keeps only these, and the one below.
- NO ACCESS: one more, added back into ~/data/locked (mode 555), so it errors.
- MISSING: one film whose files are deleted before qBittorrent starts: "missing files".
- GIVING BACK: the first three of the library by name and one radio show, which the leecher
  downloads again and again.
Writes ~/.arrive/{list,peers,locked,missing} and copies .torrent files to ~/.arrive and ~/.stash.
"""
import os
import re
import shutil
import sys

H = sys.argv[1]
PC = f"{H}/.local/share/qbt-pc/qBittorrent/data/BT_backup"
SEED = f"{H}/.local/share/qbt-seed/qBittorrent/data/BT_backup"


def field(raw, key):
    m = re.search(rb"%d:%s(\d+):" % (len(key), key), raw)
    return raw[m.end():m.end() + int(m.group(1))].decode() if m else ""


lib = {}
for f in os.listdir(PC):
    if not f.endswith(".torrent"):
        continue
    h = f[:-8]
    t = open(f"{PC}/{f}", "rb").read()
    r = open(f"{PC}/{h}.fastresume", "rb").read()
    name = field(t, b"name")
    size = sum(int(x) for x in re.findall(rb"6:lengthi(\d+)e", t))
    lib[name] = dict(h=h, cat=field(r, b"qBt-category"), save=field(r, b"save_path"), size=size)


def pick(pattern, lo=0, hi=1 << 60, taken=()):
    for n in sorted(lib):
        if re.search(pattern, n) and lo <= lib[n]["size"] <= hi and n not in taken:
            return n
    raise SystemExit(f"nothing matches {pattern}")


G = 1024**3
taken = []
for pat, lo, hi in [(r"^archlinux-2026\.09", 0, 4 * G), (r"^Fedora-Workstation", 0, 4 * G),
                    (r"^ubuntu-26", 0, 7 * G), (r"^nixos", 0, 4 * G), (r"^debian-13\.3", 0, 4 * G)]:
    taken.append(pick(pat, lo, hi, taken))
noaccess = pick(r"^tails-7\.4", taken=taken)
films = [n for n in sorted(lib) if lib[n]["cat"] == "films" and 0.6 * G < lib[n]["size"] < 4 * G]
missing = films[0]
# the first three GIVING BACK rows (the rows view sorts them by name), so the uploads show on top
special = set(taken) | {noaccess, missing}
talks = [n for n in sorted(lib) if n not in special and lib[n]["cat"] in ("software", "talks")][:3]
radio = pick(r"^Old Time Radio - Suspense \(1950\)")

# KB/s the seeder gives each ARRIVING torrent (0: no seeder at all)
limits = [700, 420, 260, 0, 160]
keep = set()
os.makedirs(f"{H}/.arrive", exist_ok=True)
with open(f"{H}/.arrive/list", "w") as out:
    for n, lim in list(zip(taken, limits)) + [(noaccess, 300)]:
        e = lib[n]
        shutil.copy(f"{PC}/{e['h']}.torrent", f"{H}/.arrive/{e['h']}.torrent")
        save = "/home/sbx/data/locked" if n == noaccess else e["save"]
        out.write(f"{e['h']} {e['cat']} {save} {lim * 1024}\n")
        for ext in (".torrent", ".fastresume"):
            os.remove(f"{PC}/{e['h']}{ext}")
        p = f"{H}/data/{e['cat']}/{n}"
        shutil.rmtree(p) if os.path.isdir(p) else os.remove(p)
        if lim:
            keep.add(e["h"])
open(f"{H}/.arrive/peers", "w").write("|".join(sorted(keep)))
open(f"{H}/.arrive/locked", "w").write(lib[noaccess]["h"])
open(f"{H}/.arrive/missing", "w").write(lib[missing]["h"])
for f in os.listdir(SEED):
    if f.split(".")[0] not in keep:
        os.remove(f"{SEED}/{f}")
p = f"{H}/data/films/{missing}"
shutil.rmtree(p) if os.path.isdir(p) else os.remove(p)
for n in talks + [radio]:
    shutil.copy(f"{PC}/{lib[n]['h']}.torrent", f"{H}/.stash/{lib[n]['h']}.torrent")
print("arriving:", ", ".join(taken))
print("no access:", noaccess, "· missing:", missing)
print("giving back:", ", ".join(talks + [radio]))
