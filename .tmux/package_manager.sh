#!/usr/bin/env bash

detect_package_manager() {
  local pm_info=()
  local default_pm="npm"

  # Check for lock files
  if [[ -f "bun.lockb" ]]; then
    pm_info=("bun" "Bun" "bun.lockb")
  elif [[ -f "pnpm-lock.yaml" ]]; then
    pm_info=("pnpm" "PNPM" "pnpm-lock.yaml")
  elif [[ -f "yarn.lock" ]]; then
    pm_info=("yarn" "Yarn" "yarn.lock")
  elif [[ -f "package-lock.json" ]]; then
    pm_info=("npm" "NPM" "package-lock.json")
  else
    # No lock file found, check for available executables
    if command -v bun >/dev/null 2>&1; then
      pm_info=("bun" "Bun" "")
    elif command -v pnpm >/dev/null 2>&1; then
      pm_info=("pnpm" "PNPM" "")
    elif command -v yarn >/dev/null 2>&1; then
      pm_info=("yarn" "Yarn" "")
    else
      pm_info=("$default_pm" "NPM" "")
    fi
  fi

  echo "${pm_info[0]} ${pm_info[1]}"
}

is_pane_running_command() {
  local pane_id=$1
  local pane_pid=$(tmux display-message -p -t "$pane_id" "#{pane_pid}")
  local pane_children=$(pgrep -P "$pane_pid" | wc -l)

  [ "$pane_children" -gt 0 ]
}

search_packages() {
  local pm_cmd="$1"
  local pm_name="$2"
  local query="$3"

  if [[ -z "$query" ]]; then
    return
  fi

  case "$pm_cmd" in
  npm)
    npm search --json "$query" 2>/dev/null | jq -r '.[] | "\(.name) => \(.description)"' 3>/dev/null
    ;;
  yarn)
    # yarn doesn't have a good search command in newer versions, fall back to npm search
    npm search --json "$query" 2>/dev/null | jq -r '.[] | "\(.name) => \(.description)"' 3>/dev/null
    ;;
  pnpm)
    # pnpm search output isn't JSON by default, so we format it
    pnpm search "$query" 2>/dev/null | tail -n +2 | awk '{name=$1; $1=""; desc=$0; gsub(/^ /, "", desc); print name " => " desc}' 3>/dev/null
    ;;
  bun)
    # bun search output needs formatting
    bun pm search "$query" 2>/dev/null | grep -v "^Searching" | awk '{name=$1; $1=""; desc=$0; gsub(/^ /, "", desc); print name " => " desc}' 3>/dev/null
    ;;
  esac
}

select_packages() {
  local pm_cmd="$1"
  local pm_display="$2"
  local temp_file=$(mktemp)
  local selected_packages

  export -f search_packages
  export PM_CMD="$pm_cmd"
  export PM_DISPLAY="$pm_display"

  local packages=$(
    fzf --tmux --multi --reverse --border-label=" Install ${pm_display} Packages " \
      --color=border:blue,gutter:-1,label:-1,bg+:0,info:gray,pointer:blue,label:blue \
      --prompt "Search ${pm_cmd}: " \
      --header 'Enter search term, select multiple packages with TAB' \
      --query '' \
      --delimiter ' => ' \
      --with-nth 1.. \
      --bind "change:reload:sleep 0.1; search_packages $PM_CMD $PM_DISPLAY {q}" \
      --track
  )

  if [[ -n "$packages" ]]; then
    echo "$packages" | sed 's/ => .*//'
  fi
}

execute_package_command() {
  local command="$1"
  local script_name="$2"
  local display_mode="$3"
  local current_pane="$4"
  local pm_display="$5"

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

  local title="${pm_display}:$script_name"

  case "$display_mode" in
  "popup")
    tmux display-popup -E -h 80% -w 80% -T "$pm_display" "bash -c '$wrapped_command' _ '$command' '$title'"
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

run_package_scripts() {
  local pm_info=($(detect_package_manager))
  local pm_cmd="${pm_info[0]}"
  local pm_display="${pm_info[1]}"

  if [[ ! -f "package.json" ]]; then
    tmux display-message "No package.json found in the current directory for the detected package manager"
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    tmux display-message "jq is required but not installed to parse scripts for the detected package manager"
    return 0
  fi

  local scripts=$(jq -r '.scripts | to_entries | map("\(.key)|\(.value)") | .[]' package.json)

  if [[ -z "$scripts" ]]; then
    tmux display-message "No scripts found in the package.json for the detected package manager"
    return 0
  fi

  local scriptstorun="install|Install ${pm_display} dependencies"$'\n'"install-package|Install ${pm_display} package"$'\n'"$scripts"
  local current_pane=$(tmux display-message -p "#{pane_id}")

  local display_mode
  if is_pane_running_command "$current_pane"; then
    display_mode="popup"
  else
    display_mode="window"
  fi

  while true; do
    local result=$(echo "$scriptstorun" | sed 's/|/ => /g' | fzf --tmux --reverse \
      --border-label=" ${pm_display} Scripts ($(if [[ "$display_mode" == "popup" ]]; then echo -e "\033[33mpopup\033[0m"; else echo -e "\033[36mwindow\033[0m"; fi)) " \
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

  if [[ -n "$selection" ]]; then
    local script_name=$(echo "$selection" | sed 's/ => .*//')
    local command="npm run $script_name"

    if [ "$script_name" == "install" ]; then
      command="npm $script_name"
    fi

    if [ "$script_name" == "install-package" ]; then
      local pm_cmd="${pm_info[0]}"
      local pm_display="${pm_info[1]}"
      local packages=$(select_packages "$pm_cmd" "$pm_display")

      if [[ -n "$packages" ]]; then
        command="$pm_cmd install ${packages}"
      else
        return 0
      fi
    fi

    execute_package_command "$command" "$script_name" "$display_mode" "$current_pane" "$pm_display"
  fi
}

run_package_scripts
