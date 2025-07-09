# MacSetup 日志系统使用文档

## 概述

日志系统 (`scripts/core/logger.sh`) 是 MacSetup 的重要组件，提供了完整的日志记录、管理和分析功能。它支持多级别日志、彩色输出、文件轮转、日志分析等高级特性。

## 主要功能

### 1. 多级别日志记录
- DEBUG、INFO、WARN、ERROR、FATAL 五个级别
- 支持级别过滤和动态调整

### 2. 双输出模式
- 同时支持控制台和文件输出
- 彩色终端显示增强可读性

### 3. 日志管理
- 自动文件轮转和清理
- 会话追踪和调用者信息

### 4. 日志分析
- 统计信息生成
- 错误日志快速查看

---

## 基本使用方法

### 初始化日志系统

```bash
# 加载日志系统
source scripts/core/logger.sh

# 初始化（推荐在脚本开始时调用）
setup_logging

# 自定义初始化
setup_logging "/custom/log/dir" "my-app.log" "$LOG_LEVEL_DEBUG"
```

### 基本日志记录

```bash
# 不同级别的日志
log_debug "调试信息：变量值为 $var"
log_info "程序开始执行"
log_warn "检测到潜在问题"
log_error "操作失败：无法创建文件"
log_fatal "严重错误：系统崩溃"

# 成功日志（特殊的 INFO 级别）
log_success "操作成功完成"
```

---

## 详细功能说明

### 1. 日志级别管理

#### 日志级别定义

| 级别 | 数值 | 用途 | 示例 |
|------|------|------|------|
| DEBUG | 0 | 调试信息 | 变量值、函数调用 |
| INFO | 1 | 一般信息 | 操作开始、配置加载 |
| WARN | 2 | 警告信息 | 可恢复的错误、建议 |
| ERROR | 3 | 错误信息 | 操作失败、文件不存在 |
| FATAL | 4 | 致命错误 | 系统崩溃、无法恢复 |

#### 设置日志级别

```bash
# 使用字符串设置
set_log_level "debug"    # 显示所有日志
set_log_level "info"     # 显示 INFO 及以上
set_log_level "warn"     # 显示 WARN 及以上
set_log_level "error"    # 仅显示 ERROR 和 FATAL

# 使用数字设置
set_log_level 0          # DEBUG 级别
set_log_level 1          # INFO 级别
set_log_level 2          # WARN 级别
set_log_level 3          # ERROR 级别
set_log_level 4          # FATAL 级别

# 示例：根据环境变量设置级别
if [[ "${DEBUG:-false}" == "true" ]]; then
    set_log_level "debug"
else
    set_log_level "info"
fi
```

### 2. 基础日志函数

#### `log_debug()`

记录调试信息，用于开发和故障排除。

```bash
# 基本用法
log_debug "进入函数 install_package"
log_debug "当前变量值: package_name=$package_name"

# 调试复杂数据结构
declare -A config_map=([key1]=value1 [key2]=value2)
for key in "${!config_map[@]}"; do
    log_debug "配置项: $key = ${config_map[$key]}"
done

# 调试函数执行流程
install_homebrew_package() {
    local package="$1"
    log_debug "开始安装包: $package"
    
    if brew list "$package" &>/dev/null; then
        log_debug "包 $package 已安装，跳过"
        return 0
    fi
    
    log_debug "执行安装命令: brew install $package"
    if brew install "$package"; then
        log_debug "包 $package 安装成功"
        return 0
    else
        log_debug "包 $package 安装失败"
        return 1
    fi
}
```

#### `log_info()`

记录一般信息，用于跟踪程序执行流程。

```bash
# 程序流程记录
log_info "开始 Mac 初始化过程"
log_info "加载配置文件: $config_file"
log_info "检测到 ${#packages[@]} 个待安装包"

# 状态更新
log_info "正在下载文件: $filename"
log_info "当前进度: $current/$total"
log_info "网络连接状态: 正常"

# 配置信息
log_info "使用配置方案: $profile_name"
log_info "日志文件位置: $log_file_path"
log_info "系统架构: $(uname -m)"
```

#### `log_success()`

记录成功操作，提供积极反馈。

```bash
# 操作成功
log_success "Homebrew 安装完成"
log_success "系统配置应用成功"
log_success "所有软件包安装完成"

# 验证成功
log_success "网络连接测试通过"
log_success "权限检查通过"
log_success "配置文件验证通过"

# 恢复操作
log_success "备份文件创建成功: $backup_file"
log_success "系统配置已恢复到初始状态"
```

