#!/bin/bash

# =============================================================================
# MacSetup - Homebrew 安装器
# =============================================================================

set -euo pipefail

# 导入依赖
SCRIPT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -f "$SCRIPT_BASE_DIR/scripts/core/utils.sh" ]]; then
    source "$SCRIPT_BASE_DIR/scripts/core/utils.sh"
fi

if [[ -f "$SCRIPT_BASE_DIR/scripts/core/logger.sh" ]]; then
    source "$SCRIPT_BASE_DIR/scripts/core/logger.sh"
fi

if [[ -f "$SCRIPT_BASE_DIR/scripts/core/config.sh" ]]; then
    source "$SCRIPT_BASE_DIR/scripts/core/config.sh"
fi

# =============================================================================
# Homebrew 配置常量
# =============================================================================

readonly HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
readonly HOMEBREW_CHINA_INSTALL_URL="https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh"
readonly HOMEBREW_PREFIX_INTEL="/usr/local"
readonly HOMEBREW_PREFIX_ARM="/opt/homebrew"

# 全局变量
HOMEBREW_PREFIX=""
HOMEBREW_BIN=""
USE_CHINA_MIRROR=false
PARALLEL_INSTALL=true
MAX_PARALLEL_JOBS=4

# =============================================================================
# Homebrew 检测和初始化
# =============================================================================

# 检测 Homebrew 是否已安装
check_homebrew_installed() {
    if command -v brew &> /dev/null; then
        HOMEBREW_PREFIX="$(brew --prefix)"
        HOMEBREW_BIN="$HOMEBREW_PREFIX/bin/brew"
        log_success "检测到已安装的 Homebrew: $HOMEBREW_PREFIX"
        return 0
    else
        log_info "未检测到 Homebrew"
        return 1
    fi
}

# 检测系统架构并设置 Homebrew 路径
detect_homebrew_prefix() {
    local arch
    arch="$(uname -m)"
    
    case "$arch" in
        "arm64")
            HOMEBREW_PREFIX="$HOMEBREW_PREFIX_ARM"
            log_info "检测到 Apple Silicon (M1/M2)，使用路径: $HOMEBREW_PREFIX"
            ;;
        "x86_64")
            HOMEBREW_PREFIX="$HOMEBREW_PREFIX_INTEL"
            log_info "检测到 Intel 处理器，使用路径: $HOMEBREW_PREFIX"
            ;;
        *)
            log_error "不支持的系统架构: $arch"
            return 1
            ;;
    esac
    
    HOMEBREW_BIN="$HOMEBREW_PREFIX/bin/brew"
}

# 检查网络连接并选择安装源
select_install_source() {
    log_info "检测网络连接和最佳安装源..."
    
    # 测试GitHub连接
    if curl -m 10 -s "https://api.github.com" &> /dev/null; then
        log_success "GitHub 连接正常，使用官方源"
        USE_CHINA_MIRROR=false
        return 0
    fi
    
    # 测试国内镜像连接
    if curl -m 10 -s "https://gitee.com" &> /dev/null; then
        log_warn "GitHub 连接异常，尝试使用国内镜像源"
        USE_CHINA_MIRROR=true
        return 0
    fi
    
    log_error "网络连接异常，无法访问安装源"
    return 1
}

# =============================================================================
# Homebrew 安装
# =============================================================================

# 安装 Homebrew
install_homebrew() {
    if check_homebrew_installed; then
        log_info "Homebrew 已安装，跳过安装步骤"
        return 0
    fi
    
    log_step_start "安装 Homebrew"
    
    # 检测系统架构
    detect_homebrew_prefix
    
    # 选择安装源
    select_install_source
    
    # 执行安装
    local install_cmd
    if [[ "$USE_CHINA_MIRROR" == "true" ]]; then
        install_cmd="curl -fsSL '$HOMEBREW_CHINA_INSTALL_URL' | bash"
        log_info "使用国内镜像安装 Homebrew"
    else
        install_cmd="curl -fsSL '$HOMEBREW_INSTALL_URL' | bash"
        log_info "使用官方源安装 Homebrew"
    fi
    
    # 安装过程
    if eval "$install_cmd"; then
        log_success "Homebrew 安装完成"
    else
        log_error "Homebrew 安装失败"
        return 1
    fi
    
    # 设置环境变量
    setup_homebrew_environment
    
    # 验证安装
    if verify_homebrew_installation; then
        log_step_complete "安装 Homebrew"
        return 0
    else
        log_error "Homebrew 安装验证失败"
        return 1
    fi
}

