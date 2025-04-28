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
alias eworkspaces='e ~/workspace/dotfiles/nvim/workspaces'

alias workspace='cd ~/workspace'
alias dotfiles='cd ~/workspace/dotfiles'
alias gambit='cd ~/workspace/gambit'
alias base='cd ~/workspace/base'
alias app='cd ~/workspace/base/app'
alias api='cd ~/workspace/base/api'
alias hoahq='cd ~/workspace/hoahq'
alias fs='foreman start'

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

. /opt/homebrew/opt/asdf/libexec/asdf.sh
