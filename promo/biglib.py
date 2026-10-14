#!/usr/bin/env python3
"""A big synthetic library for the promo video: N torrents written straight into a qBittorrent
profile's BT_backup (a .torrent and a .fastresume each), so qBittorrent starts with them
already complete, with upload totals, categories and tags, and nothing is checked.

    biglib.py PROFILE CONTENT_DIR BOX_CONTENT_DIR [N]

PROFILE: the qBittorrent --profile directory as this side sees it (BT_backup and the categories
go under PROFILE/qBittorrent). CONTENT_DIR: where the sparse files are made (this side);
BOX_CONTENT_DIR: the same directory as the box sees it (the save path written in the resume
data). Every file is sparse, so a 14 TiB library costs no disk, and the piece hashes are those
of zeros, so the files are the torrents' real content and a peer can download them. Names are public-domain films, Linux images,
conference talks, audiobooks, radio, datasets and open-source software: things people really
seed. Deterministic for a given N.
"""
import hashlib
import json
import math
import os
import random
import sys
import time

PROFILE, CONTENT, BOX_CONTENT = sys.argv[1:4]
N = int(sys.argv[4]) if len(sys.argv) > 4 else 3500
rng = random.Random(2026_10_14)
KB, MB, GB = 1024, 1024**2, 1024**3


def bencode(x):
    if isinstance(x, bool):
        x = int(x)
    if isinstance(x, int):
        return b"i%de" % x
    if isinstance(x, str):
        x = x.encode()
    if isinstance(x, bytes):
        return b"%d:%s" % (len(x), x)
    if isinstance(x, list):
        return b"l" + b"".join(bencode(i) for i in x) + b"e"
    if isinstance(x, dict):
        items = sorted((k.encode() if isinstance(k, str) else k, v) for k, v in x.items())
        return b"d" + b"".join(bencode(k) + bencode(v) for k, v in items) + b"e"
    raise TypeError(type(x))


# Trackers people really seed to; reached through the box's announce proxy (tracker-proxy.py).
T_UBUNTU = "http://torrent.ubuntu.com:6969/announce"
T_DEBIAN = "http://bttracker.debian.org:6969/announce"
T_FEDORA = "http://torrent.fedoraproject.org:6969/announce"
T_LINUX = "http://linuxtracker.org:2710/announce"
T_ARCHIVE = "http://bt1.archive.org:6969/announce"
T_ARCHIVE2 = "http://bt2.archive.org:6969/announce"
T_ACADEMIC = "http://academictorrents.com/announce.php"
T_OPEN = "http://tracker.opentrackr.org:1337/announce"
T_CCC = "http://tracker.media.ccc.de:6969/announce"


def gb(lo, hi):
    return int(rng.uniform(lo, hi) * GB)


def mb(lo, hi):
    return int(rng.uniform(lo, hi) * MB)


# ---- what is in the library ----------------------------------------------------------------
specs = []  # (name, category, tags, trackers, [(relpath, size)])


def add(name, cat, tags, trackers, files):
    specs.append((name, cat, tags, trackers, files))


