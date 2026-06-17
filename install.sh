#!/bin/bash
set -e

DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Hyprkill Dotfiles Installer ==="
echo "Dots directory: $DOTS_DIR"
echo ""

# --- Install yay if not present ---
if ! command -v yay &>/dev/null; then
  echo "[1/6] Installing yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd "$DOTS_DIR"
  rm -rf /tmp/yay
else
  echo "[1/6] yay already installed"
fi

# --- Install packages ---
echo "[2/6] Installing packages..."
yay -S --needed --noconfirm - < "$DOTS_DIR/packages.txt"

# --- Deploy configs ---
echo "[3/6] Deploying configs to ~/.config ..."

CONFIGS=(
  hypr
  waybar
  dunst
  kitty
  rofi
  wofi
  wlogout
  yazi
  neofetch
  nvim
  fish
  btop
  lazygit
  systemd
)

for cfg in "${CONFIGS[@]}"; do
  src="$DOTS_DIR/config/$cfg"
  dest="$HOME/.config/$cfg"

  if [ ! -d "$src" ]; then
    continue
  fi

  if [ -d "$dest" ] || [ -L "$dest" ]; then
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "  Backing up existing $cfg -> $backup"
    mv "$dest" "$backup"
  fi

  ln -sf "$src" "$dest"
  echo "  Linked $cfg"
done

# --- Deploy scripts ---
echo "[4/6] Deploying scripts to ~/.local/bin ..."
mkdir -p "$HOME/.local/bin"

for script in "$DOTS_DIR"/bin/*; do
  [ -f "$script" ] || continue
  name="$(basename "$script")"
  ln -sf "$script" "$HOME/.local/bin/$name"
  chmod +x "$script"
  echo "  Linked $name"
done

# --- Desktop entries + MIME defaults ---
# yazi es TUI, así que necesita un .desktop propio que lo lance en kitty para que
# "Mostrar en carpeta" del navegador (xdg-open sobre el directorio) abra el gestor
# en vez de una terminal pelada. Por defecto inode/directory apuntaba a kitty-open.
if [ -d "$DOTS_DIR/applications" ]; then
  mkdir -p "$HOME/.local/share/applications"
  for app in "$DOTS_DIR"/applications/*.desktop; do
    [ -f "$app" ] || continue
    ln -sf "$app" "$HOME/.local/share/applications/$(basename "$app")"
    echo "  Linked $(basename "$app")"
  done
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
  xdg-mime default yazi-kitty.desktop inode/directory 2>/dev/null || true
fi

# --- System setup (greeter + network + fonts) ---
# Estos son los pasos de sistema que antes había que hacer a mano. Necesitan sudo.
echo "[5/6] System setup (greeter, network, fonts)..."

# Greeter: greetd + tuigreet (TUI, sin Qt/GPU -> fiable en hybrid GPU), tema
# ULTRAKILL en rojo/negro. Lanza 'start-hyprland' (el launcher del .desktop, que
# activa graphical-session.target -> arranca el portal correctamente).
sudo mkdir -p /etc/greetd
if [ -f /etc/greetd/config.toml ] && [ ! -f /etc/greetd/config.toml.bak.hyprkill ]; then
  sudo cp /etc/greetd/config.toml /etc/greetd/config.toml.bak.hyprkill
fi
sudo tee /etc/greetd/config.toml >/dev/null <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --remember --remember-session --time --asterisks --greeting 'MANKIND IS DEAD. BLOOD IS FUEL. HELL IS FULL.' --theme 'border=red;text=white;prompt=red;time=red;greet=red;action=white;button=red;container=black;input=white;title=red' --cmd start-hyprland"
user = "greeter"
EOF
sudo systemd-sysusers >/dev/null 2>&1 || true   # crea el usuario 'greeter' si falta
sudo systemctl enable greetd.service
# Desactiva otros display managers para que arranque greetd
for dm in sddm gdm lightdm ly; do
  sudo systemctl disable "$dm.service" 2>/dev/null || true
done

# Red: NetworkManager es el gestor (backend wpa_supplicant). iwd (lo usaba impala)
# se pelea con NM por la tarjeta y tira la wifi -> se enmascara. La wifi se maneja
# con nmtui / nmcli (el módulo de red del waybar abre 'kitty nmtui').
sudo systemctl enable NetworkManager.service
sudo systemctl mask iwd.service 2>/dev/null || true

# Fuentes: refresca la caché (VCR OSD Mono + Nerd Fonts ya instaladas por packages)
fc-cache -f >/dev/null 2>&1 || true

# --- Directories, dirs & default shell ---
echo "[6/6] Directories & shell..."

# --- Create expected directories ---
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/WallPaper"

# --- Set fish as default shell ---
if command -v fish &>/dev/null; then
  FISH_PATH="$(which fish)"
  if [ "$SHELL" != "$FISH_PATH" ]; then
    echo ""
    read -p "Set fish as default shell? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      chsh -s "$FISH_PATH"
      echo "Default shell set to fish"
    fi
  fi
fi

echo ""
echo "=== Done! ==="
echo "Notes:"
echo "  - Wallpapers go in ~/Pictures/WallPaper/ (set one + SUPER+R to randomize)"
echo "  - Screenshots save to ~/Pictures/Screenshots/"
echo "  - Greeter: greetd + tuigreet (reboot to see the red/black login)"
echo "  - Wi-Fi: managed by NetworkManager (waybar network module -> nmtui)"
echo "  - Reboot to start the greeter and Hyprland"
echo "  - If configs look wrong, backups are at ~/.config/<name>.bak.*"
