# Mac Init 主入口脚本使用文档

## 概述

`init.sh` 是 Mac Init 的主入口脚本，提供完整的 Mac 电脑自动初始化功能。它集成了所有模块，支持交互式和非交互式使用方式。

## 基本用法

### 最简单的使用方式

```bash
# 交互式安装（推荐新手使用）
./init.sh
```

这将启动交互式向导，引导你完成整个配置过程。

### 快速安装

```bash
# 使用默认配置，跳过所有确认
./init.sh --yes

# 使用开发者配置方案
./init.sh --profile developer --yes
```

## 命令行选项详解

### 基本选项

| 选项 | 长选项 | 说明 |
|------|--------|------|
| `-h` | `--help` | 显示帮助信息 |
| `-v` | `--version` | 显示版本信息 |
| `-i` | `--interactive` | 启用交互式模式（默认） |
| `-y` | `--yes` | 跳过所有确认提示 |

**示例：**
```bash
# 查看帮助
./init.sh --help

# 查看版本
./init.sh --version

# 自动确认所有操作
./init.sh --yes
```

### 配置选项

| 选项 | 长选项 | 参数 | 说明 |
|------|--------|------|------|
| `-p` | `--profile` | NAME | 使用指定的配置方案 |
| `-c` | `--config` | FILE | 使用自定义配置文件 |
| | `--list-profiles` | | 列出所有可用配置方案 |

**示例：**
```bash
# 使用内置配置方案
./init.sh --profile developer
./init.sh --profile designer
./init.sh --profile basic

# 使用自定义配置文件
./init.sh --config /path/to/my-config.conf

# 查看可用配置方案
./init.sh --list-profiles
```

### 执行模式

| 选项 | 说明 |
|------|------|
| `--packages-only` | 仅安装软件包，跳过系统配置 |
| `--config-only` | 仅进行系统配置，跳过软件安装 |
| `--dotfiles-only` | 仅安装 dotfiles 配置 |
| `--homebrew-only` | 仅安装 Homebrew 相关内容 |
| `--system-only` | 仅进行系统设置 |

**示例：**
```bash
# 只安装软件包
./init.sh --packages-only

# 只配置系统设置
./init.sh --config-only

# 只安装开发工具
./init.sh --homebrew-only --profile developer
```

### 安装选项控制

| 选项 | 说明 |
|------|------|
| `--no-homebrew` | 跳过 Homebrew 安装 |
| `--no-packages` | 跳过命令行工具包安装 |
| `--no-casks` | 跳过 GUI 应用安装 |
| `--no-appstore` | 跳过 App Store 应用安装 |
| `--enable-appstore` | 启用 App Store 应用安装 |
| `--no-system-config` | 跳过系统配置 |

**示例：**
```bash
# 安装软件但不配置系统
./init.sh --no-system-config

# 只安装命令行工具，不安装 GUI 应用
./init.sh --no-casks --no-appstore

# 启用 App Store 应用安装
./init.sh --enable-appstore --profile developer
```

### 调试和日志选项

| 选项 | 长选项 | 参数 | 说明 |
|------|--------|------|------|
| | `--dry-run` | | 预览模式，不实际执行 |
| | `--verbose` | | 启用详细输出 |
| | `--log-file` | FILE | 指定日志文件路径 |

**示例：**
```bash
# 预览安装过程
./init.sh --dry-run --profile developer

# 详细输出模式
./init.sh --verbose

# 自定义日志文件
./init.sh --log-file /tmp/my-install.log --verbose

# 组合使用
./init.sh --dry-run --verbose --profile developer
```

## 使用场景和示例

### 场景1：新手第一次使用

```bash
# 启动交互式向导
./init.sh
```

系统会引导你：
1. 选择配置方案（基础/开发者/设计师/自定义）
2. 确认安装选项
3. 预览安装内容
4. 开始安装

### 场景2：开发者快速设置

```bash
# 使用开发者配置，跳过确认
./init.sh --profile developer --yes --verbose
```

这将：
- 安装开发工具和环境
- 配置开发者友好的系统设置
- 显示详细的安装过程

### 场景3：仅安装软件不改变系统

```bash
# 只安装软件包，不修改系统设置
./init.sh --packages-only --profile developer
```

### 场景4：测试和预览

```bash
# 预览完整安装过程
./init.sh --dry-run --profile developer --verbose

# 预览自定义配置
./init.sh --dry-run --config my-config.conf
```

