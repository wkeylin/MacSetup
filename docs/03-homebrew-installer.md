# MacSetup Homebrew 安装器使用文档

## 概述

Homebrew 安装器是 MacSetup 的核心模块，负责自动安装和管理 Homebrew、命令行工具包、GUI 应用程序等。它支持智能网络检测、并行安装、错误恢复等高级功能。

## 主要功能

### 1. Homebrew 自动安装
- 自动检测系统架构（Intel/Apple Silicon）
- 智能选择安装源（官方源/国内镜像）
- 自动配置环境变量
- 安装验证和健康检查

### 2. 软件包管理
- 批量安装命令行工具
- 批量安装 GUI 应用（Cask）
- 并行安装提升效率
- 智能跳过已安装软件

### 3. 错误处理和恢复
- 网络异常自动重试
- 安装失败详细报告
- 支持断点续传

## 基本使用方法

### 直接调用模块

```bash
# 加载 Homebrew 安装器
source scripts/installers/homebrew.sh

# 检查 Homebrew 是否已安装
if check_homebrew_installed; then
    echo "Homebrew 已安装"
else
    echo "Homebrew 未安装"
fi

# 安装 Homebrew
install_homebrew

# 更新 Homebrew
update_homebrew
```

### 通过主脚本使用

```bash
# 仅安装 Homebrew 相关内容
./init.sh --homebrew-only

# 仅安装命令行工具
./init.sh --packages-only

# 仅安装 GUI 应用
./init.sh --config-only --profile developer
```

## 详细功能说明

### Homebrew 安装

#### 自动检测和安装

```bash
# 完整的 Homebrew 设置流程
setup_homebrew

# 这个函数会执行：
# 1. 检测是否已安装
# 2. 检测系统架构
# 3. 选择最佳安装源
# 4. 执行安装
# 5. 配置环境变量
# 6. 验证安装
```

#### 系统架构检测

Homebrew 安装器会自动检测你的 Mac 架构：

**Apple Silicon (M1/M2)**
- 安装路径：`/opt/homebrew`
- 环境变量：`eval "$(/opt/homebrew/bin/brew shellenv)"`

**Intel 处理器**
- 安装路径：`/usr/local`
- 环境变量：`export PATH="/usr/local/bin:$PATH"`

#### 网络源选择

```bash
# 系统会自动测试网络连接并选择最佳源：

# 测试 GitHub 连接
if curl -m 10 -s "https://api.github.com" &> /dev/null; then
    # 使用官方源
    USE_CHINA_MIRROR=false
else
    # 使用国内镜像源
    USE_CHINA_MIRROR=true
fi
```

**手动设置安装源：**
```bash
# 强制使用官方源
set_homebrew_options true 4 false

# 强制使用国内镜像
set_homebrew_options true 4 true

# 自动选择（默认）
set_homebrew_options true 4 auto
```

### 软件包安装

#### 安装命令行工具

```bash
# 使用默认配置文件安装
install_homebrew_packages

# 使用自定义配置文件
install_homebrew_packages "configs/packages/my-packages.txt"

# 安装单个包
install_package "git"
install_package "node" true  # 强制重新安装
```

**配置文件格式：**
```bash
# configs/packages/homebrew.txt
git                    # 版本控制
node                   # Node.js
python3                # Python 3
wget                   # 下载工具
tree                   # 目录树
```

#### 安装 GUI 应用

```bash
# 批量安装 Cask 应用
install_homebrew_casks

# 使用自定义配置文件
install_homebrew_casks "configs/packages/my-casks.txt"

# 安装单个应用
install_cask "visual-studio-code"
install_cask "google-chrome" true  # 强制重新安装
```

**配置文件格式：**
```bash
# configs/packages/cask.txt
visual-studio-code     # 代码编辑器
google-chrome          # 浏览器
docker                 # 容器平台
iterm2                 # 终端
```

### 并行安装优化

#### 配置并行安装

```bash
# 设置并行安装选项
set_homebrew_options true 6 auto
# 参数说明：
# - 第1个参数：是否启用并行安装 (true/false)
# - 第2个参数：最大并发数 (推荐 2-8)
# - 第3个参数：是否使用国内镜像 (true/false/auto)
```

#### 并行安装策略

```bash
# 小于等于3个包：串行安装
packages=("git" "wget" "curl")
install_packages_serial "${packages[@]}"

# 大于3个包：并行安装
packages=("git" "node" "python3" "go" "rust" "docker")
install_packages_parallel "${packages[@]}"
```

#### 性能优化建议

