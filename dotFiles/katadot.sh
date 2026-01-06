#!/bin/sh

ORIGINAL_DIR=$(pwd)
REPO_NAME="$HOME/kata/dotFiles"

is_stow_installed(){
  pacman Qi "stow" &> /dev/null
}

if ! is_stow_installed; then
  yay -S --noconfirm --needed stow
fi

cd ~

echo "Removing old config files"
rm -rf ~/.config/nvim
rm -rf ~/.local/share/omarchy/default/xcompose
#next one that needst to be removed

cd "$REPO_NAME"

stow -t ~ nvim
stow -t ~ commands

 omarchy-restart-xcompose
