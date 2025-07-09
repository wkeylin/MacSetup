# MacSetup 核心工具函数库文档

## 概述

核心工具函数库 (`scripts/core/utils.sh`) 是 MacSetup 的基础模块，提供了系统检查、文件操作、用户交互、进度显示等基本功能。所有其他模块都依赖于这个库的功能。

## 功能分类

### 1. 系统检查函数
### 2. 命令和文件操作函数
### 3. 用户交互函数
### 4. 进度显示函数
### 5. 清理和维护函数

---

## 1. 系统检查函数

### 1.1 `check_macos()`

检查当前系统是否为 macOS。

**语法**:
```bash
check_macos
```

**返回值**:
- `0`: 是 macOS 系统
- `1`: 不是 macOS 系统

**示例**:
```bash
if check_macos; then
    echo "在 macOS 系统上运行"
else
    echo "不支持的操作系统"
    exit 1
fi
```

### 1.2 `check_macos_version()`

检查 macOS 版本是否满足最低要求。

**语法**:
```bash
check_macos_version [min_version]
```

**参数**:
- `min_version`: 最低版本要求（默认: "10.15"）

**返回值**:
- `0`: 版本满足要求
- `1`: 版本不满足要求

**示例**:
```bash
# 检查是否为 macOS 11.0 或更高版本
if check_macos_version "11.0"; then
    echo "版本检查通过"
else
    echo "需要 macOS 11.0 或更高版本"
fi

# 使用默认最低版本 (10.15)
if check_macos_version; then
    echo "系统版本合适"
fi
```

### 1.3 `check_network()`

检查网络连接状态。

**语法**:
```bash
check_network
```

**返回值**:
- `0`: 网络连接正常
- `1`: 网络连接异常

**示例**:
```bash
if check_network; then
    echo "网络连接正常"
    proceed_with_download
else
    echo "网络连接异常，请检查网络设置"
    exit 1
fi
```

**测试的主机**:
- www.apple.com
- brew.sh
- github.com

### 1.4 `check_sudo()`

检查是否有管理员权限。

**语法**:
```bash
check_sudo
```

**返回值**:
- `0`: 有管理员权限
- `1`: 无管理员权限

**示例**:
```bash
if check_sudo; then
    echo "有管理员权限"
else
    echo "某些操作需要管理员权限"
    echo "请使用 sudo 运行或以管理员身份登录"
fi
```

---

## 2. 命令和文件操作函数

### 2.1 `is_command_available()`

检查指定命令是否可用。

**语法**:
```bash
is_command_available <command>
```

**参数**:
- `command`: 要检查的命令名

**返回值**:
- `0`: 命令可用
- `1`: 命令不可用

**示例**:
```bash
if is_command_available "git"; then
    echo "Git 已安装"
    git --version
else
    echo "Git 未安装，正在安装..."
    install_git
fi

# 检查多个命令
commands=("git" "node" "python3")
for cmd in "${commands[@]}"; do
    if is_command_available "$cmd"; then
        echo "✅ $cmd 可用"
    else
        echo "❌ $cmd 不可用"
    fi
done
```

### 2.2 `safe_mkdir()`

安全地创建目录。

**语法**:
```bash
safe_mkdir <directory>
```

**参数**:
- `directory`: 要创建的目录路径

**功能**:
- 如果目录不存在则创建
- 自动创建父目录
- 输出创建信息

**示例**:
```bash
# 创建单个目录
safe_mkdir "/path/to/new/directory"

# 创建多个目录
directories=("logs" "backups" "configs/custom")
for dir in "${directories[@]}"; do
    safe_mkdir "$dir"
done
```

### 2.3 `backup_file()`

备份文件或目录。

**语法**:
```bash
backup_file <source> [backup_name]
```

**参数**:
- `source`: 要备份的文件或目录
- `backup_name`: 备份文件名（可选，默认使用原文件名）

**返回值**:
- `0`: 备份成功
- `1`: 源文件不存在

**示例**:
```bash
# 备份配置文件
backup_file "$HOME/.zshrc"

# 备份到指定名称
backup_file "$HOME/.gitconfig" "gitconfig-before-changes"

# 备份目录
backup_file "$HOME/.ssh" "ssh-backup"

# 检查备份是否成功
if backup_file "$HOME/.vimrc"; then
    echo "配置文件已备份"
    # 现在可以安全地修改原文件
    modify_vimrc
else
    echo "源文件不存在，跳过备份"
fi
```