#### `log_warn()`

记录警告信息，提醒用户注意。

```bash
# 潜在问题
log_warn "磁盘空间不足，剩余: ${available_gb}GB"
log_warn "网络连接较慢，安装可能需要更长时间"
log_warn "检测到较旧的 macOS 版本: $macos_version"

# 配置问题
log_warn "配置文件不存在，使用默认配置: $default_config"
log_warn "某些包可能不兼容当前系统"
log_warn "跳过已安装的软件包: $package"

# 权限警告
log_warn "缺少管理员权限，某些操作可能失败"
log_warn "无法访问系统配置，跳过相关设置"
```

#### `log_error()`

记录错误信息，表示操作失败。

```bash
# 文件操作错误
log_error "无法创建目录: $directory"
log_error "配置文件读取失败: $config_file"
log_error "备份操作失败: $source_file"

# 网络错误
log_error "下载失败: $download_url"
log_error "网络连接超时"
log_error "无法解析域名: $hostname"

# 安装错误
log_error "包安装失败: $package_name"
log_error "系统配置应用失败"
log_error "权限验证失败"

# 错误处理示例
install_package() {
    local package="$1"
    
    if ! brew install "$package"; then
        log_error "包安装失败: $package"
        
        # 尝试诊断问题
        if ! command -v brew &>/dev/null; then
            log_error "Homebrew 未安装或不在 PATH 中"
        elif ! brew doctor &>/dev/null; then
            log_error "Homebrew 配置有问题，请运行 'brew doctor'"
        else
            log_error "未知安装错误，请检查网络连接"
        fi
        
        return 1
    fi
}
```

#### `log_fatal()`

记录致命错误，通常导致程序退出。

```bash
# 系统要求不满足
if ! check_macos; then
    log_fatal "此脚本仅支持 macOS 系统"
    exit 1
fi

# 必需组件缺失
if ! command -v curl &>/dev/null; then
    log_fatal "curl 命令不可用，无法继续执行"
    exit 1
fi

# 权限问题
if [[ $EUID -eq 0 ]]; then
    log_fatal "不能以 root 用户运行此脚本"
    exit 1
fi

# 磁盘空间不足
if [[ $available_space -lt $required_space ]]; then
    log_fatal "磁盘空间不足，需要 ${required_space}GB，可用 ${available_space}GB"
    exit 1
fi
```

### 3. 特殊日志函数

#### `log_step_start()` 和 `log_step_complete()`

用于记录重要步骤的开始和完成。

```bash
# 基本用法
log_step_start "安装 Homebrew"
install_homebrew
log_step_complete "安装 Homebrew"

# 带描述的步骤
log_step_start "系统配置" "应用开发者设置"
configure_developer_settings
log_step_complete "系统配置" "120"  # 耗时120秒

# 复杂操作示例
install_development_environment() {
    log_step_start "开发环境安装"
    
    local start_time=$(date +%s)
    
    # 子步骤
    log_step_start "安装编程语言"
    install_languages
    log_step_complete "安装编程语言"
    
    log_step_start "安装开发工具"
    install_dev_tools
    log_step_complete "安装开发工具"
    
    log_step_start "配置开发环境"
    configure_dev_environment
    log_step_complete "配置开发环境"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_step_complete "开发环境安装" "$duration"
}
```

#### `log_progress()`

记录进度信息。

```bash
# 基本进度记录
total_packages=50
for ((i=1; i<=total_packages; i++)); do
    log_progress $i $total_packages "安装软件包"
    install_package "package_$i"
done

# 文件处理进度
files=("file1.txt" "file2.txt" "file3.txt")
total=${#files[@]}

for ((i=0; i<total; i++)); do
    current=$((i+1))
    log_progress $current $total "处理文件: ${files[i]}"
    process_file "${files[i]}"
done

# 多阶段进度
phases=("下载" "解压" "安装" "配置")
for ((phase=0; phase<${#phases[@]}; phase++)); do
    current_phase=$((phase+1))
    log_progress $current_phase ${#phases[@]} "${phases[phase]}阶段"
    execute_phase $phase
done
```

#### `log_command()`

记录命令执行。

