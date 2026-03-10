#!/bin/bash

profile=$(powerprofilesctl get)

case $profile in
performance)
icon="󰓅"
;;
balanced)
icon="󰾅"
;;
power-saver)
icon="󰾆"
;;
esac

echo "{\"text\": \"$icon\", \"tooltip\": \"$profile\"}"
