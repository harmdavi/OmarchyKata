
#!/bin/sh
set -e

SAKURA_DIR="$HOME/.config/omarchy/themes/sakura"

if [ -d "$SAKURA_DIR" ]; then
  echo "Sakura theme already exists."
  echo "Theme configuration can be found at $SAKURA_DIR"
  exit 0
else
  echo "Sakura theme not found. Pulling repository..."
omarchy-theme-install https://github.com/bjarneo/omarchy-sakura-themefi
fi
