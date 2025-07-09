#!/bin/bash

# =============================================================================
# MacSetup - 配置管理系统
# =============================================================================

set -euo pipefail

# 导入依赖
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/utils.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
fi

if [[ -f "$(dirname "${BASH_SOURCE[0]}")/logger.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
fi

# =============================================================================
# 配置文件路径定义
# =============================================================================

if [[ -z "${CONFIG_ROOT:-}" ]]; then
    readonly CONFIG_ROOT="${SCRIPT_DIR:-$(pwd)}/configs"
    readonly PACKAGES_DIR="$CONFIG_ROOT/packages"
    readonly DOTFILES_DIR="$CONFIG_ROOT/dotfiles"
    readonly SYSTEM_DIR="$CONFIG_ROOT/system"
    readonly PROFILES_DIR="$CONFIG_ROOT/profiles"
    readonly TEMPLATES_DIR="$CONFIG_ROOT/templates"
    
    # 默认配置文件
    readonly DEFAULT_HOMEBREW_FILE="$PACKAGES_DIR/homebrew.txt"
    readonly DEFAULT_CASK_FILE="$PACKAGES_DIR/cask.txt"
    readonly DEFAULT_APPSTORE_FILE="$PACKAGES_DIR/appstore.txt"
    readonly DEFAULT_SYSTEM_CONFIG="$SYSTEM_DIR/defaults.sh"
    
    # 默认配置模板
    readonly DEFAULT_HOMEBREW_TEMPLATE="$TEMPLATES_DIR/homebrew.txt"
    readonly DEFAULT_CASK_TEMPLATE="$TEMPLATES_DIR/cask.txt"
    readonly DEFAULT_APPSTORE_TEMPLATE="$TEMPLATES_DIR/appstore.txt"
fi

# 全局配置变量
if [[ -z "${CONFIG_VALUES_INITIALIZED:-}" ]]; then
    if [[ "${BASH_VERSION%%.*}" -ge 4 ]]; then
        declare -A CONFIG_VALUES
        declare -A CONFIG_FILES
    fi
    CONFIG_VALUES_INITIALIZED=1
fi

# 进度显示配置
if [[ -z "${SHOW_BREW_OUTPUT:-}" ]]; then
    readonly SHOW_BREW_OUTPUT="${SHOW_BREW_OUTPUT:-true}"  # true, false
fi
CURRENT_PROFILE=""

# =============================================================================
# 配置系统初始化
# =============================================================================

# 初始化配置系统
init_config_system() {
    log_step_start "配置系统初始化"
    
    # 创建必要的目录
    safe_mkdir "$PACKAGES_DIR"
    safe_mkdir "$DOTFILES_DIR"
    safe_mkdir "$SYSTEM_DIR"
    safe_mkdir "$PROFILES_DIR"
    safe_mkdir "$TEMPLATES_DIR"
    
    # 创建默认配置文件
    create_default_configs
    
    log_step_complete "配置系统初始化"
}

# 创建默认配置文件
create_default_configs() {
    # 检查文件权限并尝试修复
    check_and_fix_permissions() {
        local file="$1"
        if [[ -f "$file" ]]; then
            if [[ ! -r "$file" ]]; then
                log_warn "配置文件权限异常: $file"
                log_warn "文件所有者: $(ls -l "$file" | awk '{print $3":"$4}')"
                log_warn "当前用户: $(whoami)"
                if [[ -w "$(dirname "$file")" ]]; then
                    log_info "尝试创建新的配置文件..."
                    return 1  # 需要重新创建
                fi
            else
                # 文件存在且可读，检查是否有内容
                if [[ -s "$file" ]]; then
                    return 0  # 文件正常且非空
                else
                    log_warn "配置文件为空: $file"
                    return 1  # 需要重新创建
                fi
            fi
        fi
        return 1  # 文件不存在，需要创建
    }
    
    # 从模板复制配置文件
    copy_from_template() {
        local template_file="$1"
        local target_file="$2"
        local config_name="$3"
        
        if [[ -f "$template_file" ]]; then
            cp "$template_file" "$target_file"
            log_info "从模板创建${config_name}配置: $target_file"
            return 0
        else
            log_error "模板文件不存在: $template_file"
            log_error "请检查 configs/templates/ 目录是否完整"
            return 1
        fi
    }
    
    # 检查并创建默认的Homebrew包列表
    if ! check_and_fix_permissions "$DEFAULT_HOMEBREW_FILE"; then
        # 确保目录存在且有写权限
        if [[ ! -w "$PACKAGES_DIR" ]]; then
            log_warn "包配置目录没有写权限: $PACKAGES_DIR"
            return 1
        fi
        
        # 从模板复制配置文件
        if ! copy_from_template "$DEFAULT_HOMEBREW_TEMPLATE" "$DEFAULT_HOMEBREW_FILE" "Homebrew"; then
            log_error "无法创建Homebrew配置文件"
            return 1
        fi
    fi
    
    # 检查并创建默认的Cask列表
    if ! check_and_fix_permissions "$DEFAULT_CASK_FILE"; then
        if [[ ! -w "$PACKAGES_DIR" ]]; then
            log_warn "包配置目录没有写权限: $PACKAGES_DIR"
            return 1
        fi
        
        # 从模板复制配置文件
        if ! copy_from_template "$DEFAULT_CASK_TEMPLATE" "$DEFAULT_CASK_FILE" "Cask"; then
            log_error "无法创建Cask配置文件"
            return 1
        fi
    fi
    
    # 检查并创建默认的App Store列表
    if ! check_and_fix_permissions "$DEFAULT_APPSTORE_FILE"; then
        if [[ ! -w "$PACKAGES_DIR" ]]; then
            log_warn "包配置目录没有写权限: $PACKAGES_DIR"
            return 1
        fi
        
        # 从模板复制配置文件
        if ! copy_from_template "$DEFAULT_APPSTORE_TEMPLATE" "$DEFAULT_APPSTORE_FILE" "App Store"; then
            log_error "无法创建App Store配置文件"
            return 1
        fi
    fi
    
    # 创建默认系统配置
    if [[ ! -f "$DEFAULT_SYSTEM_CONFIG" ]]; then
        cat > "$DEFAULT_SYSTEM_CONFIG" << 'EOF'
#!/bin/bash
# MacSetup - 系统默认配置

# Dock设置
defaults write com.apple.dock "tilesize" -int "48"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "autohide-delay" -float "0"

# Finder设置
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "ShowStatusBar" -bool "true"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# 截图设置
defaults write com.apple.screencapture "location" -string "~/Desktop"
defaults write com.apple.screencapture "type" -string "png"

# 重启相关服务
killall Dock
killall Finder
EOF
        chmod +x "$DEFAULT_SYSTEM_CONFIG"
        log_info "创建默认系统配置: $DEFAULT_SYSTEM_CONFIG"
    fi
}

# =============================================================================
# 配置文件解析
# =============================================================================

# 解析包列表文件
parse_package_list() {
    local file="$1"
    local packages=()
    
    if [[ ! -f "$file" ]]; then
        log_error "配置文件不存在: $file"
        return 1
    fi
    
    log_debug "解析包列表文件: $file"
    
    while IFS= read -r line; do
        # 移除行首尾空白
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # 跳过空行和注释行
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # 提取包名(注释前的部分)
        local package
        package=$(echo "$line" | cut -d'#' -f1 | sed 's/[[:space:]]*$//')
        
        if [[ -n "$package" ]]; then
            packages+=("$package")
        fi
    done < "$file"
    
    log_debug "解析到 ${#packages[@]} 个包"
    printf '%s\n' "${packages[@]}"
}

# 解析App Store应用列表
parse_appstore_list() {
    local file="$1"
    local apps=()
    
    if [[ ! -f "$file" ]]; then
        log_error "App Store配置文件不存在: $file"
        return 1
    fi
    
    log_debug "解析App Store应用列表: $file"
    
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # 解析格式: ID:名称
        if [[ "$line" =~ ^([0-9]+):(.+)$ ]]; then
            local app_id="${BASH_REMATCH[1]}"
            local app_name="${BASH_REMATCH[2]}"
            apps+=("$app_id:$app_name")
        fi
    done < "$file"
    
    log_debug "解析到 ${#apps[@]} 个App Store应用"
    printf '%s\n' "${apps[@]}"
}

# =============================================================================
# 配置方案管理
# =============================================================================

# 加载配置方案
load_profile() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/$profile_name.conf"
    
    if [[ ! -f "$profile_file" ]]; then
        log_error "配置方案不存在: $profile_name"
        return 1
    fi
    
    log_step_start "加载配置方案" "$profile_name"
    
    # 清空当前配置
    CONFIG_VALUES=()
    CONFIG_FILES=()
    
    # 读取配置方案
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        if [[ "$line" =~ ^([A-Z_]+)=(.+)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            # 移除引号
            value=$(echo "$value" | sed 's/^"//;s/"$//')
            
            # 如果支持关联数组，则使用CONFIG_VALUES
            if [[ "${BASH_VERSION%%.*}" -ge 4 ]]; then
                CONFIG_VALUES["$key"]="$value"
            fi
            
            # 同时设置为普通变量以便向后兼容
            eval "$key=\"$value\""
            log_debug "配置项: $key = $value"
        fi
    done < "$profile_file"
    
    CURRENT_PROFILE="$profile_name"
    log_step_complete "加载配置方案" "$profile_name"
}

# 创建配置方案
create_profile() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/$profile_name.conf"
    
    if [[ -f "$profile_file" ]]; then
        if ! confirm "配置方案 $profile_name 已存在，是否覆盖"; then
            return 1
        fi
        backup_file "$profile_file"
    fi
    
    log_step_start "创建配置方案" "$profile_name"
    
    cat > "$profile_file" << EOF
# MacSetup 配置方案: $profile_name
# 创建时间: $(date '+%Y-%m-%d %H:%M:%S')

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
EOF
    
    log_step_complete "创建配置方案" "$profile_name"
    log_info "配置方案已创建: $profile_file"
}

# 列出可用的配置方案
list_profiles() {
    log_info "可用的配置方案:"
    
    if [[ ! -d "$PROFILES_DIR" ]]; then
        log_warn "配置方案目录不存在"
        return 1
    fi
    
    local profiles
    profiles=$(find "$PROFILES_DIR" -name "*.conf" -type f 2>/dev/null | sort)
    
    if [[ -z "$profiles" ]]; then
        log_warn "未找到任何配置方案"
        return 1
    fi
    
    while IFS= read -r profile_file; do
        local profile_name
        profile_name=$(basename "$profile_file" .conf)
        local description=""
        
        # 尝试从文件中提取描述
        if grep -q "^# MacSetup 配置方案:" "$profile_file" 2>/dev/null; then
            description=$(grep "^# MacSetup 配置方案:" "$profile_file" | cut -d: -f2- | sed 's/^[[:space:]]*//')
        fi
        
        echo "  - $profile_name${description:+ ($description)}"
    done <<< "$profiles"
}

# =============================================================================
# 配置验证
# =============================================================================

# 验证配置文件
validate_config() {
    local config_file="$1"
    local config_type="${2:-package}"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "配置文件不存在: $config_file"
        return 1
    fi
    
    log_debug "验证配置文件: $config_file ($config_type)"
    
    case "$config_type" in
        "package")
            validate_package_config "$config_file"
            ;;
        "appstore")
            validate_appstore_config "$config_file"
            ;;
        "profile")
            validate_profile_config "$config_file"
            ;;
        *)
            log_error "未知的配置类型: $config_type"
            return 1
            ;;
    esac
}

