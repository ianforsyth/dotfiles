#!/bin/zsh

echo "Starting setup..."

echo "Removing everthing from macbook dock and autohiding..."
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
defaults write com.apple.dock autohide -bool true
killall Dock

echo "Enabling natural scrolling..."
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo "Disabling two finger right click..."

echo "Enable tap to click..."
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

echo "Disabling swipe navigation..."
defaults write -g com.apple.swipescrolldirection -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool false
defaults write -g AppleEnableSwipeNavigateWithScrolls -bool false

echo 'Turning keyboard repeat up and keyboard delay down'
defaults write -g InitialKeyRepeat -int 10 
defaults write -g KeyRepeat -int 1

echo 'Restarting system ui for preferences to take hold...'
killall SystemUIServer

# This is getting overwritten on every reboot - just suggesting setting it manually for now
# echo "Mapping caps lock to control..."
# hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'

if ! command -v brew &> /dev/null
then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Commands required by brew post-install
    echo >> /Users/ianforsyth/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/ianforsyth/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew found. Updating and upgrading..."
    brew update
    brew upgrade
fi

echo 'Installing homebrew utils...'
brew install git
brew install asdf
brew install neovim
brew install font-monaspace-nerd-font

# Needed for yarn
brew install gnu-tar 
brew install gnupg

echo 'Installing homebrew applications...'
brew install --cask vivaldi
brew install --cask google-drive
brew install --cask slack
brew install --cask spotify
brew install --cask 1password
brew install --cask rectangle-pro
brew install --cask obsidian
brew install --cask todoist

echo "Installing asdf plugins..."
asdf plugin add nodejs
asdf install nodejs latest
asdf set nodejs $(asdf list nodejs | tail -1)

asdf plugin add yarn
asdf install yarn latest
asdf set yarn $(asdf list yarn | tail -1)

echo "Creating basic directories..."
mkdir ~/stuff
mkdir ~/workspace

echo 'Linking .zshrc...'
ln -s ~/workspace/dotfiles/.zshrc ~/.zshrc
source ~/.zshrc

echo 'Linking .gitconfig...'
ln -s ~/workspace/dotfiles/.gitconfig ~/.gitconfig

echo 'Linking .gitignore...'
ln -s ~/workspace/dotfiles/.gitignore ~/.gitignore

echo 'Linking Neovim configuration...'
ln -s ~/workspace/dotfiles/nvim ~/.config/nvim
