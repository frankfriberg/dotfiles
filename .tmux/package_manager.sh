#!/usr/bin/env bash

check_dependencies() {
  local missing=()
  command -v ni >/dev/null 2>&1 || missing+=("ni (brew install ni / npm i -g @antfu/ni)")
  command -v jq >/dev/null 2>&1 || missing+=("jq")
  command -v fzf >/dev/null 2>&1 || missing+=("fzf")

  if [[ ${#missing[@]} -gt 0 ]]; then
    tmux display-message "Missing: ${missing[*]}"
    return 1
  fi

  if [[ ! -f "package.json" ]]; then
    tmux display-message "No package.json found"
    return 1
  fi

  return 0
}

is_pane_busy() {
  local pane_pid=$(tmux display-message -p "#{pane_pid}")
  [[ $(pgrep -P "$pane_pid" | wc -l) -gt 0 ]]
}

search_packages() {
  local query="$1"
  [[ -z "$query" ]] && return
  npm search --json "$query" 2>/dev/null | jq -r '.[] | "\(.name) => \(.description)"' 2>/dev/null || true
}

select_packages() {
  export -f search_packages
  fzf --tmux --multi --reverse --border-label=" Install Packages " \
    --color=border:blue,label:blue,bg+:0,info:gray,pointer:blue \
    --prompt "Search: " \
    --header 'Type to search, TAB to select multiple, ENTER to install' \
    --delimiter ' => ' --with-nth 1.. \
    --bind "change:reload:sleep 0.1; search_packages {q}" \
    --track | sed 's/ => .*//' | tr '\n' ' ' | sed 's/[[:space:]]*$//'
}

execute_command() {
  local cmd="$1" title="$2" mode="$3" pane="$4"
  local cwd=$(tmux display-message -p -F "#{pane_current_path}")

  local wrapper='
    output_file=$(mktemp)
    
    # Force color output for common package managers
    export FORCE_COLOR=1
    export NPM_CONFIG_COLOR=always
    
    # Run command with fnm setup
    {
      if command -v fnm >/dev/null 2>&1; then
        fnm use --silent-if-unchanged 2>/dev/null || true
      fi
      echo -e "\033[1;34m$ '"$cmd"'\033[0m"
      '"$cmd"'
    } 2>&1 | tee "$output_file"
    code=${PIPESTATUS[0]}
    
    {
      echo
      if [[ $code -eq 0 ]]; then
        echo -e "\033[1;32m✓ Success\033[0m"
      else
        echo -e "\033[1;31m✗ Failed (exit: $code)\033[0m"
      fi
      echo
      echo -e "\033[1;36mScroll with j and k | Page scroll with C-u and C-d | Press q to close\033[0m"
    } | tee -a "$output_file"
    
    less -R -K +G "$output_file"
    rm -f "$output_file"
  '

  case "$mode" in
  popup)
    tmux display-popup -E -h 80% -w 80% -T "$title" -d '#{pane_current_path}' "bash -c '$wrapper'"
    ;;
  window)
    if is_pane_busy; then
      tmux new-window -n "$title" -c '#{pane_current_path}' "bash -c '$wrapper'"
    else
      tmux send-keys -t "$pane" C-u "$cmd" C-m
    fi
    ;;
  esac
}

build_menu() {
  local scripts
  if ! scripts=$(jq -r '.scripts | to_entries | map("\(.key)|\(.value)") | .[]' package.json 2>/dev/null); then
    scripts=""
  fi

  cat <<EOF
install|Install dependencies
add|Add packages
add-dev|Add dev dependencies
${scripts}
EOF
}

main() {
  check_dependencies || return 1

  local current_pane=$(tmux display-message -p "#{pane_id}")
  local display_mode=$(is_pane_busy && echo "popup" || echo "window")

  local mode_file
  mode_file=$(mktemp) || {
    tmux display-message "Failed to create temp file"
    return 1
  }
  echo "$display_mode" >"$mode_file"
  export MODE_FILE="$mode_file"

  local menu=$(build_menu)
  local mode_color=$([[ "$display_mode" == "popup" ]] && echo "yellow" || echo "cyan")

  local result
  result=$(echo "$menu" | sed 's/|/ => /g' | fzf --tmux --reverse \
    --border-label=" Package Manager ($display_mode) " \
    --color=border:white,label:$mode_color,bg+:0,info:gray,pointer:blue \
    --header "C-w: Toggle mode | ESC: Cancel" \
    --expect="esc" \
    --bind='ctrl-w:transform:
      current=$(cat $MODE_FILE)
      new_mode=$([[ "$current" == "popup" ]] && echo "window" || echo "popup")
      echo "$new_mode" > $MODE_FILE
      echo "change-border-label( Package Manager ($new_mode) )"
    ') || {
    # fzf was cancelled or failed
    rm -f "$mode_file"
    unset MODE_FILE
    return 0
  }

  # Get final mode and cleanup
  if [[ -f "$mode_file" ]]; then
    display_mode=$(cat "$mode_file" 2>/dev/null || echo "$display_mode")
    rm -f "$mode_file"
  fi
  unset MODE_FILE

  local key=$(echo "$result" | head -1)
  local selection=$(echo "$result" | tail -n +2)

  [[ "$key" == "esc" || -z "$selection" ]] && return 0

  local script_name=$(echo "$selection" | sed 's/ => .*//')
  local command title

  case "$script_name" in
  install)
    command="ni"
    title="Install"
    ;;
  add)
    local packages
    packages=$(select_packages)
    packages=$(echo "$packages" | xargs) # Trim whitespace
    [[ -z "$packages" ]] && return 0
    command="ni $packages"
    title="Add"
    ;;
  add-dev)
    local packages
    packages=$(select_packages)
    packages=$(echo "$packages" | xargs) # Trim whitespace
    [[ -z "$packages" ]] && return 0
    command="ni -D $packages"
    title="Add Dev"
    ;;
  *)
    command="nr $script_name"
    title="$script_name"
    ;;
  esac

  execute_command "$command" "$title" "$display_mode" "$current_pane"
}

main "$@"
