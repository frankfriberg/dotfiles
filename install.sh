#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

. scripts/utils.sh
. scripts/brew.sh
. scripts/packages.sh
. scripts/osx.sh
. scripts/git.sh

if ! command -v brew &>/dev/null; then
  info "Installing brew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ ! -d ~/Development ]; then
  mkdir ~/Development
fi

brew bundle install

setup_osx
setup_git

# Set Wezterm as terminal
tempfile=$(mktemp) &&
  curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo &&
  tic -x -o ~/.terminfo $tempfile &&
  rm $tempfile

stow .

nvim --headless "+Lazy! install" +qall
