.PHONY: all copy-zsh copy-wezterm copy-vscode-settings copy-vscode-insiders-settings copy-vscodium-settings copy-kiro-desktop-settings copy-kiro-desktop-agents copy-kiro-cli-agents copy-claude-mcp copy-claude-settings copy-claude-output-styles copy-opencode copy-opencode-agents copy-all reload-zsh help install-deps git-config copy-gitconfig copy-gitignore-global


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
	@echo "  copy-vscodium-settings         - Copy config/vscodium/settings.json to VSCodium settings"
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

# Backup macro: backup file or directory before overwriting
BACKUP_SUFFIX := .bak.$(shell date +%s)
define backup-file
	@if [ -e $(1) ]; then \
		if [ -d $(1) ]; then \
			cp -r $(1) $(1)$(BACKUP_SUFFIX); \
			echo "Backed up directory $(1) to $(1)$(BACKUP_SUFFIX)"; \
		else \
			cp $(1) $(1)$(BACKUP_SUFFIX); \
			echo "Backed up $(1) to $(1)$(BACKUP_SUFFIX)"; \
		fi; \
	fi
endef

install-deps:
	@echo "Installing Homebrew dependencies..."
	@brew list wezterm@nightly &>/dev/null || brew install --cask wezterm@nightly
	@brew list curl &>/dev/null || brew install curl
	@brew list eza &>/dev/null || brew install eza
	@brew list bat &>/dev/null || brew install bat
	@brew list jaq &>/dev/null || brew install jaq
	@brew list git-delta &>/dev/null || brew install git-delta
	@brew list powerlevel10k &>/dev/null || brew install powerlevel10k
	@brew list zsh-syntax-highlighting &>/dev/null || brew install zsh-syntax-highlighting
	@brew list zsh-autosuggestions &>/dev/null || brew install zsh-autosuggestions
	@brew list zsh-history-substring-search &>/dev/null || brew install zsh-history-substring-search
	@brew list fzf &>/dev/null || brew install fzf
	@brew list zoxide &>/dev/null || brew install zoxide
	@brew list font-hack-nerd-font &>/dev/null || brew install --cask font-hack-nerd-font
	@brew list font-fira-code-nerd-font &>/dev/null || brew install --cask font-fira-code-nerd-font
	@echo "All dependencies installed successfully!"

git-config:
	@echo "Configuring git with delta and merge settings..."
	@git config --global --replace-all core.pager delta
	@git config --global --replace-all interactive.diffFilter "delta --color-only"
	@git config --global --replace-all delta.navigate true
	@git config --global --replace-all delta.dark true
	@git config --global --replace-all delta.line-numbers true
	@git config --global --replace-all delta.side-by-side true
	@git config --global --replace-all merge.conflictStyle zdiff3
	@git config --global --replace-all core.excludesfile ~/.gitignore_global
	@echo "Git configured successfully!"

copy-zsh:
	$(call backup-file,$(HOME)/.zshrc)
	@cp $(CURRENT_DIR)/config/zsh/.zshrc $(HOME)/.zshrc
	@echo "Copied .zshrc to ~/.zshrc"

copy-wezterm:
	$(call backup-file,$(HOME)/.wezterm.lua)
	@cp $(CURRENT_DIR)/config/wezterm/.wezterm.lua $(HOME)/.wezterm.lua
	@echo "Copied .wezterm.lua to ~/.wezterm.lua"

copy-vscode-settings:
	@mkdir -p "$(HOME)/Library/Application Support/Code/User"
	$(call backup-file,"$(HOME)/Library/Application Support/Code/User/settings.json")
	@cp $(CURRENT_DIR)/config/vscode/settings.json "$(HOME)/Library/Application Support/Code/User/settings.json"
	@echo "Copied config/vscode/settings.json to VS Code settings"

copy-vscode-insiders-settings:
	@mkdir -p "$(HOME)/Library/Application Support/Code - Insiders/User"
	$(call backup-file,"$(HOME)/Library/Application Support/Code - Insiders/User/settings.json")
	@cp $(CURRENT_DIR)/config/vscode-insiders/settings.json "$(HOME)/Library/Application Support/Code - Insiders/User/settings.json"
	@echo "Copied config/vscode-insiders/settings.json to VS Code Insiders settings"