distros = [
    ("archlinux", ["2025.11.01", "2025.12.01", "2026.01.01", "2026.02.01", "2026.03.01", "2026.04.01",
                   "2026.05.01", "2026.06.01", "2026.07.01", "2026.08.01", "2026.09.01", "2026.10.01"],
     ["x86_64"], T_LINUX, (1.1, 1.4)),
    ("debian", ["12.12.0", "12.13.0", "13.0.0", "13.1.0", "13.2.0", "13.3.0"],
     ["amd64-netinst", "amd64-DVD-1", "arm64-netinst", "amd64-xfce-live", "amd64-kde-live",
      "amd64-gnome-live"], T_DEBIAN, (0.6, 4.2)),
    ("ubuntu", ["24.04.3", "24.04.4", "25.10", "26.04", "26.04.1"],
     ["desktop-amd64", "live-server-amd64", "desktop-arm64"], T_UBUNTU, (2.6, 6.1)),
    ("kubuntu", ["24.04.3", "25.10", "26.04"], ["desktop-amd64"], T_UBUNTU, (3.8, 4.4)),
    ("xubuntu", ["24.04.3", "25.10", "26.04"], ["desktop-amd64", "minimal-amd64"], T_UBUNTU, (2.4, 4.0)),
    ("Fedora-Workstation-Live", ["42-1.1", "43-1.6", "44-1.4"], ["x86_64", "aarch64"], T_FEDORA, (2.1, 2.6)),
    ("Fedora-KDE-Desktop-Live", ["42-1.1", "43-1.6", "44-1.4"], ["x86_64"], T_FEDORA, (2.6, 3.0)),
    ("Fedora-Server-dvd", ["42-1.1", "43-1.6", "44-1.4"], ["x86_64", "aarch64"], T_FEDORA, (2.4, 2.9)),
    ("linuxmint", ["22.1", "22.2", "22.3", "23"], ["cinnamon-64bit", "xfce-64bit", "mate-64bit"], T_LINUX, (2.7, 3.1)),
    ("openSUSE-Tumbleweed-DVD", ["Snapshot20260801", "Snapshot20260901", "Snapshot20261001"], ["x86_64"], T_LINUX, (4.1, 4.6)),
    ("manjaro", ["25.0.6", "25.1.0", "26.0.1"], ["kde-plasma", "gnome", "xfce"], T_LINUX, (3.4, 4.2)),
    ("pop-os", ["24.04"], ["amd64_intel_20", "amd64_nvidia_20"], T_LINUX, (2.6, 3.4)),
    ("endeavouros", ["Mercury-2025.03.19", "Mercury-Neo-2025.05.01", "Ganymede-2026.01.12", "Ganymede-2026.06.20"],
     ["x86_64"], T_LINUX, (2.6, 2.9)),
    ("cachyos", ["desktop-linux-260124", "desktop-linux-260425", "desktop-linux-260728"], ["x86_64"], T_LINUX, (2.5, 2.9)),
    ("nixos", ["25.05", "25.11", "26.05"], ["gnome-x86_64-linux", "plasma6-x86_64-linux", "minimal-x86_64-linux"],
     T_LINUX, (1.1, 3.2)),
    ("kali-linux", ["2025.3", "2025.4", "2026.1", "2026.2", "2026.3"], ["installer-amd64", "live-amd64"], T_LINUX, (3.8, 4.4)),
    ("tails", ["7.0", "7.1", "7.2", "7.3", "7.4"], ["amd64"], T_LINUX, (1.4, 1.6)),
    ("AlmaLinux", ["9.6", "9.7", "10.0", "10.1"], ["x86_64-dvd", "x86_64-minimal"], T_LINUX, (2.0, 11.0)),
    ("Rocky", ["9.6", "9.7", "10.0", "10.1"], ["x86_64-dvd", "x86_64-minimal"], T_LINUX, (2.0, 10.5)),
    ("FreeBSD", ["14.3-RELEASE", "14.4-RELEASE", "15.0-RELEASE"], ["amd64-dvd1", "arm64-aarch64-dvd1"], T_LINUX, (4.0, 4.7)),
    ("alpine-extended", ["3.21.4", "3.22.1", "3.22.2", "3.23.0"], ["x86_64"], T_LINUX, (0.9, 1.1)),
    ("void-live", ["x86_64-20250202", "x86_64-20260108"], ["xfce", "base"], T_LINUX, (0.5, 1.0)),
    ("omarchy", ["3.0.2", "3.1.0", "3.2.1", "3.3.0", "3.4.2"], ["x86_64"], T_LINUX, (6.0, 6.8)),
]
for name, versions, flavours, tracker, (lo, hi) in distros:
    for v in versions:
        for f in flavours:
            iso = f"{name}-{v}-{f}.iso"
            add(iso, "linux-isos", ["linux"], [tracker], [("", gb(lo, hi))])

