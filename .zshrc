export XDG_CONFIG_HOME="$HOME/.config"
export PATH="$HOME/.local/bin:$PATH"

autoload -U compinit; compinit

source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"
eval "$(direnv hook zsh)"

zvm_after_init() {
 # I need to put this here because zsh-vi-mode seems to override CTRL+R binding
  # Set up fzf key bindings and fuzzy completion: $(brew --prefix)/opt/fzf/install
  # [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  source <(fzf --zsh)
}

zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# heroku autocomplete setup
HEROKU_AC_ZSH_SETUP_PATH=/Users/Frank/Library/Caches/heroku/autocomplete/zsh_setup && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
