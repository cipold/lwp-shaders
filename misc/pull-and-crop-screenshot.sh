#!/bin/bash
SD_FILE="/sdcard/screenshot.png"
FILE="screenshot-$(date +%s).png"
adb shell screencap -p "$SD_FILE"
adb pull "$SD_FILE" "$FILE"
adb shell rm "$SD_FILE"
convert "$FILE" -crop 1080x1920+0+230 +repage -resize 540x960 "$FILE"