films = [
    "Nosferatu (1922)", "Metropolis (1927)", "The General (1926)", "Sherlock Jr. (1924)",
    "The Cabinet of Dr. Caligari (1920)", "A Trip to the Moon (1902)", "The Kid (1921)",
    "Safety Last! (1923)", "The Gold Rush (1925)", "The Phantom of the Opera (1925)",
    "Battleship Potemkin (1925)", "Steamboat Willie (1928)", "The Passion of Joan of Arc (1928)",
    "Night of the Living Dead (1968)", "His Girl Friday (1940)", "Charade (1963)", "Detour (1945)",
    "D.O.A. (1949)", "Carnival of Souls (1962)", "The Little Shop of Horrors (1960)",
    "Plan 9 from Outer Space (1959)", "The Last Man on Earth (1964)", "Meet John Doe (1941)",
    "The Stranger (1946)", "Scarlet Street (1945)", "Penny Serenade (1941)", "Royal Wedding (1951)",
    "McLintock! (1963)", "The Hitch-Hiker (1953)", "Suddenly (1954)", "Kansas City Confidential (1952)",
    "The Brain That Wouldn't Die (1962)", "House on Haunted Hill (1959)", "The Terror (1963)",
    "Dementia 13 (1963)", "Reefer Madness (1936)", "Popeye the Sailor Meets Sindbad (1936)",
    "Gulliver's Travels (1939)", "Superman - The Mechanical Monsters (1941)",
    "The Lost World (1925)", "Nanook of the North (1922)", "Man with a Movie Camera (1929)",
    "The Hunchback of Notre Dame (1923)", "Häxan (1922)", "Dr. Jekyll and Mr. Hyde (1920)",
    "The Wizard of Oz (1925)", "Pandora's Box (1929)", "Sunrise (1927)", "Wings (1927)", "Faust (1926)",
]
open_movies = ["Big Buck Bunny (2008)", "Elephants Dream (2006)", "Sintel (2010)", "Tears of Steel (2012)",
               "Cosmos Laundromat (2015)", "Caminandes - Llamigos (2016)", "Agent 327 (2017)", "Spring (2019)",
               "Coffee Run (2020)", "Sprite Fight (2021)", "Charge (2022)", "Wing It! (2023)", "Singularity (2025)"]
for title in films:
    for q in rng.sample(["1080p", "720p", "4K restoration", "DVD rip"], 2):
        base = f"{title} [{q}]"
        files = [(f"{title}.mkv", gb(0.7, 9.0) if q != "4K restoration" else gb(18, 42))]
        if rng.random() < 0.6:
            files.append((f"{title}.en.srt", 60 * KB + rng.randint(0, 40000)))
        if rng.random() < 0.3:
            files.append(("poster.jpg", mb(0.3, 2.5)))
        add(base, "films", ["public-domain", "archive.org"], [T_ARCHIVE, T_ARCHIVE2], files)
for title in open_movies:
    for q in ["1080p", "4K"]:
        add(f"{title} [{q}] Blender Open Movie", "films", ["creative-commons", "blender"], [T_OPEN],
            [(f"{title}.mkv", gb(0.4, 2.0) if q == "1080p" else gb(3, 9)),
             ("subtitles/en.srt", 20 * KB), ("subtitles/de.srt", 21 * KB), ("subtitles/pt-BR.srt", 21 * KB),
             ("subtitles/ja.srt", 24 * KB), ("LICENSE.txt", 1200)])

# Conference talks, one file each: the bulk of a big library.
rooms = ["Saal 1", "Saal GLITCH", "Saal ZIGZAG", "Saal FUSE", "Stage HUFF"]
topics = ["Reverse engineering", "Radio hacking", "Open hardware", "Memory safety", "Satellites",
          "Mesh networking", "Election security", "Keyboard firmware", "Retrocomputing", "Compilers",
          "Wayland", "Kernel scheduling", "Rust in the kernel", "Garbage collection", "Linkers",
          "Package managers", "Reproducible builds", "Bootloaders", "Smart meters", "E-ink",
          "Synthesizers", "Fonts", "Maps", "Typesetting", "Weather models", "Trains", "Bikes",
          "Batteries", "Solar", "Lockpicking", "Space probes", "Telescopes", "Accessibility",
          "Libraries", "Archiving the web", "Game preservation", "Demoscene", "Tiling window managers"]
angles = ["for beginners", "the hard way", "in 2026", "a postmortem", "from scratch", "at scale",
          "what went wrong", "ten years later", "on a budget", "explained", "deep dive", "lessons learned"]
