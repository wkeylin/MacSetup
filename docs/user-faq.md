# Mac Init 常见问题解答

## 🤔 使用前的疑问

### Q: Mac Init 安全吗？会不会损坏我的 Mac？
**A: 完全安全！** 
- ✅ 所有操作都有备份，可以随时恢复
- ✅ 只安装来自官方渠道的软件
- ✅ 提供预览模式，你可以先看看会做什么
- ✅ 如果不确定，先用 `./init.sh --dry-run` 预览

### Q: 我的 Mac 已经用了一段时间，还能用 Mac Init 吗？
**A: 当然可以！**
- Mac Init 会自动跳过已经安装的软件
- 现有的文件和设置会被备份
- 建议先用预览模式看看会改变什么

### Q: 需要多长时间？
**A: 通常 20-60 分钟**
- 基础配置：约 20 分钟
- 开发者配置：约 45 分钟  
- 设计师配置：约 60 分钟
- 自定义配置：取决于你选择的内容

### Q: 需要花钱吗？
**A: 大部分是免费的**
- ✅ Mac Init 本身完全免费
- ✅ 大多数软件都是免费的开源软件
- ⚠️ 某些专业软件可能需要付费（如 Adobe 软件）
- ℹ️ 会在安装前告知哪些软件需要付费

---

## 🚀 安装过程中的问题

### Q: 安装过程卡住了，怎么办？
**A: 按 Ctrl+C 停止，然后重新运行**
```bash
# 停止当前安装
按 Ctrl+C

# 重新开始，会跳过已安装的内容
./init.sh
```

