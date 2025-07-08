#!/bin/bash
# 我的自定义系统配置

echo "应用自定义系统配置..."

# Dock 设置 - 更大的图标
defaults write com.apple.dock "tilesize" -int "64"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "show-recents" -bool "false"

# Finder 设置 - 开发者友好
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "ShowStatusBar" -bool "true"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"

# 截图设置 - 保存到专门文件夹
mkdir -p ~/Desktop/Screenshots
defaults write com.apple.screencapture "location" -string "~/Desktop/Screenshots"
defaults write com.apple.screencapture "type" -string "png"

# 键盘设置 - 快速重复
defaults write NSGlobalDomain "KeyRepeat" -int "1"
defaults write NSGlobalDomain "InitialKeyRepeat" -int "10"

# 触控板设置 - 启用轻触
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad "Clicking" -bool "true"
defaults write NSGlobalDomain "com.apple.mouse.tapBehavior" -int "1"

# 重启相关服务
killall Dock
killall Finder

echo "自定义系统配置完成！"