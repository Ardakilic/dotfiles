.PHONY: all copy-zsh copy-wezterm copy-vscode-settings copy-vscode-insiders-settings copy-vscodium-settings copy-kiro-desktop-settings copy-kiro-desktop-agents copy-kiro-cli-agents copy-claude-mcp copy-claude-settings copy-claude-output-styles copy-opencode copy-opencode-agents copy-all reload-zsh help install-deps copy-gitconfig copy-gitignore-global copy-git-allowed-signers


all: help

CURRENT_DIR := $(shell pwd)

# Email matching [user] in config/git/.gitconfig — used as the allowed_signers principal.
GIT_USER_EMAIL := ardakilicdagi@gmail.com

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
	@echo "  copy-claude-settings           - Copy .claude/settings.json + statusline-command.sh to ~/.claude/"
	@echo "  copy-claude-output-styles      - Copy output styles to ~/.claude/output-styles/"
	@echo "  copy-opencode                  - Copy opencode.json to ~/.config/opencode/opencode.json"
	@echo "  copy-opencode-agents           - Copy opencode agents to ~/.config/opencode/agents/"
	@echo "  copy-gitconfig                 - Copy config/git/.gitconfig to ~/.gitconfig"
	@echo "  copy-gitignore-global          - Copy config/git/.gitignore_global to ~/.gitignore_global"
	@echo "  copy-git-allowed-signers        - Rebuild ~/.ssh/allowed_signers from ~/.ssh/arda.pub (no key committed to repo)"
	@echo "  copy-all                       - Copy all config files"
	@echo "  reload-zsh                     - Reload zsh configuration"
	@echo "  install-deps                   - Install formulae, casks, and App Store apps from config/brew/Brewfile (sign into App Store first on fresh machines)"

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
	@echo "Trusting third-party taps..."
	@brew trust --tap ardakilic/tap 2>/dev/null || true
	@brew trust --tap wxtsky/tap   2>/dev/null || true
	@if ! command -v mas >/dev/null 2>&1; then \
		echo "Installing mas CLI (needed for App Store apps)..."; \
		brew install mas; \
	fi
	@if ! mas list >/dev/null 2>&1; then \
		echo ""; \
		echo "ERROR: Not signed into the Mac App Store."; \
		echo "App Store apps require sign-in. Open the App Store app,"; \
		echo "sign in with your Apple ID, then re-run 'make install-deps'."; \
		exit 1; \
	fi
	@echo "Installing formulae, casks, and App Store apps from Brewfile..."
	@brew bundle install --no-upgrade --file=$(CURRENT_DIR)/config/brew/Brewfile

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
	$(call backup-file,$(HOME)/.claude/statusline-command.sh)
	@cp $(CURRENT_DIR)/config/claude-code/statusline-command.sh "$(HOME)/.claude/statusline-command.sh"
	@chmod +x "$(HOME)/.claude/statusline-command.sh"
	@echo "Copied .claude/statusline-command.sh to ~/.claude/statusline-command.sh"

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

# Rebuild ~/.ssh/allowed_signers from the existing ~/.ssh/arda.pub on disk.
# The public key is NOT committed to the repo — only this generator is.
# Format: <email> <pubkey-type> <pubkey-blob>  (one line, trusted for SSH signing verification)
copy-git-allowed-signers:
	@if [ ! -f "$(HOME)/.ssh/arda.pub" ]; then \
		echo "ERROR: $(HOME)/.ssh/arda.pub not found. Place your SSH public key there first."; \
		exit 1; \
	fi
	@mkdir -p "$(HOME)/.ssh"
	@chmod 700 "$(HOME)/.ssh"
	$(call backup-file,$(HOME)/.ssh/allowed_signers)
	@echo "$(GIT_USER_EMAIL) $$(awk '{print $$1, $$2}' $(HOME)/.ssh/arda.pub)" > "$(HOME)/.ssh/allowed_signers"
	@chmod 600 "$(HOME)/.ssh/allowed_signers"
	@echo "Rebuilt ~/.ssh/allowed_signers from ~/.ssh/arda.pub (key not committed to repo)"

copy-all: copy-zsh copy-wezterm copy-vscode-settings copy-vscode-insiders-settings copy-vscodium-settings copy-kiro-desktop-settings copy-kiro-desktop-agents copy-kiro-cli-agents copy-claude-mcp copy-claude-settings copy-claude-output-styles copy-opencode copy-opencode-agents copy-gitconfig copy-gitignore-global copy-git-allowed-signers

reload-zsh:
	@zsh -c "source $(HOME)/.zshrc"
	@echo "Reloaded zsh configuration (in a subshell; run 'source ~/.zshrc' in your current shell to apply live)"
