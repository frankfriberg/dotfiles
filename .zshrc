export XDG_CONFIG_HOME="$HOME/.config"

eval "$(starship init zsh)"

source <(fzf --zsh)

source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

