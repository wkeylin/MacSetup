#!/bin/bash

# =============================================================================
# MacSetup - 日志系统
# =============================================================================

set -euo pipefail

# 导入工具函数
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/utils.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
fi

# =============================================================================
# 日志配置
# =============================================================================

# 日志级别定义
if [[ -z "${LOG_LEVEL_DEBUG:-}" ]]; then
    readonly LOG_LEVEL_DEBUG=0
    readonly LOG_LEVEL_INFO=1
    readonly LOG_LEVEL_WARN=2
    readonly LOG_LEVEL_ERROR=3
    readonly LOG_LEVEL_FATAL=4
fi

# 默认配置
DEFAULT_LOG_LEVEL=${LOG_LEVEL_INFO}
# 使用 macOS 临时目录
DEFAULT_LOG_DIR="${TMPDIR:-/tmp}/macsetup-logs"
# 改为一天一个文件的格式
DEFAULT_LOG_FILE="macsetup-$(date +%Y%m%d).log"
ENABLE_CONSOLE_OUTPUT=true
ENABLE_FILE_OUTPUT=true
MAX_LOG_FILES=10

# 全局变量
CURRENT_LOG_LEVEL=${DEFAULT_LOG_LEVEL}
LOG_FILE_PATH=""
LOG_SESSION_ID="$(date +%s)-$$"

# =============================================================================
# 日志系统初始化
# =============================================================================

# 初始化日志系统
setup_logging() {
    local log_dir="${1:-$DEFAULT_LOG_DIR}"
    local log_file="${2:-$DEFAULT_LOG_FILE}"
    local log_level="${3:-$DEFAULT_LOG_LEVEL}"
    
    # 创建日志目录
    safe_mkdir "$log_dir"
    
    # 设置日志文件路径
    LOG_FILE_PATH="$log_dir/$log_file"
    CURRENT_LOG_LEVEL="$log_level"
    
    # 创建日志文件并写入头部信息
    if [[ "$ENABLE_FILE_OUTPUT" == "true" ]]; then
        # 如果是当天第一次运行，创建新文件；否则追加到现有文件
        if [[ ! -f "$LOG_FILE_PATH" ]]; then
            {
                echo "# MacSetup 日志文件 - $(date '+%Y-%m-%d')"
                echo "# 系统信息: $(uname -a)"
                echo "# macOS版本: $(sw_vers -productVersion)"
                echo "# 用户: $(whoami)"
                echo "# ============================================================================="
                echo ""
            } > "$LOG_FILE_PATH"
        fi
        
        # 每次运行时添加会话开始标记
        {
            echo "# 会话开始: $(date '+%Y-%m-%d %H:%M:%S') (PID: $$)"
        } >> "$LOG_FILE_PATH"
    fi
    
    # 清理旧日志文件
    cleanup_old_logs "$log_dir"
    
    log_info "日志系统初始化完成: $LOG_FILE_PATH"
}

# 清理旧日志文件
cleanup_old_logs() {
    local log_dir="$1"
    local log_pattern="macsetup-*.log"
    
    # 获取日志文件数量
    local log_count
    log_count=$(find "$log_dir" -name "$log_pattern" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $log_count -gt $MAX_LOG_FILES ]]; then
        # 按日期排序，删除最旧的日志文件
        local files_to_delete=$((log_count - MAX_LOG_FILES))
        find "$log_dir" -name "$log_pattern" -type f | sort | head -n "$files_to_delete" | xargs rm -f
        log_info "清理了 $files_to_delete 个旧日志文件"
    fi
}

# =============================================================================
# 日志级别管理
# =============================================================================

# 设置日志级别
set_log_level() {
    local level="$1"
    case "$level" in
        "debug"|"DEBUG"|0) CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
        "info"|"INFO"|1) CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO ;;
        "warn"|"WARN"|2) CURRENT_LOG_LEVEL=$LOG_LEVEL_WARN ;;
        "error"|"ERROR"|3) CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR ;;
        "fatal"|"FATAL"|4) CURRENT_LOG_LEVEL=$LOG_LEVEL_FATAL ;;
        *) 
            log_error "无效的日志级别: $level"
            return 1
            ;;
    esac
    log_info "日志级别设置为: $level"
}

