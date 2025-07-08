# GitHub Actions Release Workflow

这个目录包含了自动化构建和发布的 GitHub Actions 配置。

## 文件说明

- `release.yml` - 主要的发布工作流，在创建 GitHub Release 时触发

## 发布流程

1. 创建 git tag: `git tag v1.0.0 && git push origin v1.0.0`
2. 在 GitHub 上创建 Release
3. 自动触发构建，生成以下文件：
   - `mac-init-v1.0.0.tar.gz` - 完整源码包（不含文档）
   - `mac-init-lite-v1.0.0.tar.gz` - 轻量版本（仅核心脚本）
   - `mac-init-installer-v1.0.0.sh` - 自解压安装器
   - `install.sh` - 快速安装脚本
   - `checksums.txt` - SHA256 校验和
   - `checksums-sha512.txt` - SHA512 校验和

## 生成的安装方式

### 快速安装
```bash
curl -fsSL https://github.com/用户名/mac-init/releases/latest/download/install.sh | bash
```

### 下载安装器
```bash
wget https://github.com/用户名/mac-init/releases/download/v1.0.0/mac-init-installer-v1.0.0.sh
chmod +x mac-init-installer-v1.0.0.sh
./mac-init-installer-v1.0.0.sh
```

## 自动功能

- ✅ 版本号从 git tag 自动获取
- ✅ 自动生成 changelog（基于 git commits）
- ✅ 排除 docs 目录减少文件大小
- ✅ 生成 SHA256/SHA512 校验和文件
- ✅ 创建自解压安装器
- ✅ 更新 GitHub Release 页面