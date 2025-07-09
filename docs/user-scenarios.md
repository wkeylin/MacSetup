# MacSetup 使用场景指南

根据你的工作类型和需求，选择最适合的配置方案。每个场景都为你精心设计了最佳的软件组合和系统设置。

## 🧑‍💻 我是开发者

### 适合你的场景
- 写代码、做软件开发
- 需要各种编程语言和工具
- 经常使用终端和命令行
- 需要与 Git、API、数据库交互

### 一键安装命令
```bash
./init.sh --profile developer --yes
```

### 你将得到什么

#### 🛠 开发工具
- **VS Code** - 强大的代码编辑器
- **iTerm2** - 更好的终端应用
- **Git** - 版本控制必备
- **Docker** - 容器化开发环境
- **Postman** - API 测试工具

#### 💻 编程语言环境
- **Node.js & npm** - JavaScript 开发
- **Python 3** - Python 开发
- **Go** - Go 语言开发
- **Homebrew** - Mac 最好的包管理器

#### ⚙️ 系统优化
- 显示隐藏文件和文件夹
- 显示完整文件路径
- 禁用烦人的文件扩展名警告
- 优化终端和键盘设置

### 安装后你可以
- 立即开始任何编程项目
- 克隆 GitHub 仓库并运行
- 构建和测试应用程序
- 管理数据库和 API

---

## 🎨 我是设计师

### 适合你的场景  
- 做 UI/UX 设计、平面设计
- 需要创意和设计软件
- 处理图片、视频、原型
- 与开发团队协作

### 一键安装命令
```bash
./init.sh --profile designer --yes
```

### 你将得到什么

#### 🎨 设计软件
- **Figma** - 现代 UI 设计工具
- **Sketch** - Mac 经典设计软件
- **Adobe Creative Cloud** - 专业创意套件
- **ImageOptim** - 图片优化工具

#### 🖼 图像处理
- **ImageMagick** - 强大的图像处理
- **FFmpeg** - 视频/音频处理
- **GIMP** - 免费的图像编辑器

#### 💻 协作工具
- **Chrome** - 设计师必备浏览器
- **Slack** - 团队沟通
- **Dropbox** - 文件同步和分享

#### ⚙️ 系统优化
- 优化色彩管理设置
- 安装常用设计字体
- 配置更大的预览图标
- 优化创意工作流程

### 安装后你可以
- 开始任何设计项目
- 与开发团队无缝协作
- 处理各种格式的媒体文件
- 高效管理设计资源

---

## 📚 我是学生/办公用户

### 适合你的场景
- 日常学习、办公工作
- 写文档、做演示、处理数据
- 上网、娱乐、邮件
- 需要稳定可靠的基础工具

### 一键安装命令
```bash
./init.sh --profile basic --yes
```

### 你将得到什么

#### 📄 办公软件
- **Microsoft Office** - Word、Excel、PowerPoint
- **Pages、Numbers、Keynote** - Apple 办公套件
- **PDF Expert** - PDF 阅读和编辑

#### 🌐 浏览和通讯
- **Chrome** - 主力浏览器
- **Firefox** - 备用浏览器
- **Zoom** - 视频会议
- **微信** - 即时通讯

#### 🛠 实用工具
- **Alfred** - 强大的启动器
- **1Password** - 密码管理器
- **The Unarchiver** - 解压缩工具
- **CleanMyMac** - 系统清理

#### ⚙️ 系统优化
- 优化 Dock 和桌面布局
- 设置更好的截图选项
- 配置节能和安全设置
- 优化学习/办公体验

### 安装后你可以
- 处理所有日常办公任务
- 高效管理文件和密码
- 享受清爽整洁的系统
- 专注于学习和工作

---

## 🔧 我想完全自定义

### 适合你的场景
- 有特殊的软件需求
- 想要完全控制安装内容
- 对系统设置有特定要求
- 想要学习和了解每个步骤

### 启动自定义向导
```bash
./init.sh
```
然后选择"自定义配置"

### 自定义步骤

#### 第1步：选择软件类型
- ✅ 是否安装命令行工具？
- ✅ 是否安装图形界面应用？
- ✅ 是否安装 App Store 应用？

#### 第2步：选择系统设置
- ✅ 是否修改 Dock 和 Finder？
- ✅ 是否应用开发者设置？
- ✅ 是否配置安全选项？

#### 第3步：预览和确认
- 📋 查看将要安装的所有内容
- ⏱ 预估安装时间
- ✅ 最终确认开始安装

### 高级自定义选项

#### 创建你的专属配置
```bash
# 第一次设置时保存配置
./init.sh --save-config my-setup

# 以后使用保存的配置
./init.sh --load-config my-setup
```

#### 只做特定操作
```bash
# 只安装软件，不改系统设置
./init.sh --packages-only

# 只修改系统设置，不安装软件
./init.sh --config-only

# 先预览，再决定
./init.sh --dry-run
```

---

## 🏢 团队使用场景

### 为团队创建统一环境

#### 场景：新员工入职
```bash
# 创建公司标准配置
./init.sh --profile company-standard --yes
```

#### 场景：项目团队协作
```bash
# 所有人使用相同的开发环境
./init.sh --config team-project.conf --yes
```

#### 场景：实习生培训
```bash
# 简化的安全配置
./init.sh --profile intern --packages-only
```

### 配置共享和管理

#### 导出当前配置
```bash
./init.sh --export-config > our-team-setup.conf
```

#### 团队配置版本控制
```bash
# 将配置文件加入 Git 仓库
git add configs/team-*.conf
git commit -m "Update team development setup"
```

---

## 💡 选择建议

### 如果你不确定选什么
**推荐：开发者配置**
- 包含最多有用的工具
- 适合各种类型的工作
- 可以随时卸载不需要的软件

### 如果你的网络较慢
**推荐：分步安装**
```bash
# 先安装基础工具
./init.sh --packages-only --basic

# 再安装应用程序
./init.sh --apps-only

# 最后配置系统
./init.sh --config-only
```

### 如果你在公司网络
**推荐：检查网络限制**
```bash
# 先测试网络
./init.sh --network-test

# 使用企业友好的配置
./init.sh --profile enterprise
```

### 如果你是 Mac 新手
**推荐：基础配置 + 向导**
```bash
./init.sh --profile basic --interactive
```

---

## 🔄 配置更新和维护

### 更新已安装的软件
```bash
# 更新所有 Homebrew 软件
brew update && brew upgrade

# 更新 Mac App Store 应用
mas upgrade
```

### 添加新软件到现有配置
```bash
# 只安装新添加的软件
./init.sh --update-only
```

### 重置到初始状态
```bash
# 恢复系统设置
./init.sh --restore-defaults

# 卸载所有安装的软件
./init.sh --uninstall-all
```

---

**下一步**：选择你的场景并开始使用，或查看 [常见问题解答](user-faq.md) 了解更多信息。