# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MacSetup is a comprehensive macOS automation tool for quickly configuring new Macs with software installations and system optimizations. The project features a modular shell script architecture with extensive logging, configuration management, and user-friendly interfaces.

## Core Commands

### Main Entry Point
```bash
./init.sh                           # Interactive wizard (recommended)
./init.sh --help                    # Show comprehensive help
./init.sh --list-profiles           # List available configuration profiles
```

### Profile-Based Installation
```bash
./init.sh --profile developer       # Developer environment setup
./init.sh --profile designer        # Designer tools and applications  
./init.sh --profile basic          # Basic office setup
./init.sh --config custom.conf     # Use custom configuration file
```

### Execution Modes
```bash
./init.sh --packages-only           # Install software packages only
./init.sh --config-only             # Apply system configurations only
./init.sh --dry-run                 # Preview mode (no actual installation)
./init.sh --verbose                 # Detailed output with debug info
./init.sh --yes                     # Skip all confirmation prompts
```

### Remote Configuration
```bash
./init.sh --remote list             # List community configurations
./init.sh --remote use URL          # Use configuration from URL
./init.sh --remote install NAME     # Install community configuration
```

## Architecture Overview

### Core Module Structure
- `scripts/core/utils.sh` - System utilities and helper functions
- `scripts/core/logger.sh` - Advanced logging system with multiple levels
- `scripts/core/config.sh` - Configuration management and profile loading
- `scripts/core/remote-config.sh` - Remote configuration handling
- `scripts/installers/homebrew.sh` - Homebrew package management
- `scripts/configurers/system.sh` - macOS system settings configuration

### Configuration System
- `configs/packages/` - Software package lists (homebrew.txt, cask.txt, appstore.txt)
- `configs/profiles/` - Pre-defined configuration profiles (basic.conf, developer.conf, designer.conf)  
- `configs/system/` - System configuration scripts (defaults.sh)
- `configs/dotfiles/` - Configuration file templates

## Key Development Patterns

### Modular Design
Each major function is separated into its own module with consistent error handling and logging. Core utilities provide shared functionality across modules.

### Configuration-Driven Approach
All behavior is controlled through configuration files. Command-line arguments override configuration settings. Supports conditional configurations based on system properties.

### Safety-First Philosophy
- Dry-run mode for previewing operations
- Automatic backup creation before system modifications
- Graceful failure handling with detailed error reporting
- User confirmation for potentially destructive operations

### Logging System
Multi-level logging (DEBUG, INFO, WARN, ERROR, FATAL) with file and console output, automatic log rotation, and built-in error analysis.

## Configuration File Formats

### Package Lists (configs/packages/*.txt)
```bash
git                    # Version control system
node                   # Node.js runtime  
docker                 # Container platform
```

### Profile Configuration (configs/profiles/*.conf)
```bash
PACKAGES_FILE="dev-packages.txt"
CASKS_FILE="dev-apps.txt"
INSTALL_HOMEBREW="true"
CONFIGURE_SYSTEM="true"
DEVELOPER_MODE="true"
```

### App Store Apps (configs/packages/appstore.txt)
```bash
497799835:Xcode        # Apple development tools
```

## Development Workflow

When modifying this codebase:
1. Test changes with `--dry-run` mode first
2. Use the logging system for debugging (`log_debug`, `log_info`, etc.)
3. Follow the modular pattern - add new features as separate modules
4. Update configuration files rather than hardcoding values
5. Ensure all operations support backup and recovery
6. Test on both Intel and Apple Silicon Macs when possible

## System Requirements

- macOS 10.15 (Catalina) or later
- At least 5GB available disk space
- Administrator account privileges
- Stable internet connection