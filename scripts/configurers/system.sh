#!/bin/bash

# =============================================================================
# MacSetup - 系统配置器
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
# 系统配置常量
# =============================================================================

readonly MACOS_DEFAULTS_DOMAINS=(
    "com.apple.dock"
    "com.apple.finder"
    "com.apple.screencapture"
    "com.apple.Safari"
    "com.apple.terminal"
    "NSGlobalDomain"
)

# 需要重启的服务
readonly RESTART_SERVICES=(
    "Dock"
    "Finder"
    "SystemUIServer"
)

# 全局变量
BACKUP_DEFAULTS_DIR=""
APPLIED_CONFIGS=()
FAILED_CONFIGS=()

# =============================================================================
# 系统配置备份和恢复
# =============================================================================

# 初始化系统配置备份
init_system_backup() {
    BACKUP_DEFAULTS_DIR="$BACKUP_DIR/system-defaults"
    safe_mkdir "$BACKUP_DEFAULTS_DIR"
    
    log_step_start "备份当前系统配置"
    
    for domain in "${MACOS_DEFAULTS_DOMAINS[@]}"; do
        backup_domain_defaults "$domain"
    done
    
    log_step_complete "备份当前系统配置"
}

# 备份指定域的配置
backup_domain_defaults() {
    local domain="$1"
    local backup_file="$BACKUP_DEFAULTS_DIR/${domain}.plist"
    
    log_debug "备份域配置: $domain"
    
    if defaults export "$domain" "$backup_file" 2>/dev/null; then
        log_success "备份成功: $domain -> $backup_file"
    else
        log_warn "备份失败: $domain (可能是空配置)"
    fi
}