# 设置 Homebrew 环境变量
setup_homebrew_environment() {
    log_info "设置 Homebrew 环境变量"
    
    # 添加到当前会话
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
    
    # 检查并更新 shell 配置文件
    local shell_config=""
    case "$SHELL" in
        */zsh)
            shell_config="$HOME/.zshrc"
            ;;
        */bash)
            shell_config="$HOME/.bash_profile"
            ;;
        *)
            log_warn "未知的 shell: $SHELL，请手动添加 Homebrew 到 PATH"
            return 1
            ;;
    esac
    
    # 检查是否已经配置
    if [[ -f "$shell_config" ]] && grep -q "homebrew" "$shell_config"; then
        log_info "Homebrew 环境变量已配置: $shell_config"
        return 0
    fi
    
    # 添加配置
    local env_config
    if [[ "$(uname -m)" == "arm64" ]]; then
        env_config='eval "$(/opt/homebrew/bin/brew shellenv)"'
    else
        env_config='export PATH="/usr/local/bin:$PATH"'
    fi
    
    echo "" >> "$shell_config"
    echo "# Homebrew configuration (added by mac-init)" >> "$shell_config"
    echo "$env_config" >> "$shell_config"
    
    log_success "已添加 Homebrew 环境变量到: $shell_config"
}

# 验证 Homebrew 安装
verify_homebrew_installation() {
    log_info "验证 Homebrew 安装"
    
    # 检查 brew 命令
    if [[ -x "$HOMEBREW_BIN" ]]; then
        log_success "brew 可执行文件存在: $HOMEBREW_BIN"
    else
        log_error "brew 可执行文件不存在: $HOMEBREW_BIN"
        return 1
    fi
    
    # 运行 brew doctor
    log_info "运行 brew doctor 检查"
    if "$HOMEBREW_BIN" doctor &> /dev/null; then
        log_success "brew doctor 检查通过"
    else
        log_warn "brew doctor 检查发现问题，但不影响基本使用"
    fi
    
    # 测试基本功能
    local brew_version
    if brew_version="$("$HOMEBREW_BIN" --version 2>/dev/null)"; then
        log_success "Homebrew 版本: $(echo "$brew_version" | head -n1)"
        return 0
    else
        log_error "无法获取 Homebrew 版本信息"
        return 1
    fi
}

# =============================================================================
# 包管理功能
# =============================================================================

# 更新 Homebrew
update_homebrew() {
    log_step_start "更新 Homebrew"
    
    if ! check_homebrew_installed; then
        log_error "Homebrew 未安装"
        return 1
    fi
    
    log_info "正在更新 Homebrew..."
    if log_command "$HOMEBREW_BIN update" true; then
        log_step_complete "更新 Homebrew"
        return 0
    else
        log_error "Homebrew 更新失败"
        return 1
    fi
}

# 检查包是否已安装
is_package_installed() {
    local package="$1"
    "$HOMEBREW_BIN" list --formula "$package" &> /dev/null
}

# 检查 Cask 应用是否已安装
is_cask_installed() {
    local cask="$1"
    "$HOMEBREW_BIN" list --cask "$cask" &> /dev/null
}

# 安装单个包
install_package() {
    local package="$1"
    local force="${2:-false}"
    
    if [[ "$force" != "true" ]] && is_package_installed "$package"; then
        log_info "包已安装，跳过: $package"
        return 0
    fi
    
    log_info "安装包: $package"
    if log_command "$HOMEBREW_BIN install $package"; then
        log_success "包安装成功: $package"
        return 0
    else
        log_error "包安装失败: $package"
        return 1
    fi
}

