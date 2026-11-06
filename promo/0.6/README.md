# The v0.6.0 video

A director project (`~/code/omarchy/director`): ten omabox takes of omaseed v0.6.0 on a made-up
library, cut into a 2:17 film by `build.py`. `BRIEF.md` is the intent, `STORYBOARD.md` what was
built. Nothing here reaches the real library (:8080) or the playground (:8081).

## The box

`stage.sh` (below) makes it from omaseed's v0.6.0 Release build in a worktree of omaseed:

```bash
git -C ../../../omaseed worktree add --detach ~/code/omarchy/.worktrees/omaseed/promo-v060 v0.6.0
cd ~/code/omarchy/.worktrees/omaseed/promo-v060
cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF
CMAKE_BUILD_PARALLEL_LEVEL=4 cmake --build build-release -j4
```

(The first cut was made on omaseed's manual box; none of its takes are left.)

## Takes and film

The stage (round 2 on): `./stage.sh` makes the box `v06` (omaseed v0.6.0 Release from the
`promo-v060` worktree, 400 made-up torrents in a network namespace, real up and downloads, two that
need you, private albums from a made-up tracker); `./take.sh NAME` records one take (acts in
`acts.sh`: rows, space, before_files, before_web, move, fix, create, burst, console, small).

```bash
python3 build.py && director check && director render     # renders/0.6.mp4
python3 build.py --at 63.5 88                             # what the film shows at those times
python3 review.py                                         # a frame from every hold, tiled, renders/review/
omabox down -b v06
```

build.py's framings are rectangles in the box's layout px (1536x864), read off gridded frames of
the takes. The camera's rules (cut 4): one 0.6 s move with no overshoot, then still; text only
while still; holds of 2.5 s or more; straight cuts inside a take, dissolves only between takes.

## Final

Cut 4 is the film that went out (2026-11-06; on 0.6, posted after 0.7 shipped). Kept local, not in
git: the takes (`assets/footage/`, 115 MB), the renders, and `BRIEF.md` (personal direction notes).
The omaseed worktree `promo-v060` is removed; a retake needs it again (the recipe above).
