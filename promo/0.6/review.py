#!/usr/bin/env python3
"""Reads the rendered film back, hold by hold: one frame from the middle of every still framing
and every montage item, tiled nine to a sheet with its film time, so crops, ghosting and
text-on-text can be checked by eye before showing a cut.

    python3 review.py [OUT_DIR] [--video renders/0.6.mp4]

build.py's plan has the holds: by construction the camera never moves during one, and no text is
up while it moves (cut 4's rules, from the review of cut 3).
"""
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build  # noqa: E402

args = sys.argv[1:]
video = args[args.index("--video") + 1] if "--video" in args else "renders/0.6.mp4"
out = Path(next((a for a in args if not a.startswith("--") and a != video), "renders/review"))
out.mkdir(parents=True, exist_ok=True)
chapters, m, close, total = build.plan()
pts = []
for c in chapters:
    for n, k in enumerate(c["clips"]):
        for i, (a, b) in enumerate(k["holds"]):
            a2 = max(a, c["start"] + build.CARD + 0.4) if n == 0 else a
            if b - a2 > 0.3:
                pts.append((f"{c['id']} {n + 1}.{i + 1}", (a2 + b) / 2))
for n, k in enumerate(m["items"][1:], 1):
    pts.append((f"small {n}", k["start"] + k["dur"] / 2))
pts.append(("close", close["start"] + 3))
shots = []
for name, t in pts:
    f = out / f"{t:06.1f}.jpg"
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-ss", f"{t:.2f}", "-i", video, "-frames:v", "1",
                    "-vf", "scale=640:-1", "-q:v", "4", str(f)], check=True)
    shots.append((name, t, f))
for g in range(0, len(shots), 9):
    o = Image.new("RGB", (1920, 3 * 380), "black")
    dr = ImageDraw.Draw(o)
    for i, (name, t, f) in enumerate(shots[g:g + 9]):
        x, y = (i % 3) * 640, (i // 3) * 380
        o.paste(Image.open(f), (x, y + 20))
        dr.text((x + 4, y + 4), f"{name} @ {t:.1f}s", fill="yellow")
    o.save(out / f"sheet-{g // 9}.png")
print(f"{len(shots)} holds, sheets in {out}/sheet-*.png")
