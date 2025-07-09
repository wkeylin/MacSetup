#!/bin/bash
# MacSetup - 系统默认配置

# Dock设置
defaults write com.apple.dock "tilesize" -int "48"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "autohide-delay" -float "0"

# Finder设置
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "ShowStatusBar" -bool "true"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# 截图设置
defaults write com.apple.screencapture "location" -string "~/Desktop"
defaults write com.apple.screencapture "type" -string "png"

# 重启相关服务
killall Dock
killall Finder
