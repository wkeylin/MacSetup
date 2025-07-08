# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Mac computer software and configuration initialization repository (mac电脑软件、配置初始化). The repository is designed to automate Mac setup through configuration files and scripts.

## Repository Structure

- `configs/` - Configuration files for Mac applications and system settings (dotfiles, preferences, etc.)
- `scripts/` - Automation scripts for installing software and applying configurations
- `README.md` - Project description in Chinese

## Current State

The repository is in an initial/empty state with only the basic directory structure in place. Both `configs/` and `scripts/` directories are currently empty and ready for content.

## Development Context

This appears to be a template or starter repository for Mac initialization. When working with this repository, expect to:
- Add shell scripts for software installation and system configuration
- Store dotfiles and application configurations in the `configs/` directory
- Create automation scripts that reference files in `configs/`

## Common Patterns for Mac Init Repositories

- Shell scripts (.sh) for Homebrew package installation
- Configuration files for development tools (git, zsh, vim, etc.)
- Symlink creation scripts for dotfiles
- System preference automation via `defaults` commands