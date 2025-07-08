# Mac Init 系统配置器使用文档

## 概述

系统配置器是 Mac Init 的重要组件，负责自动配置 macOS 系统设置，包括 Dock、Finder、截图、安全、键盘、触控板等各个方面。它提供了预设配置和完全自定义两种方式，并具备完整的备份恢复功能。

## 主要功能

### 1. 系统组件配置
- **Dock 配置** - 大小、位置、自动隐藏等
- **Finder 配置** - 显示选项、搜索设置等  
- **截图配置** - 保存位置、格式、阴影等
- **键盘配置** - 重复速度、快捷键等
- **触控板配置** - 点击、拖拽、手势等

### 2. 开发者设置
- 显示隐藏文件和文件夹
- 显示完整文件路径
- 禁用文件扩展名警告
- 优化开发环境设置

### 3. 安全配置
- 防火墙设置
- 屏幕保护程序密码
- 远程访问控制

### 4. 备份和恢复
- 自动备份原始设置
- 支持一键恢复
- 配置变更追踪

## 基本使用方法

### 通过主脚本使用

```bash
# 完整系统配置
./init.sh --config-only

# 仅系统配置，使用特定方案
./init.sh --config-only --profile developer

# 预览系统配置
./init.sh --dry-run --config-only --verbose
```

### 直接调用模块

```bash
# 加载系统配置器
source scripts/configurers/system.sh

# 执行完整系统配置
configure_system

# 执行特定组件配置
configure_dock
configure_finder
configure_developer_settings
```

### 交互式配置

```bash
# 启动交互式系统配置向导
source scripts/configurers/system.sh
interactive_system_config
```

会显示菜单让你选择：
```
=== 交互式系统配置 ===
请选择配置选项:
1. 完整系统配置 (推荐)
2. 仅配置 Dock
3. 仅配置 Finder  
4. 仅配置开发者设置
5. 仅配置安全设置
6. 自定义配置文件
7. 重置系统配置
8. 退出
```

## 详细配置说明

### Dock 配置

#### 可配置项目

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `tilesize` | int | 48 | 图标大小（像素） |
| `autohide` | bool | true | 自动隐藏 |
| `autohide-delay` | float | 0 | 自动隐藏延迟（秒） |
| `autohide-time-modifier` | float | 0.5 | 隐藏动画速度 |
| `show-recents` | bool | false | 显示最近使用的应用 |
| `magnification` | bool | true | 启用放大效果 |
| `largesize` | int | 64 | 放大后大小 |
| `orientation` | string | bottom | 位置（left/bottom/right） |
| `mineffect` | string | scale | 最小化效果 |

#### 使用示例

```bash
# 仅配置 Dock
configure_dock

# 手动设置 Dock 选项
apply_defaults_config "com.apple.dock" "tilesize" "int" "56"
apply_defaults_config "com.apple.dock" "autohide" "bool" "true"
apply_defaults_config "com.apple.dock" "orientation" "string" "left"

# 重启 Dock 使设置生效
killall Dock
```

#### 自定义 Dock 配置

```bash
# 创建自定义 Dock 配置函数
configure_custom_dock() {
    log_step_start "配置自定义 Dock"
    
    # 更大的图标
    apply_defaults_config "com.apple.dock" "tilesize" "int" "64"
    
    # 放置在左侧
    apply_defaults_config "com.apple.dock" "orientation" "string" "left"
    
    # 禁用放大效果
    apply_defaults_config "com.apple.dock" "magnification" "bool" "false"
    
    # 更快的动画
    apply_defaults_config "com.apple.dock" "autohide-time-modifier" "float" "0.2"
    
    # 重启 Dock
    killall Dock
    
    log_step_complete "配置自定义 Dock"
}
```

### Finder 配置

#### 主要配置项

| 配置项 | 说明 |
|--------|------|
| `ShowPathbar` | 显示路径栏 |
| `ShowStatusBar` | 显示状态栏 |
| `ShowTabView` | 显示标签页栏 |
| `_FXShowPosixPathInTitle` | 标题栏显示完整路径 |
| `FXDefaultSearchScope` | 默认搜索范围 |
| `FXEnableExtensionChangeWarning` | 扩展名更改警告 |
| `AppleShowAllFiles` | 显示隐藏文件 |
| `ShowHardDrivesOnDesktop` | 桌面显示硬盘 |

