#!/bin/bash

. ./.local/bin/functions.sh

if ! docker info >/dev/null 2>&1; then
  sub_header "${GREEN}Hang on!${NC} This script uses Docker, and it isn't running. Please start Docker and try again."
  exit 3
fi
