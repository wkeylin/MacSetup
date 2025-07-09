# MacSetup 使用手册

欢迎使用 MacSetup！这个工具可以帮你快速把一台全新的 Mac 变成理想的工作环境。无论你是开发者、设计师还是普通用户，都能找到适合的配置。

## 🎯 我能用 MacSetup 做什么？

### 一键安装你需要的所有软件
- **开发工具**：VS Code、Git、Node.js、Python、Docker 等
- **设计软件**：Figma、Sketch、Adobe Creative Cloud 等
- **日常应用**：Chrome、Zoom、1Password、Alfred 等
- **命令行工具**：各种让终端更强大的工具

### 优化系统设置
- 让 Dock 和 Finder 更好用
- 优化键盘和触控板设置
- 配置更好的截图选项
- 增强安全和隐私设置

### 自动化配置
- 省去手动下载安装的繁琐
- 避免遗漏重要软件
- 团队保持一致的开发环境
- 新 Mac 或重装系统后快速恢复

---

## 🚀 马上开始

### 最简单的方式（推荐新手）
```bash
./init.sh
```
这会启动一个友好的向导，一步步引导你完成设置。

### 如果你知道自己想要什么
```bash
# 开发者环境
./init.sh --profile developer --yes

# 设计师环境  
./init.sh --profile designer --yes

# 基础办公环境
./init.sh --profile basic --yes
```

### 如果你想先看看会做什么
```bash
./init.sh --dry-run
```
这会显示将要安装的内容，但不会实际安装。

---

## 🎯 选择你的使用场景

### 👨‍💻 我是开发者
**推荐使用开发者配置**

会安装：
- 📦 **开发工具**：Git、VS Code、iTerm2、Docker
- 🔧 **编程语言**：Node.js、Python、Go
- 🗄 **数据库**：PostgreSQL、Redis、MySQL
- ⚙️ **系统优化**：显示隐藏文件、优化终端

```bash
./init.sh --profile developer
```

### 🎨 我是设计师
**推荐使用设计师配置**

会安装：
- 🎨 **设计软件**：Figma、Sketch、Adobe Creative Cloud
- 🖼 **图像工具**：ImageOptim、GIMP
- 💻 **协作工具**：Slack、Dropbox、Zoom
- ⚙️ **系统优化**：色彩管理、字体管理

```bash
./init.sh --profile designer
```

### 📚 我是学生/办公用户
**推荐使用基础配置**

会安装：
- 📄 **办公软件**：Microsoft Office、Pages、Numbers
- 🌐 **浏览器**：Chrome、Firefox
- 📊 **实用工具**：Alfred、1Password、CleanMyMac
- ⚙️ **系统优化**：基础效率设置

```bash
./init.sh --profile basic
```

### 🔧 我想完全自定义
**使用交互式向导**

你可以：
- ✅ 选择具体要安装哪些软件
- ✅ 决定是否修改系统设置  
- ✅ 控制每一个安装细节

```bash
./init.sh
# 然后选择"自定义配置"
```

---

## ⚡️ 常用命令

### 基础使用
```bash
# 启动向导（最安全的方式）
./init.sh

# 查看帮助
./init.sh --help

# 查看版本信息
./init.sh --version
```

### 使用预设配置
```bash
# 开发者配置
./init.sh --profile developer

# 设计师配置
./init.sh --profile designer

# 基础配置
./init.sh --profile basic

# 查看所有可用配置
./init.sh --list-profiles
```

### 部分安装
```bash
# 只安装软件，不改系统设置
./init.sh --packages-only

# 只修改系统设置，不安装软件
./init.sh --config-only

# 只安装命令行工具
./init.sh --homebrew-only
```

### 预览和调试
```bash
# 预览模式（不实际安装）
./init.sh --dry-run

# 详细输出模式
./init.sh --verbose

# 跳过所有确认
./init.sh --yes
```

---

## 🛠 自定义你的配置

### 创建你的软件清单

**步骤 1：创建软件包列表**
```bash
# 编辑命令行工具列表
nano configs/packages/my-packages.txt
```

在文件中添加你需要的工具：
```
# 我的开发工具
git                    # 版本控制
node                   # JavaScript 运行时
python3                # Python 编程
docker                 # 容器技术

# 我的实用工具
wget                   # 下载工具
tree                   # 显示目录结构
htop                   # 系统监控
```

**步骤 2：创建应用程序列表**
```bash
# 编辑应用程序列表
nano configs/packages/my-apps.txt
```

```
# 我的应用程序
visual-studio-code     # 代码编辑器
google-chrome          # 浏览器
slack                  # 团队沟通
spotify                # 音乐
```

**步骤 3：创建配置方案**
```bash
# 创建个人配置
nano configs/profiles/my-setup.conf
```

```bash
# 我的个人配置方案
PACKAGES_FILE="my-packages.txt"
CASKS_FILE="my-apps.txt"

# 安装选项
INSTALL_HOMEBREW="true"
INSTALL_PACKAGES="true"
INSTALL_CASKS="true"
CONFIGURE_SYSTEM="true"

# 个人偏好
PARALLEL_INSTALL="true"
DEVELOPER_MODE="true"
```