# 验证包配置文件
validate_package_config() {
    local file="$1"
    local line_num=0
    local errors=0
    
    while IFS= read -r line; do
        ((line_num++))
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        local package
        package=$(echo "$line" | cut -d'#' -f1 | sed 's/[[:space:]]*$//')
        
        # 检查包名格式
        if [[ ! "$package" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            log_warn "第 $line_num 行: 可能的无效包名 '$package'"
            ((errors++))
        fi
    done < "$file"
    
    if [[ $errors -eq 0 ]]; then
        log_success "配置文件验证通过: $file"
        return 0
    else
        log_warn "配置文件验证发现 $errors 个警告: $file"
        return 1
    fi
}

# 验证App Store配置文件
validate_appstore_config() {
    local file="$1"
    local line_num=0
    local errors=0
    
    while IFS= read -r line; do
        ((line_num++))
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        if [[ ! "$line" =~ ^[0-9]+:.+$ ]]; then
            log_error "第 $line_num 行: 格式错误，应为 'ID:应用名称'"
            ((errors++))
        fi
    done < "$file"
    
    if [[ $errors -eq 0 ]]; then
        log_success "App Store配置验证通过: $file"
        return 0
    else
        log_error "App Store配置验证失败: $file ($errors 个错误)"
        return 1
    fi
}

# 验证配置方案文件
validate_profile_config() {
    local file="$1"
    local required_keys=("PACKAGES_FILE" "CASKS_FILE" "SYSTEM_CONFIG")
    local errors=0
    
    for key in "${required_keys[@]}"; do
        if ! grep -q "^$key=" "$file"; then
            log_error "配置方案缺少必需项: $key"
            ((errors++))
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        log_success "配置方案验证通过: $file"
        return 0
    else
        log_error "配置方案验证失败: $file ($errors 个错误)"
        return 1
    fi
}

# =============================================================================
# 配置获取函数
# =============================================================================

# 获取配置值
get_config() {
    local key="$1"
    local default_value="${2:-}"
    
    # 检查是否支持关联数组
    if [[ "${BASH_VERSION%%.*}" -ge 4 ]]; then
        if [[ -n "${CONFIG_VALUES[$key]:-}" ]]; then
            echo "${CONFIG_VALUES[$key]}"
        else
            echo "$default_value"
        fi
    else
        # 对于旧版本bash，使用eval获取变量值
        local value
        if eval "value=\${$key:-}"; then
            echo "${value:-$default_value}"
        else
            echo "$default_value"
        fi
    fi
}

# 获取包配置文件路径
get_packages_file() {
    local file
    file=$(get_config "PACKAGES_FILE" "homebrew.txt")
    
    if [[ "$file" =~ ^/ ]]; then
        echo "$file"
    else
        echo "$PACKAGES_DIR/$file"
    fi
}

# 获取Cask配置文件路径
get_casks_file() {
    local file
    file=$(get_config "CASKS_FILE" "cask.txt")
    
    if [[ "$file" =~ ^/ ]]; then
        echo "$file"
    else
        echo "$PACKAGES_DIR/$file"
    fi
}

# 获取App Store配置文件路径
get_appstore_file() {
    local file
    file=$(get_config "APPSTORE_FILE" "appstore.txt")
    
    if [[ "$file" =~ ^/ ]]; then
        echo "$file"
    else
        echo "$PACKAGES_DIR/$file"
    fi
}

# 获取系统配置文件路径
get_system_config_file() {
    local file
    file=$(get_config "SYSTEM_CONFIG" "defaults.sh")
    
    if [[ "$file" =~ ^/ ]]; then
        echo "$file"
    else
        echo "$SYSTEM_DIR/$file"
    fi
}

# =============================================================================
# 配置信息显示
# =============================================================================

# 显示当前配置
show_current_config() {
    printf "\n%s=== 当前配置信息 ===%s\n" "${CYAN}" "${NC}"
    
    if [[ -n "$CURRENT_PROFILE" ]]; then
        echo "配置方案: $CURRENT_PROFILE"
    else
        echo "配置方案: 默认配置"
    fi
    
    echo "包配置文件: $(get_packages_file)"
    echo "Cask配置文件: $(get_casks_file)"
    echo "App Store配置文件: $(get_appstore_file)"
    echo "系统配置文件: $(get_system_config_file)"
    
    printf "\n安装选项:\n"
    echo "  Homebrew包: $(get_config 'INSTALL_HOMEBREW' 'true')"
    echo "  Cask应用: $(get_config 'INSTALL_CASKS' 'true')"
    echo "  App Store应用: $(get_config 'INSTALL_APPSTORE' 'false')"
    echo "  系统配置: $(get_config 'CONFIGURE_SYSTEM' 'true')"
    echo "  Dotfiles: $(get_config 'CONFIGURE_DOTFILES' 'true')"
    echo ""
}

# =============================================================================
# 导出函数
# =============================================================================

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f init_config_system create_default_configs
    export -f parse_package_list parse_appstore_list
    export -f load_profile create_profile list_profiles
    export -f validate_config get_config show_current_config
    export -f get_packages_file get_casks_file get_appstore_file get_system_config_file
fi