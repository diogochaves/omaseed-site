#!/usr/bin/env python3
"""Writes index.html for the v0.6 video, cut 4 (review of cut 3: zoom once and stay, text only
while still, holds long enough to read, cuts inside a take, dissolves only between takes).

    python3 build.py && director check
    python3 build.py --at 63.5 [MORE…]     # what the film shows at those times (for notes by time)

Framings are rectangles on the box's window in layout pixels (1536x864, the take is 2.5x that):
[x, y, w], the height follows from 16:9. A clip has `frames`: (t, rect) pairs; the first is where
the clip starts, each later one is a move that starts at t and takes MOVE seconds, with no
overshoot, and the camera is still the rest of the time. A chip belongs to one frame and shows
while the camera holds on it.
"""
import html
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
LW, LH, K = 1536, 864, 2.5     # the window in layout px; take px per layout px
MOVE = 0.6                     # one camera move
XFADE = 0.4                    # a dissolve, only where the take changes
CARD = 2.6                     # a chapter card over the start of its first clip
TITLE, CLOSE = 3.2, 4.5
WIDE = [0, 0, 1536]

# Framings, read off gridded frames of the takes.
R1 = [140, 70, 1010]      # rows: NEEDS YOU, ARRIVING, the top of GIVING BACK
R2 = [140, 296, 1010]     # rows: GIVING BACK, sending
S_MAP = [200, 75, 1150]   # space: the map
W_STATUS = [200, 80, 820]  # Web UI: names, status "Missing Files"
RM = [0, 481, 680]        # move: the rail's folders and its menu
SH = [420, 200, 900]      # move: the sheet and its checks
BA = [0, 0, 1200]         # move: the band, the rail's archive, the rows
FXS = [700, 40, 836]      # fix: NEEDS YOU's labels and the story
FX2 = [440, 250, 680]     # fix: the move sheet
FX1 = [200, 20, 1336]     # fix: the list and the details
CR1 = [98, 75, 1340]      # create: the whole sheet
CR2 = [420, 230, 700]     # create: tracker, announce, flags
CR3 = [200, 30, 1100]     # create: ready to upload
B1 = [200, 0, 900]        # burst: the title bar's speeds
B2 = [200, 459, 720]      # burst: the speeds menu
B3 = [140, 0, 1300]       # burst: speeds and GIVING BACK
B4 = [300, 437, 760]      # burst: the status line
CO1 = [48, 42, 1440]      # console: the window, inside Omarchy's bar and the wallpaper
CO2 = [380, 110, 780]     # console: Settings › Skin

