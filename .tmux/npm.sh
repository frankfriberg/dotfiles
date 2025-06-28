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

  if [[ -n "$packages" ]]; then
    echo "$packages" | sed 's/ => .*//'
  fi
}

execute_npm_command() {
  local command="$1"
  local script_name="$2"
  local display_mode="$3"
  local current_pane="$4"

  local wrapped_command='
    command_to_run="$1";
    title="$2";

    # Run the command and capture both output and exit code
    echo "$ $command_to_run";
    eval "$command_to_run";
    cmd_exit=$?;

    # Show status with color, but always treat as "success" for tmux
    if [ $cmd_exit -eq 0 ]; then
      echo -e "\n\033[1;32mCommand completed successfully ✓\033[0m";
    else
      echo -e "\n\033[1;31mCommand failed with exit code: $cmd_exit ✗\033[0m";
    fi;

    # Always wait for user input regardless of exit code
    echo -e "\n\033[1;33mPress any key to close...\033[0m";
    read -n 1 -s dummy_var || true;
    exit 0;  # Always exit with success to keep window/popup open
  '

  local title="npm:$script_name"

  case "$display_mode" in
  "popup")
    tmux display-popup -E -h 80% -w 80% -T "$title" "bash -c '$wrapped_command' _ '$command' '$title'"
    ;;
  "window")
    if is_pane_running_command "$current_pane"; then
      tmux new-window -n "$title" "bash -c '$wrapped_command' _ '$command' '$title'"
    else
      tmux rename-pane "$title"
      tmux send-keys -t "$current_pane" C-u "$command" C-m
    fi
    ;;
  esac
}

run_npm_scripts() {
  if [[ ! -f "package.json" ]]; then
    tmux display-message "No package.json found in the current directory"
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    tmux display-message "jq is required but not installed"
    return 0
  fi

  local scripts=$(jq -r '.scripts | to_entries | map("\(.key)|\(.value)") | .[]' package.json)

  if [[ -z "$scripts" ]]; then
    tmux display-message "No scripts found in package.json"
    return 0
  fi

  local scriptstorun="install|Install dependencies"$'\n'"install-package|Install package"$'\n'"$scripts"
  local current_pane=$(tmux display-message -p "#{pane_id}")

  local display_mode
  if is_pane_running_command "$current_pane"; then
    display_mode="popup"
  else
    display_mode="window"
  fi

  while true; do
    local result=$(echo "$scriptstorun" | sed 's/|/ => /g' | fzf --tmux --reverse \
      --border-label=" NPM Scripts ($(if [[ "$display_mode" == "popup" ]]; then echo -e "\033[33mpopup\033[0m"; else echo -e "\033[36mwindow\033[0m"; fi)) " \
      --color=border:blue,gutter:-1,label:-1,bg+:0,info:gray,pointer:blue,label:blue \
      --header "<C-p>: Change display mode | <esc>: Cancel" \
      --expect="ctrl-p,esc")

    local key=$(echo "$result" | head -1)
    local selection=$(echo "$result" | tail -n +2)

    if [[ -z "$key" && -n "$selection" ]]; then
      break
    fi

    case "$key" in
    "ctrl-p")
      # Toggle between popup and window modes
      if [[ "$display_mode" == "popup" ]]; then
        display_mode="window"
      else
        display_mode="popup"
      fi
      continue
      ;;
    "esc")
      return 0
      ;;
    *)
      if [[ -n "$selection" ]]; then
        break
      fi
      ;;
    esac
  done

  # Process the selection if one was made
  if [[ -n "$selection" ]]; then
    local script_name=$(echo "$selection" | sed 's/ => .*//')
    local command="npm run $script_name"

    if [ "$script_name" == "install" ]; then
      command="npm $script_name"
    fi

    if [ "$script_name" == "install-package" ]; then
      local packages=$(search_npm_packages)

      if [[ -n "$packages" ]]; then
        command="npm install ${packages}"
      else
        return 0
      fi
    fi

    execute_npm_command "$command" "$script_name" "$display_mode" "$current_pane"
  fi
}

# Run the main function
run_npm_scripts
