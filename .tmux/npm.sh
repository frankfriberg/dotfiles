#!/usr/bin/env bash

# Function to check if a pane is running a command
is_pane_running_command() {
  local pane_id=$1
  local pane_pid=$(tmux display-message -p -t "$pane_id" "#{pane_pid}")
  local pane_children=$(pgrep -P "$pane_pid" | wc -l)
  
  # If there are child processes, the pane is considered busy
  [ "$pane_children" -gt 0 ]
}

# Main function
run_npm_scripts() {
  # Check if package.json exists in the current directory
  if [[ ! -f "package.json" ]]; then
    tmux display-message "No package.json found in the current directory"
    return 1
  fi

  # Extract scripts from package.json using jq
  if ! command -v jq >/dev/null 2>&1; then
    tmux display-message "jq is required but not installed"
    return 1
  fi

  # Get the scripts section from package.json
  local scripts=$(jq -r '.scripts | to_entries | map("\(.key)|\(.value)") | .[]' package.json)
  
  if [[ -z "$scripts" ]]; then
    tmux display-message "No scripts found in package.json"
    return 1
  fi

  # Get the current pane ID
  local current_pane=$(tmux display-message -p "#{pane_id}")

  # Display scripts in fzf popup
  local selected=$(echo "$scripts" | sed 's/|/ => /g' | fzf --tmux --reverse --border-label=" NPM Scripts " \
    --color=border:blue,gutter:-1,label:-1,bg+:0,info:gray,pointer:blue,label:blue )

  # If script selected
  if [[ -n "$selected" ]]; then
    # Extract script name from selection
    local script_name=$(echo "$selected" | sed 's/ => .*//')
    local command="npm run $script_name"
    
    # Check if current pane is running a command
    if is_pane_running_command "$current_pane"; then
      # Create new window with script name and run command
      tmux new-window -n "npm:$script_name" "$command"
    else
      # Run in current pane and rename
      tmux rename-pane "npm:$script_name"
      tmux send-keys -t "$current_pane" C-u "$command" C-m
    fi
  fi
}

# Run the main function
run_npm_scripts