for congress, year in [("37c3", 2023), ("38c3", 2024), ("39c3", 2025)]:
    for i in range(330):
        title = f"{rng.choice(topics)} {rng.choice(angles)}".replace(" ", "_")
        talk = f"{congress}-{rng.randint(10000, 99999)}-eng-{title}_hd.mp4"
        add(talk, "talks", ["ccc", congress], [T_CCC], [("", mb(180, 1400))])
fosdem_rooms = ["janson", "k1105", "h2215", "ua2114", "ub2252a", "aw1120", "ud2120", "k4401"]
for year in [2024, 2025, 2026]:
    for i in range(220):
        title = f"{rng.choice(topics).lower()}_{rng.choice(angles).split()[0]}".replace(" ", "_")
        add(f"fosdem-{year}-{rng.choice(fosdem_rooms)}-{title}.webm", "talks", ["fosdem"], [T_OPEN],
            [("", mb(90, 700))])

# Audiobooks, a file per chapter: the many-file torrents.
books = [("Moby Dick", "Herman Melville", 135), ("Pride and Prejudice", "Jane Austen", 61),
         ("The Count of Monte Cristo", "Alexandre Dumas", 117), ("Frankenstein", "Mary Shelley", 28),
         ("Dracula", "Bram Stoker", 27), ("War and Peace", "Leo Tolstoy", 361),
         ("The Adventures of Sherlock Holmes", "Arthur Conan Doyle", 12), ("Middlemarch", "George Eliot", 86),
         ("Don Quixote", "Miguel de Cervantes", 126), ("Les Misérables", "Victor Hugo", 365),
         ("The Odyssey", "Homer", 24), ("Walden", "Henry David Thoreau", 18),
         ("A Tale of Two Cities", "Charles Dickens", 45), ("Great Expectations", "Charles Dickens", 59),
         ("Jane Eyre", "Charlotte Brontë", 38), ("Wuthering Heights", "Emily Brontë", 34),
         ("The Time Machine", "H. G. Wells", 12), ("The War of the Worlds", "H. G. Wells", 27),
         ("Twenty Thousand Leagues Under the Seas", "Jules Verne", 47), ("Treasure Island", "Robert Louis Stevenson", 34),
         ("The Picture of Dorian Gray", "Oscar Wilde", 20), ("Anna Karenina", "Leo Tolstoy", 239),
         ("Crime and Punishment", "Fyodor Dostoevsky", 41), ("The Brothers Karamazov", "Fyodor Dostoevsky", 96),
         ("Little Women", "Louisa May Alcott", 47), ("Emma", "Jane Austen", 55), ("Ulysses", "James Joyce", 18),
         ("Heart of Darkness", "Joseph Conrad", 3), ("The Jungle Book", "Rudyard Kipling", 13),
         ("Alice's Adventures in Wonderland", "Lewis Carroll", 12), ("Dom Casmurro", "Machado de Assis", 148),
         ("Memórias Póstumas de Brás Cubas", "Machado de Assis", 160), ("Os Lusíadas", "Luís de Camões", 10)]
for title, author, chapters in books:
    for reader in rng.sample(["Solo", "Dramatic Reading", "Version 2", "Version 3"], rng.randint(1, 3)):
        name = f"{title} - {author} [LibriVox, {reader}]"
        files = [(f"{i:03d} - {title} - Chapter {i}.mp3", mb(8, 38)) for i in range(1, chapters + 1)]
        files += [("cover.jpg", mb(0.2, 1.1)), (f"{title}.m4b", 0)]
        files = [f for f in files if f[1] > 0]
        add(name, "audiobooks", ["librivox", "public-domain"], [T_ARCHIVE, T_ARCHIVE2], files)

shows = [("The Shadow", 1937, 1954), ("Suspense", 1942, 1962), ("Dimension X", 1950, 1951),
         ("X Minus One", 1955, 1958), ("Gunsmoke", 1952, 1961), ("The Jack Benny Program", 1932, 1955),
         ("Lights Out", 1934, 1947), ("Yours Truly, Johnny Dollar", 1949, 1962),
         ("The Mercury Theatre on the Air", 1938, 1938), ("Fibber McGee and Molly", 1935, 1959)]