```bash
# 根据网络情况调整并发数
if ping -c 1 -W 3000 "brew.sh" &> /dev/null; then
    # 网络良好，使用更高并发
    MAX_PARALLEL_JOBS=6
else
    # 网络一般，使用较低并发
    MAX_PARALLEL_JOBS=2
fi
```

## 高级功能

### 状态检查和验证

#### 检查软件是否已安装

```bash
# 检查 Homebrew 包
if is_package_installed "git"; then
    echo "Git 已安装"
fi

# 检查 Cask 应用
if is_cask_installed "visual-studio-code"; then
    echo "VS Code 已安装"
fi

# 批量检查
packages=("git" "node" "python3")
for package in "${packages[@]}"; do
    if is_package_installed "$package"; then
        echo "✅ $package 已安装"
    else
        echo "❌ $package 未安装"
    fi
done
```

#### Homebrew 健康检查

```bash
# 验证 Homebrew 安装
verify_homebrew_installation

# 这会检查：
# 1. brew 可执行文件是否存在
# 2. brew doctor 是否通过
# 3. 能否正常获取版本信息
```

#### 更新和维护

```bash
# 更新 Homebrew 本身
update_homebrew

# 更新所有已安装的包
brew upgrade

# 清理旧版本
brew cleanup

# 检查系统状态
brew doctor
```

### 错误处理和恢复

#### 网络异常处理

```bash
# 下载文件时的重试机制
download_file "https://example.com/file.tar.gz" "/tmp/file.tar.gz" 3
# 参数说明：
# - URL
# - 本地路径  
# - 最大重试次数（默认3次）
```

#### 安装失败处理

```bash
# 安装失败时的处理流程
install_package_with_retry() {
    local package="$1"
    local max_retries=3
    
    for ((i=1; i<=max_retries; i++)); do
        if install_package "$package"; then
            log_success "包安装成功: $package"
            return 0
        else
            log_warn "包安装失败 (尝试 $i/$max_retries): $package"
            if [[ $i -lt $max_retries ]]; then
                sleep 5
                # 清理可能的损坏状态
                brew uninstall "$package" 2>/dev/null || true
            fi
        fi
    done
    
    log_error "包安装最终失败: $package"
    return 1
}
```

#### 权限问题解决

```bash
# 修复 Homebrew 权限问题
fix_homebrew_permissions() {
    local homebrew_prefix
    homebrew_prefix="$(brew --prefix)"
    
    # 修复目录权限
    sudo chown -R "$(whoami)" "$homebrew_prefix"
    
    # 修复关键目录
    chmod u+w "$homebrew_prefix/bin"
    chmod u+w "$homebrew_prefix/lib"
    chmod u+w "$homebrew_prefix/share"
}
```

## 自定义和扩展

### 自定义安装源

```bash
# 自定义 Homebrew 安装脚本
CUSTOM_INSTALL_URL="https://your-custom-mirror.com/install.sh"

install_homebrew_custom() {
    local install_cmd="curl -fsSL '$CUSTOM_INSTALL_URL' | bash"
    log_info "使用自定义源安装 Homebrew"
    
    if eval "$install_cmd"; then
        log_success "Homebrew 安装完成"
        setup_homebrew_environment
        return 0
    else
        log_error "Homebrew 安装失败"
        return 1
    fi
}
```

### 添加自定义包源

```bash
# 添加第三方 tap
add_custom_taps() {
    local taps=(
        "homebrew/cask-fonts"
        "homebrew/cask-drivers"
        "mongodb/brew"
        "hashicorp/tap"
    )
    
    for tap in "${taps[@]}"; do
        log_info "添加 tap: $tap"
        brew tap "$tap"
    done
}

# 在安装前添加 tap
install_with_custom_taps() {
    add_custom_taps
    install_homebrew_packages
}
```

### 条件化安装

```bash
# 根据系统版本条件安装
install_conditional_packages() {
    local macos_version
    macos_version=$(sw_vers -productVersion)
    
    # macOS 12+ 特有的包
    if [[ "$(printf '%s\n' "12.0" "$macos_version" | sort -V | head -n1)" == "12.0" ]]; then
        install_package "some-new-package"
    fi
    
    # Apple Silicon 特有的包
    if [[ "$(uname -m)" == "arm64" ]]; then
        install_package "arm-specific-tool"
    fi
}
```

## 实际使用示例

### 开发环境快速搭建