### 2.4 `create_symlink()`

创建符号链接。

**语法**:
```bash
create_symlink <source> <target> [force]
```

**参数**:
- `source`: 源文件或目录
- `target`: 目标链接路径
- `force`: 是否强制覆盖（"true"/"false"，默认: "false"）

**返回值**:
- `0`: 创建成功
- `1`: 创建失败

**示例**:
```bash
# 创建基本符号链接
create_symlink "/path/to/source" "/path/to/link"

# 强制覆盖已存在的目标
create_symlink "/path/to/source" "/path/to/link" "true"

# 批量创建 dotfiles 链接
dotfiles=(".vimrc" ".gitconfig" ".zshrc")
for file in "${dotfiles[@]}"; do
    source_file="$PWD/configs/dotfiles/$file"
    target_file="$HOME/$file"
    
    if create_symlink "$source_file" "$target_file" "true"; then
        echo "✅ 已链接 $file"
    else
        echo "❌ 链接失败 $file"
    fi
done
```

### 2.5 `download_file()`

下载文件（带重试机制）。

**语法**:
```bash
download_file <url> <destination> [max_retries]
```

**参数**:
- `url`: 下载地址
- `destination`: 保存路径
- `max_retries`: 最大重试次数（默认: 3）

**返回值**:
- `0`: 下载成功
- `1`: 下载失败

**示例**:
```bash
# 基本下载
download_file "https://example.com/file.zip" "/tmp/file.zip"

# 设置重试次数
download_file "https://example.com/large.zip" "/tmp/large.zip" 5

# 下载多个文件
files=(
    "https://example.com/file1.zip:/tmp/file1.zip"
    "https://example.com/file2.tar.gz:/tmp/file2.tar.gz"
)

for file_info in "${files[@]}"; do
    IFS=':' read -r url dest <<< "$file_info"
    if download_file "$url" "$dest"; then
        echo "✅ 下载成功: $(basename "$dest")"
    else
        echo "❌ 下载失败: $(basename "$dest")"
    fi
done
```

---

## 3. 用户交互函数

### 3.1 `confirm()`

询问用户确认。

**语法**:
```bash
confirm [prompt] [default]
```

**参数**:
- `prompt`: 提示信息（默认: "是否继续"）
- `default`: 默认选择（"y"/"n"，默认: "n"）

**返回值**:
- `0`: 用户选择是
- `1`: 用户选择否

**示例**:
```bash
# 基本确认
if confirm; then
    echo "用户选择继续"
fi

# 自定义提示信息
if confirm "是否安装 Homebrew"; then
    install_homebrew
fi

# 设置默认为"是"
if confirm "是否继续安装" "y"; then
    proceed_installation
fi

# 在脚本中使用
dangerous_operation() {
    if confirm "此操作将删除所有数据，确定继续吗" "n"; then
        rm -rf /path/to/data
        echo "数据已删除"
    else
        echo "操作已取消"
    fi
}
```

### 3.2 `show_menu()`

显示选择菜单。

**语法**:
```bash
show_menu <title> <option1> <option2> ...
```

**参数**:
- `title`: 菜单标题
- `option1, option2, ...`: 菜单选项

**示例**:
```bash
# 创建简单菜单
options=("安装开发工具" "配置系统" "退出")
show_menu "请选择操作" "${options[@]}"

# 完整的菜单交互示例
main_menu() {
    local options=(
        "完整安装"
        "仅安装软件"
        "仅配置系统"
        "自定义安装"
        "退出"
    )
    
    show_menu "MacSetup 主菜单" "${options[@]}"
    local choice
    choice=$(get_choice ${#options[@]})
    
    case $choice in
        1) full_installation ;;
        2) packages_only ;;
        3) config_only ;;
        4) custom_installation ;;
        5) exit 0 ;;
    esac
}
```

### 3.3 `get_choice()`

获取用户的数字选择。

**语法**:
```bash
get_choice <max_number>
```

**参数**:
- `max_number`: 最大可选择的数字

**返回值**: 通过 stdout 输出用户选择的数字