### 场景5：分步执行

```bash
# 第一步：只安装 Homebrew 和包
./init.sh --homebrew-only --profile developer

# 第二步：配置系统（稍后执行）
./init.sh --config-only --profile developer
```

### 场景6：故障排除

```bash
# 启用详细日志进行故障排除
./init.sh --verbose --log-file debug.log

# 检查日志
tail -f logs/debug.log
```

## 交互式向导详解

### 配置方案选择

当你运行 `./init.sh` 时，会看到：

```
请选择配置方案:
1. 默认配置 (基础软件和设置)
2. 开发者配置 (开发工具和环境)  
3. 设计师配置 (设计软件和工具)
4. 自定义配置 (手动选择)
```

### 自定义配置向导

选择"自定义配置"后，系统会询问：

1. **软件安装选项：**
   - 是否安装 Homebrew 包管理器？
   - 是否安装命令行工具包？
   - 是否安装 GUI 应用程序？
   - 是否安装 App Store 应用？

2. **系统配置选项：**
   - 是否配置系统设置（Dock, Finder 等）？
   - 是否安装配置文件（dotfiles）？

### 安装预览

在开始安装前，系统会显示：

```
=== 安装预览 ===
将执行以下步骤:
1. 安装 Homebrew 包管理器
2. 安装 15 个命令行工具包
3. 安装 8 个 GUI 应用程序
4. 配置系统设置
```

## 配置文件优先级

配置的应用顺序（后者覆盖前者）：

1. **默认配置** - 内置的基础配置
2. **配置方案文件** - `--profile` 指定的方案
3. **自定义配置文件** - `--config` 指定的文件
4. **命令行参数** - 直接传递的参数

**示例：**
```bash
# 使用开发者方案，但跳过系统配置
./init.sh --profile developer --no-system-config
```

## 环境变量支持

你也可以通过环境变量控制行为：

```bash
# 设置默认配置方案
export MAC_INIT_PROFILE="developer"

# 跳过确认
export MAC_INIT_YES="true"

# 启用详细输出
export MAC_INIT_VERBOSE="true"

# 然后运行
./init.sh
```

## 执行结果和日志

### 安装完成后的输出

```
🎉 Mac 初始化完成！
总耗时: 1245秒

=== 安装摘要 ===
Homebrew 包: 28 个
Homebrew Cask 应用: 12 个

详细日志: /path/to/logs/mac-init-20240101_120000.log

建议的下一步操作:
1. 重启终端或重新登录以确保环境变量生效
2. 运行 brew doctor 检查 Homebrew 状态
3. 检查系统偏好设置确认配置已生效
4. 备份文件位置: /Users/username/.mac-init-backup-20240101_120000
```

### 日志文件位置

- **默认位置：** `logs/mac-init-YYYYMMDD_HHMMSS.log`
- **自定义位置：** 通过 `--log-file` 指定
- **备份位置：** `~/.mac-init-backup-YYYYMMDD_HHMMSS/`

## 错误处理

### 常见错误和解决方案

1. **权限错误**
   ```bash
   # 给脚本添加执行权限
   chmod +x init.sh
   ```

2. **网络连接问题**
   ```bash
   # 检查网络连接
   ping www.apple.com
   ```

3. **Homebrew 安装失败**
   ```bash
   # 手动清理后重试
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
   ./init.sh --homebrew-only
   ```

### 中断和恢复

- **中断安装：** 按 `Ctrl+C`
- **恢复安装：** 重新运行相同命令，脚本会跳过已安装的内容
- **完全重置：** 删除 `~/.mac-init-backup-*` 目录和相关配置

## 最佳实践

1. **首次使用建议：**
   ```bash
   # 先预览，再执行
   ./init.sh --dry-run --profile developer
   ./init.sh --profile developer
   ```

2. **大型安装建议：**
   ```bash
   # 启用详细日志
   ./init.sh --verbose --log-file install.log --profile developer
   ```

3. **网络较慢时：**
   ```bash
   # 分步执行，避免超时
   ./init.sh --packages-only --profile developer
   ./init.sh --config-only --profile developer
   ```

4. **自定义场景：**
   ```bash
   # 创建并使用自己的配置
   ./init.sh --profile my-custom
   # 编辑生成的配置文件
   ./init.sh --profile my-custom --yes
   ```