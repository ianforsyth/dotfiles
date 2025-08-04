fl() {
  local DRY_RUN=""
  local ACTION=""
  local LOCAL=""
  local REMOTE=""
  local PWD_DIR="$(pwd)"

  # Check for dry run
  if [[ "$1" == "-d" ]]; then
    DRY_RUN="--dry-run"
    ACTION="$2"
    echo "🧪 Dry run enabled"
  else
    ACTION="$1"
  fi

  # Infer project from directory
  if [[ "$PWD_DIR" == *"storage-center"* ]]; then
    LOCAL="./wp-content/themes/tsc-intranet"
    REMOTE="storage-center:/var/www/html/thestoragecenter_com/intranet/wp-content/themes/tsc-intranet"
  elif [[ "$PWD_DIR" == *"warehouse-anywhere"* ]]; then
    LOCAL="./wp-content/themes"
    REMOTE="warehouse-anywhere:public_html/wp-content/themes"
  else
    echo "❌ Could not determine project from directory: $PWD_DIR"
    return 1
  fi

  # Perform action
  case "$ACTION" in
    pull)
      echo "🔽 Pulling from remote to local..."
      rclone sync "$REMOTE" "$LOCAL" \
        --delete-excluded \
        --no-update-modtime \
        --no-update-dir-modtime \
        -v \
        $DRY_RUN
      ;;
    push)
      echo "🔼 Pushing from local to remote..."
      rclone sync "$LOCAL" "$REMOTE" \
        --update \
        --no-update-modtime \
        --no-update-dir-modtime \
        $DRY_RUN
      ;;
    reset)
      echo "🧹 Resetting: mirroring local to remote (removes remote-only files)..."
      rclone sync "$LOCAL" "$REMOTE" \
        --delete-excluded \
        --no-update-modtime \
        --no-update-dir-modtime \
        $DRY_RUN
      ;;
    *)
      echo "❌ Invalid or missing action. Use: pull | push | reset"
      return 1
      ;;
  esac
}