**示例**:
```bash
# 配合 show_menu 使用
options=("选项1" "选项2" "选项3")
show_menu "选择一个选项" "${options[@]}"
choice=$(get_choice ${#options[@]})

echo "用户选择了选项 $choice: ${options[$((choice-1))]}"

# 处理用户选择
case $choice in
    1) handle_option1 ;;
    2) handle_option2 ;;
    3) handle_option3 ;;
esac
```

---

## 4. 进度显示函数

### 4.1 `show_progress()`

显示进度条。

**语法**:
```bash
show_progress <current> <total> [task_description]
```

**参数**:
- `current`: 当前进度
- `total`: 总数
- `task_description`: 任务描述（默认: "处理中"）

**示例**:
```bash
# 基本进度显示
total=100
for ((i=1; i<=total; i++)); do
    show_progress $i $total "安装软件包"
    sleep 0.1  # 模拟工作
done

# 文件处理进度
files=("file1.txt" "file2.txt" "file3.txt" "file4.txt")
total=${#files[@]}

for ((i=0; i<total; i++)); do
    current=$((i+1))
    show_progress $current $total "处理文件: ${files[i]}"
    
    # 实际的文件处理
    process_file "${files[i]}"
done

finish_progress
```

### 4.2 `finish_progress()`

完成进度显示。

**语法**:
```bash
finish_progress
```

**示例**:
```bash
# 在进度完成后调用
for ((i=1; i<=10; i++)); do
    show_progress $i 10 "安装进度"
    install_package "package$i"
done
finish_progress
echo "所有软件包安装完成"
```

---

## 5. 清理和维护函数

### 5.1 `cleanup()`

清理临时文件。

**语法**:
```bash
cleanup [temp_pattern]
```

**参数**:
- `temp_pattern`: 临时文件模式（默认: "/tmp/macsetup-*"）

**示例**:
```bash
# 清理默认临时文件
cleanup

# 清理指定模式的文件
cleanup "/tmp/my-app-*"

# 在脚本结束时自动清理
trap cleanup EXIT
```

### 5.2 `setup_cleanup()`

设置退出时自动清理。

**语法**:
```bash
setup_cleanup
```

**示例**:
```bash
# 在脚本开始时设置自动清理
setup_cleanup

# 这样即使脚本异常退出也会清理临时文件
```

---

## 高级使用示例

### 示例1: 完整的安装流程

```bash
#!/bin/bash
source scripts/core/utils.sh

install_application() {
    local app_name="$1"
    local download_url="$2"
    
    # 检查系统要求
    if ! check_macos; then
        echo "错误: 此应用仅支持 macOS"
        return 1
    fi
    
    if ! check_macos_version "10.15"; then
        echo "错误: 需要 macOS 10.15 或更高版本"
        return 1
    fi
    
    # 检查网络
    if ! check_network; then
        echo "错误: 网络连接异常"
        return 1
    fi
    
    # 用户确认
    if ! confirm "是否安装 $app_name" "y"; then
        echo "用户取消安装"
        return 0
    fi
    
    # 创建临时目录
    local temp_dir="/tmp/install-$app_name"
    safe_mkdir "$temp_dir"
    
    # 下载文件
    local download_file="$temp_dir/$(basename "$download_url")"
    echo "正在下载 $app_name..."
    if download_file "$download_url" "$download_file" 3; then
        echo "✅ 下载完成"
    else
        echo "❌ 下载失败"
        return 1
    fi
    
    # 安装过程
    echo "正在安装 $app_name..."
    show_progress 1 3 "解压文件"
    # unzip "$download_file" -d "$temp_dir"
    
    show_progress 2 3 "复制文件"
    # cp -r "$temp_dir/App.app" "/Applications/"
    
    show_progress 3 3 "设置权限"
    # chmod +x "/Applications/App.app/Contents/MacOS/App"
    
    finish_progress
    echo "✅ $app_name 安装完成"
    
    # 清理
    rm -rf "$temp_dir"
}
```

### 示例2: 批量文件处理

