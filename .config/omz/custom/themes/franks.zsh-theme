#!/bin/bash
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' formats ' %m%c%F{yellow}%b%f'
zstyle ':vcs_info:git*' actionformats ' %m%c(%F{yellow}%b%f)(%F{blue}%a%f)'
STATUS='%(?..%F{red} %f)'
RPROMPT='%F{245}%*%f'

### VIM Mode
bindkey -v

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

function zle-line-init zle-keymap-select {
  # Cursor
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[6 q'
  fi

  #VIM Mode
  NORMAL_MODE='%{$fg_bold[yellow]%}󰅂%{$reset_color%}'
  INSERT_MODE='%F{purple}󰄾%f'
  VIM_PROMPT="${${KEYMAP/vicmd/$NORMAL_MODE}/(main|viins)/$INSERT_MODE}"

  # Prompt
  vcs_info
  if [[ -z ${vcs_info_msg_0_} ]]; then
    PS1="${STATUS}%4~ ${VIM_PROMPT} "
  else
    PS1="${STATUS}%2~${vcs_info_msg_0_} ${VIM_PROMPT} "
  fi
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# GIT Status
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-st

### git: Show marker ● if there are untracked files in repository
# Make sure you have added staged to your 'formats':  %c
function +vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]]; then
    LSTATUS=$(git status --porcelain)
    local icon=""
    local gitstatus
    
    if echo "$LSTATUS" | grep -q '^A ' 2> /dev/null; then
      gitstatus+="%F{green}${icon}%f"
    fi
    if echo "$LSTATUS" | grep -q '^ M ' 2> /dev/null; then
      gitstatus+="%F{yellow}${icon}%f"
    fi
    if echo "$LSTATUS" | grep -q '^ D ' 2> /dev/null; then
      gitstatus+="%F{red}${icon}%f"
    fi
    if echo "$LSTATUS" | grep -q '^?? ' 2> /dev/null; then
      gitstatus+="%F{105}${icon}%f"
    fi
   
    if [[ $gitstatus ]] then 
      hook_com[staged]+="${gitstatus} "
    fi
  fi
}
### git: Show +N/-N when your local branch is ahead-of or behind remote HEAD.
# Make sure you have added misc to your 'formats':  %m
function +vi-git-st() {
    local ahead behind
    local -a gitstatus

    # Exit early in case the worktree is on a detached HEAD
    git rev-parse ${hook_com[branch]}@{upstream} >/dev/null 2>&1 || return 0

    local -a ahead_and_behind=(
        $(git rev-list --left-right --count HEAD...${hook_com[branch]}@{upstream} 2>/dev/null)
    )

    ahead=${ahead_and_behind[1]}
    behind=${ahead_and_behind[2]}

    (( $ahead )) && gitstatus+=("%F{cyan}↑${ahead}%f")
    (( $behind )) && gitstatus+=("%F{yellow}↓${behind}%f")

    if [[ $gitstatus ]] then 
      hook_com[misc]+="${gitstatus} "
    fi
}