#### 使用示例

```bash
# 完整 Finder 配置
configure_finder

# 单独配置项
apply_defaults_config "com.apple.finder" "ShowPathbar" "bool" "true"
apply_defaults_config "com.apple.finder" "AppleShowAllFiles" "bool" "true"

# 全局设置（显示所有扩展名）
apply_defaults_config "NSGlobalDomain" "AppleShowAllExtensions" "bool" "true"

# 重启 Finder
killall Finder
```

#### 开发者友好的 Finder 设置

```bash
configure_developer_finder() {
    log_step_start "配置开发者 Finder"
    
    # 显示所有隐藏文件
    apply_defaults_config "com.apple.finder" "AppleShowAllFiles" "bool" "true"
    
    # 显示完整路径
    apply_defaults_config "com.apple.finder" "_FXShowPosixPathInTitle" "bool" "true"
    
    # 禁用扩展名警告
    apply_defaults_config "com.apple.finder" "FXEnableExtensionChangeWarning" "bool" "false"
    
    # 默认搜索当前文件夹
    apply_defaults_config "com.apple.finder" "FXDefaultSearchScope" "string" "SCcf"
    
    # 显示 ~/Library 文件夹
    chflags nohidden ~/Library
    
    killall Finder
    log_step_complete "配置开发者 Finder"
}
```

### 截图配置

#### 配置选项

```bash
configure_screenshots() {
    log_step_start "配置截图设置"
    
    # 创建截图专用文件夹
    mkdir -p ~/Desktop/Screenshots
    
    # 设置保存位置
    apply_defaults_config "com.apple.screencapture" "location" "string" "${HOME}/Desktop/Screenshots"
    
    # 设置格式为 PNG
    apply_defaults_config "com.apple.screencapture" "type" "string" "png"
    
    # 禁用阴影
    apply_defaults_config "com.apple.screencapture" "disable-shadow" "bool" "true"
    
    # 在文件名中包含日期
    apply_defaults_config "com.apple.screencapture" "include-date" "bool" "true"
    
    log_step_complete "配置截图设置"
}
```

#### 高级截图配置

```bash
configure_advanced_screenshots() {
    # 设置截图文件名前缀
    apply_defaults_config "com.apple.screencapture" "name" "string" "Screenshot"
    
    # 显示鼠标指针
    apply_defaults_config "com.apple.screencapture" "showsCursor" "bool" "true"
    
    # 设置 JPEG 质量（如果使用 JPEG 格式）
    apply_defaults_config "com.apple.screencapture" "JPEGquality" "float" "0.9"
}
```

### 键盘和触控板配置

#### 键盘设置

```bash
configure_keyboard() {
    log_step_start "配置键盘设置"
    
    # 启用全键盘访问（Tab 键导航）
    apply_defaults_config "NSGlobalDomain" "AppleKeyboardUIMode" "int" "3"
    
    # 设置按键重复速度（1=最快，2=快速）
    apply_defaults_config "NSGlobalDomain" "KeyRepeat" "int" "2"
    
    # 设置首次重复延迟（10=短延迟）
    apply_defaults_config "NSGlobalDomain" "InitialKeyRepeat" "int" "10"
    
    # 禁用自动纠正
    apply_defaults_config "NSGlobalDomain" "NSAutomaticSpellingCorrectionEnabled" "bool" "false"
    
    # 禁用自动大写
    apply_defaults_config "NSGlobalDomain" "NSAutomaticCapitalizationEnabled" "bool" "false"
    
    log_step_complete "配置键盘设置"
}
```

#### 触控板设置

