#!/usr/bin/env bash
#
# backup.sh — dump the current Homebrew setup to a version-controlled Brewfile.
# Captures taps, formulae, casks, Mac App Store apps, and VS Code extensions.
 
set -euo pipefail
 
BREWFILE="$HOME/workspace/dotfiles/Brewfile"
 
# Bail early if Homebrew isn't on PATH.
if ! command -v brew >/dev/null 2>&1; then
  echo "error: brew not found on PATH" >&2
  exit 1
fi
 
# Make sure the destination directory exists.
mkdir -p "$(dirname "$BREWFILE")"
 
# Dump current state, overwriting any existing Brewfile.
# Add --describe if you want a comment describing each package (noisier diffs).
brew bundle dump --file="$BREWFILE" --force
 
echo "Brewfile written to $BREWFILE"
 
# --- Optional: auto-commit the change to your dotfiles repo ---
# Uncomment to have the backup land in source control on every run.
#
# cd "$(dirname "$BREWFILE")"
# git add Brewfile
# if ! git diff --cached --quiet -- Brewfile; then
#   git commit -m "Update Brewfile ($(date +%Y-%m-%d))"
#   echo "Committed updated Brewfile"
# else
#   echo "No changes to commit"
# fi