```bash
# 基本命令记录
log_command "brew update"

# 显示命令输出
log_command "brew doctor" true

# 复杂命令示例
execute_with_logging() {
    local cmd="$1"
    local show_output="${2:-false}"
    
    log_info "准备执行命令: $cmd"
    
    if log_command "$cmd" "$show_output"; then
        log_success "命令执行成功: $cmd"
        return 0
    else
        log_error "命令执行失败: $cmd"
        
        # 额外的错误诊断
        case "$cmd" in
            brew*)
                log_info "建议运行 'brew doctor' 检查 Homebrew 状态"
                ;;
            git*)
                log_info "请检查 Git 配置和网络连接"
                ;;
        esac
        
        return 1
    fi
}

# 批量命令执行
commands=(
    "brew update"
    "brew upgrade"
    "brew cleanup"
)

for cmd in "${commands[@]}"; do
    if ! log_command "$cmd"; then
        log_warn "命令失败，继续执行下一个: $cmd"
    fi
done
```

### 4. 日志管理功能

#### 日志文件初始化

```bash
# 使用默认设置（日志写入 $TMPDIR/macsetup-logs/macsetup-YYYYMMDD.log）
setup_logging

# 自定义日志目录和文件名
setup_logging "/var/log/myapp" "installation.log"

# 完全自定义
setup_logging "/custom/logs" "debug-$(date +%Y%m%d).log" "$LOG_LEVEL_DEBUG"

# 检查初始化结果
if [[ -f "$LOG_FILE_PATH" ]]; then
    log_info "日志系统初始化成功: $LOG_FILE_PATH"
else
    echo "日志系统初始化失败" >&2
    exit 1
fi
```

#### 日志轮转

```bash
# 检查日志大小并轮转
check_log_rotation 50  # 超过50MB时轮转

# 手动轮转
rotate_log

# 获取当前日志大小
size_mb=$(get_log_size)
log_info "当前日志大小: ${size_mb}MB"

# 自动轮转示例
periodic_log_rotation() {
    while true; do
        sleep 3600  # 每小时检查一次
        check_log_rotation 100  # 超过100MB时轮转
    done
}

# 在后台运行轮转检查
periodic_log_rotation &
```

#### 日志清理

```bash
# 清理旧日志文件
cleanup_old_logs "/path/to/log/dir"

# 设置保留的日志文件数量
# 在 logger.sh 中修改 MAX_LOG_FILES 变量

# 手动清理示例
manual_cleanup() {
    local log_dir="$1"
    local keep_days="${2:-7}"
    
    log_info "清理 $keep_days 天前的日志文件"
    
    find "$log_dir" -name "*.log" -mtime +$keep_days -type f | while read -r old_log; do
        log_info "删除旧日志: $(basename "$old_log")"
        rm -f "$old_log"
    done
}
```

### 5. 日志分析功能

#### 生成统计信息

```bash
# 基本统计
log_statistics

# 示例输出:
# === 日志统计信息 ===
# 日志文件: /tmp/macsetup-logs/macsetup-20240101.log
# 总行数: 1250
# INFO: 856
# WARN: 23
# ERROR: 5

# 自定义统计
custom_statistics() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        log_error "日志文件不存在: $log_file"
        return 1
    fi
    
    local total_lines=$(wc -l < "$log_file")
    local debug_count=$(grep -c "\[DEBUG\]" "$log_file" 2>/dev/null || echo 0)
    local info_count=$(grep -c "\[INFO\]" "$log_file" 2>/dev/null || echo 0)
    local warn_count=$(grep -c "\[WARN\]" "$log_file" 2>/dev/null || echo 0)
    local error_count=$(grep -c "\[ERROR\]" "$log_file" 2>/dev/null || echo 0)
    local fatal_count=$(grep -c "\[FATAL\]" "$log_file" 2>/dev/null || echo 0)
    
    echo "=== 详细日志统计 ==="
    echo "文件: $log_file"
    echo "总行数: $total_lines"
    echo "DEBUG: $debug_count"
    echo "INFO: $info_count"
    echo "WARN: $warn_count"
    echo "ERROR: $error_count"
    echo "FATAL: $fatal_count"
    
    # 计算错误率
    local total_messages=$((debug_count + info_count + warn_count + error_count + fatal_count))
    if [[ $total_messages -gt 0 ]]; then
        local error_rate=$(( (error_count + fatal_count) * 100 / total_messages ))
        echo "错误率: ${error_rate}%"
    fi
}
```

#### 查看错误日志