for show, y0, y1 in shows:
    for year in range(y0, y1 + 1):
        if rng.random() < 0.55:
            eps = rng.randint(20, 52)
            files = [(f"{show} {year}-{rng.randint(1, 12):02d}-{rng.randint(1, 28):02d} Episode {e:03d}.mp3",
                      mb(6, 14)) for e in range(1, eps + 1)]
            add(f"Old Time Radio - {show} ({year})", "radio", ["otr", "public-domain"], [T_ARCHIVE], files)

datasets = []
for d in range(1, 13):
    datasets.append((f"enwiki-2026{d:02d}01-pages-articles-multistream", gb(22, 26), 2))
    datasets.append((f"osm-planet-26{d:02d}07.osm.pbf", gb(78, 86), 1))
for i in range(1, 61):
    datasets.append((f"CC-MAIN-2026-{rng.randint(5, 40):02d} segment {i:04d}", gb(40, 120), rng.randint(30, 300)))
for name, size in [("Project Gutenberg DVD (2026-06)", 8.5), ("Stack Exchange data dump 2026-09", 98),
                   ("arXiv bulk PDF 2026-08", 340), ("Hubble Legacy Field (full resolution)", 61),
                   ("NASA Apollo 11 Mission Audio", 54), ("NASA Apollo 13 Mission Audio", 49),
                   ("Landsat 9 L1 scenes South America 2025", 2200), ("ImageNet ILSVRC2012 validation", 6.3),
                   ("LibriSpeech ASR corpus", 60), ("Common Voice 22.0 Portuguese", 14),
                   ("Open Images V7 validation", 12), ("The Pile (deduplicated) part 07", 51),
                   ("MusicBrainz database dump 2026-10", 18), ("Internet Archive Prelinger Collection vol 3", 410)]:
    datasets.append((name, int(size * GB), rng.randint(8, 400)))
for name, size, nfiles in datasets:
    if nfiles <= 1:
        files = [("", size)]
    else:
        part = size // nfiles
        files = [(f"part-{i:05d}.dat", part + rng.randint(0, MB)) for i in range(nfiles)]
        files.append(("README.md", 4200))
    add(name, "datasets", ["academic"], [T_ACADEMIC], files)

software = [("LibreOffice", ["25.8.4", "26.2.1", "26.8.0"]), ("Blender", ["4.5.3", "5.0.1", "5.1.0", "5.2.0"]),
            ("Godot", ["4.4.1", "4.5", "4.6"]), ("Krita", ["5.2.11", "6.0.1"]), ("GIMP", ["3.0.4", "3.2.0"]),
            ("Kdenlive", ["25.08.2", "26.04.0"]), ("OBS Studio", ["31.1", "32.0"]),
            ("0 A.D.", ["Alpha 27 Agni", "Alpha 28"]), ("SuperTuxKart", ["1.5", "1.6"]), ("Xonotic", ["0.8.6", "0.9.0"]),
            ("OpenTTD", ["14.1", "15.0"]), ("The Battle for Wesnoth", ["1.18.5", "1.20.0"]),
            ("Mindustry", ["v146", "v150"]), ("Veloren", ["0.17", "0.18"]), ("FreeCAD", ["1.0.2", "1.1.0"]),
            ("Inkscape", ["1.4.2", "1.5.0"]), ("Ardour", ["8.12", "9.0"]), ("Audacity", ["3.7.5", "4.0.0"])]
for app, versions in software:
    for v in versions:
        files = [(f"{app.replace(' ', '_')}-{v.replace(' ', '_')}-linux-x86_64.tar.xz", mb(80, 1600)),
                 (f"{app.replace(' ', '_')}-{v.replace(' ', '_')}-windows-x64.zip", mb(80, 1600)),
                 (f"{app.replace(' ', '_')}-{v.replace(' ', '_')}-macos-arm64.dmg", mb(80, 1600)),
                 ("SHA256SUMS", 400)]
        add(f"{app} {v} (all platforms)", "software", ["open-source"], [T_OPEN], files)

