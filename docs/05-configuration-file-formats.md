# Mac Init 配置文件格式说明

## 概述

Mac Init 使用多种格式的配置文件来管理不同类型的设置。本文档详细说明了各种配置文件的格式、语法规则和最佳实践。

## 配置文件类型概览

```
configs/
├── packages/           # 软件包配置（文本格式）
│   ├── homebrew.txt   # Homebrew 包列表
│   ├── cask.txt       # Cask 应用列表
│   └── appstore.txt   # App Store 应用列表
├── profiles/          # 配置方案（Shell 格式）
│   ├── basic.conf     # 基础配置方案
│   ├── developer.conf # 开发者配置方案
│   └── designer.conf  # 设计师配置方案
├── system/            # 系统配置（Shell 脚本）
│   └── defaults.sh    # 系统设置脚本
└── dotfiles/          # 配置文件模板
    ├── .zshrc         # Shell 配置
    ├── .gitconfig     # Git 配置
    └── .vimrc         # Vim 配置
```

## 1. 软件包配置文件

### 1.1 Homebrew 包配置 (`packages/homebrew.txt`)

#### 语法规则

- **每行一个包名**
- **支持行注释** - 使用 `#` 开头
- **支持行尾注释** - 包名后可添加 `#` 注释
- **空行被忽略**
- **行首尾空白会被自动去除**

#### 基本格式

```bash
# Mac Init - Homebrew 包配置
# 语法: 每行一个包名，支持 # 注释

# 基础工具
git                    # 版本控制系统
wget                   # 文件下载工具
curl                   # HTTP 客户端
tree                   # 目录树显示

# 开发工具
node                   # Node.js 运行时
python3                # Python 3
go                     # Go 语言

# 空行会被忽略

# 数据库
postgresql             # PostgreSQL 数据库
redis                  # Redis 缓存
```

#### 高级格式特性

```bash
# 1. 包名只能包含字母、数字、连字符和下划线
valid-package-name     # ✅ 有效
valid_package_name     # ✅ 有效
package123             # ✅ 有效

# 2. 注释可以包含任何字符
chinese-package        # 中文注释也可以 ✅
emacs                  # 编辑器 (Editor) ✅

# 3. 包名后的空白会被忽略
git          # 版本控制 ✅
node              # Node.js ✅

# 4. 无效格式示例（会被跳过或警告）
# invalid package name # ❌ 包名包含空格
# package@version      # ❌ 版本指定（Homebrew 不支持）
```

#### 组织建议

```bash
# ========================================
# Mac Init - 开发者工具包
# 维护者: developer@example.com
# 最后更新: 2024-01-01
# ========================================

# 版本控制
git                    # 分布式版本控制
git-lfs               # Git 大文件支持
gh                    # GitHub 命令行工具

# 编程语言运行时
node                   # Node.js (包含 npm)
python3                # Python 3.x
python@3.11           # 特定版本的 Python
go                     # Go 语言编译器
rust                   # Rust 语言 (包含 cargo)
ruby                   # Ruby 解释器

# 数据库和缓存
postgresql@14          # PostgreSQL 14
mysql@8.0             # MySQL 8.0
redis                  # Redis 内存数据库
sqlite                 # SQLite 数据库

# 开发工具
docker                 # 容器平台
kubernetes-cli         # kubectl 命令
terraform              # 基础设施即代码
ansible                # 自动化配置管理

# 文本处理和网络工具
jq                     # JSON 处理器
yq                     # YAML 处理器
ripgrep                # 快速文本搜索
fd                     # 现代化的 find
bat                    # 带语法高亮的 cat
exa                    # 现代化的 ls
```

### 1.2 Cask 应用配置 (`packages/cask.txt`)

#### 语法规则

与 Homebrew 包配置相同，但包名是 Cask 应用名称。

#### 基本格式

