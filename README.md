# Dotfiles

## Run the setup script
- Follow the [instructions here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to get an ssh key for GitHub
- Follow [instructions here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account) to add the sshe key to GitHub
- Run `mkdir ~/workspace; cd ~/workspace`
- Run `git clone git@github.com:ianforsyth/dotfiles.git`
- Run `cd dotfiles`
- Run `./setup.sh`
- Restart for all new settings to take effect

## Manual settings changes
- Change resolution: Mac → System Settings → Displays → More Space
- Map caps lock to ctrl: Mac → System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys

## Manual app setup
- iTerm2
  - Settings -> General -> Settings
  - Set "Load settings from a custom folder" (the iTerm directory here)
  - Set to save changes automatically
- RectanglePro
  - Import config
