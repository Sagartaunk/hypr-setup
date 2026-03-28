#!/bin/bash
LOCK="/tmp/idle-inhibit.pid"

if [ "$1" = "toggle" ]; then
    if [ -f "$LOCK" ] && kill -0 "$(cat $LOCK)" 2>/dev/null; then
        kill "$(cat $LOCK)"
        rm -f "$LOCK"
    else
        systemd-inhibit --what=idle --who=waybar --why="User inhibit" --mode=block sleep infinity &
        echo $! > "$LOCK"
    fi
    exit 0
fi

# Status output for waybar
if [ -f "$LOCK" ] && kill -0 "$(cat $LOCK)" 2>/dev/null; then
    echo '{"text":"󰛐  Inhibit","class":"active","tooltip":"Idle inhibited"}'
else
    echo '{"text":"󰒲  Inhibit","class":"inactive","tooltip":"Idle active"}'
fi
