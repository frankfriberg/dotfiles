#!/bin/sh

echo "Installing brew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

mkdir ~/Development

echo "Installing brew cask..."
brew tap homebrew/cask

brew install --cask slack
brew install --cask arc
brew install --cask wezterm
brew install --cask sf-symbols
brew install --cask notion
brew install --cask tableplus
brew install --cask figma
brew install --cask telegram
brew install --cask spotify
brew install --cask 1password
brew install --cask flux
brew install --cask raycast

brew install gh
brew install zsh
brew install jq
brew install fzf
brew install nvm
brew install yabai
brew install skhd
brew install bob
brew install prettierd
brew install starship
brew install zoxide

# Sketchybar
brew install sketchybar
brew install nowplaying-cli

# Set git defaults
git config --global core.editor nvim
git config --global push.autoSetupRemote true
git config --global push.default current
git config --global pull.rebase true
git config --global merge.tool nvim
git config --global rebase.updateRefs true
git config --global rebase.autstash true
git config --global rebase.autosquash true
git config --global status.showUntrackedFiles all
