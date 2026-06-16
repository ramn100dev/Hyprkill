#!/usr/bin/env bash
# Cambia al workspace que se pasa como argumento, usando la sintaxis Lua de Hyprland 0.55.
# Lo usa el on-click de waybar (módulo workspaces): el 'dispatch workspace N' legacy
# da error en 0.55, y meter las llaves { } del lua directamente en el JSON de waybar
# rompe el comando (waybar interpreta { } como campos de formato). Por eso este wrapper.
hyprctl dispatch "hl.dsp.focus({ workspace = $1 })"
