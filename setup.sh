#!/bin/zsh

# Remove everything from dock and hide it
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
defaults write com.apple.dock autohide -bool true
killall Dock

# Enable natural scrolling, disable two finger right click, disable swipe navigation
defaults write -g com.apple.swipescrolldirection -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool false
defaults write -g AppleEnableSwipeNavigateWithScrolls -bool false

killall SystemUIServer

# Map caps-lock to ctrl
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'

# Create basic directories
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