# 获取日志级别名称
get_log_level_name() {
    local level="$1"
    case "$level" in
        $LOG_LEVEL_DEBUG) echo "DEBUG" ;;
        $LOG_LEVEL_INFO) echo "INFO" ;;
        $LOG_LEVEL_WARN) echo "WARN" ;;
        $LOG_LEVEL_ERROR) echo "ERROR" ;;
        $LOG_LEVEL_FATAL) echo "FATAL" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# =============================================================================
# 核心日志函数
# =============================================================================

# 通用日志记录函数
_log() {
    local level="$1"
    local message="$2"
    local color="${3:-$NC}"
    local prefix="${4:-}"
    
    # 检查日志级别
    if [[ $level -lt $CURRENT_LOG_LEVEL ]]; then
        return 0
    fi
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local level_name
    level_name=$(get_log_level_name "$level")
    local caller_info=""
    
    # 获取调用者信息 (函数名和行号)
    if [[ $level -ge $LOG_LEVEL_WARN ]]; then
        local caller_function="${FUNCNAME[2]:-main}"
        local caller_line="${BASH_LINENO[1]:-0}"
        caller_info=" [$caller_function:$caller_line]"
    fi
    
    local formatted_message="[$timestamp] [$level_name]$caller_info $prefix$message"
    
    # 控制台输出
    if [[ "$ENABLE_CONSOLE_OUTPUT" == "true" ]]; then
        printf "${color}%s${NC}\n" "$formatted_message" >&2
    fi
    
    # 文件输出
    if [[ "$ENABLE_FILE_OUTPUT" == "true" && -n "$LOG_FILE_PATH" ]]; then
        echo "$formatted_message" >> "$LOG_FILE_PATH"
    fi
}

# =============================================================================
# 不同级别的日志函数
# =============================================================================

# DEBUG级别日志
log_debug() {
    _log $LOG_LEVEL_DEBUG "$1" "$PURPLE" "🔍 "
}

# INFO级别日志
log_info() {
    _log $LOG_LEVEL_INFO "$1" "$BLUE" "ℹ️  "
}

# 成功日志
log_success() {
    _log $LOG_LEVEL_INFO "$1" "$GREEN" "✅ "
}

# WARN级别日志
log_warn() {
    _log $LOG_LEVEL_WARN "$1" "$YELLOW" "⚠️  "
}

# ERROR级别日志
log_error() {
    _log $LOG_LEVEL_ERROR "$1" "$RED" "❌ "
}

# FATAL级别日志
log_fatal() {
    _log $LOG_LEVEL_FATAL "$1" "$RED" "💀 "
}

# =============================================================================
# 特殊日志函数
# =============================================================================

# 步骤开始日志
log_step_start() {
    local step="$1"
    local description="${2:-}"
    _log $LOG_LEVEL_INFO "开始执行步骤: $step $description" "$CYAN" "🚀 "
}

# 步骤完成日志
log_step_complete() {
    local step="$1"
    local duration="${2:-}"
    local msg="步骤完成: $step"
    if [[ -n "$duration" ]]; then
        msg="$msg (耗时: ${duration}s)"
    fi
    _log $LOG_LEVEL_INFO "$msg" "$GREEN" "✅ "
}

# 进度日志
log_progress() {
    local current="$1"
    local total="$2"
    local task="${3:-进度}"
    local percent=$((current * 100 / total))
    _log $LOG_LEVEL_INFO "$task: $current/$total ($percent%)" "$BLUE" "📊 "
}

# 命令执行日志
log_command() {
    local cmd="$1"
    local show_output="${2:-false}"
    
    log_debug "执行命令: $cmd"
    
    if [[ "$show_output" == "true" ]]; then
        if eval "$cmd" 2>&1 | while IFS= read -r line; do
            log_debug "  > $line"
        done; then
            log_success "命令执行成功: $cmd"
            return 0
        else
            log_error "命令执行失败: $cmd"
            return 1
        fi
    else
        if eval "$cmd" &>/dev/null; then
            log_success "命令执行成功: $cmd"
            return 0
        else
            log_error "命令执行失败: $cmd"
            return 1
        fi
    fi
}

