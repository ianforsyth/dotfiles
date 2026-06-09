# Load in keys and passwords from local file
source ~/workspace/dotfiles/.localsecrets

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# ----- Aliases -----
alias ls='eza'
alias ll='eza -l -a'
alias lt='eza --tree'
alias ..='cd ..'
alias c='clear && printf "\e[3J"'

alias backup='sh ~/workspace/dotfiles/backup.sh'

alias up='docker compose up'
alias down='docker compose down'

alias dcr='docker-compose exec api bin/rails'

alias e='nvim'
alias profile='e ~/.zshrc'
alias reload='source ~/.zshrc'
alias envim='e ~/.config/nvim/'
alias eworkspaces='e ~/workspace/dotfiles/nvim/workspaces'

alias resi='cd ~/workspace/resi-desk'
alias ng='ngrok http --url=residesk-ian-dev.ngrok.app 3000'
alias killng='pkill -f ngrok'
alias resi-test-leasing='DEBUG=true NODE_ENV=production pnpm test:leasing-assistant --manual'
alias resi-start='DEBUG=true NODE_ENV=production pnpm start'
alias resi-web='PORTLESS=0 bash scripts/portless-dev.sh web'

alias mve='cd ~/workspace/moove'

alias workspace='cd ~/workspace'
alias dotfiles='cd ~/workspace/dotfiles'
alias gambit='cd ~/workspace/gambit'
alias mercado='cd ~/workspace/mercado'
alias tsc='cd ~/workspace/local/the-storage-center'
alias tsci='cd ~/workspace/local/the-storage-center-intranet'
alias ssm='cd ~/workspace/local/ssm-plugin'
alias so='cd ~/workspace/storage-ops'
alias v='cd ~/workspace/venture'
alias mm='cd ~/workspace/money-maker'
alias wa='cd ~/workspace/local/warehouse-anywhere-v2/'

slack() {
  local message

  if [ "$1" = "last" ]; then
      message="$(git log -1 --pretty=%B)"
  else
      message="$*"
  fi

  TOKEN=$SLACK_BOT_TOKEN CHANNEL=log-ian npx slack-msg "$message"
}

sac() {
  local msg="$1"
  git add -A && git commit -m "$msg" && TOKEN=$SLACK_BOT_TOKEN CHANNEL=log-ian npx slack-msg "$msg"
}

alias pr='open "$(git config --get remote.origin.url | sed -e "s/git@github.com:/https:\/\/github.com\//" -e "s/\.git$//")/pull/new/$(git symbolic-ref --short HEAD)"'

# ----- Packages -----
autoload -U add-zsh-hook  # Handling multiple precmd hooks
autoload -Uz vcs_info # Version control info (for branch name in prompt)
autoload -Uz compinit && compinit # Git completion
# --------------------

# Load all custom scripts (after compinit so completions register)
for script in ~/workspace/dotfiles/scripts/*.sh; do
  source "$script"
done

# ----- Command Prompt -----
get_version_control_info() { vcs_info }
add-zsh-hook precmd get_version_control_info
zstyle ':vcs_info:git:*' formats ' [%b]'
setopt PROMPT_SUBST
PROMPT='${_prompt_dir}%F{yello}${vcs_info_msg_0_}%F{white} → '
# ------------------------

# ---- iTerm Tab Title -----
# Set iTerm Tab Title to Current Working Directory
if [ $ITERM_SESSION_ID ]; then
set_tab_title() {
  echo -ne "]0;$(dirs)"
}
add-zsh-hook precmd set_tab_title
fi
# --------------------------

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