# 安装单个 Cask 应用
install_cask() {
    local cask="$1"
    local force="${2:-false}"
    
    if [[ "$force" != "true" ]] && is_cask_installed "$cask"; then
        log_info "Cask 应用已安装，跳过: $cask"
        return 0
    fi
    
    log_info "安装 Cask 应用: $cask"
    if log_command "$HOMEBREW_BIN install --cask $cask"; then
        log_success "Cask 应用安装成功: $cask"
        return 0
    else
        log_error "Cask 应用安装失败: $cask"
        return 1
    fi
}

# =============================================================================
# 批量安装功能
# =============================================================================

# 并行安装包
install_packages_parallel() {
    local packages=("$@")
    local pids=()
    local results=()
    local failed_packages=()
    
    log_info "开始并行安装 ${#packages[@]} 个包 (最大并发: $MAX_PARALLEL_JOBS)"
    
    local i=0
    for package in "${packages[@]}"; do
        # 控制并发数
        while [[ ${#pids[@]} -ge $MAX_PARALLEL_JOBS ]]; do
            wait_for_job
        done
        
        # 启动后台安装任务
        (
            if install_package "$package"; then
                echo "SUCCESS:$package"
            else
                echo "FAILED:$package"
            fi
        ) &
        
        pids+=($!)
        ((i++))
        
        log_progress "$i" "${#packages[@]}" "启动安装任务"
    done
    
    # 等待所有任务完成
    log_info "等待所有安装任务完成..."
    for pid in "${pids[@]}"; do
        if wait "$pid"; then
            results+=("SUCCESS")
        else
            results+=("FAILED")
        fi
    done
    
    finish_progress
    
    # 统计结果
    local success_count=0
    local failed_count=0
    
    for result in "${results[@]}"; do
        if [[ "$result" == "SUCCESS" ]]; then
            ((success_count++))
        else
            ((failed_count++))
        fi
    done
    
    log_info "安装完成: 成功 $success_count 个，失败 $failed_count 个"
    
    if [[ $failed_count -gt 0 ]]; then
        log_error "部分包安装失败"
        return 1
    fi
    
    return 0
}

# 等待一个后台任务完成
wait_for_job() {
    local pid="${pids[0]}"
    wait "$pid"
    pids=("${pids[@]:1}")  # 移除第一个元素
}

# 串行安装包
install_packages_serial() {
    local packages=("$@")
    local failed_packages=()
    local total=${#packages[@]}
    local current=0
    
    log_info "开始串行安装 $total 个包"
    
    for package in "${packages[@]}"; do
        ((current++))
        log_progress "$current" "$total" "安装包"
        
        if ! install_package "$package"; then
            failed_packages+=("$package")
        fi
    done
    
    finish_progress
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_error "以下包安装失败: ${failed_packages[*]}"
        return 1
    fi
    
    log_success "所有包安装完成"
    return 0
}

# 批量安装 Homebrew 包
install_homebrew_packages() {
    local config_file="${1:-}"
    
    if [[ -z "$config_file" ]]; then
        config_file=$(get_packages_file)
    fi
    
    if [[ ! -f "$config_file" ]]; then
        log_error "包配置文件不存在: $config_file"
        return 1
    fi
    
    log_step_start "安装 Homebrew 包" "来源: $config_file"
    
    # 解析包列表
    local packages
    packages=($(parse_package_list "$config_file"))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "没有找到要安装的包"
        return 0
    fi
    
    log_info "准备安装 ${#packages[@]} 个包: ${packages[*]}"
    
    # 确认安装
    if ! confirm "是否继续安装这些包" "y"; then
        log_info "用户取消安装"
        return 0
    fi
    
    # 更新 Homebrew
    update_homebrew
    
    # 选择安装方式
    if [[ "$PARALLEL_INSTALL" == "true" && ${#packages[@]} -gt 3 ]]; then
        install_packages_parallel "${packages[@]}"
    else
        install_packages_serial "${packages[@]}"
    fi
    
    local result=$?
    
    if [[ $result -eq 0 ]]; then
        log_step_complete "安装 Homebrew 包"
    else
        log_error "Homebrew 包安装未完全成功"
    fi
    
    return $result
}

# 批量安装 Cask 应用
install_homebrew_casks() {
    local config_file="${1:-}"
    
    if [[ -z "$config_file" ]]; then
        config_file=$(get_casks_file)
    fi
    
    if [[ ! -f "$config_file" ]]; then
        log_error "Cask 配置文件不存在: $config_file"
        return 1
    fi
    
    log_step_start "安装 Homebrew Cask 应用" "来源: $config_file"
    
    # 解析应用列表
    local casks
    casks=($(parse_package_list "$config_file"))
    
    if [[ ${#casks[@]} -eq 0 ]]; then
        log_warn "没有找到要安装的 Cask 应用"
        return 0
    fi
    
    log_info "准备安装 ${#casks[@]} 个应用: ${casks[*]}"
    
    # 确认安装
    if ! confirm "是否继续安装这些应用" "y"; then
        log_info "用户取消安装"
        return 0
    fi
    
    # 串行安装 Cask (避免权限冲突)
    local failed_casks=()
    local total=${#casks[@]}
    local current=0
    
    for cask in "${casks[@]}"; do
        ((current++))
        log_progress "$current" "$total" "安装 Cask 应用"
        
        if ! install_cask "$cask"; then
            failed_casks+=("$cask")
        fi
    done
    
    finish_progress
    
    if [[ ${#failed_casks[@]} -gt 0 ]]; then
        log_error "以下 Cask 应用安装失败: ${failed_casks[*]}"
        log_step_complete "安装 Homebrew Cask 应用" "部分失败"
        return 1
    fi
    
    log_step_complete "安装 Homebrew Cask 应用"
    return 0
}

# =============================================================================
# 主要接口函数
# =============================================================================

# 完整的 Homebrew 设置
setup_homebrew() {
    local packages_file="${1:-}"
    local casks_file="${2:-}"
    
    log_step_start "Homebrew 完整设置"
    
    # 1. 安装 Homebrew
    if ! install_homebrew; then
        log_error "Homebrew 安装失败"
        return 1
    fi
    
    # 2. 安装包
    if [[ "$(get_config 'INSTALL_HOMEBREW' 'true')" == "true" ]]; then
        if ! install_homebrew_packages "$packages_file"; then
            log_warn "Homebrew 包安装部分失败，但继续执行"
        fi
    fi
    
    # 3. 安装 Cask 应用
    if [[ "$(get_config 'INSTALL_CASKS' 'true')" == "true" ]]; then
        if ! install_homebrew_casks "$casks_file"; then
            log_warn "Homebrew Cask 应用安装部分失败，但继续执行"
        fi
    fi
    
    log_step_complete "Homebrew 完整设置"
    log_success "Homebrew 设置完成！"
}

# 设置安装选项
set_homebrew_options() {
    local use_parallel="${1:-true}"
    local max_jobs="${2:-4}"
    local use_china="${3:-auto}"
    
    PARALLEL_INSTALL="$use_parallel"
    MAX_PARALLEL_JOBS="$max_jobs"
    
    if [[ "$use_china" != "auto" ]]; then
        USE_CHINA_MIRROR="$use_china"
    fi
    
    log_info "Homebrew 安装选项已设置"
    log_debug "并行安装: $PARALLEL_INSTALL"
    log_debug "最大并发数: $MAX_PARALLEL_JOBS"
    log_debug "使用国内镜像: $USE_CHINA_MIRROR"
}

# =============================================================================
# 导出函数
# =============================================================================

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f check_homebrew_installed install_homebrew update_homebrew
    export -f install_package install_cask is_package_installed is_cask_installed
    export -f install_homebrew_packages install_homebrew_casks setup_homebrew
    export -f set_homebrew_options verify_homebrew_installation
fi