```bash
# 显示最近的错误
show_recent_errors

# 显示指定数量的错误
show_recent_errors 20

# 自定义错误分析
analyze_errors() {
    local log_file="$1"
    local error_file="/tmp/errors-$(date +%Y%m%d_%H%M%S).txt"
    
    log_info "分析错误日志..."
    
    # 提取所有错误和致命错误
    grep -E "\[ERROR\]|\[FATAL\]" "$log_file" > "$error_file"
    
    local error_count=$(wc -l < "$error_file")
    
    if [[ $error_count -eq 0 ]]; then
        log_success "没有发现错误"
        return 0
    fi
    
    log_warn "发现 $error_count 个错误"
    
    # 错误分类
    local network_errors=$(grep -c "网络\|连接\|下载\|超时" "$error_file" || echo 0)
    local permission_errors=$(grep -c "权限\|Permission\|denied" "$error_file" || echo 0)
    local file_errors=$(grep -c "文件\|目录\|File\|Directory" "$error_file" || echo 0)
    
    echo "错误分类："
    echo "  网络相关: $network_errors"
    echo "  权限相关: $permission_errors" 
    echo "  文件相关: $file_errors"
    
    # 显示最严重的错误
    echo -e "\n最近的错误:"
    tail -10 "$error_file"
    
    rm -f "$error_file"
}
```

## 高级使用示例

### 示例1: 完整的安装日志

```bash
#!/bin/bash
source scripts/core/logger.sh

install_complete_environment() {
    # 初始化日志系统
    setup_logging "logs" "complete-install-$(date +%Y%m%d_%H%M%S).log" "$LOG_LEVEL_INFO"
    
    log_step_start "完整环境安装"
    local overall_start=$(date +%s)
    
    # 系统检查
    log_step_start "系统环境检查"
    if ! system_check; then
        log_fatal "系统环境检查失败，无法继续"
        exit 1
    fi
    log_step_complete "系统环境检查"
    
    # Homebrew 安装
    log_step_start "Homebrew 安装"
    if install_homebrew_with_logging; then
        log_success "Homebrew 安装成功"
    else
        log_error "Homebrew 安装失败"
        return 1
    fi
    log_step_complete "Homebrew 安装"
    
    # 软件包安装
    log_step_start "软件包批量安装"
    install_packages_with_progress
    log_step_complete "软件包批量安装"
    
    # 系统配置
    log_step_start "系统配置应用"
    apply_system_configuration
    log_step_complete "系统配置应用"
    
    local overall_end=$(date +%s)
    local total_duration=$((overall_end - overall_start))
    
    log_step_complete "完整环境安装" "$total_duration"
    
    # 生成安装报告
    generate_installation_report
}

install_packages_with_progress() {
    local packages=("git" "node" "python3" "docker" "kubectl")
    local total=${#packages[@]}
    local failed_packages=()
    
    log_info "开始安装 $total 个软件包"
    
    for ((i=0; i<total; i++)); do
        local package="${packages[i]}"
        local current=$((i+1))
        
        log_progress $current $total "安装: $package"
        
        if install_single_package "$package"; then
            log_success "包安装成功: $package"
        else
            log_error "包安装失败: $package"
            failed_packages+=("$package")
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warn "以下包安装失败: ${failed_packages[*]}"
        log_info "可以稍后手动安装这些包"
    else
        log_success "所有软件包安装成功"
    fi
}

generate_installation_report() {
    log_info "生成安装报告..."
    
    # 生成统计信息
    log_statistics
    
    # 显示系统状态
    log_info "=== 安装后系统状态 ==="
    
    if command -v brew &>/dev/null; then
        local brew_packages=$(brew list --formula | wc -l | tr -d ' ')
        local brew_casks=$(brew list --cask | wc -l | tr -d ' ')
        log_info "Homebrew 包: $brew_packages 个"
        log_info "Homebrew Cask: $brew_casks 个"
    fi
    
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}')
    log_info "磁盘使用率: $disk_usage"
    
    # 检查是否有错误
    show_recent_errors 5
    
    log_success "安装完成！日志文件: $LOG_FILE_PATH"
}
```

### 示例2: 调试模式支持

```bash
#!/bin/bash
source scripts/core/logger.sh

# 调试模式控制
DEBUG_MODE="${DEBUG:-false}"
VERBOSE_MODE="${VERBOSE:-false}"

setup_debug_logging() {
    local log_level="$LOG_LEVEL_INFO"
    
    if [[ "$DEBUG_MODE" == "true" ]]; then
        log_level="$LOG_LEVEL_DEBUG"
        echo "启用调试模式"
    elif [[ "$VERBOSE_MODE" == "true" ]]; then
        log_level="$LOG_LEVEL_INFO"
        echo "启用详细模式"
    fi
    
    setup_logging "logs" "debug-$(date +%Y%m%d_%H%M%S).log" "$log_level"
    
    log_info "日志级别设置为: $(get_log_level_name "$log_level")"
    log_info "调试模式: $DEBUG_MODE"
    log_info "详细模式: $VERBOSE_MODE"
}

debug_function_call() {
    local func_name="$1"
    shift
    local args=("$@")
    
    log_debug "调用函数: $func_name"
    log_debug "参数: ${args[*]}"
    
    local start_time=$(date +%s%N)
    
    # 执行函数
    "$func_name" "${args[@]}"
    local result=$?
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))  # 转换为毫秒
    
    log_debug "函数 $func_name 执行完成"
    log_debug "返回值: $result"
    log_debug "执行时间: ${duration}ms"
    
    return $result
}

# 使用示例
DEBUG=true ./install.sh
```

