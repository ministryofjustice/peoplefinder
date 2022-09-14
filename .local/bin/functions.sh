#!/bin/bash

# colours
GREEN='\033[0;32m'
GREEN_BOLD='\033[1;32m'
YELLOW='\033[0;93m'
DARK_GRAY='\033[3;90m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

UTILITY_TITLE="${YELLOW}P E O P L E   F I N D E R  ${DARK_GRAY}/  ${GREEN}T E S T   E N V I R O N M E N T"

## a full width line of stars
FULL_WIDTH_STARS="*"
for ((i = 1; i < "$(tput cols)"; i++)); do FULL_WIDTH_STARS="$FULL_WIDTH_STARS*"; done
####

header() {
  echo -e "\n${DARK_GRAY}$FULL_WIDTH_STARS${NC}\n"
  echo -e "${DARK_GRAY}******     ${GREEN}$UTILITY_TITLE${NC}\n"
  echo -e "${DARK_GRAY}******     ${NC}$1\n"
  echo -e "${DARK_GRAY}$FULL_WIDTH_STARS${NC}\n"
}

sub_header() {
  echo -e "\n\n\n${DARK_GRAY}$FULL_WIDTH_STARS${NC}\n"
  echo -e "${DARK_GRAY}******  ${NC} $1\n"
  echo -e "${DARK_GRAY}$FULL_WIDTH_STARS${NC}\n"
}

sub_header_divider() {
  echo -e "\n---\n${GREEN}***${NC}   $1\n"
}

indent() {
  sed 's/^/      /'
}