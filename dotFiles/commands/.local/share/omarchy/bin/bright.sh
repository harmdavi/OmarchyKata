#!/usr/bin/env bash

# A simple brightness control script for Arch Linux using brightnessctl

arg="$1"

# If no argument is provided
if [ -z "$arg" ]; then
    echo "Usage: bright <1-100 | norm | normal | bus>"
    exit 1
fi

# Handle keyword arguments
case "$arg" in
    norm|normal)
        brightnessctl set 80%
        exit 0
        ;;
    bus)
        brightnessctl set 2%
        exit 0
        ;;
esac

# Handle numeric values
if [[ "$arg" =~ ^[0-9]+$ ]]; then
    # Clamp values between 1 and 100
    if (( arg < 1 )); then
        arg=1
    elif (( arg > 100 )); then
        arg=100
    fi
    brightnessctl set "${arg}%"
    exit 0
else
    echo "Invalid argument: $arg"
    echo "Usage: bright <1-100 | norm | normal | bus>"
    exit 1
fi
/
