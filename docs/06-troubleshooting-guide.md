# Mac Init 故障排除指南

## 概述

本指南涵盖了使用 Mac Init 过程中可能遇到的常见问题及其解决方案。建议按照问题分类查找对应的解决方法。

## 目录

1. [安装前检查](#1-安装前检查)
2. [Homebrew 相关问题](#2-homebrew-相关问题)
3. [软件包安装问题](#3-软件包安装问题)
4. [系统配置问题](#4-系统配置问题)
5. [权限和安全问题](#5-权限和安全问题)
6. [网络连接问题](#6-网络连接问题)
7. [性能和日志问题](#7-性能和日志问题)
8. [配置文件问题](#8-配置文件问题)

---

## 1. 安装前检查

### 1.1 系统要求检查

**问题**: 不确定系统是否满足要求
**解决方案**:

```bash
# 检查 macOS 版本
sw_vers -productVersion

# 检查系统架构
uname -m

# 检查可用磁盘空间
df -h /

# 检查网络连接
ping -c 3 github.com
ping -c 3 brew.sh
```

**最低要求**:
- macOS 10.15 (Catalina) 或更高版本
- 至少 5GB 可用磁盘空间
- 稳定的网络连接

### 1.2 权限检查

**问题**: 脚本无法执行
**解决方案**:

```bash
# 给脚本添加执行权限
chmod +x init.sh

# 检查文件权限
ls -la init.sh

# 如果需要管理员权限的操作，确保可以使用 sudo
sudo -v
```

### 1.3 环境清理

**问题**: 之前的安装可能有冲突
**解决方案**:

```bash
# 检查是否已安装 Homebrew
which brew

# 如果需要重新安装，先卸载旧版本
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# 清理可能的缓存
rm -rf ~/.cache/Homebrew
rm -rf /tmp/mac-init-*
```

---

## 2. Homebrew 相关问题

### 2.1 Homebrew 安装失败

#### 问题：网络连接超时
```
curl: (7) Failed to connect to raw.githubusercontent.com port 443: Operation timed out
```

**解决方案**:
```bash
# 方法1: 使用国内镜像安装
./init.sh --verbose
# 在交互模式中选择国内镜像

# 方法2: 手动切换网络或使用代理
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890

# 方法3: 直接使用国内安装脚本
/bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```

#### 问题：权限错误
```
Permission denied @ dir_s_mkdir - /opt/homebrew
```

**解决方案**:
```bash
# 方法1: 修复目录权限 (Apple Silicon)
sudo chown -R $(whoami) /opt/homebrew

# 方法2: 修复目录权限 (Intel)
sudo chown -R $(whoami) /usr/local

# 方法3: 创建目录并设置权限
sudo mkdir -p /opt/homebrew
sudo chown -R $(whoami) /opt/homebrew
```

#### 问题：Xcode Command Line Tools 未安装
```
xcode-select: error: invalid developer directory '/Applications/Xcode.app/Contents/Developer'
```

**解决方案**:
```bash
# 安装 Xcode Command Line Tools
xcode-select --install

# 如果已安装但路径错误，重置路径
sudo xcode-select --reset

# 验证安装
xcode-select -p
```

### 2.2 Homebrew 环境问题

#### 问题：brew 命令找不到
```
command not found: brew
```

**解决方案**:
```bash
# 检查 Homebrew 安装路径
ls -la /opt/homebrew/bin/brew    # Apple Silicon
ls -la /usr/local/bin/brew       # Intel

# 手动添加到 PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc  # Apple Silicon
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc         # Intel

# 重新加载 shell 配置
source ~/.zshrc

# 或者重启终端
```

#### 问题：brew doctor 报告问题
```
Warning: You have unlinked kegs in your Cellar.
```

**解决方案**:
```bash
# 查看详细警告信息
brew doctor

# 修复常见问题
brew cleanup
brew link --overwrite --dry-run  # 预览
brew link --overwrite            # 实际执行

# 更新 Homebrew 本身
brew update
```

---

## 3. 软件包安装问题

### 3.1 单个包安装失败

#### 问题：包不存在
```
Error: No available formula with name "package-name"
```

**解决方案**:
```bash
# 搜索正确的包名
brew search package-name
brew search --cask package-name

# 更新包列表
brew update

# 检查是否需要添加 tap
brew tap homebrew/cask-fonts
brew tap homebrew/cask-drivers
```

#### 问题：依赖冲突
```
Error: Cannot install package due to conflicting dependencies
```

**解决方案**:
```bash
# 查看冲突详情
brew install package-name --verbose

# 强制重新安装
brew uninstall package-name
brew install package-name

# 解决依赖问题
brew doctor
brew cleanup
```

#### 问题：版本锁定
```
Error: package-name X.Y.Z is already installed
```

**解决方案**:
```bash
# 强制重新安装
brew reinstall package-name

# 升级到最新版本
brew upgrade package-name

# 安装特定版本
brew install package-name@version
```

### 3.2 Cask 应用安装问题

#### 问题：应用需要密码确认
```
installer: Package name is AppName
installer: Installing at base path /
installer: The install was successful.
```

**解决方案**:
```bash
# 确保以管理员权限运行
sudo ./init.sh --casks-only

# 或者在交互模式中手动输入密码
./init.sh --interactive
```

#### 问题：应用被系统阻止
```
"AppName.app" can't be opened because Apple cannot check it for malicious software.
```

**解决方案**:
```bash
# 方法1: 在系统偏好设置中允许
# 系统偏好设置 -> 安全性与隐私 -> 通用 -> 允许从以下位置下载的应用

# 方法2: 命令行移除 quarantine 属性
sudo xattr -r -d com.apple.quarantine /Applications/AppName.app

# 方法3: 重新安装应用
brew uninstall --cask app-name
brew install --cask app-name
```

### 3.3 批量安装问题

#### 问题：部分包安装失败但脚本继续
**这是正常行为**，Mac Init 会继续安装其他包并在最后报告失败的包。

**查看失败详情**:
```bash
# 使用详细模式重新运行
./init.sh --packages-only --verbose --log-file debug.log

# 查看日志中的错误信息
grep -i error logs/debug.log
grep -i failed logs/debug.log
```

**手动安装失败的包**:
```bash
# 根据日志中的失败列表手动安装
brew install failed-package-1
brew install failed-package-2
```

---

## 4. 系统配置问题

### 4.1 系统设置未生效

#### 问题：Dock 或 Finder 设置没有变化
**解决方案**:
```bash
# 手动重启相关服务
sudo killall Dock
sudo killall Finder
sudo killall SystemUIServer

# 如果仍未生效，注销重新登录
sudo launchctl bootout user/$(id -u)
```

#### 问题：defaults 命令执行失败
```
Could not write domain com.apple.dock; exiting
```

**解决方案**:
```bash
# 检查目标域是否存在
defaults domains | grep -i dock

# 创建空的配置文件
touch ~/Library/Preferences/com.apple.dock.plist

# 修复权限
chmod 644 ~/Library/Preferences/com.apple.dock.plist
```

### 4.2 权限相关的配置问题

#### 问题：某些系统设置需要更高权限
```
Operation not permitted
```

**解决方案**:
```bash
# 检查系统完整性保护状态
csrutil status

# 在系统偏好设置中授予权限
# 系统偏好设置 -> 安全性与隐私 -> 隐私 -> 完全磁盘访问

# 对于某些设置，需要在恢复模式中禁用 SIP（不推荐）
```

### 4.3 配置备份和恢复问题

#### 问题：备份文件损坏或无法恢复
**解决方案**:
```bash
# 检查备份文件
ls -la ~/.mac-init-backup-*/system-defaults/

# 手动验证备份文件
plutil -lint ~/.mac-init-backup-*/system-defaults/com.apple.dock.plist

# 手动恢复单个设置
defaults import com.apple.dock ~/.mac-init-backup-*/system-defaults/com.apple.dock.plist
```

---

## 5. 权限和安全问题

### 5.1 sudo 权限问题

#### 问题：脚本要求 sudo 但用户不在 admin 组
```
user is not in the sudoers file. This incident will be reported.
```

**解决方案**:
```bash
# 检查当前用户的组
groups $(whoami)

# 如果不在 admin 组，请系统管理员添加
# 或者跳过需要 sudo 的操作
./init.sh --no-system-config
```

### 5.2 网络安全限制

#### 问题：企业网络阻止某些下载
```
curl: (7) Failed to connect to github.com port 443: Connection refused
```

**解决方案**:
```bash
# 配置代理
export https_proxy=http://proxy.company.com:8080
export http_proxy=http://proxy.company.com:8080

# 使用内网镜像源
./init.sh --verbose  # 选择合适的镜像源

# 或者手动下载后离线安装
```

### 5.3 防火墙和杀毒软件干扰

#### 问题：杀毒软件阻止脚本执行
**解决方案**:
- 将 Mac Init 目录添加到杀毒软件白名单
- 暂时禁用实时保护（安装完成后重新启用）
- 使用 `--dry-run` 模式先检查要执行的操作

---

## 6. 网络连接问题

### 6.1 网络超时

#### 问题：下载过程中网络中断
```
curl: (28) Operation timed out after 30000 milliseconds
```

**解决方案**:
```bash
# 增加重试次数和超时时间
export HOMEBREW_CURL_RETRIES=3
export HOMEBREW_CURL_TIMEOUT=300

# 使用更稳定的网络
# 或者分批安装，避免长时间下载
./init.sh --packages-only --verbose

# 恢复中断的安装（脚本会跳过已安装的包）
./init.sh --packages-only
```

### 6.2 DNS 解析问题

#### 问题：无法解析域名
```
curl: (6) Could not resolve host: github.com
```

**解决方案**:
```bash
# 更换 DNS 服务器
sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 1.1.1.1
sudo networksetup -setdnsservers Ethernet 8.8.8.8 1.1.1.1

# 刷新 DNS 缓存
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# 测试 DNS 解析
nslookup github.com
```

### 6.3 代理配置问题

#### 问题：代理设置不正确
**解决方案**:
```bash
# 检查当前代理设置
env | grep -i proxy

# 设置代理
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
export no_proxy=localhost,127.0.0.1

# 取消代理设置
unset http_proxy https_proxy no_proxy

# 为 Homebrew 单独设置代理
export HOMEBREW_HTTP_PROXY=http://proxy.example.com:8080
export HOMEBREW_HTTPS_PROXY=http://proxy.example.com:8080
```

---

## 7. 性能和日志问题

### 7.1 安装速度慢

#### 问题：安装过程非常缓慢
**解决方案**:
```bash
# 启用并行安装
./init.sh --verbose  # 在配置中启用并行安装

# 调整并发数
# 在配置方案中设置 MAX_PARALLEL_JOBS="2"  # 网络较慢时

# 使用国内镜像源
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
```

### 7.2 内存不足

#### 问题：安装过程中系统变慢或报内存不足
**解决方案**:
```bash
# 减少并发数
# 在配置方案中设置 MAX_PARALLEL_JOBS="1"

# 分批安装
./init.sh --packages-only
# 等待完成后再执行
./init.sh --config-only

# 监控内存使用
top -o MEM
```

### 7.3 日志问题

#### 问题：日志文件过大或找不到日志
**解决方案**:
```bash
# 查找日志文件
find . -name "*.log" -type f

# 查看日志大小
ls -lh logs/

# 清理旧日志
find logs/ -name "*.log" -mtime +7 -delete

# 设置自定义日志位置
./init.sh --log-file /tmp/my-install.log
```

---

## 8. 配置文件问题

### 8.1 配置文件语法错误

#### 问题：配置文件格式不正确
```
parse error: Invalid or unexpected token
```

**解决方案**:
```bash
# 验证配置文件语法
source scripts/core/config.sh
validate_config "configs/profiles/my-profile.conf" "profile"

# 检查常见错误
# 1. 确保变量名大写
# 2. 字符串值用双引号包围
# 3. 布尔值使用 "true"/"false"
# 4. 没有多余的空格或特殊字符

# 使用模板创建新配置
cp configs/profiles/developer.conf configs/profiles/my-profile.conf
```

### 8.2 包列表错误

#### 问题：软件包名称错误
**解决方案**:
```bash
# 验证包列表
source scripts/core/config.sh
validate_config "configs/packages/homebrew.txt" "package"

# 搜索正确的包名
brew search partial-name
brew search --cask partial-name

# 检查包是否可用
brew info package-name
brew info --cask app-name
```

### 8.3 路径问题

#### 问题：配置文件路径不正确
**解决方案**:
```bash
# 使用绝对路径
./init.sh --config /full/path/to/config.conf

# 使用相对路径（从项目根目录）
./init.sh --config configs/profiles/my-profile.conf

# 检查文件是否存在
ls -la configs/profiles/my-profile.conf
```

---

## 9. 紧急恢复

### 9.1 系统配置恢复

#### 问题：系统配置导致严重问题
**解决方案**:
```bash
# 使用备份恢复
source scripts/configurers/system.sh
restore_system_defaults

# 手动恢复 Dock 设置
defaults delete com.apple.dock
killall Dock

# 手动恢复 Finder 设置
defaults delete com.apple.finder
killall Finder

# 在安全模式下启动 Mac
# 开机时按住 Shift 键
```

### 9.2 完全重置

#### 问题：需要完全清理 Mac Init 的所有更改
**解决方案**:
```bash
# 卸载 Homebrew（如果需要）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# 恢复系统配置
rm -rf ~/.mac-init-backup-*  # 谨慎操作
# 注销重新登录

# 清理 Mac Init 文件
rm -rf mac-init/
rm -rf ~/.mac-init-*

# 重置 shell 配置
# 编辑 ~/.zshrc 或 ~/.bash_profile，移除 Homebrew 相关行
```

---

## 10. 获取帮助

### 10.1 收集诊断信息

当需要寻求帮助时，请收集以下信息：

```bash
# 系统信息
sw_vers
uname -a
system_profiler SPSoftwareDataType

# Mac Init 版本和配置
./init.sh --version
cat configs/profiles/your-profile.conf

# 错误日志
tail -50 logs/mac-init-*.log

# Homebrew 状态（如果安装了）
brew doctor
brew config
```

### 10.2 常用调试命令

```bash
# 详细模式运行
./init.sh --verbose --dry-run

# 逐步运行
./init.sh --packages-only --verbose
./init.sh --config-only --verbose

# 检查特定组件
source scripts/installers/homebrew.sh
check_homebrew_installed

source scripts/configurers/system.sh
verify_system_config
```

### 10.3 社区资源

- **GitHub Issues**: 报告 bug 和功能请求
- **文档**: 查看详细的使用文档
- **示例配置**: 参考其他用户的配置方案

记住：大多数问题都可以通过仔细阅读错误信息和检查日志文件来解决。如果问题持续存在，请使用 `--verbose` 和 `--dry-run` 模式来获取更多信息。