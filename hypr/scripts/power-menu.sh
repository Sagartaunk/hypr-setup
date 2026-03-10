#!/bin/bash

choice=$(printf "Performance\nBalanced\nPower Saver" | rofi -dmenu -p "Power Profile")

case "$choice" in
"Performance")
powerprofilesctl set performance
;;
"Balanced")
powerprofilesctl set balanced
;;
"Power Saver")
powerprofilesctl set power-saver
;;
esac