**步骤 4：使用你的配置**
```bash
# 预览你的配置
./init.sh --config configs/profiles/my-setup.conf --dry-run

# 应用你的配置
./init.sh --config configs/profiles/my-setup.conf
```

---

## 🌐 使用远程配置

### 什么是远程配置？

远程配置允许你从网络上下载并使用他人创建的配置方案，非常适合：
- **团队协作**：统一团队的开发环境
- **社区分享**：使用专家推荐的配置
- **多机同步**：在多台 Mac 上保持一致的环境

### 查看可用配置

```bash
# 查看所有可用的社区配置
./init.sh --remote list
```

你会看到类似这样的列表：
```
可用的社区配置:
  frontend-dev - 前端开发环境配置
    作者: frontend-team
    URL: https://raw.githubusercontent.com/team/configs/main/frontend.conf

  backend-dev - 后端开发环境配置  
    作者: backend-team
    URL: https://raw.githubusercontent.com/team/configs/main/backend.conf
```

### 使用远程配置

**使用社区配置：**
```bash
# 安装指定的社区配置
./init.sh --remote install frontend-dev
```

**直接使用 URL：**
```bash
# 从任何 URL 下载配置
./init.sh --remote use https://raw.githubusercontent.com/your-team/configs/main/team-config.conf
```

### 团队配置分享

**为团队创建配置：**

1. 创建团队配置文件
2. 上传到 GitHub 或公司内网
3. 分享 URL 给团队成员

**团队成员使用：**
```bash
# 新员工一键配置开发环境
./init.sh --remote use https://company.com/configs/developer-setup.conf
```

### 管理远程配置

```bash
# 更新所有缓存的远程配置
./init.sh --remote update

# 清理过期缓存（默认7天）
./init.sh --remote cleanup

# 清理指定天数的缓存
./init.sh --remote cleanup 3
```

---

## 🔄 维护和更新

### 更新已安装的软件
```bash
# 更新所有 Homebrew 软件
brew update && brew upgrade

# 更新 App Store 应用
mas upgrade

# 清理旧版本
brew cleanup
```

### 备份你的配置
```bash
# 导出当前配置
./init.sh --export-config my-backup.conf

# 以后可以用这个配置恢复
./init.sh --config my-backup.conf
```

### 健康检查
```bash
# 检查 Homebrew 状态
brew doctor

# 检查系统更新
softwareupdate -l

# 查看磁盘空间
df -h /
```

---

## 🆘 遇到问题？

### 常见问题快速解决

**安装过程卡住了？**
- 按 `Ctrl+C` 停止
- 重新运行 `./init.sh`（会跳过已安装的）

**某些软件安装失败？**
- 这很正常，MacSetup 会继续安装其他软件
- 稍后可以手动安装失败的软件

**终端显示 "command not found: brew"？**
- 重启终端应用
- 或运行 `source ~/.zshrc`

**应用无法打开，提示安全问题？**
- 系统偏好设置 > 安全性与隐私 > 通用 > 点击"仍要打开"

### 获取更多帮助
- 📖 查看 [常见问题解答](user-faq.md)
- 🔧 查看 [详细故障排除指南](06-troubleshooting-guide.md)
- 💬 [提交问题](https://github.com/your-repo/macsetup/issues)

---

## 🎓 进阶使用

### 团队使用
- 为新员工创建标准化入职配置
- 保持团队开发环境一致
- 项目特定的环境配置

### 多环境管理
- 开发环境、测试环境切换
- 不同项目的工具集
- 个人和工作配置分离

### 自动化和监控
- 定期更新脚本
- 环境健康检查
- 使用情况分析报告

想了解这些高级功能？查看 [进阶使用指南](user-advanced.md)

---

## 📋 命令速查表

| 操作 | 命令 |
|------|------|
| 启动向导 | `./init.sh` |
| 开发者配置 | `./init.sh --profile developer` |
| 设计师配置 | `./init.sh --profile designer` |
| 基础配置 | `./init.sh --profile basic` |
| 预览模式 | `./init.sh --dry-run` |
| 只安装软件 | `./init.sh --packages-only` |
| 只配置系统 | `./init.sh --config-only` |
| 详细输出 | `./init.sh --verbose` |
| 跳过确认 | `./init.sh --yes` |
| 查看帮助 | `./init.sh --help` |
| 更新软件 | `brew update && brew upgrade` |
| 查看远程配置 | `./init.sh --remote list` |
| 使用远程配置 | `./init.sh --remote use URL` |
| 安装社区配置 | `./init.sh --remote install NAME` |

---

## 🌟 为什么选择 MacSetup？

### 💎 节省时间
- 一键安装几十个软件
- 避免重复的手动配置
- 新 Mac 几小时内就能开始工作

### 🔧 专业优化
- 每个配置都经过精心设计
- 基于最佳实践和社区反馈
- 针对不同使用场景优化

### 🛡 安全可靠
- 所有操作都有备份
- 可以随时恢复原始设置
- 只安装来自官方渠道的软件

### 🤝 社区驱动
- 持续更新和改进
- 社区贡献的配置方案
- 开源透明，可以查看所有代码

---

**准备好了吗？** 运行 `./init.sh` 开始你的 Mac 配置之旅！

如果这是你第一次使用，建议从 [快速入门指南](user-quickstart.md) 开始。