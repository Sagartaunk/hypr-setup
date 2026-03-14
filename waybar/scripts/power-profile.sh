#!/bin/bash

# Single script for Waybar power profile module
# No args = output JSON status for Waybar
# "toggle" arg = cycle to next profile on click

CURRENT=$(powerprofilesctl get)

if [[ "$1" == "toggle" ]]; then
    case "$CURRENT" in
        "performance") NEXT="balanced" ;;
        "balanced")    NEXT="power-saver" ;;
        "power-saver") NEXT="performance" ;;
        *)             NEXT="balanced" ;;
    esac
    powerprofilesctl set "$NEXT"
    notify-send "Power Profile" "Switched to $NEXT" --icon=battery-symbolic -t 2000
else
    case "$CURRENT" in
        "performance")
            ICON="󱐌"
            CLASS="performance"
            ;;
        "balanced")
            ICON="󰗑"
            CLASS="balanced"
            ;;
        "power-saver")
            ICON="󰌪"
            CLASS="power-saver"
            ;;
        *)
            ICON="?"
            CLASS="unknown"
            ;;
    esac
    echo "{\"text\": \"$ICON $CURRENT\", \"tooltip\": \"Click to cycle profile\", \"class\": \"$CLASS\"}"
fi