copy-vscodium-settings:
	@mkdir -p "$(HOME)/Library/Application Support/VSCodium/User"
	$(call backup-file,"$(HOME)/Library/Application Support/VSCodium/User/settings.json")
	@cp $(CURRENT_DIR)/config/vscodium/settings.json "$(HOME)/Library/Application Support/VSCodium/User/settings.json"
	@echo "Copied config/vscodium/settings.json to VSCodium settings"

copy-kiro-desktop-settings:
	@mkdir -p "$(HOME)/Library/Application Support/Kiro/User"
	$(call backup-file,"$(HOME)/Library/Application Support/Kiro/User/settings.json")
	@cp $(CURRENT_DIR)/config/kiro-desktop/settings.json "$(HOME)/Library/Application Support/Kiro/User/settings.json"
	@echo "Copied config/kiro-desktop/settings.json to Kiro desktop settings"

copy-kiro-desktop-agents:
	@mkdir -p "$(HOME)/.kiro/agents"
	$(call backup-file,$(HOME)/.kiro/agents)
	@cp -r $(CURRENT_DIR)/config/kiro-desktop/agents/*.md "$(HOME)/.kiro/agents/"
	@echo "Copied Kiro desktop agents to ~/.kiro/agents/"

copy-kiro-cli-agents:
	@mkdir -p "$(HOME)/.kiro/agents"
	$(call backup-file,$(HOME)/.kiro/agents)
	@cp -r $(CURRENT_DIR)/config/kiro-cli/agents/*.json "$(HOME)/.kiro/agents/"
	@echo "Copied Kiro CLI agents to ~/.kiro/agents/"

copy-claude-mcp:
	$(call backup-file,$(HOME)/.claude.json)
	@cp $(CURRENT_DIR)/config/claude-code/.claude.json $(HOME)/.claude.json
	@echo "Copied .claude.json to ~/.claude.json"

copy-claude-settings:
	@mkdir -p "$(HOME)/.claude"
	$(call backup-file,$(HOME)/.claude/settings.json)
	@cp $(CURRENT_DIR)/config/claude-code/settings.json "$(HOME)/.claude/settings.json"
	@echo "Copied .claude/settings.json to ~/.claude/settings.json"

copy-opencode:
	@mkdir -p "$(HOME)/.config/opencode"
	$(call backup-file,$(HOME)/.config/opencode/opencode.json)
	@cp $(CURRENT_DIR)/config/opencode/opencode.json "$(HOME)/.config/opencode/opencode.json"
	@echo "Copied opencode.json to ~/.config/opencode/opencode.json"

copy-opencode-agents:
	@mkdir -p "$(HOME)/.config/opencode/agents"
	$(call backup-file,$(HOME)/.config/opencode/agents)
	@cp $(CURRENT_DIR)/config/opencode/agents/*.md "$(HOME)/.config/opencode/agents/"
	@echo "Copied opencode agents to ~/.config/opencode/agents/"

copy-claude-output-styles:
	@mkdir -p "$(HOME)/.claude/output-styles"
	$(call backup-file,$(HOME)/.claude/output-styles)
	@cp $(CURRENT_DIR)/config/claude-code/output-styles/*.md "$(HOME)/.claude/output-styles/"
	@echo "Copied output styles to ~/.claude/output-styles/"

copy-gitconfig:
	$(call backup-file,$(HOME)/.gitconfig)
	@cp $(CURRENT_DIR)/config/git/.gitconfig $(HOME)/.gitconfig
	@echo "Copied .gitconfig to ~/.gitconfig"

copy-gitignore-global:
	$(call backup-file,$(HOME)/.gitignore_global)
	@cp $(CURRENT_DIR)/config/git/.gitignore_global $(HOME)/.gitignore_global
	@echo "Copied .gitignore_global to ~/.gitignore_global"

copy-all: copy-zsh copy-wezterm copy-vscode-settings copy-vscode-insiders-settings copy-vscodium-settings copy-kiro-desktop-settings copy-kiro-desktop-agents copy-kiro-cli-agents copy-claude-mcp copy-claude-settings copy-claude-output-styles copy-opencode copy-opencode-agents copy-gitconfig copy-gitignore-global git-config

reload-zsh:
	@source $(HOME)/.zshrc
	@echo "Reloaded zsh configuration"
