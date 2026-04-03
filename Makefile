.PHONY: all copy-zsh copy-wezterm copy-vscode copy-claude-mcp copy-claude-settings copy-all reload-zsh help install-deps

all: help

DOTFILES_DIR := $(HOME)/.dotfiles
CURRENT_DIR := $(shell pwd)

help:
	@echo "Arda Kılıçdağı's Dotfiles Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  copy-zsh              - Copy .zshrc to ~/.zshrc"
	@echo "  copy-wezterm          - Copy .wezterm.lua to ~/.wezterm.lua"
	@echo "  copy-vscode           - Copy vscode-settings.json to VS Code settings"
	@echo "  copy-claude-mcp       - Copy .claude.json to ~/.claude.json"
	@echo "  copy-claude-settings  - Copy .claude/settings.json to ~/.claude/settings.json"
	@echo "  copy-all              - Copy all config files"
	@echo "  reload-zsh            - Reload zsh configuration"
	@echo "  install-deps          - Install all dependencies via Homebrew"

install-deps:
	@echo "Installing Homebrew dependencies..."
	@brew install --cask wezterm@nightly
	@brew install curl eza bat jaq powerlevel10k zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search
	@brew install --cask font-hack-nerd-font font-firacode-nerd-font
	@echo "All dependencies installed successfully!"

copy-zsh:
	@cp $(CURRENT_DIR)/.zshrc $(HOME)/.zshrc
	@echo "Copied .zshrc to ~/.zshrc"

copy-wezterm:
	@cp $(CURRENT_DIR)/.wezterm.lua $(HOME)/.wezterm.lua
	@echo "Copied .wezterm.lua to ~/.wezterm.lua"

copy-vscode:
	@mkdir -p "$(HOME)/Library/Application Support/Code/User"
	@cp $(CURRENT_DIR)/vscode-settings.json "$(HOME)/Library/Application Support/Code/User/settings.json"
	@echo "Copied vscode-settings.json to VS Code settings"

copy-claude-mcp:
	@cp $(CURRENT_DIR)/.claude.json $(HOME)/.claude.json
	@echo "Copied .claude.json to ~/.claude.json"

copy-claude-settings:
	@mkdir -p "$(HOME)/.claude"
	@cp $(CURRENT_DIR)/.claude/settings.json "$(HOME)/.claude/settings.json"
	@echo "Copied .claude/settings.json to ~/.claude/settings.json"

copy-all: copy-zsh copy-wezterm copy-vscode copy-claude-mcp copy-claude-settings

reload-zsh:
	@source $(HOME)/.zshrc
	@echo "Reloaded zsh configuration"