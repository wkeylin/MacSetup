# MacSetup 配置管理使用文档

## 概述

配置管理系统是 MacSetup 的核心组件，负责管理软件包列表、系统设置、配置方案等。它提供了灵活的配置方式，支持预设方案和完全自定义。

## 配置文件结构

```
configs/
├── packages/          # 软件包配置
│   ├── homebrew.txt   # Homebrew 包列表
│   ├── cask.txt       # Cask 应用列表
│   └── appstore.txt   # App Store 应用列表
├── dotfiles/          # 配置文件模板
│   ├── .zshrc
│   ├── .gitconfig
│   └── .vimrc
├── system/            # 系统配置脚本
│   └── defaults.sh
└── profiles/          # 配置方案
    ├── basic.conf
    ├── developer.conf
    └── designer.conf
```

## 配置方案管理

### 查看可用配置方案

```bash
# 方法1：通过主脚本
./init.sh --list-profiles

# 方法2：直接调用配置模块
source scripts/core/config.sh
list_profiles
```

### 创建新的配置方案

```bash
# 交互式创建
./init.sh --profile my-new-profile

# 手动创建配置文件
cat > configs/profiles/my-profile.conf << 'EOF'
# MacSetup 配置方案: my-profile
# 创建时间: 2024-01-01 12:00:00

# 软件包配置文件
PACKAGES_FILE="homebrew.txt"
CASKS_FILE="cask.txt"
APPSTORE_FILE="appstore.txt"

# 系统配置
SYSTEM_CONFIG="defaults.sh"
DOTFILES_PRESET="basic"

# 安装选项
INSTALL_HOMEBREW="true"
INSTALL_CASKS="true"
INSTALL_APPSTORE="false"
CONFIGURE_SYSTEM="true"
CONFIGURE_DOTFILES="true"

# 高级选项
PARALLEL_INSTALL="true"
SKIP_EXISTING="true"
VERBOSE_OUTPUT="false"
DEVELOPER_MODE="true"
CONFIGURE_SECURITY="true"
EOF
```

### 配置方案参数详解

#### 基本软件包配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `PACKAGES_FILE` | `homebrew.txt` | Homebrew 包配置文件 |
| `CASKS_FILE` | `cask.txt` | Cask 应用配置文件 |
| `APPSTORE_FILE` | `appstore.txt` | App Store 应用配置文件 |

```bash
# 使用自定义包列表
PACKAGES_FILE="my-packages.txt"
CASKS_FILE="my-apps.txt"

# 使用绝对路径
PACKAGES_FILE="/path/to/custom/packages.txt"
```

#### 系统配置选项

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `SYSTEM_CONFIG` | `defaults.sh` | 系统配置脚本 |
| `DOTFILES_PRESET` | `basic` | Dotfiles 预设 |

#### 安装开关选项

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `INSTALL_HOMEBREW` | `true` | 是否安装 Homebrew |
| `INSTALL_PACKAGES` | `true` | 是否安装命令行工具 |
| `INSTALL_CASKS` | `true` | 是否安装 GUI 应用 |
| `INSTALL_APPSTORE` | `false` | 是否安装 App Store 应用 |
| `CONFIGURE_SYSTEM` | `true` | 是否配置系统设置 |
| `CONFIGURE_DOTFILES` | `false` | 是否安装 dotfiles |

#### 高级选项

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `PARALLEL_INSTALL` | `true` | 是否并行安装 |
| `MAX_PARALLEL_JOBS` | `4` | 最大并发数 |
| `SKIP_EXISTING` | `true` | 跳过已安装的软件 |
| `VERBOSE_OUTPUT` | `false` | 详细输出 |
| `DEVELOPER_MODE` | `false` | 开发者模式 |
| `CONFIGURE_SECURITY` | `true` | 配置安全设置 |
| `USE_CHINA_MIRROR` | `auto` | 使用国内镜像 |

### 加载和使用配置方案

```bash
# 在脚本中加载配置方案
source scripts/core/config.sh
load_profile "developer"

# 获取配置值
packages_file=$(get_config "PACKAGES_FILE" "homebrew.txt")
install_homebrew=$(get_config "INSTALL_HOMEBREW" "true")

# 显示当前配置
show_current_config
```

## 软件包配置

### Homebrew 包配置 (`packages/homebrew.txt`)

**格式规则：**
- 每行一个包名
- 支持 `#` 注释
- 空行被忽略
- 包名后可添加注释说明

**示例：**
```bash
# 基础工具
git                    # 版本控制系统
wget                   # 文件下载工具
curl                   # HTTP 客户端
tree                   # 目录树显示
htop                   # 系统监控

# 开发工具
node                   # Node.js 运行时
python3                # Python 3
go                     # Go 语言
rust                   # Rust 语言
docker                 # 容器平台

# 数据库
postgresql             # PostgreSQL 数据库
redis                  # Redis 缓存
mysql                  # MySQL 数据库

# 网络工具
nmap                   # 网络扫描
wireshark              # 网络分析
```

