# Dotfiles

## Run the setup script
- Follow the [instructions here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to get an ssh key for github
- Run `mkdir ~/workspace; cd ~/workspace`
- Run `git clone git@github.com:ianforsyth/dotfiles.git`
- Run `cd dotfiles`
- Run `./setup.sh`
- Restart for all new settings to take effect

## Manual settings changes
- Change resolution: Mac → System Settings → Displays → More Space
- Map caps lock to ctrl: Mac → System Settings → Keyboard → Keyboard → Shortcuts → Modifier Keys

## Manual app setup
- Cursor/Code
  - The setup script should handle symlinking preferences, keybindings, snippets, and .cursor (for extensions)
  - Automatically syncing everything seems brittle
  - Extentions at the time of writing:
    - Gruvbox Theme
    - Import Cost
    - Prettier
    - Vim
  - There should also be a .code_profile file in the directory to load in worst case (might be stale)
- iTerm2
  - Set "Load settings from a custom folder" (the iTerm directory here)
  - Set to save changes automatically
- RectanglePro
  - Import config
