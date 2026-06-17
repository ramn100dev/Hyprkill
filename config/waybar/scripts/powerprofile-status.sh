#!/usr/bin/env bash
# Imprime (en JSON para Waybar) el icono del perfil de energía activo.

p=$(powerprofilesctl get)

case "$p" in
  power-saver)  icon="󰌪"; label="Ahorro de energía" ;;
  balanced)     icon="󰗑"; label="Equilibrado" ;;
  performance)  icon="󰓅"; label="Rendimiento" ;;
  *)            icon="󰈸"; label="$p" ;;
esac

printf '{"text":"%s","tooltip":"Perfil: %s\\nClic: cambiar","class":"%s"}\n' \
  "$icon" "$label" "$p"
