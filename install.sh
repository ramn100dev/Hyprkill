#!/bin/bash
set -e

DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Hyprkill Dotfiles Installer ==="
echo "Dots directory: $DOTS_DIR"
echo ""

# --- Install yay if not present ---
if ! command -v yay &>/dev/null; then
  echo "[1/4] Installing yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd "$DOTS_DIR"
  rm -rf /tmp/yay
else
  echo "[1/4] yay already installed"
fi

# --- Install packages ---
echo "[2/4] Installing packages..."
yay -S --needed --noconfirm - < "$DOTS_DIR/packages.txt"

# --- Deploy configs ---
echo "[3/4] Deploying configs to ~/.config ..."

CONFIGS=(
  hypr
  waybar
  dunst
  kitty
  rofi
  wofi
  wlogout
  neofetch
  nvim
  fish
  btop
  superfile
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
echo "[4/4] Deploying scripts to ~/.local/bin ..."
mkdir -p "$HOME/.local/bin"

for script in "$DOTS_DIR"/bin/*; do
  [ -f "$script" ] || continue
  name="$(basename "$script")"
  ln -sf "$script" "$HOME/.local/bin/$name"
  chmod +x "$script"
  echo "  Linked $name"
done

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
echo "  - Wallpapers go in ~/Pictures/WallPaper/"
echo "  - Screenshots save to ~/Pictures/Screenshots/"
echo "  - Log out and back in (or reboot) to start Hyprland"
echo "  - If configs look wrong, backups are at ~/.config/<name>.bak.*"