### Cask 应用配置 (`packages/cask.txt`)

**格式规则：**同 Homebrew 包配置

**示例：**
```bash
# 开发工具
visual-studio-code     # 代码编辑器
iterm2                 # 终端模拟器
docker                 # Docker Desktop
postman                # API 测试工具
sourcetree             # Git 图形界面

# 浏览器
google-chrome          # Chrome 浏览器
firefox                # Firefox 浏览器
safari-technology-preview  # Safari 技术预览版

# 设计工具
figma                  # 界面设计
sketch                 # 矢量图设计
adobe-creative-cloud   # Adobe 创意套件

# 实用工具
alfred                 # 效率工具
1password              # 密码管理
cleanmymac             # 系统清理
the-unarchiver         # 解压工具
```

### App Store 应用配置 (`packages/appstore.txt`)

**格式规则：**
- 格式：`应用ID:应用名称`
- 支持 `#` 注释
- 需要先安装 `mas` 命令行工具

**示例：**
```bash
# 开发工具
497799835:Xcode        # Apple 开发工具
1319778037:iStat Menus # 系统监控

# 办公软件
409183694:Keynote      # 演示文稿
409201541:Pages        # 文档编辑
409203825:Numbers      # 电子表格

# 实用工具
441258766:Magnet       # 窗口管理
1482454543:Twitter     # 社交媒体
```

**获取 App Store 应用 ID：**
```bash
# 安装 mas 工具
brew install mas

# 搜索应用获取 ID
mas search Xcode
mas search "iStat Menus"

# 列出已安装的应用
mas list
```

## 系统配置

### 系统配置脚本 (`system/defaults.sh`)

这是一个可执行的 bash 脚本，用于配置 macOS 系统设置。

**基本结构：**
```bash
#!/bin/bash
# 系统配置脚本

echo "开始应用系统配置..."

# Dock 设置
defaults write com.apple.dock "tilesize" -int "48"
defaults write com.apple.dock "autohide" -bool "true"

# Finder 设置
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "ShowStatusBar" -bool "true"

# 重启相关服务
killall Dock
killall Finder

echo "系统配置完成！"
```

**常用系统配置：**

#### Dock 配置
```bash
# 设置 Dock 图标大小
defaults write com.apple.dock "tilesize" -int "48"

# 启用 Dock 自动隐藏
defaults write com.apple.dock "autohide" -bool "true"

# 设置 Dock 位置（left/bottom/right）
defaults write com.apple.dock "orientation" -string "bottom"

# 禁用最近使用的应用
defaults write com.apple.dock "show-recents" -bool "false"

# 启用放大效果
defaults write com.apple.dock "magnification" -bool "true"
defaults write com.apple.dock "largesize" -int "64"
```

#### Finder 配置
```bash
# 显示路径栏
defaults write com.apple.finder "ShowPathbar" -bool "true"

# 显示状态栏
defaults write com.apple.finder "ShowStatusBar" -bool "true"

# 显示所有文件扩展名
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# 显示隐藏文件
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"

# 在标题栏显示完整路径
defaults write com.apple.finder "_FXShowPosixPathInTitle" -bool "true"
```

#### 截图配置
```bash
# 设置截图保存位置
defaults write com.apple.screencapture "location" -string "~/Desktop/Screenshots"

# 设置截图格式
defaults write com.apple.screencapture "type" -string "png"

# 禁用截图阴影
defaults write com.apple.screencapture "disable-shadow" -bool "true"
```

#### 键盘和鼠标配置
```bash
# 设置按键重复速度
defaults write NSGlobalDomain "KeyRepeat" -int "2"
defaults write NSGlobalDomain "InitialKeyRepeat" -int "15"

# 启用触控板轻触点击
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad "Clicking" -bool "true"
defaults write NSGlobalDomain "com.apple.mouse.tapBehavior" -int "1"

# 启用三指拖拽
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad "TrackpadThreeFingerDrag" -bool "true"
```

## 配置验证

### 验证配置文件

```bash
# 验证软件包配置
source scripts/core/config.sh
validate_config "configs/packages/homebrew.txt" "package"

# 验证 App Store 配置
validate_config "configs/packages/appstore.txt" "appstore"

# 验证配置方案
validate_config "configs/profiles/developer.conf" "profile"
```

### 解析配置文件

