#!/bin/bash

while true; do
    if upower -i $(upower -e | grep BAT) | grep -q "state:\s*charging"; then
        powerprofilesctl set performance
    else
        powerprofilesctl set balanced
    fi
    sleep 30
done
