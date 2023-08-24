#!/bin/bash

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.config/omz/custom"
# export ZSH_THEME="franks"
export plugins=(git brew macos colored-man-pages zsh-syntax-highlighting zsh-autosuggestions fzf-zsh-plugin)
source "$ZSH/oh-my-zsh.sh"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#7a8478"
ZSH_AUTOSUGGEST_STRATEGY=(completion history)
# autoload -Uz vcs_info
export PATH="$HOME/tools/lua-language-server/bin/macOS:$PATH"
export PATH="$PATH:/Users/ff/Library/Python/3.9/bin"

source "$ZSH_CUSTOM/plugins/pvm.zsh"
alias python='python3'

eval "$(starship init zsh)"
