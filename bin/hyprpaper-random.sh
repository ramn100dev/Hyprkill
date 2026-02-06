#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/WallPaper/"

#Get random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

#Preload a new image
hyprctl hyprpaper preload "$WALLPAPER"

#Apply wallpaper
hyprctl hyprpaper wallpaper ",$WALLPAPER"

#Delete images not showing
hyprctl hyprpaper unload unused
