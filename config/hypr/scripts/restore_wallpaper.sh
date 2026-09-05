#!/usr/bin/env bash

# Start awww daemon if not running
pgrep -x awww-daemon > /dev/null || awww-daemon &

CACHE_FILE="$HOME/.cache/current_wallpaper"

if [ -f "$CACHE_FILE" ]; then
    IMAGE=$(readlink -f "$CACHE_FILE")
    if [ -f "$IMAGE" ]; then
        awww img "$IMAGE"
        matugen image "$IMAGE"
    fi
fi