```bash
# Mac Init - Homebrew Cask 应用配置
# 语法: 每行一个 Cask 应用名，支持 # 注释

# 开发工具
visual-studio-code     # 微软代码编辑器
iterm2                 # 终端模拟器
docker                 # Docker Desktop
postman                # API 开发测试工具
sourcetree             # Git 图形界面客户端

# 浏览器
google-chrome          # Google Chrome 浏览器
firefox                # Mozilla Firefox 浏览器
safari-technology-preview  # Safari 技术预览版

# 设计工具
figma                  # 界面设计工具
sketch                 # 矢量图形设计
adobe-creative-cloud   # Adobe 创意套件

# 实用工具
alfred                 # 启动器和效率工具
1password              # 密码管理器
cleanmymac             # 系统清理工具
the-unarchiver         # 解压缩工具
```

#### Cask 应用名称查找

```bash
# 搜索 Cask 应用
brew search --cask "visual studio"
brew search --cask chrome

# 获取应用信息
brew info --cask visual-studio-code

# 列出所有可用的 Cask
brew search --cask | head -20
```

### 1.3 App Store 应用配置 (`packages/appstore.txt`)

#### 语法规则

- **格式**: `应用ID:应用名称`
- **每行一个应用**
- **支持注释** - 使用 `#` 开头的行
- **应用ID必须是数字**
- **应用名称可以包含空格**

#### 基本格式

```bash
# Mac Init - App Store 应用配置
# 语法: App Store ID:应用名称

# 开发工具
497799835:Xcode        # Apple 开发工具
1319778037:iStat Menus # 系统监控工具
1452453066:Hidden Bar  # 菜单栏管理

# 办公软件
409183694:Keynote      # 演示文稿制作
409201541:Pages        # 文档编辑器
409203825:Numbers      # 电子表格

# 实用工具
441258766:Magnet       # 窗口管理器
1518425043:Baking Soda # Safari 扩展管理
904280696:Things 3     # 任务管理

# 媒体工具
1388020431:DevCleaner  # Xcode 缓存清理
1502839586:Hand Mirror # 实时摄像头预览
```

#### 查找 App Store 应用 ID

```bash
# 方法1: 使用 mas 工具搜索
brew install mas
mas search "Xcode"
mas search "iStat Menus"

# 方法2: 从 App Store URL 获取
# https://apps.apple.com/app/xcode/id497799835
# ID 就是 URL 中的数字: 497799835

# 方法3: 列出已安装的应用
mas list
```

#### 应用 ID 验证

```bash
# 验证配置文件格式
validate_appstore_config() {
    local file="$1"
    local line_num=0
    local errors=0
    
    while IFS= read -r line; do
        ((line_num++))
        
        # 跳过注释和空行
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # 验证格式: 数字:名称
        if [[ ! "$line" =~ ^[0-9]+:.+$ ]]; then
            echo "第 $line_num 行格式错误: $line"
            ((errors++))
        fi
    done < "$file"
    
    return $errors
}
```

## 2. 配置方案文件

### 2.1 配置方案格式 (`profiles/*.conf`)

#### 语法规则

- **Shell 变量赋值格式**: `KEY="value"`
- **支持注释** - 使用 `#` 开头的行
- **支持空行**
- **变量名必须大写**
- **字符串值建议用双引号包围**

#### 基本格式

```bash
# Mac Init 配置方案: developer
# 创建时间: 2024-01-01 12:00:00
# 描述: 专为开发者设计的完整配置方案

# ==========================================
# 软件包配置文件
# ==========================================
PACKAGES_FILE="dev-packages.txt"
CASKS_FILE="dev-apps.txt"
APPSTORE_FILE="dev-appstore.txt"

# ==========================================
# 系统配置
# ==========================================
SYSTEM_CONFIG="dev-defaults.sh"
DOTFILES_PRESET="developer"

# ==========================================
# 安装选项
# ==========================================
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
INSTALL_CASKS="true"
INSTALL_APPSTORE="false"
CONFIGURE_SYSTEM="true"
CONFIGURE_DOTFILES="true"

# ==========================================
# 高级选项
# ==========================================
PARALLEL_INSTALL="true"
MAX_PARALLEL_JOBS="4"
SKIP_EXISTING="true"
VERBOSE_OUTPUT="false"

# ==========================================
# 特定配置
# ==========================================
DEVELOPER_MODE="true"
CONFIGURE_SECURITY="true"
USE_CHINA_MIRROR="auto"
```

#### 配置变量详解

##### 基础配置变量

