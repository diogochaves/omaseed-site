#!/usr/bin/env bash
# One take for this video, in the v06 box (stage.sh): stage the moment, record the action with
# marks, into assets/footage/NAME.mp4 (+ NAME.marks.tsv, NAME.sheet.png).
#
#   ./take.sh rows | before | move | fix | create | burst | console
#
# The windows are full screen, so the frame is the app. Never the real desktop, never :8080 or
# :8081: the box's qBittorrents are its own (box/ns-up.sh). The acts are in acts.sh.
set -euo pipefail
NAME=${1:?NAME of the take}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SEED=${OMASEED_DIR:-$HOME/code/omarchy/.worktrees/omaseed/promo-v060}
BIN=$SEED/build-release/omaseed
BOX=v06
OUT=$HERE/assets/footage
mkdir -p "$OUT"
omabox ls --json | grep -q "\"name\":\"$BOX\"" || { echo "no box $BOX: run stage.sh" >&2; exit 1; }

mark() { omabox -b "$BOX" record mark "$1"; }
hold() { omabox -b "$BOX" record hold "$1"; }
pause() { omabox -b "$BOX" wait for "$1" >/dev/null 2>&1 || true; }
still() { omabox -b "$BOX" wait still --quiet "${1:-700ms}" --timeout "${2:-10s}" >/dev/null 2>&1 || true; }
W=omaseed
k() { omabox keys -b "$BOX" --window "$W" --wait "$@" >/dev/null 2>&1 || true; }
# typed one key at a time, as a person types
type_slow() { local s=$1 i a=(); for ((i = 0; i < ${#s}; i++)); do a+=(-t "${s:i:1}" -s 55ms); done
  omabox keys -b "$BOX" --window "$W" "${a[@]}" >/dev/null; }
on() { omabox click -b "$BOX" --window "$W" --find "$1" "${@:2}" --wait >/dev/null 2>&1 || echo "warn: no click on \"$1\"" >&2; }
see() { omabox -b "$BOX" wait tree "$1" --window "$W" --timeout "${2:-30s}" >/dev/null 2>&1 || echo "warn: no \"$1\"" >&2; }
has() { omabox tree -b "$BOX" --window "$W" --find "$1" >/dev/null 2>&1; }
glide() { omabox pointer -b "$BOX" --glide "${3:-600ms}" -- move "$1" "$2" >/dev/null 2>&1 || true; }
api() { omabox run -b "$BOX" -- curl -s "http://127.0.0.1:8090/api/v2/$1" "${@:2}"; }
full() { omabox lua -b "$BOX" 'hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen" }))' >/dev/null 2>&1 || true; }

# omaseed up, full screen, on the library's rows view
app() {
  W=omaseed
  if ! omabox windows -b "$BOX" 2>/dev/null | grep -q omaseed; then
    omabox run -b "$BOX" -d --wait -- "$BIN" >/dev/null
    omabox -b "$BOX" wait window omaseed --timeout 30s >/dev/null 2>&1 || true
  fi
  omabox windows -b "$BOX" 2>/dev/null | grep omaseed | grep -q '1536x864 at 0,0' || { omabox click -b "$BOX" 700 450 >/dev/null 2>&1; full; }
  k Escape; k Escape; k 0; k g; still 1s
}

# shellcheck source=acts.sh
source "$HERE/acts.sh"

declare -F "act_$NAME" >/dev/null || { echo "unknown take: $NAME" >&2; exit 2; }
if declare -F "stage_$NAME" >/dev/null; then "stage_$NAME"; fi
omabox -b "$BOX" record start -o "$OUT/$NAME.mp4" --fps 30 --glide 500ms
"act_$NAME"
omabox -b "$BOX" record stop --sheet >/dev/null
# a keyframe a second, so the compositor seeks cleanly
ffmpeg -loglevel error -y -i "$OUT/$NAME.mp4" -c:v libx264 -crf 18 -preset medium -threads 4 -g 30 -keyint_min 30 \
  -pix_fmt yuv420p -movflags +faststart -an "$OUT/$NAME.k.mp4" && mv "$OUT/$NAME.k.mp4" "$OUT/$NAME.mp4"
if declare -F "after_$NAME" >/dev/null; then "after_$NAME"; fi
echo "take: $OUT/$NAME.mp4"
