#!/usr/bin/env bash
# The take from promo/record.sh, finished: a caption per scene and an end card, then encoded for
# where it goes.
#
#   promo/cut.sh TAKE_DIR
#
# Reads TAKE_DIR/take.mp4 and TAKE_DIR/captions.tsv; writes TAKE_DIR/omaseed-4k.mp4 (the master,
# 3840x2160), omaseed-1080p.mp4 (X and Discord: H.264, 1920x1080,
# 30 fps; a few MB, under Discord's 10 MB without Nitro). Captions are pills in Tokyo Night's colours,
# JetBrains Mono like the app; the end card is omaseed's lockup, the promise and the address.
set -euo pipefail
D=${1:?TAKE_DIR}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SEED=${OMASEED_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../omaseed" && pwd)}   # the omaseed checkout
LOCKUP=$SEED/docs/media/omaseed-lockup-dark.svg
BOLD=/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Bold.ttf
REG=/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf
W=3840 H=2160
work=$D/cut; rm -rf "$work"; mkdir -p "$work"
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$D/take.mp4")

# A caption: the text on a rounded pill, transparent around it.
pill() {
  magick -background none -fill '#c0caf5' -font "$BOLD" -pointsize 76 label:"$1" -trim +repage "$work/t.png"
  local tw th; read -r tw th < <(identify -format '%w %h\n' "$work/t.png")
  local pw=$((tw + 140)) ph=$((th + 96))
  magick -size ${pw}x${ph} xc:none -fill '#1a1b26ee' -stroke '#7aa2f7' -strokewidth 4 \
    -draw "roundrectangle 2,2 $((pw - 3)),$((ph - 3)) $((ph / 2)),$((ph / 2))" \
    "$work/t.png" -gravity center -composite "$2"
}

# The end card: a dark scrim, the lockup, the promise, the address.
magick -background none -density 900 "$LOCKUP" -resize 1500x "$work/lockup.png"
magick -size ${W}x${H} xc:'#16161ef2' \
  "$work/lockup.png" -gravity center -geometry +0-260 -composite \
  -font "$REG" -pointsize 84 -fill '#a9b1d6' -annotate +0+70 'Torrents, finally at home on Omarchy.' \
  -font "$BOLD" -pointsize 120 -fill '#7aa2f7' -annotate +0+300 'omaseed.app' \
  -font "$REG" -pointsize 56 -fill '#565f89' -annotate +0+470 'Free and open source · powered by qBittorrent' \
  "$work/end.png"

# One overlay per caption, faded in and out; the last scene gets the end card.
inputs=(-i "$D/take.mp4") chain="" n=0 last="[0:v]"
mapfile -t rows <"$D/captions.tsv"
for i in "${!rows[@]}"; do
  IFS=$'\t' read -r ms text <<<"${rows[$i]}"
  a=$(awk "BEGIN{print $ms/1000}")
  if [ "$text" = "omaseed.app" ]; then
    inputs+=(-loop 1 -t "$dur" -i "$work/end.png"); n=$((n + 1))
    chain+="[$n:v]format=rgba,fade=in:st=$a:d=0.45:alpha=1[e$n];${last}[e$n]overlay=0:0:enable='gte(t,$a)'[v$n];"
    last="[v$n]"; continue
  fi
  if [ $((i + 1)) -lt ${#rows[@]} ]; then
    next=$(awk "BEGIN{print ${rows[$((i + 1))]%%$'\t'*}/1000}")
  else next=$dur; fi
  s=$(awk "BEGIN{print $a + 0.25}")
  e=$(awk "BEGIN{x=$a + 3.4; y=$next - 0.15; print (x < y ? x : y)}")
  pill "$text" "$work/c$i.png"
  inputs+=(-loop 1 -t "$dur" -i "$work/c$i.png"); n=$((n + 1))
  chain+="[$n:v]format=rgba,fade=in:st=$s:d=0.3:alpha=1,fade=out:st=$(awk "BEGIN{print $e - 0.3}"):d=0.3:alpha=1[c$n];"
  chain+="${last}[c$n]overlay=(W-w)/2:H-h-230:enable='between(t,$s,$e)'[v$n];"
  last="[v$n]"
done
# The end card held a moment longer than the take ran.
chain+="${last}tpad=stop_mode=clone:stop_duration=1.5[out]"
ffmpeg -v error -y "${inputs[@]}" -filter_complex "$chain" -map "[out]" -t "$(awk "BEGIN{print $dur + 1.5}")" \
  -c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p -movflags +faststart "$D/omaseed-4k.mp4"
ffmpeg -v error -y -i "$D/omaseed-4k.mp4" -vf scale=1920:1080:flags=lanczos \
  -c:v libx264 -preset slow -crf 20 -profile:v high -pix_fmt yuv420p -movflags +faststart "$D/omaseed-1080p.mp4"
ls -la "$D"/omaseed-*.mp4