```bash
# 解析软件包列表
packages=($(parse_package_list "configs/packages/homebrew.txt"))
echo "找到 ${#packages[@]} 个软件包: ${packages[*]}"

# 解析 App Store 应用
apps=($(parse_appstore_list "configs/packages/appstore.txt"))
for app in "${apps[@]}"; do
    IFS=':' read -r app_id app_name <<< "$app"
    echo "应用: $app_name (ID: $app_id)"
done
```

## 高级配置技巧

### 条件配置

```bash
# 在配置方案中使用条件
if [[ "$(uname -m)" == "arm64" ]]; then
    PACKAGES_FILE="homebrew-m1.txt"
else
    PACKAGES_FILE="homebrew-intel.txt"
fi
```

### 环境特定配置

```bash
# 根据用户名或主机名使用不同配置
case "$(whoami)" in
    "developer")
        PACKAGES_FILE="dev-packages.txt"
        DEVELOPER_MODE="true"
        ;;
    "designer")
        PACKAGES_FILE="design-packages.txt"
        CASKS_FILE="design-apps.txt"
        ;;
esac
```

### 配置继承

```bash
# 基础配置方案
cat > configs/profiles/base.conf << 'EOF'
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
CONFIGURE_SYSTEM="true"
EOF

# 继承基础配置的开发者方案
cat > configs/profiles/developer.conf << 'EOF'
# 继承基础配置
source "$(dirname "${BASH_SOURCE[0]}")/base.conf"

# 开发者特定配置
PACKAGES_FILE="dev-packages.txt"
CASKS_FILE="dev-apps.txt"
DEVELOPER_MODE="true"
CONFIGURE_SECURITY="true"
EOF
```

## 配置模板

### 最小配置方案

```bash
# configs/profiles/minimal.conf
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
INSTALL_CASKS="false"
INSTALL_APPSTORE="false"
CONFIGURE_SYSTEM="false"
CONFIGURE_DOTFILES="false"
PACKAGES_FILE="minimal-packages.txt"
```

### 完整开发环境配置

```bash
# configs/profiles/full-dev.conf
# 完整开发环境配置
PACKAGES_FILE="dev-packages.txt"
CASKS_FILE="dev-apps.txt"
APPSTORE_FILE="dev-appstore.txt"
SYSTEM_CONFIG="dev-defaults.sh"
DOTFILES_PRESET="developer"

INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
INSTALL_CASKS="true"
INSTALL_APPSTORE="true"
CONFIGURE_SYSTEM="true"
CONFIGURE_DOTFILES="true"

PARALLEL_INSTALL="true"
MAX_PARALLEL_JOBS="6"
DEVELOPER_MODE="true"
CONFIGURE_SECURITY="true"
VERBOSE_OUTPUT="true"
```

### 设计师配置

```bash
# configs/profiles/designer.conf
# 设计师专用配置
PACKAGES_FILE="design-packages.txt"
CASKS_FILE="design-apps.txt"
SYSTEM_CONFIG="design-defaults.sh"

INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
INSTALL_CASKS="true"
INSTALL_APPSTORE="false"
CONFIGURE_SYSTEM="true"
CONFIGURE_DOTFILES="false"

# 设计师可能需要较少的安全限制
CONFIGURE_SECURITY="false"
DEVELOPER_MODE="false"
```

## 配置最佳实践

### 1. 组织配置文件

```bash
# 按用途组织包列表
configs/packages/
├── base-packages.txt      # 基础工具
├── dev-packages.txt       # 开发工具
├── design-packages.txt    # 设计工具
├── media-packages.txt     # 媒体工具
└── gaming-packages.txt    # 游戏相关
```

### 2. 使用描述性注释

```bash
# configs/packages/dev-packages.txt
# ===========================================
# 开发者工具包配置
# 最后更新: 2024-01-01
# 维护者: developer@example.com
# ===========================================

# 版本控制
git                    # 分布式版本控制
git-lfs               # Git 大文件支持

# 语言运行时
node                   # Node.js (包含 npm)
python3                # Python 3.x
go                     # Go 语言
rust                   # Rust 语言 (包含 cargo)
```

### 3. 模块化配置

```bash
# 将大型配置拆分为多个小文件
configs/packages/
├── core.txt           # 核心工具
├── languages.txt      # 编程语言
├── databases.txt      # 数据库
├── devops.txt        # DevOps 工具
└── utilities.txt     # 实用工具

# 在配置方案中组合使用
PACKAGES_FILES="core.txt,languages.txt,databases.txt"
```

### 4. 版本管理

```bash
# 在配置文件中记录版本信息
# configs/profiles/developer.conf
# MacSetup 配置方案: developer
# 版本: 2.1.0
# 兼容性: macOS 11.0+
# 最后测试: 2024-01-01
```

这样就可以灵活地管理各种配置，满足不同用户和场景的需求。