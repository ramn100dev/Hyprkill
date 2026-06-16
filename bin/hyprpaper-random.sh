#!/usr/bin/env bash
# Cambia el fondo a otro aleatorio de ~/Pictures/WallPaper/.
# Se usa al arrancar (desde hyprland.lua) y con SUPER+R.

WALLPAPER_DIR="$HOME/Pictures/WallPaper/"

# Lista de imágenes de la carpeta
mapfile -t FILES < <(find "$WALLPAPER_DIR" -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \))
[ "${#FILES[@]}" -eq 0 ] && { notify-send "Sin fondos en $WALLPAPER_DIR" 2>/dev/null; exit 1; }

# Fondo actual, para no repetirlo
CURRENT=$(hyprctl hyprpaper listactive 2>/dev/null | grep -oE '/[^ ]+' | head -1)

# Elige uno distinto al actual (si solo hay 1, usa ese)
WALLPAPER=$(printf '%s\n' "${FILES[@]}" | grep -vxF "$CURRENT" | shuf -n 1)
[ -z "$WALLPAPER" ] && WALLPAPER=$(printf '%s\n' "${FILES[@]}" | shuf -n 1)

# Aplica a todos los monitores. El comando 'wallpaper' auto-carga la imagen.
# (En hyprpaper 0.8.4, preload/unload por IPC dan "invalid request" con hyprctl 0.55.4,
#  así que usamos solo 'wallpaper', que es lo único fiable con estas versiones.)
hyprctl hyprpaper wallpaper ",$WALLPAPER"