```bash
configure_trackpad() {
    log_step_start "配置触控板设置"
    
    # 启用轻触点击
    apply_defaults_config "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "bool" "true"
    apply_defaults_config "NSGlobalDomain" "com.apple.mouse.tapBehavior" "int" "1"
    
    # 启用三指拖拽
    apply_defaults_config "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerDrag" "bool" "true"
    
    # 设置跟踪速度（0.0-3.0）
    apply_defaults_config "NSGlobalDomain" "com.apple.trackpad.scaling" "float" "1.0"
    
    # 启用辅助点击（双指点击）
    apply_defaults_config "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadRightClick" "bool" "true"
    
    log_step_complete "配置触控板设置"
}
```

### 安全配置

#### 基础安全设置

```bash
configure_security() {
    log_step_start "配置安全设置"
    
    # 启用防火墙
    if sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null; then
        log_success "防火墙已启用"
    fi
    
    # 设置屏幕保护程序密码
    apply_defaults_config "com.apple.screensaver" "askForPassword" "bool" "true"
    apply_defaults_config "com.apple.screensaver" "askForPasswordDelay" "int" "0"
    
    # 禁用远程登录（如果需要）
    sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist 2>/dev/null || true
    
    log_step_complete "配置安全设置"
}
```

#### 高级安全配置

```bash
configure_advanced_security() {
    # 启用防火墙日志
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
    
    # 启用隐身模式
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    
    # 禁用客人用户
    sudo dscl . delete /Users/Guest
    
    # 设置自动锁定时间
    apply_defaults_config "com.apple.screensaver" "idleTime" "int" "600"  # 10分钟
}
```

## 自定义配置脚本

### 创建自定义配置脚本

你可以创建自己的系统配置脚本：

```bash
#!/bin/bash
# configs/system/my-custom-config.sh

echo "应用自定义系统配置..."

# 自定义 Dock 设置
defaults write com.apple.dock "tilesize" -int "72"
defaults write com.apple.dock "orientation" -string "left"

# 自定义 Finder 设置  
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# 自定义截图设置
mkdir -p ~/Documents/Screenshots
defaults write com.apple.screencapture "location" -string "~/Documents/Screenshots"

# 自定义安全设置
defaults write com.apple.screensaver "askForPassword" -bool "true"
defaults write com.apple.screensaver "askForPasswordDelay" -int "5"

# 重启相关服务
killall Dock
killall Finder

echo "自定义配置完成！"
```

### 使用自定义配置脚本

```bash
# 通过配置方案使用
# configs/profiles/my-profile.conf
SYSTEM_CONFIG="my-custom-config.sh"

# 直接执行
execute_custom_config "configs/system/my-custom-config.sh"

# 通过主脚本使用
./init.sh --config configs/profiles/my-profile.conf
```

## 备份和恢复

### 自动备份

系统配置器会在应用设置前自动备份原始配置：

```bash
# 初始化备份系统
init_system_backup

# 备份位置
# ~/.mac-init-backup-YYYYMMDD_HHMMSS/system-defaults/
# ├── com.apple.dock.plist
# ├── com.apple.finder.plist
# ├── com.apple.screencapture.plist
# └── NSGlobalDomain.plist
```

### 手动备份和恢复

```bash
# 备份特定域的设置
backup_domain_defaults "com.apple.dock"
backup_domain_defaults "com.apple.finder"

# 恢复所有设置
restore_system_defaults

# 恢复特定域的设置
restore_domain_defaults "com.apple.dock" "/path/to/backup.plist"
```

### 重置系统配置

```bash
# 完全重置到初始状态
reset_system_configuration

# 这会提示确认并恢复所有备份的设置
```

## 高级用法

### 条件化配置

```bash
# 根据系统版本应用不同配置
configure_conditional() {
    local macos_version
    macos_version=$(sw_vers -productVersion)
    
    if [[ "$(printf '%s\n' "12.0" "$macos_version" | sort -V | head -n1)" == "12.0" ]]; then
        # macOS 12+ 特有设置
        apply_defaults_config "com.apple.dock" "new-feature" "bool" "true"
    fi
    
    # M1 Mac 特有设置
    if [[ "$(uname -m)" == "arm64" ]]; then
        apply_defaults_config "com.apple.some-app" "arm64-optimization" "bool" "true"
    fi
}
```

### 批量配置应用

