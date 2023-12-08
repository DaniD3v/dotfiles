#!/bin/sh

swayidle \
  timeout 300 "~/.local/bin/lock -g" \
  timeout 330 "systemctl suspend"
