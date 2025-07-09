# MacSetup - macOS 自动化配置工具

<div align="center">

**🚀 一键配置你的 Mac，从全新系统到完美工作环境**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![macOS](https://img.shields.io/badge/macOS-11%2B-blue.svg)](https://www.apple.com/macos/)

[快速开始](#-快速开始) • [功能特性](#-功能特性) • [使用指南](#-使用指南) • [配置方案](#-配置方案) • [贡献](#-贡献)

</div>

---

## ✨ 什么是 MacSetup？

MacSetup 是一个强大的 macOS 自动化配置工具，可以帮你快速把一台全新的 Mac 变成理想的工作环境。无论你是开发者、设计师还是普通用户，都能找到适合的配置方案。

### 🎯 核心价值

- **⚡️ 节省时间** - 几小时完成原本需要几天的软件安装和配置
- **🔧 专业优化** - 基于最佳实践的系统设置和开发环境
- **🤝 团队协作** - 统一团队开发环境，新人快速上手
- **🛡 安全可靠** - 完整的备份恢复机制，可随时还原

---

## 🚀 快速开始

### 系统要求

- macOS 11.0 或更高版本
- 管理员权限
- 稳定的网络连接

### 安装运行

```bash
# 1. 克隆仓库
git clone https://github.com/your-username/macsetup.git
cd macsetup

# 2. 给脚本添加执行权限
chmod +x init.sh

# 3. 启动交互式向导（推荐首次使用）
./init.sh
```

### 一键配置（如果你知道自己需要什么）

```bash
# 开发者环境
./init.sh --profile developer --yes

# 设计师环境
./init.sh --profile designer --yes

# 基础办公环境
./init.sh --profile basic --yes
```

---

## 🌟 功能特性

### 📦 软件自动安装

- **🛠 开发工具**: Git, VS Code, Docker, Node.js, Python, Go 等
- **🎨 设计软件**: Figma, Sketch, Adobe Creative Suite 等
- **💻 日常应用**: Chrome, Zoom, 1Password, Alfred 等
- **⚡️ 命令行工具**: 各种提升效率的终端工具

### ⚙️ 系统配置优化

- **🖥 界面优化**: Dock, Finder, 截图设置
- **⌨️ 输入优化**: 键盘, 触控板, 快捷键配置
- **🔒 安全增强**: 防火墙, 屏保密码, 隐私设置
- **👨‍💻 开发者设置**: 显示隐藏文件, 开发环境优化

### 🌐 远程配置支持

- **👥 团队配置**: 统一团队开发环境
- **🔄 配置同步**: 多台设备保持一致
- **📚 社区配置**: 使用专家推荐的配置方案

### 🛡 备份与恢复

- **📥 自动备份**: 应用配置前自动备份原始设置
- **🔄 一键恢复**: 随时还原到初始状态
- **📋 变更追踪**: 详细记录所有配置变更

---

## 🎯 配置方案

### 👨‍💻 开发者配置 (`developer`)

**适合**: 软件开发者、DevOps 工程师

**包含软件**:
- 开发工具: Git, VS Code, iTerm2, Docker, Postman
- 编程语言: Node.js, Python, Go, Rust
- 数据库: PostgreSQL, Redis, MySQL
- 云工具: AWS CLI, kubectl, terraform

**系统优化**:
- 显示隐藏文件和完整路径
- 优化终端和开发环境设置
- 增强安全和隐私配置

### 🎨 设计师配置 (`designer`)

**适合**: UI/UX 设计师、平面设计师

**包含软件**:
- 设计工具: Figma, Sketch, Adobe Creative Cloud
- 协作工具: Slack, Dropbox, Zoom
- 图像处理: ImageOptim, GIMP
- 字体管理: FontExplorer X

**系统优化**:
- 色彩管理和显示设置
- 创意工作流程优化
- 文件管理和预览增强

### 📚 基础配置 (`basic`)

**适合**: 学生、办公用户、轻度用户

**包含软件**:
- 办公软件: Microsoft Office, Pages, Numbers
- 浏览器: Chrome, Firefox
- 实用工具: Alfred, 1Password, CleanMyMac
- 媒体工具: VLC, Spotify

**系统优化**:
- 基础效率和易用性设置
- 简化的界面和交互
- 安全和隐私基础配置

---

## 📖 使用指南

### 基础命令

```bash
# 启动交互式向导
./init.sh

# 使用特定配置方案
./init.sh --profile developer

# 预览模式（不实际安装）
./init.sh --dry-run

# 详细输出模式
./init.sh --verbose

# 跳过所有确认
./init.sh --yes
```

### 部分安装

```bash
# 只安装软件，不修改系统设置
./init.sh --packages-only

# 只修改系统设置，不安装软件  
./init.sh --config-only

# 只安装 Homebrew 和命令行工具
./init.sh --homebrew-only
```

### 远程配置

```bash
# 查看可用的社区配置
./init.sh --remote list

# 使用社区配置
./init.sh --remote install frontend-dev

# 从 URL 使用配置
./init.sh --remote use https://example.com/config.conf
```

### 自定义配置

```bash
# 使用自定义配置文件
./init.sh --config /path/to/my-config.conf

# 查看所有可用配置方案
./init.sh --list-profiles
```

---

## 🔧 高级功能

### 创建自定义配置

1. **创建软件包列表**
   ```bash
   # 编辑包列表
   nano configs/packages/my-packages.txt
   
   # 添加你需要的软件
   git
   node  
   docker
   ```

2. **创建配置方案**
   ```bash
   # 创建配置文件
   nano configs/profiles/my-profile.conf
   
   # 配置安装选项
   PACKAGES_FILE="my-packages.txt"
   INSTALL_HOMEBREW="true"
   CONFIGURE_SYSTEM="true"
   ```

3. **使用自定义配置**
   ```bash
   ./init.sh --config configs/profiles/my-profile.conf
   ```

### 团队配置分享

1. **创建团队配置并上传到 GitHub**
2. **团队成员一键配置**:
   ```bash
   ./init.sh --remote use https://raw.githubusercontent.com/team/configs/main/team-setup.conf
   ```

---

## 📁 项目结构

```
macsetup/
├── init.sh                    # 主入口脚本
├── scripts/                   # 核心脚本模块
│   ├── core/                  # 核心功能模块
│   │   ├── utils.sh          # 工具函数
│   │   ├── logger.sh         # 日志系统  
│   │   ├── config.sh         # 配置管理
│   │   └── remote-config.sh  # 远程配置
│   ├── installers/           # 安装器模块
│   │   └── homebrew.sh       # Homebrew 安装器
│   └── configurers/          # 配置器模块
│       └── system.sh         # 系统配置器
├── configs/                  # 配置文件
│   ├── packages/             # 软件包列表
│   ├── profiles/             # 配置方案
│   └── system/               # 系统配置脚本
├── docs/                     # 用户文档
│   ├── user-quickstart.md    # 快速入门
│   ├── user-guide.md         # 使用手册
│   ├── user-scenarios.md     # 使用场景
│   ├── user-faq.md          # 常见问题
│   └── user-advanced.md     # 进阶指南
└── logs/                     # 日志文件
```

---

## 🆘 常见问题

### 安装过程中断了怎么办？

重新运行相同命令，MacSetup 会自动跳过已安装的内容：
```bash
./init.sh --profile developer
```

### 某些软件安装失败？

这很正常，MacSetup 会继续安装其他软件。稍后可以手动安装失败的软件或查看日志了解原因。

### 如何卸载已安装的软件？

```bash
# 卸载 Homebrew 软件
brew uninstall package-name

# 卸载应用程序
brew uninstall --cask app-name

# 完全卸载 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

### 如何还原系统设置？

MacSetup 会自动备份原始设置，可以通过以下方式还原：
```bash
# 还原所有系统设置
source scripts/configurers/system.sh
restore_system_defaults
```

更多问题解答请查看 [常见问题文档](docs/user-faq.md)。

---

## 📚 文档

- [📖 使用手册](docs/user-guide.md) - 完整的使用指南
- [🚀 快速入门](docs/user-quickstart.md) - 5分钟上手指南  
- [💡 使用场景](docs/user-scenarios.md) - 场景化使用说明
- [❓ 常见问题](docs/user-faq.md) - 问题排查指南
- [🔧 进阶指南](docs/user-advanced.md) - 高级功能和自定义

---

## 🤝 贡献

我们欢迎所有形式的贡献！

### 如何贡献

1. **Fork 项目**
2. **创建功能分支** (`git checkout -b feature/AmazingFeature`)
3. **提交更改** (`git commit -m 'Add some AmazingFeature'`)
4. **推送分支** (`git push origin feature/AmazingFeature`)
5. **创建 Pull Request**

### 贡献方式

- 🐛 **报告 Bug** - 在 Issues 中报告问题
- 💡 **功能建议** - 提出新功能想法
- 📖 **改进文档** - 完善使用说明
- 🔧 **代码贡献** - 修复 Bug 或添加功能
- 📦 **配置分享** - 分享你的配置方案

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## ⭐️ 支持项目

如果这个项目对你有帮助，请给它一个 ⭐️！

你也可以：
- 🐦 在社交媒体上分享
- 📝 写博客文章介绍
- 💬 告诉你的朋友和同事
- 🤝 参与项目贡献

---

## 📞 联系我们

- 📧 Email: [your-email@example.com](mailto:your-email@example.com)
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/macsetup/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/your-username/macsetup/discussions)

---

<div align="center">

**🚀 准备好配置你的 Mac 了吗？**

[开始使用](docs/user-quickstart.md) • [查看文档](docs/user-guide.md) • [提交问题](https://github.com/your-username/macsetup/issues)

Made with ❤️ by MacSetup Team

</div>