CHAPTERS = [
    dict(id="rows", tag="the rows view", card=("01 · the rows view", "The rows view",
         "It opens on what needs you. Every row says it in words."), clips=[
        dict(take="rows", at=0.8, dur=9.0, frames=[(0, WIDE), (3.6, R1)],
             chips=[(1, "NEEDS YOU first, with the reason", "br", 3.4)]),
        dict(take="rows", at=21.3, dur=2.8, frames=[(0, R2)])]),
    dict(id="space", tag="rows, table, space", card=("02 · rows, table, space", "Three ways to see it",
         "Rows by question, one sorted table, or where the space goes."), clips=[
        dict(take="space", at=1.0, dur=7.0, frames=[(0, WIDE)]),
        dict(take="space", at=17.6, dur=5.7, frames=[(0, WIDE), (1.0, S_MAP)],
             chips=[(1, "Where the space goes, by folder", "tr", 3.2)])]),
    dict(id="move", tag="moving a folder", card=("03 · moving a folder", "Moving a whole folder",
         "In a file manager, every torrent in a seeding folder breaks."), clips=[
        dict(take="before_files", at=1.0, dur=5.2, frames=[(0, WIDE)]),
        dict(take="before_files", at=7.8, dur=3.6, frames=[(0, WIDE)]),
        dict(take="before_web", at=4.4, dur=4.2, frames=[(0, WIDE), (0.9, W_STATUS)],
             chips=[(1, "qBittorrent: 10 × Missing Files", "br", 2.6)]),
        dict(take="move", at=3.4, dur=4.6, frames=[(0, RM)], notag=True),
        dict(take="move", at=13.4, dur=5.0, frames=[(0, SH)]),
        dict(take="move", at=19.9, dur=7.6, frames=[(0, WIDE), (3.2, BA)],
             chips=[(0, "Still seeding while it moves", "br", 2.7)])]),
    dict(id="fix", tag="needs you", card=("04 · needs you", "It says why",
         "When a torrent stops, the reason and the fix are beside it."), clips=[
        dict(take="fix", at=0.3, dur=4.9, frames=[(0, FXS)]),
        dict(take="fix", at=9.6, dur=2.6, frames=[(0, FX2)]),
        dict(take="fix", at=29.5, dur=4.0, frames=[(0, FX1)])]),
    dict(id="create", tag="create a torrent", card=("05 · create a torrent", "Create a torrent",
         "From any folder, with what private trackers need."), clips=[
        dict(take="create", at=0.6, dur=6.6, frames=[(0, CR1)]),
        dict(take="create", at=15.7, dur=4.8, frames=[(0, CR2)],
             chips=[(0, "Your tracker and passkey, from your library", "tr", 3.4)]),
        dict(take="create", at=23.2, dur=3.4, frames=[(0, CR3)])]),
    dict(id="burst", tag="turtle and burst", card=("06 · turtle and burst", "Turtle and burst",
         "Burst for 30 min, an hour, or until you stop it."), clips=[
        dict(take="burst", at=0.0, dur=4.1, frames=[(0, B1)]),
        dict(take="burst", at=4.6, dur=2.6, frames=[(0, B2)]),
        dict(take="burst", at=11.2, dur=4.0, frames=[(0, B3)],
             chips=[(0, "When I'm not using the connection", "br", 3.2)]),
        dict(take="burst", at=16.0, dur=2.9, frames=[(0, B4)])]),
    dict(id="skin", tag="a second skin · beta", card=("07 · a second skin", "Console",
         "An experiment, still in beta."), clips=[
        dict(take="console", at=4.4, dur=7.2, frames=[(0, CO1), (3.6, CO2)]),
        dict(take="console", at=13.9, dur=2.8, frames=[(0, CO1)])]),
]
MONTAGE = dict(id="small", card=("08 · and the small things", "The small things",
               "New since the launch, one at a time."), card_dur=1.8, card_clip=("small", 0.2, WIDE),
               items=[("The rail folds · ctrl+b", "small", 0.9, 3.5, [0, 0, 1000], "br"),
                      ("A title that says what you see", "rows", 11.0, 2.7, [180, 0, 760], "bl"),
                      ("Keys when you ask · hold alt", "small", 9.0, 2.5, [0, 0, 1100], "br"),
                      ("The omaseed menu", "small", 14.0, 2.3, [0, 20, 760], "br"),
                      ("Every command by name · :", "small", 20.8, 2.4, [358, 200, 820], "tl"),
                      ("A bar for the selection", "small", 28.2, 2.3, [120, 228, 1130], "tl"),
                      ("The torrent menu, with its submenus", "small", 41.0, 2.9, [600, 420, 790], "tl"),
                      ("Search with your qBittorrent's plugins", "small", 55.0, 2.9, [0, 0, 1000], "br"),
                      ("qBittorrent's log, in the window", "small", 65.3, 2.7, [0, 0, 1100], "br")])


def zoom(rect):
    """[scale, x, y] for director.aim: the rect's centre in take px, kept inside the window."""
    x, y, w = rect
    h = w * 9 / 16
    x = min(max(0, x), LW - w)
    y = min(max(0, y), LH - h)
    return [round(LW / w, 4), round((x + w / 2) * K, 1), round((y + h / 2) * K, 1)]


def esc(s):
    return html.escape(s, quote=True)