```bash
#!/bin/bash
# 快速搭建开发环境

source scripts/installers/homebrew.sh

# 1. 安装 Homebrew
log_step_start "搭建开发环境"
install_homebrew

# 2. 安装基础开发工具
dev_packages=(
    "git"
    "node"
    "python3"
    "go"
    "docker"
    "kubectl"
    "terraform"
)

install_packages_parallel "${dev_packages[@]}"

# 3. 安装开发应用
dev_apps=(
    "visual-studio-code"
    "iterm2"
    "docker"
    "postman"
    "sourcetree"
)

install_homebrew_casks_from_array "${dev_apps[@]}"

log_step_complete "搭建开发环境"
```

### 媒体工作站配置

```bash
#!/bin/bash
# 媒体工作站配置

source scripts/installers/homebrew.sh

# 媒体处理工具
media_packages=(
    "ffmpeg"
    "imagemagick"
    "youtube-dl"
    "exiftool"
)

# 媒体应用
media_apps=(
    "adobe-creative-cloud"
    "final-cut-pro"
    "logic-pro"
    "sketch"
    "figma"
)

install_homebrew
install_packages_parallel "${media_packages[@]}"
install_casks_from_array "${media_apps[@]}"
```

### 批量安装助手函数

```bash
# 从数组安装 Cask 应用
install_casks_from_array() {
    local casks=("$@")
    local failed_casks=()
    
    for cask in "${casks[@]}"; do
        if ! install_cask "$cask"; then
            failed_casks+=("$cask")
        fi
    done
    
    if [[ ${#failed_casks[@]} -gt 0 ]]; then
        log_error "以下应用安装失败: ${failed_casks[*]}"
        return 1
    fi
    
    return 0
}

# 交互式包选择
interactive_package_selection() {
    local all_packages=(
        "git:版本控制"
        "node:Node.js运行时"
        "python3:Python编程语言"
        "go:Go编程语言"
        "docker:容器平台"
        "kubectl:Kubernetes管理工具"
    )
    
    local selected_packages=()
    
    echo "请选择要安装的软件包："
    for i in "${!all_packages[@]}"; do
        IFS=':' read -r package desc <<< "${all_packages[i]}"
        if confirm "安装 $package ($desc)" "y"; then
            selected_packages+=("$package")
        fi
    done
    
    if [[ ${#selected_packages[@]} -gt 0 ]]; then
        install_packages_parallel "${selected_packages[@]}"
    fi
}
```

## 故障排除

### 常见问题和解决方案

#### 1. Homebrew 安装失败

```bash
# 问题：网络连接超时
# 解决：使用国内镜像
set_homebrew_options true 4 true
install_homebrew

# 问题：权限不足
# 解决：修复目录权限
sudo chown -R $(whoami) /opt/homebrew  # Apple Silicon
sudo chown -R $(whoami) /usr/local     # Intel
```

#### 2. 包安装失败

```bash
# 问题：包不存在
# 解决：搜索正确的包名
brew search package-name

# 问题：依赖冲突
# 解决：强制重新安装
brew uninstall package-name
brew install package-name

# 问题：缓存损坏
# 解决：清理缓存
brew cleanup -s
```

#### 3. Cask 应用安装问题

```bash
# 问题：需要密码确认
# 解决：确保以管理员身份运行

# 问题：应用已损坏
# 解决：卸载后重新安装
brew uninstall --cask app-name
brew install --cask app-name

# 问题：quarantine 属性
# 解决：移除 quarantine
sudo xattr -r -d com.apple.quarantine /Applications/AppName.app
```

### 调试模式

```bash
# 启用详细日志
export HOMEBREW_VERBOSE=1
export HOMEBREW_DEBUG=1

# 使用调试模式安装
./init.sh --verbose --log-file debug.log --packages-only

# 查看详细错误信息
tail -f logs/debug.log
```

### 性能监控

```bash
# 监控安装进度
monitor_installation() {
    local start_time=$(date +%s)
    
    # 在后台运行安装
    install_homebrew_packages &
    local install_pid=$!
    
    # 监控进度
    while kill -0 $install_pid 2>/dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        echo "安装进行中... 已用时 ${elapsed}s"
        sleep 10
    done
    
    wait $install_pid
    local exit_code=$?
    
    local total_time=$(($(date +%s) - start_time))
    log_info "安装完成，总耗时: ${total_time}s"
    
    return $exit_code
}
```

这个文档涵盖了 Homebrew 安装器的所有主要功能和使用方法，包括基础用法、高级功能、自定义扩展和故障排除。用户可以根据需要选择合适的功能来自动化 Mac 软件安装过程。