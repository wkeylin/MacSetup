#!/bin/bash

# =============================================================================
# MacSetup - 主入口脚本
# macOS 自动化配置工具
# =============================================================================

set -euo pipefail

# =============================================================================
# 脚本信息和常量
# =============================================================================

readonly SCRIPT_NAME="MacSetup"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_AUTHOR="MacSetup Team"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 导入核心模块
source "$SCRIPT_DIR/scripts/core/utils.sh"
source "$SCRIPT_DIR/scripts/core/logger.sh"
source "$SCRIPT_DIR/scripts/core/config.sh"
source "$SCRIPT_DIR/scripts/core/remote-config.sh"

# 导入安装器模块
source "$SCRIPT_DIR/scripts/installers/homebrew.sh"

# 导入配置器模块
source "$SCRIPT_DIR/scripts/configurers/system.sh"

# =============================================================================
# 全局变量
# =============================================================================

# 命令行参数
PROFILE=""
PACKAGES_ONLY=false
CONFIG_ONLY=false
DOTFILES_ONLY=false
DRY_RUN=false
VERBOSE=false
INTERACTIVE=true
SKIP_CONFIRMATIONS=false
LOG_FILE=""
CUSTOM_CONFIG=""

# 执行选项
INSTALL_HOMEBREW=true
INSTALL_PACKAGES=true
INSTALL_CASKS=true
INSTALL_APPSTORE=false
CONFIGURE_SYSTEM=true
CONFIGURE_DOTFILES=false

# =============================================================================
# 帮助和版本信息
# =============================================================================

# 显示帮助信息
show_help() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION - macOS 自动化配置工具

用法: $0 [选项]

基本选项:
  -h, --help              显示此帮助信息
  -v, --version           显示版本信息
  -i, --interactive       交互式模式 (默认)
  -y, --yes               跳过所有确认提示

配置选项:
  -p, --profile NAME      使用指定的配置方案
  -c, --config FILE       使用自定义配置文件
  --list-profiles         列出可用的配置方案

执行模式:
  --packages-only         仅安装软件包
  --config-only           仅进行系统配置
  --dotfiles-only         仅安装 dotfiles
  --homebrew-only         仅安装 Homebrew 相关
  --system-only           仅进行系统设置

调试选项:
  --dry-run              预览模式，不实际执行
  --verbose              详细输出
  --log-file FILE        指定日志文件

安装选项:
  --no-homebrew          跳过 Homebrew 安装
  --no-packages          跳过软件包安装
  --no-casks             跳过 Cask 应用安装
  --no-appstore          跳过 App Store 应用安装
  --no-system-config     跳过系统配置
  --enable-appstore      启用 App Store 应用安装

远程配置:
  --remote list          查看可用的社区配置
  --remote use URL       使用指定 URL 的配置
  --remote install NAME  安装指定的社区配置
  --remote update        更新所有远程配置缓存
  --remote cleanup       清理过期的远程配置缓存

示例:
  $0                                    # 交互式安装
  $0 --profile developer                # 使用开发者配置方案
  $0 --packages-only --verbose          # 仅安装软件包，详细输出
  $0 --dry-run --profile basic          # 预览基础配置安装
  $0 --no-system-config --yes           # 跳过系统配置，无确认提示
  $0 --remote list                      # 查看可用的社区配置
  $0 --remote use https://example.com/config.conf  # 使用远程配置

EOF
}

# 显示版本信息
show_version() {
    echo "$SCRIPT_NAME v$SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "系统要求: macOS 10.15+"
}

