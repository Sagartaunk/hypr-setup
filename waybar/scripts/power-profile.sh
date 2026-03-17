#!/bin/bash
# TLP power profile module for Waybar

GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")

if [[ "$1" == "toggle" ]]; then
    case "$GOVERNOR" in
        "performance")
            sudo /usr/bin/tlp bat > /dev/null 2>&1
            notify-send "Power Profile" "Switched to power-saver" --icon=battery-symbolic -t 2000
            ;;
        *)
            sudo /usr/bin/tlp ac > /dev/null 2>&1
            notify-send "Power Profile" "Switched to performance" --icon=battery-symbolic -t 2000
            ;;
    esac
else
    case "$GOVERNOR" in
        "performance")
            ICON="󱐌"
            LABEL="performance"
            CLASS="performance"
            ;;
        "powersave")
            ICON="󰌪"
            LABEL="power-saver"
            CLASS="power-saver"
            ;;
        *)
            ICON="󰗑"
            LABEL="$GOVERNOR"
            CLASS="balanced"
            ;;
    esac
    echo "{\"text\": \"$ICON $LABEL\", \"tooltip\": \"CPU Governor: $GOVERNOR — Click to toggle\", \"class\": \"$CLASS\"}"
fi
