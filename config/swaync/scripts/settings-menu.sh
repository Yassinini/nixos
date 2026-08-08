#!/usr/bin/env bash
CHOICE=$(printf "Network Settings\nBluetooth Settings\nAppearance" | rofi -dmenu -theme ~/.config/rofi/config.rasi -p "Settings")
case "$CHOICE" in
    "Network Settings") nm-connection-editor ;;
    "Bluetooth Settings") blueman-manager ;;
    "Appearance") nwg-look ;;
esac
