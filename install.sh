#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if ! command -v brew &>/dev/null; then
	info "Installing brew..."
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Add Homebrew to PATH for the current session
	if [[ $(uname -m) == 'arm64' ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	else
		eval "$(/usr/local/bin/brew shellenv)"
	fi
fi

. scripts/utils.sh
. scripts/osx.sh
. scripts/kanata.sh

if [ ! -d ~/projects ]; then
	mkdir ~/projects
fi

brew bundle

stow .

setup_osx
setup_kanata
