#!/bin/sh

grace_period=""
if [ "$1" = "-g" ] || [ "$1" = "--grace" ]; then
    grace_period="--grace 30"
fi

swaylock \
  --fade-in 0.3 \
  --effect-blur 4x6 \
  --effect-vignette 0.8:0.3 \
  $grace_period
