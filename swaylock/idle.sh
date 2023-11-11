#!/bin/sh

swayidle \
  timeout 300 "lock -g" \
  timeout 330 "loginctl hibernate"