### Q: 某些软件安装失败了
**A: 这很正常，不用担心**
- Mac Init 会继续安装其他软件
- 最后会告诉你哪些安装失败了
- 你可以稍后手动安装失败的软件
- 查看 [常见安装失败原因](#安装失败的原因)

### Q: 需要输入密码很多次
**A: 这是正常的安全机制**
- Mac 需要确认安装软件的权限
- 你可以在系统偏好设置中调整密码要求
- 或者使用 `sudo -v` 预先验证一次密码

### Q: 网络很慢，安装很久
**A: 可以分批安装**
```bash
# 先安装最重要的工具
./init.sh --packages-only --essential

# 稍后安装其他应用
./init.sh --apps-only
```

---

## ⚙️ 安装后的问题

### Q: 某些应用打不开，提示安全问题
**A: 这是 Mac 的安全保护，很容易解决**

1. **方法一**：在系统偏好设置中允许
   - 打开"系统偏好设置" > "安全性与隐私" > "通用"
   - 点击"仍要打开"按钮

2. **方法二**：在应用上右键
   - 在 Applications 文件夹中找到应用
   - 右键点击，选择"打开"
   - 在弹出的对话框中确认"打开"

### Q: 终端显示 "command not found: brew"
**A: 需要重启终端或重新加载配置**
```bash
# 方法一：重启终端应用
完全关闭终端，重新打开

# 方法二：重新加载配置
source ~/.zshrc
```

### Q: VS Code 或其他编辑器无法使用某些功能
**A: 可能需要安装额外的组件**
- 打开 VS Code，按 Cmd+Shift+P
- 输入 "Install code command"
- 按照提示安装命令行工具

### Q: Docker 无法启动
**A: 需要启动 Docker Desktop**
- 在 Applications 文件夹中找到 Docker
- 双击启动 Docker Desktop
- 等待鲸鱼图标出现在菜单栏

---

## 🔧 系统设置问题

### Q: Dock 或桌面看起来不一样了
**A: Mac Init 优化了系统设置**
- 这些都是为了更好的使用体验
- 如果不喜欢，可以手动改回来
- 或者运行 `./init.sh --restore-settings`

### Q: 能看到很多之前看不到的文件
**A: Mac Init 启用了显示隐藏文件**
- 这对开发者很有用
- 如果不需要，可以关闭：按 Cmd+Shift+. 切换显示

### Q: 键盘或触控板感觉不一样
**A: 优化了重复速度和灵敏度**
- 可以在"系统偏好设置" > "键盘"和"触控板"中调整
- 或者运行恢复命令恢复默认设置

---

## 🗑 卸载和恢复

### Q: 如何撤销所有更改？
**A: Mac Init 提供了完整的恢复功能**

1. **恢复系统设置**：
```bash
./init.sh --restore-settings
```

2. **卸载所有软件**：
```bash
./init.sh --uninstall-all
```

3. **完全重置**：
```bash
./init.sh --factory-reset
```

### Q: 只想卸载某些软件
**A: 可以手动卸载或选择性卸载**

**卸载 Homebrew 软件**：
```bash
brew uninstall 软件名
```

**卸载应用程序**：
- 拖拽到废纸篓，或使用 App Cleaner

**批量卸载**：
```bash
./init.sh --uninstall --interactive
```

### Q: 如何备份当前配置？
**A: 导出配置用于以后恢复**
```bash
# 导出当前配置
./init.sh --export-config my-perfect-setup.conf

# 以后在新 Mac 上使用
./init.sh --config my-perfect-setup.conf
```

---

## 💻 特定软件问题

### Q: Homebrew 相关问题

**Q: brew doctor 报告警告**
```bash
# 运行诊断
brew doctor

# 通常可以忽略警告，但如果有问题：
brew cleanup
brew update
```

**Q: brew 安装很慢**
```bash
# 使用国内镜像（中国用户）
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
```

### Q: Git 相关问题

**Q: Git 提示配置用户信息**
```bash
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱"
```

**Q: SSH 密钥问题**
```bash
# 生成新的 SSH 密钥
ssh-keygen -t ed25519 -C "你的邮箱"

# 添加到 GitHub
cat ~/.ssh/id_ed25519.pub
# 复制输出的内容到 GitHub 设置中
```

### Q: Node.js/Python 版本问题

**Q: 需要特定版本的 Node.js**
```bash
# 安装 Node.js 版本管理器
brew install nvm

# 安装特定版本
nvm install 16.20.0
nvm use 16.20.0
```

**Q: Python 版本冲突**
```bash
# 查看安装的 Python 版本
python3 --version

# 使用 pyenv 管理多个版本
brew install pyenv
```

---

## 🌐 网络和下载问题

### Q: 下载速度很慢
**A: 尝试以下方法**

1. **检查网络连接**：
```bash
./init.sh --network-test
```

2. **使用国内镜像**（中国用户）：
```bash
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
```

3. **分批安装**：
```bash
./init.sh --packages-only --batch-size 5
```

### Q: 某些网站访问不了
**A: 网络限制或防火墙问题**
- 尝试使用手机热点
- 检查公司网络是否有限制
- 使用 VPN（如果合法）

### Q: 企业网络环境
**A: 可能需要配置代理**
```bash
# 设置代理（询问网络管理员）
export http_proxy=http://proxy.company.com:8080
export https_proxy=http://proxy.company.com:8080
```

---

## 📱 不同 Mac 型号的问题

### Q: M1/M2 Mac 特殊问题
**A: Mac Init 自动处理架构差异**
- 自动选择 ARM 版本的软件
- 某些老软件可能通过 Rosetta 运行
- 性能通常会更好

### Q: 旧款 Intel Mac
**A: 完全支持，但要注意**
- 某些新软件可能不支持老系统
- 建议升级到较新的 macOS 版本
- 可以选择"兼容性"配置

### Q: MacBook Air vs MacBook Pro
**A: 配置会自动优化**
- MacBook Air：更节能的设置
- MacBook Pro：性能优先的设置
- 可以手动切换配置模式

---

## 🆘 还是解决不了？

### 收集信息后寻求帮助

1. **运行诊断**：
```bash
./init.sh --diagnose > 诊断报告.txt
```

2. **收集日志**：
```bash
# 查看最近的错误
./init.sh --show-errors

# 导出完整日志
cp logs/最新日志文件.log ~/Desktop/
```

3. **获取帮助**：
- 📧 发邮件附上诊断报告
- 🐛 在 GitHub 提交 Issue
- 💬 在社区论坛求助

### 紧急情况

**如果 Mac 出现严重问题**：
1. 立即停止运行 Mac Init
2. 重启 Mac 到安全模式（开机时按住 Shift）
3. 运行 `./init.sh --emergency-restore`
4. 联系技术支持

**记住**：绝大多数问题都可以轻松解决，不要担心！Mac Init 设计得很安全，有完整的恢复机制。

---

**还有其他问题？** 查看 [进阶使用指南](user-advanced.md) 或 [联系我们](mailto:support@mac-init.com)。