```bash
#!/bin/bash
source scripts/core/utils.sh

process_config_files() {
    local config_dir="$1"
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d)"
    
    # 检查源目录
    if [[ ! -d "$config_dir" ]]; then
        echo "错误: 配置目录不存在: $config_dir"
        return 1
    fi
    
    # 创建备份目录
    safe_mkdir "$backup_dir"
    
    # 获取所有配置文件
    local config_files=()
    while IFS= read -r -d '' file; do
        config_files+=("$file")
    done < <(find "$config_dir" -name ".*" -type f -print0)
    
    if [[ ${#config_files[@]} -eq 0 ]]; then
        echo "未找到配置文件"
        return 0
    fi
    
    echo "找到 ${#config_files[@]} 个配置文件"
    
    # 用户确认
    if ! confirm "是否继续处理这些配置文件" "y"; then
        return 0
    fi
    
    # 处理每个文件
    local total=${#config_files[@]}
    for ((i=0; i<total; i++)); do
        local file="${config_files[i]}"
        local filename=$(basename "$file")
        local current=$((i+1))
        
        show_progress $current $total "处理: $filename"
        
        # 备份现有文件
        local home_file="$HOME/$filename"
        if [[ -f "$home_file" ]]; then
            backup_file "$home_file" "$filename.backup"
        fi
        
        # 创建符号链接
        create_symlink "$file" "$home_file" "true"
        
        sleep 0.1  # 避免显示过快
    done
    
    finish_progress
    echo "✅ 配置文件处理完成"
    echo "备份位置: $backup_dir"
}
```

### 示例3: 交互式系统检查

```bash
#!/bin/bash
source scripts/core/utils.sh

system_health_check() {
    echo "开始系统健康检查..."
    
    local checks=(
        "macOS 系统检查"
        "macOS 版本检查"
        "网络连接检查"
        "管理员权限检查"
        "磁盘空间检查"
    )
    
    local results=()
    local total=${#checks[@]}
    
    for ((i=0; i<total; i++)); do
        local current=$((i+1))
        local check="${checks[i]}"
        
        show_progress $current $total "$check"
        
        case $i in
            0)  # macOS 检查
                if check_macos; then
                    results+=("✅ $check")
                else
                    results+=("❌ $check")
                fi
                ;;
            1)  # 版本检查
                if check_macos_version "10.15"; then
                    local version=$(sw_vers -productVersion)
                    results+=("✅ $check: $version")
                else
                    results+=("⚠️ $check: 版本过低")
                fi
                ;;
            2)  # 网络检查
                if check_network; then
                    results+=("✅ $check")
                else
                    results+=("❌ $check")
                fi
                ;;
            3)  # 权限检查
                if check_sudo; then
                    results+=("✅ $check")
                else
                    results+=("⚠️ $check: 无管理员权限")
                fi
                ;;
            4)  # 磁盘空间检查
                local available_gb
                available_gb=$(df -g / | awk 'NR==2 {print $4}')
                if [[ ${available_gb:-0} -gt 5 ]]; then
                    results+=("✅ $check: ${available_gb}GB 可用")
                else
                    results+=("⚠️ $check: 磁盘空间不足")
                fi
                ;;
        esac
        
        sleep 0.5
    done
    
    finish_progress
    
    # 显示结果
    echo -e "\n系统检查结果:"
    for result in "${results[@]}"; do
        echo "  $result"
    done
}
```

## 环境变量

核心工具函数库使用以下全局变量：

| 变量名 | 说明 |
|--------|------|
| `SCRIPT_DIR` | 脚本根目录路径 |
| `BACKUP_DIR` | 备份目录路径 |
| `RED`, `GREEN`, `YELLOW`, `BLUE`, `PURPLE`, `CYAN`, `NC` | 终端颜色代码 |

## 最佳实践

1. **总是检查返回值**:
   ```bash
   if check_macos_version "11.0"; then
       # 继续执行
   else
       echo "系统版本不符合要求"
       exit 1
   fi
   ```

2. **使用进度显示增强用户体验**:
   ```bash
   for ((i=1; i<=total; i++)); do
       show_progress $i $total "处理项目 $i"
       # 执行实际工作
   done
   finish_progress
   ```

3. **始终备份重要文件**:
   ```bash
   if backup_file "$important_file"; then
       # 安全地修改文件
       modify_file "$important_file"
   fi
   ```

4. **设置自动清理**:
   ```bash
   setup_cleanup  # 在脚本开始时调用
   ```

通过这些工具函数，你可以构建稳定、用户友好的 Mac 初始化脚本。