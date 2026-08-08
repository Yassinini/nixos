#!/usr/bin/env bash
# Usage: ws-status.sh <workspace_id>
# Prints JSON {"text": "<id>", "class": "active"|""} for waybar custom module (return-type json)
WS_ID="$1"

while true; do
    ACTIVE=$(hyprctl activeworkspace -j | jq -r '.id')
    if [ "$ACTIVE" = "$WS_ID" ]; then
        echo "{\"text\": \"$WS_ID\", \"class\": \"active\"}"
    else
        echo "{\"text\": \"$WS_ID\", \"class\": \"\"}"
    fi
    # Wait for the next workspace-change event instead of polling constantly
    socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - 2>/dev/null | \
    while read -r line; do
        case "$line" in
            workspace*|focusedmon*) break ;;
        esac
    done
done
