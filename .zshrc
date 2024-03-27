source ~/workspace/dotfiles/.strava-commands.sh
source ~/workspace/dotfiles/.saas-commands
source ~/workspace/dotfiles/.localsecrets

# ----- Aliases -----
alias ll='ls -la'
alias ..='cd ..'
alias rm='rm -i'
alias rmd='rm -rf i'
alias c='clear'

alias e='nvim'

alias profile='e ~/.zshrc'
alias reload='source ~/.zshrc'
alias envim='e ~/.config/nvim/'

alias saas='cd ~/workspace/saas-starter'

alias vh='cd ~/workspace/saas/; vim .'
alias sc='cd ~/workspace/saas/saas-client'
alias sa='cd ~/workspace/saas/saas-api'
alias deploy='./deploy.sh'

alias dotfiles='cd ~/workspace/dotfiles'

# Strava specific -------------------------
alias strava='cd ~/workspace/strava/'
alias active='cd ~/workspace/strava/active'
alias bullhorn='cd ~/workspace/strava/bullhorn'
alias config='cd ~/workspace/strava/configuration/'
alias cowbell='cd ~/workspace/strava/cowbell'
alias comms='cd ~/workspace/strava/comms'
alias dass='cd ~/workspace/strava/dass'
alias einkenni='cd ~/workspace/strava/einkenni'
alias dixie='cd ~/workspace/strava/dixie'
alias erasure='cd ~/workspace/strava/erasure'
alias malheur='cd ~/workspace/strava/malheur'
alias ritmo='cd ~/workspace/strava/ritmo'
alias pike='cd ~/workspace/strava/pike'

alias fmt='sbt scalafmtAll'
# --------------------

alias pr='open "https://github.com/strava/${PWD##*/}/compare/$(git symbolic-ref --short -q HEAD)?expand=1"'

alias psg='~/workspace/strava/configuration/mesos/tools/paasage'
alias graphage='~/workspace/strava/configuration/mesos/tools/graphage'

# --------------------
alias api='docker-compose exec api sh'
alias app='docker-compose exec app sh'

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

export APOLLO_KEY="user:po.strava.iforsyth@strava.com:I3eYIJAd8IxSKIW7qgz5SA"

export GITHUB_PACKAGES_USERNAME=ianforsyth

export PATH="/usr/local/opt/docker-credential-helpers/bin:$PATH"
export PATH="/usr/local/opt/openjdk@11/bin:$PATH"
export PATH="$HOME/.canary-tools/bin:$PATH"
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=/Applications/Android\ Studio.app/sdk

. /opt/homebrew/opt/asdf/libexec/asdf.sh
