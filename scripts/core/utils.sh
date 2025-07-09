#!/bin/bash

# =============================================================================
# MacSetup - 核心工具函数库
# =============================================================================

set -euo pipefail

# 颜色定义
if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly PURPLE='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m' # No Color
fi

# 全局变量
if [[ -z "${SCRIPT_DIR:-}" ]]; then
    readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
if [[ -z "${BACKUP_DIR:-}" ]]; then
    readonly BACKUP_DIR="$HOME/.macsetup-backup-$(date +%Y%m%d_%H%M%S)"
fi

# =============================================================================
# 系统检查函数
# =============================================================================

# 检查是否为macOS系统
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        printf "${RED}错误: 此脚本仅支持 macOS 系统${NC}\n" >&2
        return 1
    fi
}

# 检查macOS版本
check_macos_version() {
    local min_version=${1:-"10.15"}
    local current_version
    current_version=$(sw_vers -productVersion)
    
    if [[ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" != "$min_version" ]]; then
        printf "${YELLOW}警告: 检测到 macOS $current_version，建议使用 $min_version 及以上版本${NC}\n" >&2
        return 1
    fi
    
    printf "${GREEN}✓ macOS 版本检查通过: $current_version${NC}\n"
    return 0
}

# 检查网络连接
check_network() {
    local test_hosts=("www.apple.com" "brew.sh" "github.com")
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 3000 "$host" &> /dev/null; then
            printf "${GREEN}✓ 网络连接正常${NC}\n"
            return 0
        fi
    done
    
    printf "${RED}错误: 网络连接异常，请检查网络设置${NC}\n" >&2
    return 1
}

# 检查管理员权限
check_sudo() {
    if sudo -n true 2>/dev/null; then
        printf "${GREEN}✓ 管理员权限检查通过${NC}\n"
        return 0
    else
        printf "${YELLOW}提示: 某些操作需要管理员权限${NC}\n"
        return 1
    fi
}

# =============================================================================
# 命令和文件操作函数
# =============================================================================

# 检查命令是否可用
is_command_available() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

# 安全地创建目录
safe_mkdir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        printf "${BLUE}创建目录: $dir${NC}\n"
    fi
}

# 安全地备份文件
backup_file() {
    local file="$1"
    local backup_name="${2:-$(basename "$file")}"
    
    if [[ -e "$file" ]]; then
        safe_mkdir "$BACKUP_DIR"
        cp -R "$file" "$BACKUP_DIR/$backup_name"
        printf "${BLUE}备份文件: $file -> $BACKUP_DIR/$backup_name${NC}\n"
        return 0
    fi
    return 1
}

# 创建符号链接
create_symlink() {
    local source="$1"
    local target="$2"
    local force="${3:-false}"
    
    if [[ ! -e "$source" ]]; then
        printf "${RED}错误: 源文件不存在: $source${NC}\n" >&2
        return 1
    fi
    
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$force" == "true" ]]; then
            backup_file "$target"
            rm -rf "$target"
        else
            printf "${YELLOW}目标已存在: $target${NC}\n"
            return 1
        fi
    fi
    
    ln -sf "$source" "$target"
    printf "${GREEN}✓ 创建符号链接: $source -> $target${NC}\n"
}

# 下载文件
download_file() {
    local url="$1"
    local destination="$2"
    local max_retries="${3:-3}"
    
    for ((i=1; i<=max_retries; i++)); do
        if curl -fsSL "$url" -o "$destination"; then
            printf "${GREEN}✓ 下载完成: $destination${NC}\n"
            return 0
        else
            printf "${YELLOW}下载失败 (尝试 $i/$max_retries): $url${NC}\n"
            [[ $i -lt $max_retries ]] && sleep 2
        fi
    done
    
    printf "${RED}错误: 下载失败: $url${NC}\n" >&2
    return 1
}

# =============================================================================
# 用户交互函数
# =============================================================================

# 询问用户确认
confirm() {
    local prompt="${1:-是否继续}"
    local default="${2:-n}"
    local response
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$prompt [Y/n]: " response
            response=${response:-y}
        else
            read -p "$prompt [y/N]: " response
            response=${response:-n}
        fi
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo "请输入 y 或 n" ;;
        esac
    done
}

# 显示选择菜单
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    printf "\n${CYAN}$title${NC}\n"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[i]}"
    done
    echo
}

# 获取用户选择
get_choice() {
    local max="$1"
    local choice
    
    while true; do
        read -p "请选择 [1-$max]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max" ]; then
            echo "$choice"
            return 0
        else
            printf "${RED}无效选择，请输入 1-$max 之间的数字${NC}\n"
        fi
    done
}

# =============================================================================
# 进度显示函数
# =============================================================================

# 显示进度条
show_progress() {
    local current="$1"
    local total="$2"
    local task="${3:-处理中}"
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r${BLUE}$task${NC} ["
    printf "%*s" $filled | tr ' ' '='
    printf "%*s" $empty | tr ' ' '-'
    printf "] %d%% (%d/%d)" $percent $current $total
}

# 完成进度显示
finish_progress() {
    printf "\n${GREEN}✓ 完成${NC}\n"
}

# =============================================================================
# 清理函数
# =============================================================================

# 清理临时文件
cleanup() {
    local temp_dir="${1:-/tmp/macsetup-*}"
    if ls $temp_dir 1> /dev/null 2>&1; then
        rm -rf $temp_dir
        printf "${BLUE}清理临时文件${NC}\n"
    fi
}

# 设置退出时清理
setup_cleanup() {
    trap cleanup EXIT
}

# =============================================================================
# 导出函数 (供其他脚本使用)
# =============================================================================

# 如果脚本被source，则导出函数
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f check_macos check_macos_version check_network check_sudo
    export -f is_command_available safe_mkdir backup_file create_symlink download_file
    export -f confirm show_menu get_choice show_progress finish_progress
    export -f cleanup setup_cleanup
fi