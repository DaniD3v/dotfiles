#!/bin/sh

current_state=$(hyprctl getoption "device:asue120a:00-04f3:319b-touchpad:enabled" | grep -oP "(?<=int: )\N") # fetch old value
new_state=$((($current_state + 1) % 2)) # reverse value

hyprctl keyword "device:asue120a:00-04f3:319b-touchpad:enabled" $new_state # Set the new state