| 变量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `PACKAGES_FILE` | string | `homebrew.txt` | Homebrew 包配置文件 |
| `CASKS_FILE` | string | `cask.txt` | Cask 应用配置文件 |
| `APPSTORE_FILE` | string | `appstore.txt` | App Store 应用配置文件 |
| `SYSTEM_CONFIG` | string | `defaults.sh` | 系统配置脚本 |
| `DOTFILES_PRESET` | string | `basic` | Dotfiles 预设名称 |

##### 安装开关变量

| 变量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `INSTALL_HOMEBREW` | boolean | `true` | 是否安装 Homebrew |
| `INSTALL_PACKAGES` | boolean | `true` | 是否安装命令行工具包 |
| `INSTALL_CASKS` | boolean | `true` | 是否安装 GUI 应用 |
| `INSTALL_APPSTORE` | boolean | `false` | 是否安装 App Store 应用 |
| `CONFIGURE_SYSTEM` | boolean | `true` | 是否配置系统设置 |
| `CONFIGURE_DOTFILES` | boolean | `false` | 是否安装 dotfiles |

##### 性能优化变量

| 变量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `PARALLEL_INSTALL` | boolean | `true` | 是否并行安装 |
| `MAX_PARALLEL_JOBS` | integer | `4` | 最大并发任务数 |
| `SKIP_EXISTING` | boolean | `true` | 跳过已安装的软件 |
| `VERBOSE_OUTPUT` | boolean | `false` | 是否输出详细信息 |

##### 特殊功能变量

| 变量名 | 类型 | 可选值 | 说明 |
|--------|------|--------|------|
| `DEVELOPER_MODE` | boolean | `true/false` | 开发者模式 |
| `CONFIGURE_SECURITY` | boolean | `true/false` | 配置安全设置 |
| `USE_CHINA_MIRROR` | string | `auto/true/false` | 使用国内镜像源 |
| `CUSTOM_SYSTEM_CONFIG` | boolean | `true/false` | 执行自定义系统配置 |

#### 高级配置技巧

##### 条件配置

```bash
# 根据系统架构设置不同的包列表
if [[ "$(uname -m)" == "arm64" ]]; then
    PACKAGES_FILE="packages-m1.txt"
    CASKS_FILE="casks-m1.txt"
else
    PACKAGES_FILE="packages-intel.txt"
    CASKS_FILE="casks-intel.txt"
fi

# 根据 macOS 版本设置
MACOS_VERSION=$(sw_vers -productVersion)
if [[ "$(printf '%s\n' "12.0" "$MACOS_VERSION" | sort -V | head -n1)" == "12.0" ]]; then
    ENABLE_NEW_FEATURES="true"
else
    ENABLE_NEW_FEATURES="false"
fi
```

##### 配置继承

```bash
# 基础配置文件: profiles/base.conf
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
CONFIGURE_SYSTEM="true"
PARALLEL_INSTALL="true"

# 开发者配置文件: profiles/developer.conf
# 继承基础配置
source "$(dirname "${BASH_SOURCE[0]}")/base.conf"

# 开发者特定配置
PACKAGES_FILE="dev-packages.txt"
CASKS_FILE="dev-apps.txt"
DEVELOPER_MODE="true"
INSTALL_APPSTORE="true"
```

##### 环境特定配置

```bash
# 根据用户名或主机名自定义配置
case "$(whoami)" in
    "developer"|"dev")
        PACKAGES_FILE="dev-packages.txt"
        DEVELOPER_MODE="true"
        ;;
    "designer")
        PACKAGES_FILE="design-packages.txt"
        CASKS_FILE="design-apps.txt"
        DEVELOPER_MODE="false"
        ;;
    *)
        PACKAGES_FILE="basic-packages.txt"
        ;;
esac

# 根据网络环境自动选择镜像
if ping -c 1 -W 3000 "github.com" &> /dev/null; then
    USE_CHINA_MIRROR="false"
else
    USE_CHINA_MIRROR="true"
fi
```

## 3. 系统配置脚本

### 3.1 系统配置脚本格式 (`system/*.sh`)

#### 语法规则

- **标准 Bash 脚本格式**
- **必须以 `#!/bin/bash` 开头**
- **建议添加 `set -euo pipefail`**
- **使用 `defaults` 命令配置系统**
- **必须具有执行权限**

