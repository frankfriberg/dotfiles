export XDG_CONFIG_HOME="$HOME/.config"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Update automatically without asking
zstyle ':omz:update' mode auto      

plugins=(git zoxide nvm)

source $ZSH/oh-my-zsh.sh
