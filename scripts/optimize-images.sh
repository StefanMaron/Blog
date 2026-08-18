#!/usr/bin/env bash
# Compresses images in place: caps width at 1440px, strips metadata, and
# recompresses lossily. Run this on any new image before committing it
# under static/images/ (see CLAUDE.md "Images" section).
#
# Usage:
#   scripts/optimize-images.sh                 # optimize everything under static/images
#   scripts/optimize-images.sh path/to/file.png # optimize a single file
#   scripts/optimize-images.sh path/to/dir      # optimize everything under a dir
set -euo pipefail

MAX_WIDTH=1440
JPEG_QUALITY=75
PNG_COLOR_THRESHOLD=6000 # unique colors below this -> quantize to 256 (safe for UI screenshots, skipped for photos)

TARGET="${1:-static/images}"

if [ -f "$TARGET" ]; then
    FILES="$TARGET"
elif [ -d "$TARGET" ]; then
    FILES=$(find "$TARGET" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \))
else
    echo "Not a file or directory: $TARGET" >&2
    exit 1
fi

total_before=0
total_after=0

for f in $FILES; do
    before=$(stat -c%s "$f")
    total_before=$((total_before + before))

    case "$f" in
        *.jpg | *.jpeg | *.JPG | *.JPEG)
            magick "$f" -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -strip \
                -sampling-factor 4:2:0 -quality "$JPEG_QUALITY" -interlace Plane "$f"
            ;;
        *.png | *.PNG)
            colors=$(identify -format "%k" "$f")
            if [ "$colors" -lt "$PNG_COLOR_THRESHOLD" ]; then
                magick "$f" -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -strip \
                    -colors 256 -define png:compression-level=9 "$f"
            else
                magick "$f" -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -strip \
                    -define png:compression-level=9 "$f"
            fi
            ;;
    esac

    after=$(stat -c%s "$f")
    total_after=$((total_after + after))
    printf "%6d -> %6d KB  %s\n" "$((before / 1024))" "$((after / 1024))" "$f"
done

echo "---"
echo "Total: $((total_before / 1024 / 1024)) MB -> $((total_after / 1024 / 1024)) MB"
