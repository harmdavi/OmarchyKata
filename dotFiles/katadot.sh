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
rm -rf ~/.local/share/omarchy/default/hypr/bindings/tiling-v2.conf
rm -rf ~/.config/hypr/input.conf 
#next one that needst to be removed

cd "$REPO_NAME"

stow -t ~ custConf 
stow -t ~ custLocal 

while true; do
    read -rp "A reboot is required to apply changes. Reboot now? (y/n): " answer
    case "${answer,,}" in
        y|yes)
            echo "Rebooting..."
            reboot
            break
            ;;
        n|no)
            echo "Reboot canceled. Please reboot later to apply changes."
            break
            ;;
        *)
            echo "Please answer y or n."
            ;;
    esac
done
