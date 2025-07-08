#!/bin/bash

# =============================================================================
# MacSetup - 远程配置管理器
# =============================================================================

set -euo pipefail

# 导入核心模块
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# =============================================================================
# 远程配置管理
# =============================================================================

readonly REMOTE_CONFIG_CACHE="$HOME/.macsetup/remote-configs"
readonly CONFIG_REGISTRY="https://raw.githubusercontent.com/macsetup/registry/main/configs.json"

# 下载远程配置文件
download_remote_config() {
    local config_url="$1"
    local local_name="${2:-$(basename "$config_url")}"
    local cache_dir="$REMOTE_CONFIG_CACHE/$(date +%Y%m%d)"
    
    safe_mkdir "$cache_dir"
    
    local local_file="$cache_dir/$local_name"
    
    log_info "下载远程配置: $config_url"
    
    if download_file "$config_url" "$local_file" 3; then
        log_success "配置下载成功: $local_file"
        echo "$local_file"
        return 0
    else
        log_error "配置下载失败: $config_url"
        return 1
    fi
}

# 验证远程配置
validate_remote_config() {
    local config_file="$1"
    
    log_info "验证远程配置安全性..."
    
    # 检查文件是否包含可疑内容
    local suspicious_patterns=(
        "rm -rf"
        "sudo rm"
        "format"
        "del /f"
        ">&2"
        "eval.*curl"
        "bash.*curl"
    )
    
    for pattern in "${suspicious_patterns[@]}"; do
        if grep -i "$pattern" "$config_file" &>/dev/null; then
            log_error "配置文件包含可疑内容: $pattern"
            log_error "为了安全，请手动检查配置文件"
            return 1
        fi
    done
    
    # 验证配置文件格式
    if ! validate_config "$config_file" "profile"; then
        log_error "配置文件格式无效"
        return 1
    fi
    
    log_success "远程配置验证通过"
    return 0
}