def plan():
    t = TITLE
    chapters = []
    for ch in CHAPTERS:
        c = dict(ch, start=round(t, 3))
        clips, cs, prev = [], t, None
        for k in ch["clips"]:
            join = "start" if prev is None else ("cut" if k["take"] == prev else "dissolve")
            if join == "dissolve":
                cs -= XFADE
            frames = [(f, zoom(r)) for f, r in k["frames"]]
            # holds: (start, end) of each frame's stillness, in film time
            holds = []
            for i, (f, _) in enumerate(frames):
                a = cs + (f + MOVE if i else f)
                b = cs + (frames[i + 1][0] if i + 1 < len(frames) else k["dur"])
                holds.append((round(a, 3), round(b, 3)))
            chips = []
            for fi, text, pos, d in k.get("chips", []):
                a, b = holds[fi]
                a = max(a, c["start"] + CARD) + 0.2
                chips.append(dict(text=text, pos=pos, a=round(a, 3), b=round(min(b - 0.25, a + d), 3)))
            clips.append(dict(take=k["take"], at=k["at"], dur=k["dur"], start=round(cs, 3), join=join, notag=k.get("notag", False),
                              frames=[(round(cs + f, 3), z) for f, z in frames], holds=holds, chips=chips))
            cs += k["dur"]
            prev = k["take"]
        c["clips"], c["end"] = clips, round(cs, 3)
        chapters.append(c)
        t = cs
    m = dict(MONTAGE, start=round(t, 3))
    take, at, rect = m["card_clip"]
    items = [dict(label="", take=take, at=at, dur=m["card_dur"], start=round(t, 3), z=zoom(rect), pos="")]
    cs = t + m["card_dur"]
    for label, take, at, dur, rect, pos in m["items"]:
        items.append(dict(label=label, take=take, at=at, dur=dur, start=round(cs, 3), z=zoom(rect), pos=pos))
        cs += dur
    m["items"], m["end"] = items, round(cs, 3)
    close = dict(start=round(cs, 3), end=round(cs + CLOSE, 3))
    return chapters, m, close, close["end"]


def video(vid, take, at, dur, start, track):
    return (f'<video id="{vid}" src="assets/footage/{take}.mp4" muted data-start="{start}" '
            f'data-duration="{round(dur, 3)}" data-media-start="{at}" data-track-index="{track}"></video>')


def markup(chapters, m):
    out, track = ['''<div id="title" class="title">
  <img id="title-icon" src="assets/icon.svg" alt="" />
  <div id="title-name" class="display big">omaseed <span class="accent">0.6</span></div>
  <div id="title-line" class="display sub">A native torrent client for Omarchy</div>
  <div id="title-ver" class="mono ver">v0.6.0 · 5 Nov 2026</div>
</div>'''], 1
    for ch in chapters:
        for n, k in enumerate(ch["clips"]):
            dur = k["dur"] + (XFADE if n + 1 < len(ch["clips"]) and ch["clips"][n + 1]["join"] == "dissolve" else 0)
            out.append(f'<div id="{ch["id"]}-z{n}" class="zoom" data-layout-allow-overflow>'
                       + video(f'{ch["id"]}-v{n}', k["take"], k["at"], dur, k["start"], track) + "</div>")
            track += 1
            for i, c in enumerate(k["chips"]):
                out.append(f'<div id="{ch["id"]}-c{n}-{i}" class="chip chip-{c["pos"]}">{esc(c["text"])}</div>')
        eb, t, line = ch["card"]
        out.append(f'<div id="{ch["id"]}-card" class="card"><div class="mono eb">{esc(eb)}</div>'
                   f'<div class="display ct">{esc(t)}</div><div class="display cl">{esc(line)}</div></div>')
        out.append(f'<div id="{ch["id"]}-tag" class="mono tag">{esc(ch["tag"])}</div>')
    for n, k in enumerate(m["items"]):
        out.append(f'<div id="small-z{n}" class="zoom" data-layout-allow-overflow>'
                   + video(f"small-v{n}", k["take"], k["at"], k["dur"], k["start"], track) + "</div>")
        track += 1
        if k["label"]:
            out.append(f'<div id="small-l{n}" class="mono tag tag-{k["pos"]}">{esc(k["label"])}</div>')
    eb, t, line = m["card"]
    out.append(f'<div id="small-card" class="card"><div class="mono eb">{esc(eb)}</div>'
               f'<div class="display ct">{esc(t)}</div><div class="display cl">{esc(line)}</div></div>')
    out.append('''<div id="close" class="close">
  <img id="close-icon" src="assets/icon-close.svg" alt="" />
  <div id="close-name" class="display big">omaseed</div>
  <div id="close-line" class="display sub">A native torrent client for Omarchy, powered by qBittorrent</div>
  <div id="close-url" class="mono url">omaseed.app · free · MIT</div>
  <div id="close-omabox" class="omabox"><img src="assets/omabox-lockup-dark.svg" alt="omabox" />
    <div class="display ob">Every shot recorded in omabox, a hidden desktop my agent drives · omabox.app</div></div>
  <div id="close-note" class="mono note">the library is made up</div>
</div>''')
    return "\n".join(out)


