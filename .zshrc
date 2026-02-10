# Load in keys and passwords from local file
source ~/workspace/dotfiles/.localsecrets

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# ----- Aliases -----
alias ll='ls -la'
alias ..='cd ..'
# alias rm='rm -i'
# alias rmd='rm -rf i'
alias c='clear && printf "\e[3J"'

alias up='docker compose up'
alias down='docker compose down'

alias dcr='docker-compose exec api bin/rails'

alias e='cursor'
alias tm='task-master'

alias profile='e ~/.zshrc'
alias reload='source ~/.zshrc'
alias envim='e ~/.config/nvim/'
alias eworkspaces='e ~/workspace/dotfiles/nvim/workspaces'

alias resi='cd ~/workspace/resi-desk'
alias ng='ngrok http --url=residesk-ian-dev.ngrok.app 3000'
alias killng='pkill -f ngrok'
alias resi-test-leasing='DEBUG=true NODE_ENV=production yarn test:leasing-assistant --manual'
alias resi-start='DEBUG=true NODE_ENV=production yarn start'
alias resi-web='yarn --cwd Web start'

alias workspace='cd ~/workspace'
alias dotfiles='cd ~/workspace/dotfiles'
alias gambit='cd ~/workspace/gambit'
alias tsc='cd ~/workspace/local/the-storage-center'
alias tsci='cd ~/workspace/local/the-storage-center-intranet'
alias ssm='cd ~/workspace/local/ssm-plugin'

slack() {
  local message

  if [ "$1" = "last" ]; then
      message="$(git log -1 --pretty=%B)"
  else
      message="$*"
  fi

  TOKEN=$SLACK_BOT_TOKEN CHANNEL=log-ian npx slack-msg "$message"
}

cursor() {
  if [[ "$1" == "init" ]]; then
    mkdir -p .cursor/rules
    mkdir projects
    ln -s ~/workspace/dotfiles/my-rules .cursor/rules/my-rules
    touch .cursor/rules/project.mdc
  else
    command cursor "$@"
  fi
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

# Adding direnv for project-specific docker commands (base app)
eval "$(direnv hook zsh)"

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
