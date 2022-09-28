# ----- Aliases -----
alias ll='ls -la'
alias ..='cd ..'
alias rm='rm -i'
alias rmd='rm -rf i'
alias cl='clear'

alias e='nvim'

alias vimrc='e ~/.vimrc'
alias profile='e ~/.zshrc'
alias reload='source ~/.zshrc'
alias envim='e ~/.config/nvim/'

alias vh='cd ~/workspace/saas/; vim .'
alias sc='cd ~/workspace/saas/saas-client'
alias sa='cd ~/workspace/saas/saas-api'
alias deploy='./deploy.sh'
alias pgh='docker stop relay_db_1; brew services start postgresql'
alias pgr='brew services stop postgresql; docker start relay_db_1'

alias strava='cd ~/workspace/strava/'

alias active='cd ~/workspace/strava/active'
alias bullhorn='cd ~/workspace/strava/bullhorn'
alias config='cd ~/workspace/strava/configuration/'
alias cowbell='cd ~/workspace/strava/cowbell'
alias dass='cd ~/workspace/strava/dass'

alias bumpPatch="sbt 'bumpVersion patch'"
alias bumpMinor="sbt 'bumpVersion minor'"
alias bumpMajor="sbt 'bumpVersion major'"

alias pr='open "https://github.com/strava/${PWD##*/}/compare/$(git symbolic-ref --short -q HEAD)?expand=1"'

alias psg='~/workspace/strava/configuration/mesos/tools/paasage'
alias graphage='~/workspace/strava/configuration/mesos/tools/graphage'

alias hoahq='cd ~/workspace/hoahq/'
# --------------------

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(rbenv init - zsh)"

export PATH="/usr/local/opt/docker-credential-helpers/bin:$PATH"
export PATH="/usr/local/opt/openjdk@11/bin:$PATH"
