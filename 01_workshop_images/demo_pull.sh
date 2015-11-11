#!/bin/sh

if id -u demo >/dev/null 2>&1; then
  cd /home/demo
  git clone https://github.com/de-wiring/tests-docker-hardening
else
  echo "Error: user demo does not exist."
  exit 1
fi
