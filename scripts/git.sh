setup_git() {
  info "Configuring Git default settings"
  git config --global core.editor nvim
  git config --global push.autoSetupRemote true
  git config --global push.default current
  git config --global pull.rebase true
  git config --global merge.tool nvim
  git config --global rebase.updateRefs true
  git config --global rebase.autstash true
  git config --global rebase.autosquash true
  git config --global status.showUntrackedFiles all
}