# 实时输出的命令执行
log_command_with_output() {
    local cmd="$1"
    local show_output="${2:-true}"
    local prefix="${3:-}"
    
    log_debug "执行命令: $cmd"
    
    if [[ "$show_output" == "true" ]]; then
        # 直接显示命令输出，不做任何过滤
        if [[ -n "$prefix" ]]; then
            eval "$cmd" 2>&1 | while IFS= read -r line; do
                echo "$prefix$line"
            done
        else
            eval "$cmd" 2>&1
        fi
        
        local exit_code=${PIPESTATUS[0]}
        
        if [[ $exit_code -eq 0 ]]; then
            log_success "命令执行成功: $cmd"
            return 0
        else
            log_error "命令执行失败: $cmd"
            return 1
        fi
    else
        # 静默模式
        if eval "$cmd" &>/dev/null; then
            log_success "命令执行成功: $cmd"
            return 0
        else
            log_error "命令执行失败: $cmd"
            return 1
        fi
    fi
}

# =============================================================================
# 日志分析和统计
# =============================================================================

# 生成日志统计
log_statistics() {
    if [[ ! -f "$LOG_FILE_PATH" ]]; then
        log_warn "日志文件不存在，无法生成统计信息"
        return 1
    fi
    
    local total_lines
    local info_count
    local warn_count  
    local error_count
    
    total_lines=$(wc -l < "$LOG_FILE_PATH")
    info_count=$(grep -c "\[INFO\]" "$LOG_FILE_PATH" 2>/dev/null || echo 0)
    warn_count=$(grep -c "\[WARN\]" "$LOG_FILE_PATH" 2>/dev/null || echo 0)
    error_count=$(grep -c "\[ERROR\]" "$LOG_FILE_PATH" 2>/dev/null || echo 0)
    
    echo -e "\n${CYAN}=== 日志统计信息 ===${NC}"
    echo "日志文件: $LOG_FILE_PATH"
    echo "总行数: $total_lines"
    echo "INFO: $info_count"
    echo "WARN: $warn_count"
    echo "ERROR: $error_count"
    echo ""
}

# 显示最近的错误日志
show_recent_errors() {
    local count="${1:-10}"
    
    if [[ ! -f "$LOG_FILE_PATH" ]]; then
        log_warn "日志文件不存在"
        return 1
    fi
    
    echo -e "\n${RED}=== 最近的错误日志 (最多 $count 条) ===${NC}"
    grep "\[ERROR\]\|\[FATAL\]" "$LOG_FILE_PATH" | tail -n "$count" | while IFS= read -r line; do
        echo -e "${RED}$line${NC}"
    done
    echo ""
}

# =============================================================================
# 日志轮转和管理
# =============================================================================

# 轮转当前日志文件
rotate_log() {
    if [[ -f "$LOG_FILE_PATH" ]]; then
        local rotated_name="${LOG_FILE_PATH%.log}-$(date +%H%M%S).log"
        mv "$LOG_FILE_PATH" "$rotated_name"
        log_info "日志文件已轮转: $rotated_name"
        
        # 重新初始化日志文件
        setup_logging "$(dirname "$LOG_FILE_PATH")" "$(basename "$LOG_FILE_PATH")"
    fi
}

# 获取日志文件大小 (MB)
get_log_size() {
    if [[ -f "$LOG_FILE_PATH" ]]; then
        local size_bytes
        size_bytes=$(stat -f%z "$LOG_FILE_PATH" 2>/dev/null || echo 0)
        echo $((size_bytes / 1024 / 1024))
    else
        echo 0
    fi
}

# 检查是否需要轮转日志
check_log_rotation() {
    local max_size_mb="${1:-50}"
    local current_size
    current_size=$(get_log_size)
    
    if [[ $current_size -gt $max_size_mb ]]; then
        log_info "日志文件大小 ${current_size}MB 超过限制 ${max_size_mb}MB，执行轮转"
        rotate_log
    fi
}

# =============================================================================
# 导出函数
# =============================================================================

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f setup_logging set_log_level cleanup_old_logs
    export -f log_debug log_info log_success log_warn log_error log_fatal
    export -f log_step_start log_step_complete log_progress log_command log_command_with_output
    export -f log_statistics show_recent_errors rotate_log check_log_rotation
fi