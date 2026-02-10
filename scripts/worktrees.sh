# Defines `wt` and `wtd` for managing git worktrees
# wt <branch>  — create or switch to a worktree
# wt            — pick from recent worktrees
# wtd           — pick and delete a worktree + its branch

WT_ROOT="$HOME/workspace"

_wt_prompt() {
  if [[ "$PWD" == "$WT_ROOT/worktrees/"* ]]; then
    local rel=${PWD#$WT_ROOT/worktrees/}
    _prompt_dir=${rel%%/*}
  else
    _prompt_dir=${PWD##*/}
  fi
}
add-zsh-hook precmd _wt_prompt

_wt() {
  local -a branches
  branches=(${(f)"$(git worktree list --porcelain 2>/dev/null | grep '^branch ' | sed 's|^branch refs/heads/||')"})
  compadd -- "${branches[@]}"
}
compdef _wt wt

_wt_select() {
  local base="$WT_ROOT/worktrees"
  local history="$base/.history"

  if [[ ! -f "$history" ]]; then
    echo "No worktree history"
    return 1
  fi

  local -a paths
  paths=(${(f)"$(tail -r "$history" | awk '!seen[$2]++ {print $2}' | head -9)"})

  if [[ ${#paths[@]} -eq 0 ]]; then
    echo "No worktrees found"
    return 1
  fi

  local i
  for i in {1..${#paths[@]}}; do
    local project=$(basename "$(dirname "${paths[$i]}")")
    local branch=$(basename "${paths[$i]}")
    echo "$i. $project/$branch"
  done

  echo ""
  read -sk 1 choice

  if [[ "$choice" =~ ^[1-9]$ ]] && (( choice <= ${#paths[@]} )); then
    _wt_selected="${paths[$choice]}"
    return 0
  else
    echo "Invalid selection"
    return 1
  fi
}

wt() {
  local branch="$1"

  if [[ -z "$branch" ]]; then
    _wt_select || return 1
    if [[ -d "$_wt_selected" ]]; then
      cd "$_wt_selected" || return 1
      echo "$(date +%s) $_wt_selected" >> "$WT_ROOT/worktrees/.history"
    else
      echo "Worktree no longer exists: $_wt_selected"
      return 1
    fi
    return 0
  fi

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not a git repository"
    return 1
  fi

  local project=$(basename "$(git rev-parse --show-toplevel)")
  local base="$WT_ROOT/worktrees"
  local dir_name=${branch//\//-}
  local worktree="$base/$project/$dir_name"

  mkdir -p "$base/$project"

  if [[ -d "$worktree" ]]; then
    cd "$worktree" || return 1
  else
    local existing=$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '$1=="worktree"{p=$0} $0=="branch "b{print p}' | sed 's/^worktree //')
    if [[ -n "$existing" ]]; then
      cd "$existing" || return 1
    elif ! git worktree add "$worktree" "$branch" 2>/dev/null && \
         ! git worktree add "$worktree" -b "$branch"; then
      echo "Failed to create worktree"
      return 1
    else
      cd "$worktree" || return 1
    fi
  fi

  echo "$(date +%s) $worktree" >> "$base/.history"
}

wtd() {
  _wt_select || return 1
  local target="$_wt_selected"
  local history="$WT_ROOT/worktrees/.history"

  if [[ ! -d "$target" ]]; then
    echo "Worktree no longer exists, cleaning up history"
    sed -i '' "\|$target|d" "$history"
    return 1
  fi

  if [[ "$PWD" == "$target"* ]]; then
    cd "$WT_ROOT" || return 1
  fi

  local main_repo=$(git -C "$target" worktree list --porcelain | head -1 | sed 's/^worktree //')
  local branch=$(git -C "$target" rev-parse --abbrev-ref HEAD)

  if git -C "$main_repo" worktree remove "$target"; then
    git -C "$main_repo" branch -d "$branch" 2>/dev/null || \
      git -C "$main_repo" branch -D "$branch" 2>/dev/null
    echo "Removed: $(basename "$(dirname "$target")")/$branch"
    sed -i '' "\|$target|d" "$history"
  else
    echo "Has uncommitted changes — use 'git worktree remove --force' to override"
    return 1
  fi
}
