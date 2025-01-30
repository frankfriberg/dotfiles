taps=(
  FelixKratz/formulae
)

packages=(
  fd
  fzf
  gh
  ical-buddy
  jq
  neovim
  nowplaying-cli
  nvm
  prettierd
  sketchybar
  starship
  zoxide
  zsh
)

casks=(
  1password
  arc
  bleunlock
  docker
  figma
  font-jetbrains-mono-nerd-font
  karabiner-elements
  nikitabobko/tap/aerospace
  notion
  openvpn-connect
  linear-linear
  raycast
  sf-symbols
  slack
  spotify
  tableplus
  telegram
  wezterm
)

install_packages() {
	info "Configuring taps..."
	apply_brew_taps "${taps[@]}"

	info "Installing packages..."
	install_brew_formulas "${packages[@]}"

  info "Installing casks..."
  install_brew_casks "${casks[@]}"

	echo "Cleaning up brew packages..."
	brew cleanup
}
