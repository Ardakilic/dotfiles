.PHONY: all copy-zsh copy-wezterm copy-vscode-settings copy-vscode-insiders-settings copy-kiro-desktop-settings copy-kiro-desktop-agents copy-kiro-cli-agents copy-claude-mcp copy-claude-settings copy-claude-output-styles copy-opencode copy-opencode-agents copy-all reload-zsh help install-deps git-config


all: help

CURRENT_DIR := $(shell pwd)

help:
	@echo "Arda Kılıçdağı's Dotfiles Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  copy-zsh                    - Copy .zshrc to ~/.zshrc"
	@echo "  copy-wezterm                - Copy .wezterm.lua to ~/.wezterm.lua"
	@echo "  copy-vscode-settings          - Copy config/vscode/settings.json to VS Code settings"
	@echo "  copy-vscode-insiders-settings  - Copy config/vscode-insiders/settings.json to VS Code Insiders settings"
	@echo "  copy-kiro-desktop-settings     - Copy config/kiro-desktop/settings.json to Kiro desktop settings"
	@echo "  copy-kiro-desktop-agents       - Copy Kiro desktop agents to ~/.kiro/agents/"
	@echo "  copy-kiro-cli-agents           - Copy Kiro CLI agents to ~/.kiro/agents/"
	@echo "  copy-claude-mcp                - Copy .claude.json to ~/.claude.json"
	@echo "  copy-claude-settings           - Copy .claude/settings.json to ~/.claude/settings.json"
	@echo "  copy-claude-output-styles      - Copy output styles to ~/.claude/output-styles/"
	@echo "  copy-opencode                  - Copy opencode.json to ~/.config/opencode/opencode.json"
	@echo "  copy-opencode-agents           - Copy opencode agents to ~/.config/opencode/agents/"
	@echo "  copy-all                       - Copy all config files"
	@echo "  reload-zsh                     - Reload zsh configuration"
	@echo "  install-deps                   - Install all dependencies via Homebrew"
	@echo "  git-config                     - Configure git with delta and merge settings"

install-deps:
	@echo "Installing Homebrew dependencies..."
	@brew install --cask wezterm@nightly
	@brew install curl eza bat jaq git-delta powerlevel10k zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search
	@brew install --cask font-hack-nerd-font font-fira-code-nerd-font
	@echo "All dependencies installed successfully!"

git-config:
	@echo "Configuring git with delta and merge settings..."
	@git config --global core.pager delta
	@git config --global interactive.diffFilter "delta --color-only"
	@git config --global delta.navigate true
	@git config --global delta.dark true
	@git config --global delta.line-numbers true
	@git config --global delta.side-by-side true
	@git config --global merge.conflictStyle zdiff3
	@echo "Git configured successfully!"

copy-zsh:
	@cp $(CURRENT_DIR)/config/zsh/.zshrc $(HOME)/.zshrc
	@echo "Copied .zshrc to ~/.zshrc"

copy-wezterm:
	@cp $(CURRENT_DIR)/config/wezterm/.wezterm.lua $(HOME)/.wezterm.lua
	@echo "Copied .wezterm.lua to ~/.wezterm.lua"

copy-vscode-settings:
	@mkdir -p "$(HOME)/Library/Application Support/Code/User"
	@cp $(CURRENT_DIR)/config/vscode/settings.json "$(HOME)/Library/Application Support/Code/User/settings.json"
	@echo "Copied config/vscode/settings.json to VS Code settings"

copy-vscode-insiders-settings:
	@mkdir -p "$(HOME)/Library/Application Support/Code - Insiders/User"
	@cp $(CURRENT_DIR)/config/vscode-insiders/settings.json "$(HOME)/Library/Application Support/Code - Insiders/User/settings.json"
	@echo "Copied config/vscode-insiders/settings.json to VS Code Insiders settings"

copy-kiro-desktop-settings:
	@mkdir -p "$(HOME)/Library/Application Support/Kiro/User"
	@cp $(CURRENT_DIR)/config/kiro-desktop/settings.json "$(HOME)/Library/Application Support/Kiro/User/settings.json"
	@echo "Copied config/kiro-desktop/settings.json to Kiro desktop settings"

copy-kiro-desktop-agents:
	@mkdir -p "$(HOME)/.kiro/agents"
	@cp -r $(CURRENT_DIR)/config/kiro-desktop/agents/*.md "$(HOME)/.kiro/agents/"
	@echo "Copied Kiro desktop agents to ~/.kiro/agents/"

copy-kiro-cli-agents:
	@mkdir -p "$(HOME)/.kiro/agents"
	@cp -r $(CURRENT_DIR)/config/kiro-cli/agents/*.json "$(HOME)/.kiro/agents/"
	@echo "Copied Kiro CLI agents to ~/.kiro/agents/"

copy-claude-mcp:
	@cp $(CURRENT_DIR)/config/claude-code/.claude.json $(HOME)/.claude.json
	@echo "Copied .claude.json to ~/.claude.json"

copy-claude-settings:
	@mkdir -p "$(HOME)/.claude"
	@cp $(CURRENT_DIR)/config/claude-code/settings.json "$(HOME)/.claude/settings.json"
	@echo "Copied .claude/settings.json to ~/.claude/settings.json"

copy-opencode:
	@mkdir -p "$(HOME)/.config/opencode"
	@cp $(CURRENT_DIR)/config/opencode/opencode.json "$(HOME)/.config/opencode/opencode.json"
	@echo "Copied opencode.json to ~/.config/opencode/opencode.json"

copy-opencode-agents:
	@mkdir -p "$(HOME)/.config/opencode/agents"
	@cp $(CURRENT_DIR)/config/opencode/agents/*.md "$(HOME)/.config/opencode/agents/"
	@echo "Copied opencode agents to ~/.config/opencode/agents/"

copy-claude-output-styles:
	@mkdir -p "$(HOME)/.claude/output-styles"
	@cp $(CURRENT_DIR)/config/claude-code/output-styles/*.md "$(HOME)/.claude/output-styles/"
	@echo "Copied output styles to ~/.claude/output-styles/"

copy-all: copy-zsh copy-wezterm copy-vscode-settings copy-vscode-insiders-settings copy-kiro-desktop-settings copy-kiro-desktop-agents copy-kiro-cli-agents copy-claude-mcp copy-claude-settings copy-claude-output-styles copy-opencode copy-opencode-agents git-config

reload-zsh:
	@source $(HOME)/.zshrc
	@echo "Reloaded zsh configuration"