#### 基本格式

```bash
#!/bin/bash
# Mac Init - 系统配置脚本
# 描述: 配置 macOS 系统设置

set -euo pipefail

echo "开始应用系统配置..."

# ==========================================
# Dock 配置
# ==========================================
echo "配置 Dock..."

# 设置 Dock 图标大小
defaults write com.apple.dock "tilesize" -int "48"

# 启用自动隐藏
defaults write com.apple.dock "autohide" -bool "true"

# 设置自动隐藏延迟
defaults write com.apple.dock "autohide-delay" -float "0"

# ==========================================
# Finder 配置
# ==========================================
echo "配置 Finder..."

# 显示路径栏
defaults write com.apple.finder "ShowPathbar" -bool "true"

# 显示状态栏
defaults write com.apple.finder "ShowStatusBar" -bool "true"

# 显示所有文件扩展名
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# ==========================================
# 截图配置
# ==========================================
echo "配置截图设置..."

# 创建截图文件夹
mkdir -p ~/Desktop/Screenshots

# 设置截图保存位置
defaults write com.apple.screencapture "location" -string "~/Desktop/Screenshots"

# 设置截图格式
defaults write com.apple.screencapture "type" -string "png"

# ==========================================
# 重启相关服务
# ==========================================
echo "重启系统服务..."

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "系统配置完成！"
```

#### defaults 命令格式

```bash
# 基本语法
defaults write <domain> <key> -<type> <value>

# 数据类型
-bool    true/false          # 布尔值
-int     123                 # 整数
-float   1.5                 # 浮点数
-string  "text"              # 字符串
-array   value1 value2       # 数组
-dict    key1 value1 key2 value2  # 字典

# 示例
defaults write com.apple.dock "tilesize" -int "48"
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.screencapture "location" -string "~/Desktop"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
```

#### 常用系统域 (Domain)

| 域名 | 说明 |
|------|------|
| `com.apple.dock` | Dock 设置 |
| `com.apple.finder` | Finder 设置 |
| `com.apple.screencapture` | 截图设置 |
| `com.apple.Safari` | Safari 浏览器设置 |
| `com.apple.terminal` | 终端设置 |
| `NSGlobalDomain` | 全局系统设置 |
| `com.apple.screensaver` | 屏幕保护程序设置 |

#### 高级脚本示例

```bash
#!/bin/bash
# 高级系统配置脚本

set -euo pipefail

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查函数
check_macos_version() {
    local version
    version=$(sw_vers -productVersion)
    log_info "当前 macOS 版本: $version"
    
    if [[ "$(printf '%s\n' "11.0" "$version" | sort -V | head -n1)" != "11.0" ]]; then
        log_warn "此配置需要 macOS 11.0 或更高版本"
        return 1
    fi
}

# 备份当前设置
backup_settings() {
    local backup_dir="$HOME/.macos-config-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    log_info "备份当前设置到: $backup_dir"
    
    defaults export com.apple.dock "$backup_dir/dock.plist" 2>/dev/null || true
    defaults export com.apple.finder "$backup_dir/finder.plist" 2>/dev/null || true
    
    log_info "备份完成"
}

# 配置 Dock
configure_dock() {
    log_info "配置 Dock..."
    
    # 根据屏幕大小调整图标大小
    local screen_width
    screen_width=$(system_profiler SPDisplaysDataType | grep Resolution | head -1 | awk '{print $2}')
    
    if [[ ${screen_width:-0} -gt 2000 ]]; then
        defaults write com.apple.dock "tilesize" -int "64"
        log_info "大屏幕：设置 Dock 图标大小为 64"
    else
        defaults write com.apple.dock "tilesize" -int "48"
        log_info "标准屏幕：设置 Dock 图标大小为 48"
    fi
    
    # 其他 Dock 设置
    defaults write com.apple.dock "autohide" -bool "true"
    defaults write com.apple.dock "autohide-delay" -float "0.2"
    defaults write com.apple.dock "show-recents" -bool "false"
}

# 配置开发者设置
configure_developer_settings() {
    log_info "配置开发者设置..."
    
    # 显示隐藏文件
    defaults write com.apple.finder "AppleShowAllFiles" -bool "true"
    
    # 显示 Library 文件夹
    chflags nohidden ~/Library
    
    # 禁用 .DS_Store 在网络卷上创建
    defaults write com.apple.desktopservices "DSDontWriteNetworkStores" -bool "true"
    
    # 启用完整键盘访问
    defaults write NSGlobalDomain "AppleKeyboardUIMode" -int "3"
}

# 主函数
main() {
    log_info "开始系统配置..."
    
    # 检查系统版本
    if ! check_macos_version; then
        log_error "系统版本不兼容，退出"
        exit 1
    fi
    
    # 备份设置
    backup_settings
    
    # 应用配置
    configure_dock
    configure_developer_settings
    
    # 重启服务
    log_info "重启系统服务..."
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    
    log_info "系统配置完成！"
    log_warn "某些设置可能需要注销重新登录才能生效"
}

# 执行主函数
main "$@"
```

