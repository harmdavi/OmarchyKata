#!/usr/bin/env bash

set -e
BASHRC_CONFIG="$HOME/.bashrc"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_CONFIG="$SCRIPT_DIR/configFiles/bashrc.txt"
SOURCE_LINE="source \"$OVERRIDES_CONFIG\""

# Check if .bashrc exists
if [ ! -f "$BASHRC_CONFIG" ]; then
  echo ".bashrc not found at $BASHRC_CONFIG"
  exit 1
fi

# Check if override config exists
if [ ! -f "$OVERRIDES_CONFIG" ]; then
  echo "Override config not found at $OVERRIDES_CONFIG"
  exit 1
fi

# Check if source line already exists in .bashrc
if grep -Fxq "$SOURCE_LINE" "$BASHRC_CONFIG"; then
  echo "Source line already exists in $BASHRC_CONFIG"
else
  echo "Adding source line to $BASHRC_CONFIG"
  echo "" >> "$BASHRC_CONFIG"
  echo "$SOURCE_LINE" >> "$BASHRC_CONFIG"
  echo "Source line added successfully"
fi

echo "Bashrc Override Setup Complete!"
