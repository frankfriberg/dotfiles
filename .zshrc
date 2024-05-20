export ZSH="$HOME/.oh-my-zsh"
plugins=(git zsh-npm-scripts-autocomplete)

source $ZSH/oh-my-zsh.sh
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install >/dev/null
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use >/dev/null
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

eval "$(starship init zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ff/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ff/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ff/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ff/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Aliases
alias gitclean="git branch --merged | grep -v '\*\|master\|main\|develop\|staging' | xargs -n 1 git branch -d"
alias v="nvim"
alias vo="NVIM_APPNAME=nvim-old nvim"

eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

alias cd="z"
