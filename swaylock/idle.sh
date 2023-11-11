#!/bin/sh

swayidle \
  timeout 300 "lock -g" \
  timeout 330 "echo mem > /sys/power/state"