```bash
# 定义配置数组
declare -a dock_configs=(
    "tilesize:int:48"
    "autohide:bool:true"
    "orientation:string:bottom"
    "magnification:bool:true"
    "largesize:int:64"
)

# 批量应用配置
apply_dock_configs() {
    for config in "${dock_configs[@]}"; do
        IFS=':' read -r key type value <<< "$config"
        apply_defaults_config "com.apple.dock" "$key" "$type" "$value"
    done
    killall Dock
}
```

### 配置验证

```bash
# 验证配置是否成功应用
verify_dock_config() {
    local expected_size="48"
    local actual_size
    actual_size=$(defaults read com.apple.dock tilesize 2>/dev/null || echo "0")
    
    if [[ "$actual_size" == "$expected_size" ]]; then
        log_success "Dock 大小配置正确: $actual_size"
        return 0
    else
        log_error "Dock 大小配置错误: 期望 $expected_size，实际 $actual_size"
        return 1
    fi
}

# 验证所有关键配置
verify_system_config() {
    local errors=0
    
    verify_dock_config || ((errors++))
    verify_finder_config || ((errors++))
    verify_screenshot_config || ((errors++))
    
    if [[ $errors -eq 0 ]]; then
        log_success "所有系统配置验证通过"
        return 0
    else
        log_error "系统配置验证失败，$errors 个错误"
        return 1
    fi
}
```

## 故障排除

### 常见问题

#### 1. 配置未生效

```bash
# 手动重启相关服务
sudo killall Dock
sudo killall Finder
sudo killall SystemUIServer

# 注销重新登录
sudo launchctl bootout user/$(id -u)
```

#### 2. 权限问题

```bash
# 检查配置文件权限
ls -la ~/Library/Preferences/com.apple.dock.plist

# 修复权限
chmod 644 ~/Library/Preferences/*.plist
```

#### 3. 恢复默认设置

```bash
# 删除特定应用的配置文件
rm ~/Library/Preferences/com.apple.dock.plist
killall Dock

# 使用 defaults 删除特定设置
defaults delete com.apple.dock tilesize
```

### 调试配置

```bash
# 查看当前设置
defaults read com.apple.dock
defaults read com.apple.finder

# 监控配置变化
defaults read com.apple.dock > before.txt
# 应用配置
defaults read com.apple.dock > after.txt
diff before.txt after.txt
```

### 安全模式配置

```bash
# 在安全模式下应用最小配置
configure_safe_mode() {
    log_info "安全模式：应用最小配置"
    
    # 只应用关键配置
    apply_defaults_config "com.apple.dock" "autohide" "bool" "true"
    apply_defaults_config "com.apple.finder" "ShowPathbar" "bool" "true"
    
    # 跳过可能有问题的配置
    log_warn "跳过高级配置以避免问题"
}
```

## 配置最佳实践

### 1. 渐进式配置

```bash
# 分阶段应用配置，便于排查问题
configure_progressive() {
    configure_dock && log_success "Dock 配置完成"
    configure_finder && log_success "Finder 配置完成"  
    configure_screenshots && log_success "截图配置完成"
    configure_keyboard && log_success "键盘配置完成"
}
```

### 2. 用户确认重要变更

```bash
# 重要配置前询问用户
configure_with_confirmation() {
    if confirm "是否要显示所有隐藏文件"; then
        apply_defaults_config "com.apple.finder" "AppleShowAllFiles" "bool" "true"
    fi
    
    if confirm "是否要启用防火墙"; then
        configure_security
    fi
}
```

### 3. 配置文档化

```bash
# 在配置脚本中添加详细注释
configure_documented() {
    # 设置 Dock 图标大小为 48 像素
    # 这个大小在大多数显示器上都有良好的可读性
    apply_defaults_config "com.apple.dock" "tilesize" "int" "48"
    
    # 启用 Dock 自动隐藏以获得更多屏幕空间
    # 对于小屏幕设备特别有用
    apply_defaults_config "com.apple.dock" "autohide" "bool" "true"
}
```

通过这些详细的使用说明，你可以完全掌控 Mac 系统的各种设置，打造最适合自己的工作环境。