# 恢复系统配置
restore_system_defaults() {
    if [[ ! -d "$BACKUP_DEFAULTS_DIR" ]]; then
        log_error "备份目录不存在: $BACKUP_DEFAULTS_DIR"
        return 1
    fi
    
    log_step_start "恢复系统配置"
    
    for plist_file in "$BACKUP_DEFAULTS_DIR"/*.plist; do
        if [[ -f "$plist_file" ]]; then
            local domain
            domain=$(basename "$plist_file" .plist)
            restore_domain_defaults "$domain" "$plist_file"
        fi
    done
    
    restart_affected_services
    log_step_complete "恢复系统配置"
}

# 恢复指定域的配置
restore_domain_defaults() {
    local domain="$1"
    local plist_file="$2"
    
    log_info "恢复域配置: $domain"
    
    if defaults import "$domain" "$plist_file" 2>/dev/null; then
        log_success "恢复成功: $domain"
    else
        log_error "恢复失败: $domain"
    fi
}

# =============================================================================
# Dock 配置
# =============================================================================

# 配置 Dock
configure_dock() {
    log_step_start "配置 Dock"
    
    local configs=(
        "设置 Dock 图标大小为 48 像素:tilesize:int:48"
        "启用 Dock 自动隐藏:autohide:bool:true"
        "设置 Dock 自动隐藏延迟为 0 秒:autohide-delay:float:0"
        "设置 Dock 自动隐藏动画速度:autohide-time-modifier:float:0.5"
        "在 Dock 中显示最近使用的应用:show-recents:bool:false"
        "启用 Dock 放大效果:magnification:bool:true"
        "设置 Dock 放大大小:largesize:int:64"
        "将 Dock 置于屏幕底部:orientation:string:bottom"
        "设置 Dock 最小化效果为缩放:mineffect:string:scale"
    )
    
    for config in "${configs[@]}"; do
        apply_dock_config "$config"
    done
    
    log_step_complete "配置 Dock"
}

# 应用单个 Dock 配置
apply_dock_config() {
    local config="$1"
    local description key type value
    
    IFS=':' read -r description key type value <<< "$config"
    
    log_info "$description"
    
    if apply_defaults_config "com.apple.dock" "$key" "$type" "$value"; then
        APPLIED_CONFIGS+=("Dock: $description")
    else
        FAILED_CONFIGS+=("Dock: $description")
    fi
}

# =============================================================================
# Finder 配置
# =============================================================================

# 配置 Finder
configure_finder() {
    log_step_start "配置 Finder"
    
    local configs=(
        "显示路径栏:ShowPathbar:bool:true"
        "显示状态栏:ShowStatusBar:bool:true"
        "显示标签页栏:ShowTabView:bool:true"
        "在标题栏显示完整路径:_FXShowPosixPathInTitle:bool:true"
        "默认搜索当前文件夹:FXDefaultSearchScope:string:SCcf"
        "禁用扩展名更改警告:FXEnableExtensionChangeWarning:bool:false"
        "显示隐藏文件:AppleShowAllFiles:bool:true"
        "在桌面显示硬盘:ShowHardDrivesOnDesktop:bool:true"
        "在桌面显示外部硬盘:ShowExternalHardDrivesOnDesktop:bool:true"
        "在桌面显示可移动媒体:ShowRemovableMediaOnDesktop:bool:true"
    )
    
    for config in "${configs[@]}"; do
        apply_finder_config "$config"
    done
    
    # 全局 Finder 设置
    log_info "显示所有文件扩展名"
    if apply_defaults_config "NSGlobalDomain" "AppleShowAllExtensions" "bool" "true"; then
        APPLIED_CONFIGS+=("Finder: 显示所有文件扩展名")
    else
        FAILED_CONFIGS+=("Finder: 显示所有文件扩展名")
    fi
    
    log_step_complete "配置 Finder"
}

# 应用单个 Finder 配置
apply_finder_config() {
    local config="$1"
    local description key type value
    
    IFS=':' read -r description key type value <<< "$config"
    
    log_info "$description"
    
    if apply_defaults_config "com.apple.finder" "$key" "$type" "$value"; then
        APPLIED_CONFIGS+=("Finder: $description")
    else
        FAILED_CONFIGS+=("Finder: $description")
    fi
}

# =============================================================================
# 截图和媒体配置
# =============================================================================

# 配置截图设置
configure_screenshots() {
    log_step_start "配置截图设置"
    
    local configs=(
        "设置截图保存位置为桌面:location:string:${HOME}/Desktop"
        "设置截图格式为 PNG:type:string:png"
        "禁用截图阴影:disable-shadow:bool:true"
        "在截图文件名中包含日期:include-date:bool:true"
    )
    
    for config in "${configs[@]}"; do
        apply_screenshot_config "$config"
    done
    
    log_step_complete "配置截图设置"
}

# 应用单个截图配置
apply_screenshot_config() {
    local config="$1"
    local description key type value
    
    IFS=':' read -r description key type value <<< "$config"
    
    log_info "$description"
    
    if apply_defaults_config "com.apple.screencapture" "$key" "$type" "$value"; then
        APPLIED_CONFIGS+=("截图: $description")
    else
        FAILED_CONFIGS+=("截图: $description")
    fi
}

# =============================================================================
# 安全和隐私配置
# =============================================================================

# 配置安全设置
configure_security() {
    log_step_start "配置安全设置"
    
    # 防火墙设置
    log_info "启用防火墙"
    if sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on &>/dev/null; then
        log_success "防火墙已启用"
        APPLIED_CONFIGS+=("安全: 启用防火墙")
    else
        log_error "防火墙启用失败"
        FAILED_CONFIGS+=("安全: 启用防火墙")
    fi
    
    # 禁用远程登录 (默认情况下)
    log_info "确保远程登录被禁用"
    if sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist &>/dev/null; then
        log_success "远程登录已禁用"
        APPLIED_CONFIGS+=("安全: 禁用远程登录")
    else
        log_info "远程登录已经是禁用状态"
    fi
    
    # 屏幕保护程序密码
    log_info "启用屏幕保护程序密码"
    if apply_defaults_config "com.apple.screensaver" "askForPassword" "bool" "true"; then
        apply_defaults_config "com.apple.screensaver" "askForPasswordDelay" "int" "0"
        APPLIED_CONFIGS+=("安全: 启用屏幕保护程序密码")
    else
        FAILED_CONFIGS+=("安全: 启用屏幕保护程序密码")
    fi
    
    log_step_complete "配置安全设置"
}

# =============================================================================
# 键盘和触控板配置
# =============================================================================

# 配置键盘设置
configure_keyboard() {
    log_step_start "配置键盘设置"
    
    local configs=(
        "启用全键盘访问:AppleKeyboardUIMode:int:3"
        "设置按键重复速度:KeyRepeat:int:2"
        "设置按键重复延迟:InitialKeyRepeat:int:15"
        "在菜单栏显示输入法:AppleLanguages:array:'(zh-Hans, en)'"
    )
    
    for config in "${configs[@]}"; do
        apply_keyboard_config "$config"
    done
    
    log_step_complete "配置键盘设置"
}

# 应用单个键盘配置
apply_keyboard_config() {
    local config="$1"
    local description key type value
    
    IFS=':' read -r description key type value <<< "$config"
    
    log_info "$description"
    
    if apply_defaults_config "NSGlobalDomain" "$key" "$type" "$value"; then
        APPLIED_CONFIGS+=("键盘: $description")
    else
        FAILED_CONFIGS+=("键盘: $description")
    fi
}

# 配置触控板设置
configure_trackpad() {
    log_step_start "配置触控板设置"
    
    # 启用轻触点击
    log_info "启用触控板轻触点击"
    if apply_defaults_config "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "bool" "true"; then
        apply_defaults_config "NSGlobalDomain" "com.apple.mouse.tapBehavior" "int" "1"
        APPLIED_CONFIGS+=("触控板: 启用轻触点击")
    else
        FAILED_CONFIGS+=("触控板: 启用轻触点击")
    fi
    
    # 启用三指拖拽
    log_info "启用三指拖拽"
    if apply_defaults_config "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerDrag" "bool" "true"; then
        APPLIED_CONFIGS+=("触控板: 启用三指拖拽")
    else
        FAILED_CONFIGS+=("触控板: 启用三指拖拽")
    fi
    
    log_step_complete "配置触控板设置"
}

# =============================================================================
# 开发者设置
# =============================================================================

# 配置开发者相关设置
configure_developer_settings() {
    log_step_start "配置开发者设置"
    
    # 显示 ~/Library 文件夹
    log_info "显示用户 Library 文件夹"
    if chflags nohidden ~/Library 2>/dev/null; then
        log_success "Library 文件夹已显示"
        APPLIED_CONFIGS+=("开发者: 显示 Library 文件夹")
    else
        log_error "显示 Library 文件夹失败"
        FAILED_CONFIGS+=("开发者: 显示 Library 文件夹")
    fi
    
    # 禁用文件扩展名更改警告
    log_info "禁用文件扩展名更改警告"
    if apply_defaults_config "com.apple.finder" "FXEnableExtensionChangeWarning" "bool" "false"; then
        APPLIED_CONFIGS+=("开发者: 禁用扩展名更改警告")
    else
        FAILED_CONFIGS+=("开发者: 禁用扩展名更改警告")
    fi
    
    # 在 Finder 标题栏显示完整路径
    log_info "在 Finder 标题栏显示完整路径"
    if apply_defaults_config "com.apple.finder" "_FXShowPosixPathInTitle" "bool" "true"; then
        APPLIED_CONFIGS+=("开发者: Finder 显示完整路径")
    else
        FAILED_CONFIGS+=("开发者: Finder 显示完整路径")
    fi
    
    # 禁用 .DS_Store 文件在网络卷上创建
    log_info "禁用网络卷上的 .DS_Store 文件"
    if apply_defaults_config "com.apple.desktopservices" "DSDontWriteNetworkStores" "bool" "true"; then
        APPLIED_CONFIGS+=("开发者: 禁用网络 .DS_Store")
    else
        FAILED_CONFIGS+=("开发者: 禁用网络 .DS_Store")
    fi
    
    log_step_complete "配置开发者设置"
}

# =============================================================================
# 核心配置函数
# =============================================================================

# 应用 defaults 配置
apply_defaults_config() {
    local domain="$1"
    local key="$2"
    local type="$3"
    local value="$4"
    
    local cmd="defaults write '$domain' '$key'"
    
    case "$type" in
        "bool")
            cmd="$cmd -bool '$value'"
            ;;
        "int")
            cmd="$cmd -int '$value'"
            ;;
        "float")
            cmd="$cmd -float '$value'"
            ;;
        "string")
            cmd="$cmd -string '$value'"
            ;;
        "array")
            cmd="$cmd -array '$value'"
            ;;
        *)
            log_error "不支持的配置类型: $type"
            return 1
            ;;
    esac
    
    log_debug "执行配置命令: $cmd"
    
    if eval "$cmd" 2>/dev/null; then
        log_debug "配置应用成功: $domain.$key = $value"
        return 0
    else
        log_error "配置应用失败: $domain.$key"
        return 1
    fi
}

# 重启受影响的服务
restart_affected_services() {
    log_step_start "重启系统服务"
    
    for service in "${RESTART_SERVICES[@]}"; do
        log_info "重启服务: $service"
        if killall "$service" 2>/dev/null; then
            log_success "服务重启成功: $service"
        else
            log_warn "服务重启失败或未运行: $service"
        fi
        sleep 1
    done
    
    log_step_complete "重启系统服务"
}

# =============================================================================
# 自定义配置文件执行
# =============================================================================

# 执行自定义配置脚本
execute_custom_config() {
    local config_file="${1:-}"
    
    if [[ -z "$config_file" ]]; then
        config_file=$(get_system_config_file)
    fi
    
    if [[ ! -f "$config_file" ]]; then
        log_warn "系统配置文件不存在: $config_file"
        return 0
    fi
    
    if [[ ! -x "$config_file" ]]; then
        log_warn "系统配置文件不可执行: $config_file"
        chmod +x "$config_file"
    fi
    
    log_step_start "执行自定义系统配置" "文件: $config_file"
    
    if log_command "$config_file" true; then
        log_step_complete "执行自定义系统配置"
        APPLIED_CONFIGS+=("自定义: $(basename "$config_file")")
        return 0
    else
        log_error "自定义配置执行失败: $config_file"
        FAILED_CONFIGS+=("自定义: $(basename "$config_file")")
        return 1
    fi
}

# =============================================================================
# 主要接口函数
# =============================================================================

# 完整的系统配置
configure_system() {
    local config_file="${1:-}"
    
    log_step_start "系统配置"
    
    # 初始化备份
    init_system_backup
    
    # 基础系统配置
    configure_dock
    configure_finder
    configure_screenshots
    configure_keyboard
    configure_trackpad
    
    # 开发者设置
    if [[ "$(get_config 'DEVELOPER_MODE' 'true')" == "true" ]]; then
        configure_developer_settings
    fi
    
    # 安全设置
    if [[ "$(get_config 'CONFIGURE_SECURITY' 'true')" == "true" ]]; then
        configure_security
    fi
    
    # 自定义配置
    if [[ "$(get_config 'CUSTOM_SYSTEM_CONFIG' 'true')" == "true" ]]; then
        execute_custom_config "$config_file"
    fi
    
    # 重启服务
    restart_affected_services
    
    # 显示配置结果
    show_configuration_summary
    
    log_step_complete "系统配置"
}

# 显示配置结果摘要
show_configuration_summary() {
    printf "\n%s=== 系统配置摘要 ===%s\n" "${CYAN}" "${NC}"
    
    if [[ ${#APPLIED_CONFIGS[@]} -gt 0 ]]; then
        printf "%s成功应用的配置 (%d 项):%s\n" "${GREEN}" "${#APPLIED_CONFIGS[@]}" "${NC}"
        for config in "${APPLIED_CONFIGS[@]}"; do
            echo "  ✅ $config"
        done
    fi
    
    if [[ ${#FAILED_CONFIGS[@]} -gt 0 ]]; then
        printf "\n%s失败的配置 (%d 项):%s\n" "${RED}" "${#FAILED_CONFIGS[@]}" "${NC}"
        for config in "${FAILED_CONFIGS[@]}"; do
            echo "  ❌ $config"
        done
    fi
    
    printf "\n%s注意: 某些配置可能需要重启系统或重新登录才能完全生效%s\n" "${YELLOW}" "${NC}"
    printf "%s备份位置: %s%s\n" "${BLUE}" "$BACKUP_DEFAULTS_DIR" "${NC}"
    echo ""
}

# 重置所有系统配置
reset_system_configuration() {
    if [[ ! -d "$BACKUP_DEFAULTS_DIR" ]]; then
        log_error "没有找到配置备份，无法重置"
        return 1
    fi
    
    if ! confirm "确定要重置所有系统配置吗？这将恢复到初始状态" "n"; then
        log_info "用户取消重置操作"
        return 0
    fi
    
    restore_system_defaults
    log_success "系统配置已重置"
}

# =============================================================================
# 交互式配置向导
# =============================================================================

# 交互式系统配置
interactive_system_config() {
    printf "\n%s=== 交互式系统配置 ===%s\n" "${CYAN}" "${NC}"
    
    local options=(
        "完整系统配置 (推荐)"
        "仅配置 Dock"
        "仅配置 Finder"
        "仅配置开发者设置"
        "仅配置安全设置"
        "自定义配置文件"
        "重置系统配置"
        "退出"
    )
    
    show_menu "请选择配置选项:" "${options[@]}"
    local choice
    choice=$(get_choice ${#options[@]})
    
    case $choice in
        1) configure_system ;;
        2) configure_dock && restart_affected_services ;;
        3) configure_finder && restart_affected_services ;;
        4) configure_developer_settings ;;
        5) configure_security ;;
        6) 
            read -p "请输入配置文件路径: " config_file
            execute_custom_config "$config_file"
            ;;
        7) reset_system_configuration ;;
        8) 
            log_info "退出系统配置"
            return 0
            ;;
    esac
    
    show_configuration_summary
}

# =============================================================================
# 导出函数
# =============================================================================

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f configure_system configure_dock configure_finder configure_screenshots
    export -f configure_security configure_keyboard configure_trackpad configure_developer_settings
    export -f execute_custom_config interactive_system_config reset_system_configuration
    export -f apply_defaults_config restart_affected_services show_configuration_summary
fi