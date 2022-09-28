#!/bin/zsh

echo 'Linking .zshrc...'
ln -s ~/workspace/dotfiles/.zshrc ~/.zshrc
source ~/.zshrc

echo 'Linking .gitconfig...'
ln -s ~/workspace/dotfiles/.gitconfig ~/.gitconfig