# 使用远程配置
use_remote_config() {
    local config_url="$1"
    local force_download="${2:-false}"
    
    # 检查是否是 URL
    if [[ ! "$config_url" =~ ^https?:// ]]; then
        log_error "无效的配置 URL: $config_url"
        return 1
    fi
    
    # 生成缓存文件名
    local cache_name
    cache_name="remote-$(echo "$config_url" | md5sum | cut -d' ' -f1).conf"
    local cached_file="$REMOTE_CONFIG_CACHE/$cache_name"
    
    # 检查缓存
    if [[ -f "$cached_file" && "$force_download" != "true" ]]; then
        local cache_age
        cache_age=$(($(date +%s) - $(stat -f %m "$cached_file" 2>/dev/null || echo 0)))
        
        if [[ $cache_age -lt 3600 ]]; then  # 1小时内的缓存
            log_info "使用缓存的配置文件: $cached_file"
            echo "$cached_file"
            return 0
        fi
    fi
    
    # 下载配置
    local downloaded_file
    downloaded_file=$(download_remote_config "$config_url" "$cache_name")
    
    if [[ -z "$downloaded_file" ]]; then
        return 1
    fi
    
    # 验证配置
    if ! validate_remote_config "$downloaded_file"; then
        rm -f "$downloaded_file"
        return 1
    fi
    
    # 移动到缓存位置
    safe_mkdir "$(dirname "$cached_file")"
    mv "$downloaded_file" "$cached_file"
    
    echo "$cached_file"
    return 0
}

# 列出可用的社区配置
list_community_configs() {
    log_info "获取社区配置列表..."
    
    local registry_file="/tmp/mac-init-registry.json"
    
    if download_file "$CONFIG_REGISTRY" "$registry_file" 2; then
        log_info "可用的社区配置:"
        
        # 解析 JSON 并显示配置
        python3 -c "
import json
import sys

try:
    with open('$registry_file', 'r') as f:
        data = json.load(f)
    
    for config in data.get('configs', []):
        print(f\"  {config['name']} - {config['description']}\")
        print(f\"    作者: {config['author']}\")
        print(f\"    URL: {config['url']}\")
        print()
except Exception as e:
    print(f'解析配置列表失败: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null || {
            log_warn "无法解析配置列表，显示原始内容:"
            cat "$registry_file"
        }
        
        rm -f "$registry_file"
    else
        log_error "无法获取社区配置列表"
        return 1
    fi
}

# 安装社区配置
install_community_config() {
    local config_name="$1"
    
    local registry_file="/tmp/mac-init-registry.json"
    
    if ! download_file "$CONFIG_REGISTRY" "$registry_file" 2; then
        log_error "无法获取配置注册表"
        return 1
    fi
    
    # 查找配置 URL
    local config_url
    config_url=$(python3 -c "
import json

try:
    with open('$registry_file', 'r') as f:
        data = json.load(f)
    
    for config in data.get('configs', []):
        if config['name'] == '$config_name':
            print(config['url'])
            exit(0)
    
    print('配置未找到', file=sys.stderr)
    exit(1)
except Exception as e:
    print(f'错误: {e}', file=sys.stderr)
    exit(1)
" 2>/dev/null)
    
    rm -f "$registry_file"
    
    if [[ -z "$config_url" ]]; then
        log_error "未找到配置: $config_name"
        return 1
    fi
    
    log_info "安装社区配置: $config_name"
    
    local local_config
    local_config=$(use_remote_config "$config_url")
    
    if [[ -n "$local_config" ]]; then
        log_success "配置已准备就绪: $local_config"
        echo "$local_config"
        return 0
    else
        return 1
    fi
}

# 更新所有缓存的远程配置
update_remote_configs() {
    log_info "更新所有远程配置缓存..."
    
    if [[ ! -d "$REMOTE_CONFIG_CACHE" ]]; then
        log_info "没有缓存的远程配置"
        return 0
    fi
    
    local updated=0
    local failed=0
    
    find "$REMOTE_CONFIG_CACHE" -name "*.conf" -type f | while read -r cached_file; do
        local cache_name
        cache_name=$(basename "$cached_file")
        
        # 从文件中提取原始 URL（如果有记录的话）
        local original_url
        original_url=$(grep "# Original URL:" "$cached_file" 2>/dev/null | cut -d' ' -f3- || echo "")
        
        if [[ -n "$original_url" ]]; then
            log_info "更新配置: $cache_name"
            
            if use_remote_config "$original_url" "true" >/dev/null; then
                ((updated++))
                log_success "更新成功: $cache_name"
            else
                ((failed++))
                log_error "更新失败: $cache_name"
            fi
        fi
    done
    
    log_info "配置更新完成: 成功 $updated 个，失败 $failed 个"
}

# 清理远程配置缓存
cleanup_remote_cache() {
    local days_old="${1:-7}"
    
    log_info "清理 $days_old 天前的远程配置缓存..."
    
    if [[ -d "$REMOTE_CONFIG_CACHE" ]]; then
        find "$REMOTE_CONFIG_CACHE" -type f -mtime +$days_old -delete
        find "$REMOTE_CONFIG_CACHE" -type d -empty -delete
        log_success "缓存清理完成"
    fi
}

# =============================================================================
# 主函数接口
# =============================================================================

# 处理远程配置的主要入口
handle_remote_config() {
    local action="$1"
    shift
    
    case "$action" in
        "use")
            use_remote_config "$@"
            ;;
        "list")
            list_community_configs
            ;;
        "install")
            install_community_config "$@"
            ;;
        "update")
            update_remote_configs
            ;;
        "cleanup")
            cleanup_remote_cache "$@"
            ;;
        *)
            log_error "未知操作: $action"
            echo "可用操作: use, list, install, update, cleanup"
            return 1
            ;;
    esac
}

# 导出函数
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f download_remote_config validate_remote_config use_remote_config
    export -f list_community_configs install_community_config update_remote_configs
    export -f cleanup_remote_cache handle_remote_config
fi