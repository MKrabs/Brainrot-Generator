#!/bin/bash
set -e

INPUT_IMAGE="$1"
OUTPUT_IMAGE="$2"

WIDTH=1080
HEIGHT=1920

if [[ -z "$INPUT_IMAGE" || -z "$OUTPUT_IMAGE" ]]; then
  echo "Usage: $0 input_image output_image"
  exit 1
fi

ffmpeg -y -v error -loop 1 -i "$INPUT_IMAGE" -vf "
scale=w=if(gt(iw/ih\,${WIDTH}/${HEIGHT})\,${WIDTH}\,-2):
      h=if(gt(iw/ih\,${WIDTH}/${HEIGHT})\,-2\,${HEIGHT}),
pad=${WIDTH}:${HEIGHT}:(ow-iw)/2:(oh-ih)/2:color=black,
setsar=1
" -frames:v 1 "$OUTPUT_IMAGE"
