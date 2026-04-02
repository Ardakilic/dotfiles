.PHONY: all copy-zsh copy-wezterm copy-vscode copy-claude copy-all reload-zsh help

all: help

DOTFILES_DIR := $(HOME)/.dotfiles
CURRENT_DIR := $(shell pwd)

help:
	@echo "Arda Kılıçdağı's Dotfiles Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  copy-zsh     - Copy .zshrc to ~/.zshrc"
	@echo "  copy-wezterm - Copy .wezterm.lua to ~/.wezterm.lua"
	@echo "  copy-vscode  - Copy vscode-settings.json to VS Code settings"
	@echo "  copy-claude  - Copy .claude.json to ~/.claude.json"
	@echo "  copy-all     - Copy all config files"
	@echo "  reload-zsh   - Reload zsh configuration"

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

copy-claude:
	@cp $(CURRENT_DIR)/.claude.json $(HOME)/.claude.json
	@echo "Copied .claude.json to ~/.claude.json"

copy-all: copy-zsh copy-wezterm copy-vscode copy-claude

reload-zsh:
	@source $(HOME)/.zshrc
	@echo "Reloaded zsh configuration"