music = [("Nine Inch Nails", "Ghosts I-IV", 36), ("Nine Inch Nails", "The Slip", 10),
         ("Josh Woodward", "The Simple Life", 12), ("Josh Woodward", "Breadcrumbs", 13),
         ("Brad Sucks", "Out of It", 11), ("Brad Sucks", "I Don't Know What I'm Doing", 12),
         ("Kevin MacLeod", "Royalty Free Vol. 1", 40), ("Kevin MacLeod", "Royalty Free Vol. 2", 40),
         ("Kevin MacLeod", "Royalty Free Vol. 3", 40), ("Musopen", "Bach - Goldberg Variations", 32),
         ("Musopen", "Chopin - Complete Nocturnes", 21), ("Musopen", "Beethoven - Symphonies 1-9", 37),
         ("Musopen", "Brahms - Symphony No. 4", 4), ("Musopen", "Tchaikovsky - Swan Lake Suite", 6),
         ("Kimiko Ishizaka", "The Open Goldberg Variations", 32), ("Kimiko Ishizaka", "The Open Well-Tempered Clavier", 48),
         ("Jonathan Coulton", "Thing a Week One", 13), ("Chris Zabriskie", "Divider", 9),
         ("Podington Bear", "Soundscapes", 25), ("Lee Rosevere", "Music for Podcasts", 18),
         ("Blue Dot Sessions", "Selections 2025", 30), ("Broke For Free", "Directionless EP", 6)]
for artist, album, tracks in music:
    for fmt in rng.sample(["FLAC", "MP3 320", "FLAC 24-96"], rng.randint(1, 2)):
        ext = "mp3" if fmt.startswith("MP3") else "flac"
        size = (8, 14) if ext == "mp3" else (22, 60)
        files = [(f"{i:02d} - Track {i}.{ext}", mb(*size)) for i in range(1, tracks + 1)]
        files += [("cover.jpg", mb(0.5, 3)), ("LICENSE.txt", 900)]
        add(f"{artist} - {album} [{fmt}]", "music", ["creative-commons"], [T_ARCHIVE, T_OPEN], files)

# Lectures, a folder per course.
courses = ["MIT 6.006 Introduction to Algorithms", "MIT 6.042J Mathematics for Computer Science",
           "MIT 18.06 Linear Algebra", "MIT 8.01 Classical Mechanics", "Stanford CS229 Machine Learning",
           "Stanford CS106B Programming Abstractions", "Berkeley CS61A Structure and Interpretation",
           "Harvard CS50 Introduction to Computer Science", "MIT 6.824 Distributed Systems",
           "CMU 15-445 Database Systems", "MIT 6.S081 Operating System Engineering", "Yale PHIL 176 Death",
           "MIT 18.01 Single Variable Calculus", "MIT 5.111 Principles of Chemical Science"]
for course in courses:
    for year in rng.sample([2019, 2020, 2021, 2022, 2023, 2024, 2025], 3):
        n = rng.randint(18, 40)
        files = [(f"Lecture {i:02d}.mp4", mb(250, 900)) for i in range(1, n + 1)]
        files += [(f"notes/lecture-{i:02d}.pdf", mb(0.3, 4)) for i in range(1, n + 1)]
        add(f"{course} ({year})", "lectures", ["opencourseware"], [T_ACADEMIC], files)

rng.shuffle(specs)
seen, unique = set(), []
for s in specs:
    if s[0] not in seen:
        seen.add(s[0])
        unique.append(s)
specs = unique
print(f"{len(specs)} named before the top-up", file=sys.stderr)
while len(specs) < N:  # top up with talks
    i = len(specs)
    talk = f"39c3-{rng.randint(10000, 99999)}-deu-{rng.choice(topics).replace(' ', '_')}_{rng.choice(angles).replace(' ', '_')}_hd.mp4"
    if talk not in seen:
        seen.add(talk)
        specs.append((talk, "talks", ["ccc", "39c3"], [T_CCC], [("", mb(180, 1400))]))
specs = specs[:N]

_zero = {}


