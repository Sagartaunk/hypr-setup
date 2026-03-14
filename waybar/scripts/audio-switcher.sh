#!/bin/bash

# Audio output device switcher using wofi
# Lists all available PulseAudio sinks and lets you pick one

SINKS=$(pactl list sinks | awk '
/^Sink #/ { id=substr($2,2) }
/^\s+Name:/ { name=$2 }
/^\s+Description:/ {
    desc=substr($0, index($0,$2))
    print id ": " desc " [" name "]"
}')

if [[ -z "$SINKS" ]]; then
    notify-send "Audio Switcher" "No audio devices found" -t 2000
    exit 1
fi

CHOSEN=$(echo "$SINKS" | rofi -dmenu \
    -p "Audio Output" \
    -theme-str 'window {width: 500px;}')

[[ -z "$CHOSEN" ]] && exit 0

# Extract sink name from chosen line
SINK_NAME=$(echo "$CHOSEN" | grep -oP '\[.*?\]' | tr -d '[]')

if [[ -z "$SINK_NAME" ]]; then
    notify-send "Audio Switcher" "Failed to parse device" -t 2000
    exit 1
fi

# Set as default sink
pactl set-default-sink "$SINK_NAME"

# Move all existing audio streams to new sink
pactl list sink-inputs | grep "Sink Input #" | awk '{print substr($3,2)}' | while read -r stream; do
    pactl move-sink-input "$stream" "$SINK_NAME"
done

FRIENDLY=$(echo "$CHOSEN" | sed 's/[0-9]*: //' | sed 's/ \[.*\]//')
notify-send "Audio Output" "Switched to $FRIENDLY" --icon=audio-speakers-symbolic -t 2000
