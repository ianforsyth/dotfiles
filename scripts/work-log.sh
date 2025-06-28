# Defines the `lg` function for logging and Slack messaging

lg () {
  local message

  # 1. Get message content
  if [ "$1" = "last" ]; then
    message="$(git log -1 --pretty=%B)"
  else
    message="$*"
  fi

  # 2. Date/time + log file setup
  local log_dir="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault/work/log"
  local today="$(date +%Y-%m-%d)"
  local timestamp="$(date "+%I:%M %p")"
  local log_file="$log_dir/$today.md"
  local log_line="$timestamp: $message"

  mkdir -p "$log_dir"

  # 3a. If it's a new file, write the date header first
  if [ ! -f "$log_file" ]; then
    formatted_date="$(date "+%B %d, %Y")"  # e.g. June 23, 2025
    echo "# $formatted_date" >> "$log_file"
    echo "" >> "$log_file"
  fi

  # 3b. Append the log line
  echo "$log_line" >> "$log_file"
  echo "📓 Logged to $log_file"

  # 4. Post to Slack
  if [[ -n "$SLACK_BOT_TOKEN" ]]; then
    env TOKEN="$SLACK_BOT_TOKEN" CHANNEL="log-ian" npx slack-msg "$message"
    echo "📤 Sent to Slack"
  else
    echo "⚠️ SLACK_BOT_TOKEN not set — skipping Slack post"
  fi
}