# =============================================================================
# 命令行参数解析
# =============================================================================

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -y|--yes)
                SKIP_CONFIRMATIONS=true
                INTERACTIVE=false
                shift
                ;;
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -c|--config)
                CUSTOM_CONFIG="$2"
                shift 2
                ;;
            --list-profiles)
                list_profiles
                exit 0
                ;;
            --remote)
                if [[ -n "${2:-}" ]]; then
                    local remote_action="$2"
                    local remote_param="${3:-}"
                    
                    case "$remote_action" in
                        "list"|"update"|"cleanup")
                            handle_remote_config "$remote_action" "$remote_param"
                            shift 2
                            ;;
                        "use"|"install")
                            if [[ -n "$remote_param" ]]; then
                                handle_remote_config "$remote_action" "$remote_param"
                                shift 3
                            else
                                echo "错误: --remote $remote_action 需要指定参数"
                                exit 1
                            fi
                            ;;
                        *)
                            echo "错误: 未知的远程配置操作: $remote_action"
                            echo "可用操作: list, use, install, update, cleanup"
                            exit 1
                            ;;
                    esac
                    exit $?
                else
                    echo "错误: --remote 需要指定操作 (list, use, install, update, cleanup)"
                    exit 1
                fi
                ;;
            --packages-only)
                PACKAGES_ONLY=true
                CONFIG_ONLY=false
                DOTFILES_ONLY=false
                shift
                ;;
            --config-only)
                PACKAGES_ONLY=false
                CONFIG_ONLY=true
                DOTFILES_ONLY=false
                shift
                ;;
            --dotfiles-only)
                PACKAGES_ONLY=false
                CONFIG_ONLY=false
                DOTFILES_ONLY=true
                shift
                ;;
            --homebrew-only)
                INSTALL_PACKAGES=true
                INSTALL_CASKS=true
                CONFIGURE_SYSTEM=false
                CONFIGURE_DOTFILES=false
                shift
                ;;
            --system-only)
                INSTALL_PACKAGES=false
                INSTALL_CASKS=false
                CONFIGURE_SYSTEM=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --log-file)
                LOG_FILE="$2"
                shift 2
                ;;
            --no-homebrew)
                INSTALL_HOMEBREW=false
                shift
                ;;
            --no-packages)
                INSTALL_PACKAGES=false
                shift
                ;;
            --no-casks)
                INSTALL_CASKS=false
                shift
                ;;
            --no-appstore)
                INSTALL_APPSTORE=false
                shift
                ;;
            --enable-appstore)
                INSTALL_APPSTORE=true
                shift
                ;;
            --no-system-config)
                CONFIGURE_SYSTEM=false
                shift
                ;;
            *)
                echo "未知选项: $1" >&2
                echo "使用 --help 查看帮助信息" >&2
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# 初始化和检查
# =============================================================================

# 系统环境检查
check_system_requirements() {
    log_step_start "系统环境检查"
    
    # 检查 macOS
    if ! check_macos; then
        log_fatal "此脚本仅支持 macOS 系统"
        exit 1
    fi
    
    # 检查 macOS 版本
    if ! check_macos_version "10.15"; then
        if ! confirm "检测到较旧的 macOS 版本，可能存在兼容性问题，是否继续" "n"; then
            log_info "用户选择退出"
            exit 0
        fi
    fi
    
    # 检查网络连接
    if ! check_network; then
        log_fatal "网络连接异常，无法继续"
        exit 1
    fi
    
    # 检查磁盘空间
    check_disk_space
    
    log_step_complete "系统环境检查"
}

# 检查磁盘空间
check_disk_space() {
    local available_gb
    available_gb=$(df -g / | awk 'NR==2 {print $4}')
    
    if [[ $available_gb -lt 5 ]]; then
        log_warn "可用磁盘空间较少 (${available_gb}GB)，建议清理后再运行"
        if ! confirm "是否继续" "n"; then
            exit 0
        fi
    else
        log_success "磁盘空间充足 (${available_gb}GB)"
    fi
}

# 初始化脚本环境
initialize_environment() {
    log_step_start "初始化环境"
    
    # 设置日志级别
    if [[ "$VERBOSE" == "true" ]]; then
        set_log_level "debug"
    fi
    
    # 初始化日志系统
    local log_file="${LOG_FILE:-}"
    if [[ -z "$log_file" ]]; then
        log_file="mac-init-$(date +%Y%m%d_%H%M%S).log"
    fi
    setup_logging "$(pwd)/logs" "$log_file"
    
    # 初始化配置系统
    init_config_system
    
    # 设置清理函数
    setup_cleanup
    
    log_step_complete "初始化环境"
}

# =============================================================================
# 配置加载
# =============================================================================

