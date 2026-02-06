#!/bin/bash

OPTIONS="🔒 Lock\n🔁 Reboot\n🌙 Suspend\n🛑 Shutdown"

CHOICE=$(echo -e "$OPTIONS" | wofi \
  --dmenu \
  --style ~/.config/wofi/power-menu.css \
  --columns 2 \
  --width 400 \
  --height 200 \
  --location center)

case "$CHOICE" in
"🔒 Lock") hyprlock ;;
"🔁 Reboot") systemctl reboot ;;
"🌙 Suspend") systemctl suspend ;;
"🛑 Shutdown") systemctl poweroff ;;
esac