def zero_pieces(piece, size):
    """The piece hashes of `size` zero bytes: the sparse files are all zeros, so they are the
    torrent's real data and a peer can download it."""
    if piece not in _zero:
        _zero[piece] = hashlib.sha1(bytes(piece)).digest()
    full, rest = divmod(size, piece)
    return _zero[piece] * full + (hashlib.sha1(bytes(rest)).digest() if rest else b"")


# ---- write it --------------------------------------------------------------------------------
backup = os.path.join(PROFILE, "qBittorrent", "data", "BT_backup")
os.makedirs(backup, exist_ok=True)
now = int(time.time())
categories = {}
queue = []
total = 0
stats = {"seeding": 0, "stopped": 0}
for idx, (name, cat, tags, trackers, files) in enumerate(specs):
    save = f"{BOX_CONTENT}/{cat}"
    categories[cat] = {"save_path": save}
    host_root = os.path.join(CONTENT, cat)
    single = len(files) == 1 and files[0][0] == ""
    size = sum(s for _, s in files)
    total += size
    piece = 1 << max(15, min(24, math.ceil(math.log2(max(size, 1) / 1500))))
    npieces = max(1, math.ceil(size / piece))
    pieces = zero_pieces(piece, size)
    info = {"name": name, "piece length": piece, "pieces": pieces}
    if single:
        info["length"] = size
        paths = [os.path.join(host_root, name)]
    else:
        info["files"] = [{"length": s, "path": rel.split("/")} for rel, s in files]
        paths = [os.path.join(host_root, name, rel) for rel, _ in files]
    for p, (_, s) in zip(paths, files):
        os.makedirs(os.path.dirname(p), exist_ok=True)
        if not (os.path.exists(p) and os.path.getsize(p) == s):
            with open(p, "wb") as f:
                f.truncate(s)
    ihash = hashlib.sha1(bencode(info)).digest()
    hexhash = ihash.hex()
    torrent = {"announce": trackers[0], "info": info, "created by": "omaseed promo",
               "creation date": now - rng.randint(30, 900) * 86400}
    if len(trackers) > 1:
        torrent["announce-list"] = [[t] for t in trackers]
    with open(os.path.join(backup, hexhash + ".torrent"), "wb") as f:
        f.write(bencode(torrent))
    added = now - int(rng.uniform(2, 1400) * 86400)
    # Ratios as a long-lived library has them: most modest, a long tail of heavy seeders.
    ratio = min(60.0, rng.lognormvariate(0.2, 1.2))
    stopped = rng.random() < 0.09
    stats["stopped" if stopped else "seeding"] += 1
    resume = {
        "file-format": "libtorrent resume file", "file-version": 1,
        "info-hash": ihash, "name": name, "save_path": save,
        "pieces": b"\x01" * npieces,
        "total_downloaded": size, "total_uploaded": int(size * ratio),
        "added_time": added, "completed_time": added + rng.randint(600, 86400 * 3),
        "active_time": now - added, "finished_time": now - added - 3600, "seeding_time": now - added - 3600,
        "paused": 1 if stopped else 0, "auto_managed": 0 if stopped else 1,
        "trackers": [[t] for t in trackers],
        "qBt-category": cat, "qBt-tags": tags, "qBt-savePath": save,
        "qBt-name": "", "qBt-ratioLimit": -2000, "qBt-seedingTimeLimit": -2,
        "qBt-inactiveSeedingTimeLimit": -2, "qBt-contentLayout": "Original",
        "qBt-firstLastPiecePriority": 0, "qBt-stopCondition": "None", "qBt-queuePosition": -1,
    }
    with open(os.path.join(backup, hexhash + ".fastresume"), "wb") as f:
        f.write(bencode(resume))
    queue.append(hexhash)

conf = os.path.join(PROFILE, "qBittorrent", "config")
os.makedirs(conf, exist_ok=True)
with open(os.path.join(conf, "categories.json"), "w") as f:
    json.dump(categories, f, indent=4)
print(f"{len(specs)} torrents, {sum(len(s[4]) for s in specs)} files, {total / 1024**4:.1f} TiB; "
      f"{stats['seeding']} seeding, {stats['stopped']} stopped; categories: {', '.join(sorted(categories))}")