### 示例3: 日志监控

```bash
#!/bin/bash
source scripts/core/logger.sh

# 实时日志监控
monitor_logs() {
    local log_file="$1"
    local alert_keywords=("ERROR" "FATAL" "failed" "timeout")
    
    log_info "开始监控日志文件: $log_file"
    
    tail -f "$log_file" | while IFS= read -r line; do
        # 检查警告关键词
        for keyword in "${alert_keywords[@]}"; do
            if [[ "$line" =~ $keyword ]]; then
                echo "🚨 检测到问题: $line"
                # 可以在这里添加通知逻辑
                break
            fi
        done
        
        # 显示重要日志
        if [[ "$line" =~ \[ERROR\]|\[FATAL\]|\[WARN\] ]]; then
            echo "$line"
        fi
    done
}

# 日志分析守护进程
log_analyzer_daemon() {
    local log_dir="$1"
    local check_interval="${2:-300}"  # 5分钟
    
    while true; do
        for log_file in "$log_dir"/*.log; do
            if [[ -f "$log_file" ]]; then
                analyze_log_health "$log_file"
            fi
        done
        
        sleep "$check_interval"
    done
}

analyze_log_health() {
    local log_file="$1"
    local error_threshold=10
    local warn_threshold=50
    
    local recent_errors=$(tail -100 "$log_file" | grep -c "\[ERROR\]")
    local recent_warnings=$(tail -100 "$log_file" | grep -c "\[WARN\]")
    
    if [[ $recent_errors -gt $error_threshold ]]; then
        echo "警告: 检测到过多错误 ($recent_errors) 在 $log_file"
    fi
    
    if [[ $recent_warnings -gt $warn_threshold ]]; then
        echo "注意: 检测到过多警告 ($recent_warnings) 在 $log_file"
    fi
}
```

## 配置选项

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `ENABLE_CONSOLE_OUTPUT` | `true` | 是否输出到控制台 |
| `ENABLE_FILE_OUTPUT` | `true` | 是否输出到文件 |
| `MAX_LOG_FILES` | `10` | 保留的最大日志文件数 |

### 日志格式定制

```bash
# 自定义日志格式
customize_log_format() {
    # 修改时间戳格式
    timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    # 添加进程ID
    local pid=$$
    
    # 添加线程信息（如果适用）
    local thread_info="[Thread-$$]"
    
    # 自定义格式
    local formatted_message="[$timestamp] [PID:$pid] [$level_name] $message"
    
    echo "$formatted_message"
}
```

## 最佳实践

1. **合适的日志级别**:
   ```bash
   # 生产环境使用 INFO
   set_log_level "info"
   
   # 开发和调试使用 DEBUG
   set_log_level "debug"
   
   # 关键系统使用 WARN 减少噪音
   set_log_level "warn"
   ```

2. **结构化日志信息**:
   ```bash
   # 好的日志格式
   log_info "开始处理用户请求: user=$username, action=$action, timestamp=$(date)"
   
   # 避免的格式
   log_info "doing stuff"
   ```

3. **错误处理结合日志**:
   ```bash
   process_file() {
       local file="$1"
       
       if [[ ! -f "$file" ]]; then
           log_error "文件不存在: $file"
           return 1
       fi
       
       if ! cp "$file" "$destination"; then
           log_error "文件复制失败: $file -> $destination"
           return 1
       fi
       
       log_success "文件处理完成: $file"
   }
   ```

4. **性能敏感场景的日志**:
   ```bash
   # 避免在循环中使用DEBUG日志影响性能
   for ((i=1; i<=10000; i++)); do
       process_item $i
       # 而不是: log_debug "processing item $i"
   done
   
   # 使用采样或批量日志
   if (( i % 1000 == 0 )); then
       log_debug "处理进度: $i/10000"
   fi
   ```

通过这个日志系统，你可以获得完整的操作可见性，便于调试问题和监控系统状态。