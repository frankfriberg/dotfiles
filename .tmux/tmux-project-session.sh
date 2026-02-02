#!/bin/bash

# Parent directories to scan for subfolders
PARENT_DIRS=(
  "$HOME/projects"
  "$HOME/dotfiles/.config"
  "$HOME/projects/allgravy"
)

# Individual directories to include directly
INDIVIDUAL_DIRS=(
  "$HOME/projects"
  "$HOME/dotfiles"
  "$HOME/dotfiles/.hammerspoon"
)

# Function to get session name from path
get_session_name() {
  basename "$1" | tr '.' '_'
}

# Function to get display name (parentfolder/name)
get_display_name() {
  local full_path="$1"
  local parent_dir=${full_path%/*}
  parent_dir=${parent_dir##*/}
  local dir_name=${full_path##*/}

  # Special case for dotfiles (show as just "dotfiles")
  if [[ "$full_path" == *"/dotfiles" ]]; then
    echo "dotfiles"
  else
    echo "$parent_dir/$dir_name"
  fi
}

# Function to generate project options
generate_project_options() {
  # Get existing tmux sessions
  existing_sessions=$(tmux list-sessions -F "#{session_name} #{session_activity}" 2>/dev/null || echo "")

  # Collect all directories first
  all_dirs=()

  # Scan parent directories for subfolders
  for parent_dir in "${PARENT_DIRS[@]}"; do
    if [[ -d "$parent_dir" ]]; then
      for subdir in "$parent_dir"/*; do
        [[ -d "$subdir" ]] && all_dirs+=("$subdir")
      done
    fi
  done

  # Add individual directories that exist
  for dir in "${INDIVIDUAL_DIRS[@]}"; do
    [[ -d "$dir" ]] && all_dirs+=("$dir")
  done

  # Track which sessions we've matched to directories (simple string)
  matched_sessions=""

  # Generate options array for directories
  project_options=""
  for dir in "${all_dirs[@]}"; do
    [[ ! -d "$dir" ]] && continue

    session_name=$(get_session_name "$dir")
    display_name=$(get_display_name "$dir")

    session_line=$(echo "$existing_sessions" | grep "^${session_name} " | head -1)
    if [[ -n "$session_line" ]]; then
      activity=$(echo "$session_line" | cut -d' ' -f2)
      project_options+="\033[34m[󰊠] $display_name\033[0m\t$dir\t1\t$activity\t$session_name\n"
      matched_sessions+=" $session_name "
    else
      project_options+=" →  $display_name\t$dir\t0\t0\t\n"
    fi
  done

  # Add orphaned sessions (sessions without corresponding directories)
  while IFS=' ' read -r session_name activity; do
    [[ -z "$session_name" ]] && continue
    if [[ "$matched_sessions" != *" $session_name "* ]]; then
      project_options+="\033[33m[*] $session_name\033[0m\t\t1\t$activity\t$session_name\n"
    fi
  done <<<"$existing_sessions"

  # Sort: sessions (1) before directories (0), then by activity (newest first), then alphabetically
  printf "$project_options" | sort -t$'\t' -k3,3nr -k4,4nr -k1,1
}

# If called with --generate-options, just output the options and exit
if [[ "$1" == "--generate-options" ]]; then
  generate_project_options
  exit 0
fi

# Generate project options
project_options=$(generate_project_options)

# Exit if no directories found
if [[ -z "$project_options" ]]; then
  echo "No available project directories found"
  exit 1
fi

# Use fzf to select directory
selected=$(echo "$project_options" | fzf \
  --tmux center,40%,50% \
  --no-sort --ansi --border-label ' Tmux Sessions ' \
  --prompt="> " \
  --with-nth=1 \
  --delimiter=$'\t' \
  --color=border:white,label:-1,bg+:0,info:gray,pointer:blue,label:blue \
  --gutter ' ' \
  --border \
  --bind 'ctrl-d:execute(tmux kill-session -t {5})+reload('"$0"' --generate-options)' \
  --reverse)

# Exit if nothing selected
if [[ -z "$selected" ]]; then
  exit 0
fi

# Extract the actual directory path and session info
selected_dir=$(echo "$selected" | cut -d$'\t' -f2)
selected_status=$(echo "$selected" | cut -d$'\t' -f3)
selected_session=$(echo "$selected" | cut -d$'\t' -f5)

# Handle orphaned sessions (no directory)
if [[ -z "$selected_dir" ]]; then
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$selected_session"
  else
    tmux attach-session -t "$selected_session"
  fi
  exit 0
fi

# Get session name from directory
session_name=$(get_session_name "$selected_dir")

# Check if we're inside tmux
if [[ -n "$TMUX" ]]; then
  # Inside tmux - switch to session or create new one
  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux switch-client -t "$session_name"
  else
    tmux new-session -d -s "$session_name" -c "$selected_dir"
    tmux switch-client -t "$session_name"
  fi
else
  # Outside tmux - attach to session or create new one
  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
  else
    tmux new-session -s "$session_name" -c "$selected_dir"
  fi
fi