# 加载用户配置
load_user_configuration() {
    log_step_start "加载配置"
    
    # 加载配置方案
    if [[ -n "$PROFILE" ]]; then
        if load_profile "$PROFILE"; then
            log_success "已加载配置方案: $PROFILE"
        else
            log_error "配置方案加载失败: $PROFILE"
            exit 1
        fi
    elif [[ -n "$CUSTOM_CONFIG" ]]; then
        if [[ -f "$CUSTOM_CONFIG" ]]; then
            log_success "已指定自定义配置文件: $CUSTOM_CONFIG"
        else
            log_error "自定义配置文件不存在: $CUSTOM_CONFIG"
            exit 1
        fi
    else
        log_info "使用默认配置"
    fi
    
    # 应用命令行参数覆盖
    apply_command_line_overrides
    
    log_step_complete "加载配置"
}

# 应用命令行参数覆盖配置
apply_command_line_overrides() {
    # 覆盖安装选项
    CONFIG_VALUES["INSTALL_HOMEBREW"]="$INSTALL_HOMEBREW"
    CONFIG_VALUES["INSTALL_PACKAGES"]="$INSTALL_PACKAGES"
    CONFIG_VALUES["INSTALL_CASKS"]="$INSTALL_CASKS"
    CONFIG_VALUES["INSTALL_APPSTORE"]="$INSTALL_APPSTORE"
    CONFIG_VALUES["CONFIGURE_SYSTEM"]="$CONFIGURE_SYSTEM"
    CONFIG_VALUES["CONFIGURE_DOTFILES"]="$CONFIGURE_DOTFILES"
    
    # 覆盖执行模式
    if [[ "$PACKAGES_ONLY" == "true" ]]; then
        CONFIG_VALUES["CONFIGURE_SYSTEM"]="false"
        CONFIG_VALUES["CONFIGURE_DOTFILES"]="false"
    elif [[ "$CONFIG_ONLY" == "true" ]]; then
        CONFIG_VALUES["INSTALL_HOMEBREW"]="false"
        CONFIG_VALUES["INSTALL_PACKAGES"]="false"
        CONFIG_VALUES["INSTALL_CASKS"]="false"
        CONFIG_VALUES["INSTALL_APPSTORE"]="false"
    elif [[ "$DOTFILES_ONLY" == "true" ]]; then
        CONFIG_VALUES["INSTALL_HOMEBREW"]="false"
        CONFIG_VALUES["INSTALL_PACKAGES"]="false"
        CONFIG_VALUES["INSTALL_CASKS"]="false"
        CONFIG_VALUES["INSTALL_APPSTORE"]="false"
        CONFIG_VALUES["CONFIGURE_SYSTEM"]="false"
        CONFIG_VALUES["CONFIGURE_DOTFILES"]="true"
    fi
    
    log_debug "命令行参数已应用到配置"
}

# =============================================================================
# 交互式向导
# =============================================================================

