#!/usr/bin/env bash

is_pane_running_command() {
  local pane_id=$1
  local pane_pid=$(tmux display-message -p -t "$pane_id" "#{pane_pid}")
  local pane_children=$(pgrep -P "$pane_pid" | wc -l)

  [ "$pane_children" -gt 0 ]
}

search_npm() {
  query="$1"
  if [[ -n "$query" ]]; then
    npm search --json "$query" 2>/dev/null | jq -r '.[] | "\(.name) => \(.description)"' 3>/dev/null
  fi
}

search_npm_packages() {
  local temp_file=$(mktemp)
  local selected_packages

  export -f search_npm

  local packages=$(
    fzf --tmux --multi --reverse --border-label=' Install NPM Packages ' \
      --color=border:blue,gutter:-1,label:-1,bg+:0,info:gray,pointer:blue,label:blue \
      --prompt 'Search npm: ' \
      --header 'Enter search term, select multiple packages with TAB' \
      --query '' \
      --delimiter ' => ' \
      --with-nth 1.. \
      --bind "change:reload:sleep 0.1; search_npm {q}" \
      --track
  )

  if [[ -n "$selected_packages" ]]; then
    echo "$selected_packages" | sed 's/ => .*//'
  fi
}

run_npm_scripts() {
  if [[ ! -f "package.json" ]]; then
    tmux display-message "No package.json found in the current directory"
    return 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    tmux display-message "jq is required but not installed"
    return 1
  fi

  local scripts=$(jq -r '.scripts | to_entries | map("\(.key)|\(.value)") | .[]' package.json)

  if [[ -z "$scripts" ]]; then
    tmux display-message "No scripts found in package.json"
    return 1
  fi

  local scriptstorun="install|Install dependencies"$'\n'"install-package|Install package"$'\n'"$scripts"
  local current_pane=$(tmux display-message -p "#{pane_id}")

  local selected=$(echo "$scriptstorun" | sed 's/|/ => /g' | fzf --tmux --reverse --border-label=" NPM Scripts " \
    --color=border:blue,gutter:-1,label:-1,bg+:0,info:gray,pointer:blue,label:blue)

  if [[ -n "$selected" ]]; then
    local script_name=$(echo "$selected" | sed 's/ => .*//')
    local command="npm run $script_name"

    if [ $script_name == "install" ]; then
      command="npm $script_name"
    fi

    if [ $script_name == "install-package" ]; then
      local packages=$(search_npm_packages)

      if [[ -n "$packages" ]]; then
        command="npm install ${packages}"
      else
        exit 0
      fi
    fi

    if is_pane_running_command "$current_pane"; then
      tmux new-window -n "npm:$script_name" "$command"
    else
      tmux rename-pane "npm:$script_name"
      tmux send-keys -t "$current_pane" C-u "$command" C-m
    fi
  fi
}

# Run the main function
run_npm_scripts
