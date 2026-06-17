#!/usr/bin/env bash
# Rota entre los perfiles de power-profiles-daemon y avisa con una notificación.
# Bindeado al clic del módulo custom/powerprofile en Waybar.

profiles=(power-saver balanced performance)

current=$(powerprofilesctl get)

# Buscar el índice actual y saltar al siguiente (con wrap-around).
next="${profiles[0]}"
for i in "${!profiles[@]}"; do
  if [[ "${profiles[$i]}" == "$current" ]]; then
    next="${profiles[$(( (i + 1) % ${#profiles[@]} ))]}"
    break
  fi
done

powerprofilesctl set "$next"

case "$next" in
  power-saver)  icon="󰌪"; label="Ahorro de energía" ;;
  balanced)     icon="󰗑"; label="Equilibrado" ;;
  performance)  icon="󰓅"; label="Rendimiento" ;;
esac

notify-send -t 1500 -h string:x-canonical-private-synchronous:powerprofile \
  "$icon  Perfil de energía" "$label"
