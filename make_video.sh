#!/bin/bash
set -e

INPUT_DIR="${1%/}"
DEFAULT_DIR="default_assets"
DURATION=15
OUTPUT="$INPUT_DIR/final_video.mp4"

WIDTH=1080
HEIGHT=1920

# Resolve asset paths
get_asset() {
  local name="$1"
  local input_path="$INPUT_DIR/$name"
  local default_path="$DEFAULT_DIR/$name"

  if [[ -f "$input_path" ]]; then
    echo "$input_path"
  elif [[ -f "$default_path" ]]; then
    echo "$default_path"
  else
    echo "❌ Missing required asset: $name" >&2
    exit 1
  fi
}

BG=$(get_asset "background.jpg")
OVERLAY=$(get_asset "overlay.png")
AUDIO=$(get_asset "audio.mp3")
TITLE_FILE="$INPUT_DIR/title.txt"
TITLE_TEXT=$(cat "$TITLE_FILE" 2>/dev/null || echo "Untitled Video")

BLURRED_BG="/tmp/blurred_bg.png"
CENTERED_BG="/tmp/centered_bg.png"
BG_WITH_TEXT="/tmp/bg_with_text.mp4"

echo "[INFO] Using:"
echo "  Background: $BG"
echo "  Overlay:    $OVERLAY"
echo "  Audio:      $AUDIO"
echo "  Title:      $TITLE_TEXT"

# 1) Create blurred background
./make_blur.sh "$BG" "$BLURRED_BG"

# 2) Create centered background image
./make_centered.sh "$BG" "$CENTERED_BG"

# 3) Overlay centered image on blurred bg + add text as a video of duration DURATION
ffmpeg -y -v error -loop 1 -i "$BLURRED_BG" -loop 1 -i "$CENTERED_BG" -filter_complex "
[0:v][1:v] overlay=(W-w)/2:(H-h)/2,drawtext=text='$TITLE_TEXT':fontcolor=white:fontsize=80:x=(w-text_w)/2:y=100:shadowcolor=black:shadowx=2:shadowy=2
" -t $DURATION -c:v libx264 -pix_fmt yuv420p -r 25 "$BG_WITH_TEXT"

# 4) Add overlay image and audio to final video
ffmpeg -y -v error -i "$BG_WITH_TEXT" -i "$OVERLAY" -i "$AUDIO" -filter_complex "
[0:v][1:v] overlay=0:0:format=auto
" -map 0:v -map 2:a -c:v libx264 -pix_fmt yuv420p -r 25 -c:a aac -movflags +faststart -shortest "$OUTPUT"

echo "✅ Video created at: $OUTPUT"
