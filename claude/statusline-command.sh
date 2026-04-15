#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')

# Get current directory basename
dir=$(basename "$cwd")

# Get git branch if in a git repo (skip optional locks for performance)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_branch="  $branch"
  fi
fi

# Get context usage (calculated manually from token counts for accuracy)
context_info=""
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_creation=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
if [ -n "$context_window_size" ] && [ "$context_window_size" != "0" ] && [ "$input_tokens" != "null" ]; then
  total_used=$(echo "$input_tokens + $cache_creation + $cache_read + $output_tokens" | bc)
  used=$(echo "scale=1; $total_used * 100 / $context_window_size" | bc)
  used_int=$(printf "%.0f" "$used")
  context_info="  ${used_int}%"
fi

# Build status line with colors (using printf for ANSI codes)
printf "\033[96m%s\033[0m\033[32m%s\033[0m\033[35m%s\033[0m" \
  "$dir" "$git_branch" "$context_info"

# Add output style if present and not "default"
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
  printf " \033[33m[%s]\033[0m" "$output_style"
fi