# 显示欢迎信息
show_welcome() {
    cat << 'EOF'

   __  __              ___       _ _   
  |  \/  |            |_ _|_ __ (_) |_ 
  | |\/| | __ _  ___   | || '_ \| | __|
  | |  | |/ _` |/ __|  | || | | | | |_ 
  |_|  |_|\__,_|\___| |___|_| |_|_|\__|
                                      
        Mac 电脑自动初始化工具

EOF
    
    echo -e "${BLUE}欢迎使用 Mac Init！${NC}"
    echo "此工具将帮助您快速配置您的 Mac 电脑"
    echo ""
}

# 交互式配置向导
interactive_setup_wizard() {
    show_welcome
    
    if [[ "$INTERACTIVE" != "true" ]]; then
        return 0
    fi
    
    echo -e "${CYAN}=== 配置向导 ===${NC}"
    
    # 选择配置方案
    if [[ -z "$PROFILE" ]]; then
        select_configuration_profile
    fi
    
    # 确认安装选项
    confirm_installation_options
    
    # 显示安装预览
    show_installation_preview
    
    # 最终确认
    if ! confirm "确认开始安装" "y"; then
        log_info "用户取消安装"
        exit 0
    fi
}

# 选择配置方案
select_configuration_profile() {
    echo -e "\n请选择配置方案:"
    
    local profiles=(
        "默认配置 (基础软件和设置)"
        "开发者配置 (开发工具和环境)"
        "设计师配置 (设计软件和工具)"
        "自定义配置 (手动选择)"
    )
    
    show_menu "配置方案:" "${profiles[@]}"
    local choice
    choice=$(get_choice ${#profiles[@]})
    
    case $choice in
        1)
            PROFILE="basic"
            ;;
        2)
            PROFILE="developer"
            ;;
        3)
            PROFILE="designer"
            ;;
        4)
            custom_configuration_wizard
            return
            ;;
    esac
    
    # 检查配置方案是否存在，不存在则创建
    if [[ ! -f "$PROFILES_DIR/$PROFILE.conf" ]]; then
        log_info "配置方案不存在，创建默认配置: $PROFILE"
        create_profile "$PROFILE"
    fi
    
    load_profile "$PROFILE"
}

# 自定义配置向导
custom_configuration_wizard() {
    echo -e "\n${CYAN}=== 自定义配置 ===${NC}"
    
    # 软件安装选项
    echo "软件安装选项:"
    INSTALL_HOMEBREW=$(confirm "安装 Homebrew 包管理器" "y" && echo "true" || echo "false")
    
    if [[ "$INSTALL_HOMEBREW" == "true" ]]; then
        INSTALL_PACKAGES=$(confirm "安装命令行工具包" "y" && echo "true" || echo "false")
        INSTALL_CASKS=$(confirm "安装 GUI 应用程序" "y" && echo "true" || echo "false")
    fi
    
    INSTALL_APPSTORE=$(confirm "安装 App Store 应用" "n" && echo "true" || echo "false")
    
    # 系统配置选项
    echo -e "\n系统配置选项:"
    CONFIGURE_SYSTEM=$(confirm "配置系统设置 (Dock, Finder 等)" "y" && echo "true" || echo "false")
    CONFIGURE_DOTFILES=$(confirm "安装配置文件 (dotfiles)" "n" && echo "true" || echo "false")
}

# 确认安装选项
confirm_installation_options() {
    if [[ "$SKIP_CONFIRMATIONS" == "true" ]]; then
        return 0
    fi
    
    echo -e "\n${CYAN}=== 安装选项确认 ===${NC}"
    show_current_config
    
    if ! confirm "这些配置是否正确" "y"; then
        log_info "重新配置..."
        custom_configuration_wizard
    fi
}

# 显示安装预览
show_installation_preview() {
    echo -e "\n${CYAN}=== 安装预览 ===${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}⚠️  预览模式 - 不会实际执行安装${NC}"
    fi
    
    local steps=()
    
    if [[ "$(get_config 'INSTALL_HOMEBREW' 'true')" == "true" ]]; then
        steps+=("安装 Homebrew 包管理器")
    fi
    
    if [[ "$(get_config 'INSTALL_PACKAGES' 'true')" == "true" ]]; then
        local packages_file
        packages_file=$(get_packages_file)
        if [[ -f "$packages_file" ]]; then
            local package_count
            package_count=$(parse_package_list "$packages_file" | wc -l | tr -d ' ')
            steps+=("安装 $package_count 个命令行工具包")
        fi
    fi
    
    if [[ "$(get_config 'INSTALL_CASKS' 'true')" == "true" ]]; then
        local casks_file
        casks_file=$(get_casks_file)
        if [[ -f "$casks_file" ]]; then
            local cask_count
            cask_count=$(parse_package_list "$casks_file" | wc -l | tr -d ' ')
            steps+=("安装 $cask_count 个 GUI 应用程序")
        fi
    fi
    
    if [[ "$(get_config 'INSTALL_APPSTORE' 'false')" == "true" ]]; then
        steps+=("安装 App Store 应用")
    fi
    
    if [[ "$(get_config 'CONFIGURE_SYSTEM' 'true')" == "true" ]]; then
        steps+=("配置系统设置")
    fi
    
    if [[ "$(get_config 'CONFIGURE_DOTFILES' 'false')" == "true" ]]; then
        steps+=("安装配置文件")
    fi
    
    echo "将执行以下步骤:"
    for i in "${!steps[@]}"; do
        echo "  $((i+1)). ${steps[i]}"
    done
    
    echo ""
    
    if [[ ${#steps[@]} -eq 0 ]]; then
        log_warn "没有选择任何安装步骤"
        exit 0
    fi
}

# =============================================================================
# 主要安装流程
# =============================================================================

# 执行完整安装流程
execute_installation() {
    local start_time
    start_time=$(date +%s)
    
    log_step_start "开始 Mac 初始化"
    
    # 安装 Homebrew
    if [[ "$(get_config 'INSTALL_HOMEBREW' 'true')" == "true" ]] && [[ "$CONFIG_ONLY" != "true" ]]; then
        execute_with_dry_run install_homebrew
    fi
    
    # 安装软件包
    if [[ "$(get_config 'INSTALL_PACKAGES' 'true')" == "true" ]] && [[ "$CONFIG_ONLY" != "true" ]]; then
        execute_with_dry_run install_homebrew_packages
    fi
    
    # 安装 Cask 应用
    if [[ "$(get_config 'INSTALL_CASKS' 'true')" == "true" ]] && [[ "$CONFIG_ONLY" != "true" ]]; then
        execute_with_dry_run install_homebrew_casks
    fi
    
    # 安装 App Store 应用
    if [[ "$(get_config 'INSTALL_APPSTORE' 'false')" == "true" ]] && [[ "$CONFIG_ONLY" != "true" ]]; then
        log_warn "App Store 应用安装功能尚未实现"
    fi
    
    # 系统配置
    if [[ "$(get_config 'CONFIGURE_SYSTEM' 'true')" == "true" ]] && [[ "$PACKAGES_ONLY" != "true" ]]; then
        execute_with_dry_run configure_system
    fi
    
    # Dotfiles 配置
    if [[ "$(get_config 'CONFIGURE_DOTFILES' 'false')" == "true" ]] && [[ "$PACKAGES_ONLY" != "true" ]] && [[ "$CONFIG_ONLY" != "true" ]]; then
        log_warn "Dotfiles 配置功能尚未实现"
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_step_complete "Mac 初始化完成" "$duration"
    
    # 显示安装结果
    show_installation_summary "$duration"
}

# 带预览模式执行函数
execute_with_dry_run() {
    local func_name="$1"
    shift
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "预览模式: 将执行 $func_name"
        return 0
    else
        "$func_name" "$@"
    fi
}

# 显示安装结果摘要
show_installation_summary() {
    local duration="$1"
    
    echo -e "\n${GREEN}🎉 Mac 初始化完成！${NC}"
    echo -e "${BLUE}总耗时: ${duration}秒${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}注意: 这是预览模式，未实际执行安装${NC}"
        return 0
    fi
    
    echo -e "\n${CYAN}=== 安装摘要 ===${NC}"
    
    # 显示安装的软件统计
    if command -v brew &> /dev/null; then
        local brew_packages
        local brew_casks
        brew_packages=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
        brew_casks=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
        echo "Homebrew 包: $brew_packages 个"
        echo "Homebrew Cask 应用: $brew_casks 个"
    fi
    
    # 显示日志文件位置
    echo -e "\n${BLUE}详细日志: $LOG_FILE_PATH${NC}"
    
    # 显示下一步建议
    echo -e "\n${CYAN}建议的下一步操作:${NC}"
    echo "1. 重启终端或重新登录以确保环境变量生效"
    echo "2. 运行 brew doctor 检查 Homebrew 状态"
    echo "3. 检查系统偏好设置确认配置已生效"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        echo "4. 备份文件位置: $BACKUP_DIR"
    fi
    
    echo ""
}

# =============================================================================
# 主函数
# =============================================================================

# 主函数
main() {
    # 解析命令行参数
    parse_arguments "$@"
    
    # 初始化环境
    initialize_environment
    
    # 系统检查
    check_system_requirements
    
    # 加载配置
    load_user_configuration
    
    # 交互式向导
    interactive_setup_wizard
    
    # 执行安装
    execute_installation
    
    # 生成日志统计
    log_statistics
    
    log_success "Mac Init 执行完成！"
}

# =============================================================================
# 脚本入口
# =============================================================================

# 错误处理
handle_error() {
    local exit_code=$?
    log_error "脚本执行过程中发生错误 (退出码: $exit_code)"
    
    if [[ -n "${LOG_FILE_PATH:-}" ]]; then
        echo -e "\n${RED}详细错误信息请查看日志文件: $LOG_FILE_PATH${NC}"
        show_recent_errors 5
    fi
    
    cleanup
    exit $exit_code
}

# 中断处理
handle_interrupt() {
    log_warn "接收到中断信号，正在清理..."
    cleanup
    exit 130
}

# 设置错误处理
trap handle_error ERR
trap handle_interrupt INT TERM

# 检查是否直接执行 (非 source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi