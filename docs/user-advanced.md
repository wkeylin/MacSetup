# Mac Init 进阶使用指南

当你熟悉了基础操作后，Mac Init 还提供了许多高级功能，让你可以打造完全个性化的 Mac 环境。

## 🎯 创建你的专属配置

### 我想要一个完全符合我需求的配置

#### 步骤 1：分析你的需求
在创建配置前，先想想你的工作流程：

**开发者的思考清单**：
- 我主要用什么编程语言？
- 我需要哪些数据库？
- 我用什么设计工具？
- 我的团队用什么协作工具？

**设计师的思考清单**：
- 我做什么类型的设计？
- 我需要哪些 Adobe 软件？
- 我怎么与开发者协作？
- 我需要什么硬件支持？

**学生的思考清单**：
- 我的专业需要什么软件？
- 我需要处理什么类型的文件？
- 我的学习习惯是什么？
- 我的预算有限制吗？

#### 步骤 2：创建软件清单

**创建你的软件列表**：
```bash
# 创建自定义软件包列表
nano configs/packages/my-packages.txt
```

在文件中添加你需要的软件：
```
# 我的专属软件包配置
# 核心开发工具
git                    # 必备版本控制
node                   # 我主要用 JavaScript
python3                # 数据分析需要

# 我的特殊需求
ffmpeg                 # 我经常处理视频
imagemagick            # 图片批处理
postgresql             # 我们项目用的数据库

# 团队协作
slack                  # 团队沟通
notion                 # 项目管理
```

**创建应用列表**：
```bash
nano configs/packages/my-apps.txt
```

```
# 我的专属应用配置
visual-studio-code     # 主力编辑器
iterm2                 # 更好的终端
figma                  # UI 设计工具
discord                # 社区交流
spotify                # 工作时听音乐
```

#### 步骤 3：创建配置方案
```bash
nano configs/profiles/my-perfect-setup.conf
```

```bash
# 我的完美配置方案
PACKAGES_FILE="my-packages.txt"
CASKS_FILE="my-apps.txt"

# 我的偏好设置
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
INSTALL_CASKS="true"
CONFIGURE_SYSTEM="true"

# 个性化选项
PARALLEL_INSTALL="true"        # 我网络很快
MAX_PARALLEL_JOBS="6"          # 我的 Mac 性能很好
DEVELOPER_MODE="true"          # 我需要看到隐藏文件
CONFIGURE_SECURITY="false"     # 我不想太严格的安全设置
```

#### 步骤 4：测试和完善
```bash
# 先预览一下
./init.sh --config configs/profiles/my-perfect-setup.conf --dry-run

# 满意了就正式安装
./init.sh --config configs/profiles/my-perfect-setup.conf --yes
```

---

## 🏢 团队和企业使用

### 为你的团队创建标准化环境

#### 场景：新员工入职标准化

**创建入职配置**：
```bash
# configs/profiles/company-onboarding.conf
# 公司新员工入职标准配置

# 必备开发工具
PACKAGES_FILE="company-dev-tools.txt"
CASKS_FILE="company-apps.txt"

# 公司安全要求
CONFIGURE_SECURITY="true"
ENABLE_FIREWALL="true"
REQUIRE_PASSWORD="true"

# 统一的开发环境
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
CONFIGURE_SYSTEM="true"
```

**团队软件标准**：
```bash
# configs/packages/company-dev-tools.txt
# 公司开发工具标准

# 版本控制（必装）
git
git-lfs

# 我们的技术栈
node@18                # 锁定 Node.js 版本
python@3.11            # 锁定 Python 版本
docker                 # 容器化开发

# 公司内部工具
kubectl                # 我们用 Kubernetes
terraform              # 基础设施管理
aws-cli                # 我们用 AWS
```

**一键入职命令**：
```bash
./init.sh --config configs/profiles/company-onboarding.conf --yes
```

#### 场景：项目特定环境

**为特定项目创建环境**：
```bash
# configs/profiles/project-alpha.conf
# Alpha 项目开发环境

PACKAGES_FILE="project-alpha-tools.txt"
PROJECT_NAME="alpha"
BRANCH_POLICY="strict"

# 项目特定需求
DATABASE="postgresql@13"
NODEJS_VERSION="16.20.0"
PYTHON_VERSION="3.9.18"
```

**项目切换脚本**：
```bash
#!/bin/bash
# switch-project.sh - 项目环境切换

case "$1" in
    "alpha")
        ./init.sh --config configs/profiles/project-alpha.conf --update-only
        ;;
    "beta")
        ./init.sh --config configs/profiles/project-beta.conf --update-only
        ;;
    *)
        echo "用法: ./switch-project.sh [alpha|beta]"
        ;;
esac
```

---

## 🔄 维护和更新

### 保持你的环境最新

#### 定期更新所有软件
```bash
# 创建更新脚本
nano update-my-mac.sh
```

```bash
#!/bin/bash
# 我的 Mac 定期更新脚本

echo "🔄 开始更新 Mac 环境..."

# 更新 Homebrew 本身
echo "📦 更新 Homebrew..."
brew update

# 更新所有 Homebrew 软件
echo "⬆️ 更新所有软件包..."
brew upgrade

# 更新 App Store 应用
echo "🍎 更新 App Store 应用..."
mas upgrade

# 清理旧版本
echo "🧹 清理旧文件..."
brew cleanup

# 检查系统健康
echo "🏥 检查系统健康..."
brew doctor

echo "✅ 更新完成！"
```

#### 备份你的配置
```bash
# 定期备份当前配置
./init.sh --export-config "backup-$(date +%Y%m%d).conf"

# 备份重要的配置文件
cp ~/.zshrc ~/backup/zshrc-$(date +%Y%m%d)
cp ~/.gitconfig ~/backup/gitconfig-$(date +%Y%m%d)
```

#### 环境健康检查
```bash
# 创建健康检查脚本
nano health-check.sh
```

```bash
#!/bin/bash
# Mac 环境健康检查

echo "🔍 检查 Mac 环境健康状态..."

# 检查磁盘空间
echo "💾 磁盘空间:"
df -h /

# 检查 Homebrew 状态
echo "🍺 Homebrew 状态:"
brew doctor

# 检查重要软件版本
echo "📊 软件版本:"
echo "Git: $(git --version)"
echo "Node.js: $(node --version 2>/dev/null || echo '未安装')"
echo "Python: $(python3 --version 2>/dev/null || echo '未安装')"

# 检查系统更新
echo "🔄 系统更新:"
softwareupdate -l

echo "✅ 健康检查完成！"
```

---

## 🎨 个性化系统设置

### 深度定制你的 Mac

#### 创建个人系统配置脚本
```bash
nano configs/system/my-personal-settings.sh
```

```bash
#!/bin/bash
# 我的个人系统设置

echo "🎨 应用个人系统设置..."

# 我喜欢的 Dock 设置
defaults write com.apple.dock "tilesize" -int "72"          # 更大的图标
defaults write com.apple.dock "orientation" -string "left"   # 放在左边
defaults write com.apple.dock "autohide" -bool "true"       # 自动隐藏

# 我的 Finder 偏好
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "ShowStatusBar" -bool "true"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# 我的截图设置
mkdir -p ~/Desktop/Screenshots
defaults write com.apple.screencapture "location" -string "~/Desktop/Screenshots"
defaults write com.apple.screencapture "type" -string "png"

# 我喜欢的键盘设置
defaults write NSGlobalDomain "KeyRepeat" -int "1"           # 最快重复
defaults write NSGlobalDomain "InitialKeyRepeat" -int "10"   # 短延迟

# 重启相关服务
killall Dock
killall Finder

echo "✅ 个人设置应用完成！"
```

#### 主题和外观定制
```bash
# 安装我喜欢的字体
brew install --cask font-fira-code
brew install --cask font-jetbrains-mono

# 安装主题管理器
brew install --cask themeengine

# 设置深色模式
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
```

---

## 🚀 高级自动化

### 让 Mac Init 更智能

#### 条件化安装
```bash
# configs/profiles/smart-setup.conf
# 智能配置 - 根据情况自动选择

# 检测网络环境
if ping -c 1 -W 3000 "github.com" &> /dev/null; then
    USE_CHINA_MIRROR="false"
    INSTALL_SPEED="fast"
else
    USE_CHINA_MIRROR="true"
    INSTALL_SPEED="slow"
fi

# 根据 Mac 型号调整
if [[ "$(uname -m)" == "arm64" ]]; then
    # M1/M2 Mac 优化
    MAX_PARALLEL_JOBS="8"
    ENABLE_ROSETTA="true"
else
    # Intel Mac 设置
    MAX_PARALLEL_JOBS="4"
    ENABLE_ROSETTA="false"
fi

# 根据可用空间调整
AVAILABLE_SPACE=$(df -g / | awk 'NR==2 {print $4}')
if [[ $AVAILABLE_SPACE -lt 20 ]]; then
    INSTALL_MODE="minimal"
else
    INSTALL_MODE="full"
fi
```

#### 多环境配置切换
```bash
# 创建环境切换器
nano switch-env.sh
```

```bash
#!/bin/bash
# 多环境配置切换器

show_menu() {
    echo "🔧 选择你的工作环境:"
    echo "1) 开发环境"
    echo "2) 设计环境" 
    echo "3) 学习环境"
    echo "4) 演示环境"
    echo "5) 重置到默认"
}

switch_to_dev() {
    echo "🧑‍💻 切换到开发环境..."
    ./init.sh --config configs/profiles/development.conf --update-only
    # 启动开发服务
    brew services start postgresql
    brew services start redis
}

switch_to_design() {
    echo "🎨 切换到设计环境..."
    ./init.sh --config configs/profiles/design.conf --update-only
    # 优化图形性能
    sudo pmset -c gpuswitch 2  # 强制使用独立显卡
}

switch_to_learning() {
    echo "📚 切换到学习环境..."
    ./init.sh --config configs/profiles/learning.conf --update-only
    # 启用专注模式
    do-not-disturb on
}

# 主菜单
show_menu
read -p "请选择 (1-5): " choice

case $choice in
    1) switch_to_dev ;;
    2) switch_to_design ;;
    3) switch_to_learning ;;
    4) switch_to_demo ;;
    5) ./init.sh --restore-defaults ;;
    *) echo "无效选择" ;;
esac
```

---

## 📊 监控和分析

### 了解你的使用情况

#### 创建使用情况报告
```bash
nano usage-report.sh
```

```bash
#!/bin/bash
# Mac 使用情况分析报告

echo "📊 生成 Mac 使用情况报告..."

# 安装的软件统计
echo "=== 已安装软件 ==="
echo "Homebrew 包: $(brew list --formula | wc -l | tr -d ' ') 个"
echo "GUI 应用: $(brew list --cask | wc -l | tr -d ' ') 个"
echo "App Store 应用: $(mas list | wc -l | tr -d ' ') 个"

# 最常用的软件
echo -e "\n=== 最常用的命令行工具 ==="
history | awk '{print $2}' | sort | uniq -c | sort -nr | head -10

# 系统资源使用
echo -e "\n=== 系统资源 ==="
echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
echo "内存: $(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2 $3}')"
echo "磁盘使用: $(df -h / | awk 'NR==2 {print $5}')"

# 网络使用情况
echo -e "\n=== 最近的下载 ==="
find ~/Downloads -name "*.dmg" -o -name "*.pkg" -o -name "*.zip" | head -5

echo -e "\n📈 报告生成完成！"
```

#### 性能优化建议
```bash
nano optimize-performance.sh
```

```bash
#!/bin/bash
# Mac 性能优化建议

echo "⚡️ 分析 Mac 性能..."

# 检查启动项
echo "🚀 启动项分析:"
launchctl list | grep -v com.apple | wc -l | xargs echo "非系统启动项:" 

# 检查内存使用
MEMORY_PRESSURE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print $5}' | tr -d '%')
if [[ $MEMORY_PRESSURE -lt 20 ]]; then
    echo "⚠️ 内存压力较高，建议关闭一些应用"
fi

# 检查磁盘空间
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [[ $DISK_USAGE -gt 80 ]]; then
    echo "⚠️ 磁盘空间不足，建议清理"
    echo "💡 可以运行: brew cleanup"
    echo "💡 可以清理: ~/Downloads, ~/Desktop"
fi

# 检查 Homebrew 健康状态
if brew doctor &>/dev/null; then
    echo "✅ Homebrew 状态良好"
else
    echo "⚠️ Homebrew 需要维护，运行: brew doctor"
fi

echo "✅ 性能分析完成！"
```

