#!/bin/bash
set -e

INPUT="$1"
OUTPUT="$2"
TEXT="$3"

if [[ -z "$INPUT" || -z "$OUTPUT" || -z "$TEXT" ]]; then
  echo "Usage: $0 input_image_or_video output_file text"
  exit 1
fi

ffmpeg -y -v error -i "$INPUT" -vf "
drawtext=text='$TEXT':fontcolor=white:fontsize=80:
x=(w-text_w)/2:y=100:shadowcolor=black:shadowx=2:shadowy=2
" -c:v libx264 -pix_fmt yuv420p -r 25 "$OUTPUT"