def main():
    chapters, m, close, total = plan()
    data = dict(title=TITLE, chapters=chapters, montage=m, close=close, card=CARD, move=MOVE, xfade=XFADE)
    page = (HERE / "index.html.tmpl").read_text()
    page = (page.replace("{{DURATION}}", str(total)).replace("{{MARKUP}}", markup(chapters, m))
            .replace("{{PLAN}}", json.dumps(data)))
    (HERE / "index.html").write_text(page)
    print(f"index.html: {total:.1f} s")
    short = []
    for c in chapters:
        print(f"  {c['start']:6.1f}-{c['end']:6.1f}  {c['id']}")
        for n, k in enumerate(c["clips"]):
            for i, (a, b) in enumerate(k["holds"]):
                vis = b - max(a, c["start"] + CARD if n == 0 else a)
                need = 0.9 if i + 1 < len(k["holds"]) else 2.3   # a look before a move; a hold to read
                if vis < need:
                    short.append(f"{c['id']} {n + 1}, framing {i + 1}: {vis:.1f} s")
    print(f"  {m['start']:6.1f}-{m['end']:6.1f}  small things")
    print(f"  {close['start']:6.1f}-{close['end']:6.1f}  close")
    for s in short:
        print("  short:", s)


def at(t):
    """What the film shows at time t: the chapter, the clip, its take and take time, the framing."""
    chapters, m, close, total = plan()
    if t < TITLE:
        return f"{t:.1f} s: the title"
    for c in chapters:
        for n, k in enumerate(c["clips"]):
            if k["start"] <= t < k["start"] + k["dur"]:
                rel = t - k["start"]
                src = next(r for r in reversed(CHAPTERS) if r["id"] == c["id"])["clips"][n]
                fi = max(i for i, (f, _) in enumerate(src["frames"]) if f <= rel)
                card = " (under the card)" if n == 0 and t < c["start"] + CARD else ""
                return (f"{t:.1f} s: chapter {c['id']}, clip {n + 1} of {len(c['clips'])}{card}; take "
                        f"{k['take']} at {k['at'] + rel:.1f} s; framing {fi + 1} {src['frames'][fi][1]} "
                        f"(build.py CHAPTERS → {c['id']} → clips[{n}])")
    for n, k in enumerate(m["items"]):
        if k["start"] <= t < k["start"] + k["dur"]:
            what = k["label"] or "the montage's card"
            return (f"{t:.1f} s: the small things, item {n}: {what}; take {k['take']} at "
                    f"{k['at'] + t - k['start']:.1f} s (build.py MONTAGE items[{n - 1}])")
    return f"{t:.1f} s: the close"


if __name__ == "__main__":
    import sys
    if len(sys.argv) > 2 and sys.argv[1] == "--at":
        for a in sys.argv[2:]:
            print(at(float(a)))
    else:
        main()