---

## 🔐 安全和备份

### 保护你的配置和数据

#### 配置版本控制
```bash
# 将配置文件加入 Git 管理
cd mac-init
git init
git add configs/
git commit -m "我的 Mac 配置初始版本"

# 推送到私人仓库（保护隐私）
git remote add origin https://github.com/你的用户名/my-mac-setup.git
git push -u origin main
```

#### 敏感信息管理
```bash
# 创建敏感信息配置
nano configs/secrets/personal.conf
```

```bash
# 个人敏感配置（不要提交到 Git）
GITHUB_TOKEN="你的token"
AWS_ACCESS_KEY="你的密钥"
DATABASE_PASSWORD="你的密码"

# 加入 .gitignore
echo "configs/secrets/" >> .gitignore
```

#### 定期备份脚本
```bash
nano backup-everything.sh
```

```bash
#!/bin/bash
# 完整备份脚本

BACKUP_DIR="$HOME/mac-init-backup-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

echo "💾 开始完整备份..."

# 备份配置文件
cp -r configs/ "$BACKUP_DIR/"

# 备份重要的点文件
cp ~/.zshrc "$BACKUP_DIR/"
cp ~/.gitconfig "$BACKUP_DIR/"
cp ~/.ssh/config "$BACKUP_DIR/" 2>/dev/null || true

# 备份已安装软件列表
brew list --formula > "$BACKUP_DIR/installed-packages.txt"
brew list --cask > "$BACKUP_DIR/installed-apps.txt"
mas list > "$BACKUP_DIR/appstore-apps.txt"

# 压缩备份
tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

echo "✅ 备份完成: $BACKUP_DIR.tar.gz"
```

---

## 🌟 分享和贡献

### 与社区分享你的配置

#### 创建可分享的配置包
```bash
# 创建分享包
nano create-share-package.sh
```

```bash
#!/bin/bash
# 创建可分享的配置包

SHARE_NAME="$1"
if [[ -z "$SHARE_NAME" ]]; then
    echo "用法: ./create-share-package.sh 包名"
    exit 1
fi

SHARE_DIR="share-packages/$SHARE_NAME"
mkdir -p "$SHARE_DIR"

# 复制配置文件（移除敏感信息）
cp configs/profiles/my-setup.conf "$SHARE_DIR/setup.conf"
cp configs/packages/*.txt "$SHARE_DIR/"

# 创建说明文件
cat > "$SHARE_DIR/README.md" << EOF
# $SHARE_NAME 配置包

这是我的 Mac 配置分享，适合：
- 描述适用场景
- 列出主要软件
- 注意事项

## 使用方法
\`\`\`bash
./init.sh --config share-packages/$SHARE_NAME/setup.conf
\`\`\`
EOF

echo "✅ 分享包创建完成: $SHARE_DIR"
```

#### 贡献到社区
```bash
# 提交你的配置到社区仓库
git fork https://github.com/mac-init/community-configs
git clone https://github.com/你的用户名/community-configs
cd community-configs

# 添加你的配置
cp -r ../share-packages/我的配置 ./community/

# 提交 Pull Request
git add .
git commit -m "添加：我的配置包"
git push origin main
```

---

**恭喜！** 你现在已经掌握了 Mac Init 的高级用法。你可以：
- 🎯 创建完全个性化的配置
- 🏢 为团队建立标准化环境  
- 🔄 自动化维护和更新
- 🎨 深度定制系统设置
- 📊 监控和优化性能
- 🔐 安全地管理配置
- 🌟 与社区分享经验

继续探索和实验，打造最适合你的 Mac 环境！