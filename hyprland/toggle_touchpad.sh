#!/bin/sh

# Fetch current state and toggle it
current_state=$(hyprctl getoption "device:asue120a:00-04f3:319b-touchpad:enabled" | grep -oP "(?<=int: )\N")
new_state=$((($current_state + 1) % 2))

echo $current_state
echo $new_state

# Set the new state
hyprctl keyword "device:asue120a:00-04f3:319b-touchpad:enabled" $new_state