## 4. 配置文件验证

### 4.1 验证工具

```bash
# 验证软件包配置
validate_package_config() {
    local file="$1"
    local errors=0
    
    while IFS= read -r line; do
        # 跳过注释和空行
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # 提取包名
        local package
        package=$(echo "$line" | cut -d'#' -f1 | sed 's/[[:space:]]*$//')
        
        # 验证包名格式
        if [[ ! "$package" =~ ^[a-zA-Z0-9_@.-]+$ ]]; then
            echo "无效包名: $package"
            ((errors++))
        fi
    done < "$file"
    
    return $errors
}

# 验证配置方案
validate_profile_config() {
    local file="$1"
    local required_vars=("PACKAGES_FILE" "CASKS_FILE" "INSTALL_HOMEBREW")
    local errors=0
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^$var=" "$file"; then
            echo "缺少必需变量: $var"
            ((errors++))
        fi
    done
    
    return $errors
}
```

### 4.2 最佳实践检查

```bash
# 检查配置文件最佳实践
check_config_best_practices() {
    local file="$1"
    local warnings=0
    
    # 检查是否有文件头注释
    if ! head -5 "$file" | grep -q "# Mac Init"; then
        echo "建议添加文件头注释"
        ((warnings++))
    fi
    
    # 检查是否有维护者信息
    if ! grep -q "# 维护者\|# 作者\|# Author\|# Maintainer" "$file"; then
        echo "建议添加维护者信息"
        ((warnings++))
    fi
    
    # 检查包是否有描述注释
    local packages_without_comments=0
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        if [[ ! "$line" =~ \# ]]; then
            ((packages_without_comments++))
        fi
    done < "$file"
    
    if [[ $packages_without_comments -gt 5 ]]; then
        echo "建议为软件包添加描述注释"
        ((warnings++))
    fi
    
    return $warnings
}
```

## 5. 配置模板

### 5.1 最小配置模板

```bash
# configs/profiles/minimal.conf
# 最小化配置方案

PACKAGES_FILE="minimal-packages.txt"
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
INSTALL_CASKS="false"
CONFIGURE_SYSTEM="false"
```

### 5.2 完整配置模板

```bash
# configs/profiles/complete.conf
# 完整功能配置方案
# 维护者: admin@example.com
# 创建时间: 2024-01-01
# 适用于: 高级用户和开发者

# 软件包配置
PACKAGES_FILE="complete-packages.txt"
CASKS_FILE="complete-apps.txt"
APPSTORE_FILE="complete-appstore.txt"

# 系统配置
SYSTEM_CONFIG="complete-defaults.sh"
DOTFILES_PRESET="complete"

# 安装选项 (全部启用)
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
INSTALL_CASKS="true"
INSTALL_APPSTORE="true"
CONFIGURE_SYSTEM="true"
CONFIGURE_DOTFILES="true"

# 性能优化
PARALLEL_INSTALL="true"
MAX_PARALLEL_JOBS="6"
SKIP_EXISTING="true"

# 特殊功能
DEVELOPER_MODE="true"
CONFIGURE_SECURITY="true"
VERBOSE_OUTPUT="true"

# 网络设置
USE_CHINA_MIRROR="auto"
```

这个配置文件格式说明涵盖了 Mac Init 中所有类型配置文件的详细格式、语法规则和最佳实践，帮助用户正确创建和维护配置文件。