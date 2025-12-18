#!/bin/sh

set -e

SAKURA_DIR="$HOME/.config/omarchy/themes/sakura/"

if [! -f "$SAKURA_DIR"]; then 
  echo "Sakura Theme already exsists"
  echo "Theme configuration can be found at $SAKURA_DIR"
fi

#omarchy-theme-install https://github.com/bjarneo/omarchy-sakura-theme
#/home/david/.config/omarchy/themes/sakura
