#!/bin/bash

if ! command -v yay &>/dev/null; then
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd -
fi

yay -S --needed - <packages.txt
