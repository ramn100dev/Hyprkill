#!/usr/bin/env bash
# Hyprkill — lock con vídeo de fondo (mpvpaper) que SOBREVIVE a dpms/suspend.
#
# El fondo de hyprlock es transparente: el "fondo" es el vídeo de mpvpaper, que
# corre en una capa overlay POR DEBAJO de la superficie de bloqueo. Si el vídeo
# muere, a través del hyprlock transparente se ve el escritorio.
#
# Bug original: mpvpaper se lanzaba con '-s' (--auto-stop), que DETIENE mpv cuando
# el wallpaper se oculta (p.ej. al apagar la pantalla con dpms) y no lo reanuda.
# Aquí se quita ese flag y, por seguridad, se reanima el vídeo tras dpms/suspend.
#
# Uso:
#   lock.sh          -> bloquea: lanza vídeo + hyprlock; al desbloquear quita el vídeo
#   lock.sh revive   -> si ya está bloqueado, reinicia SOLO el vídeo (tras dpms/suspend)

VIDEO="$HOME/.config/hypr/ultrakill.mp4"

start_video() {
    pkill -x mpvpaper 2>/dev/null
    sleep 0.2
    # -f: fork (sobrevive al cierre del script).  SIN -s (no auto-stop).
    mpvpaper -f -l overlay -o 'no-audio loop panscan=1.0' '*' "$VIDEO"
}

# Modo reanimar: solo si realmente estamos bloqueados
if [ "$1" = "revive" ]; then
    pidof hyprlock >/dev/null && start_video
    exit 0
fi

# Ya bloqueado (lock_cmd disparado de nuevo): solo aseguramos el vídeo, sin re-lockear
if pidof hyprlock >/dev/null; then
    start_video
    exit 0
fi

# Bloqueo normal
start_video
hyprlock                      # bloquea (bloqueante hasta desbloquear)
pkill -x mpvpaper 2>/dev/null # al desbloquear, fuera vídeo
