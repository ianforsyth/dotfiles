# Load in keys and passwords from local file
source ~/workspace/dotfiles/.localsecrets

# Load all custom scripts
for script in ~/workspace/dotfiles/scripts/*.sh; do
  source "$script"
done

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

alias resi='cd ~/workspace/residesk/Server_Web_Outlook'
alias ng='ngrok http --url=residesk-ian-dev.ngrok.app 5001'

alias workspace='cd ~/workspace'
alias dotfiles='cd ~/workspace/dotfiles'
alias gambit='cd ~/workspace/gambit'
alias base='cd ~/workspace/base'
alias app='cd ~/workspace/base/app'
alias api='cd ~/workspace/base/api'
alias hoahq='cd ~/workspace/hoahq'

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

# ----- Command Prompt -----
get_version_control_info() { vcs_info }
add-zsh-hook precmd get_version_control_info
zstyle ':vcs_info:git:*' formats ' [%b]'
setopt PROMPT_SUBST
PROMPT='%1/%F{yello}${vcs_info_msg_0_}%F{white} → '
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

export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
