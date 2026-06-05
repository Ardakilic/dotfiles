# AGENTS.md — Dotfiles

## Repository Overview

Minimal dotfiles for macOS daily development. Configures shell (zsh), terminal (WezTerm), editors (VS Code, VS Code Insiders, VSCodium, Kiro Desktop), version control (git), and AI coding tools (OpenCode, Claude Code, Kiro CLI/Desktop). Uses Homebrew for package management and a Makefile for setup orchestration.

**Owner:** Arda Kılıçdağı  
**License:** MIT  
**Platform:** macOS (Darwin) only

## Project Structure

```
/
├── AGENTS.md                    # This file — agent instructions
├── Makefile                     # Setup automation (copy configs, install deps, git config)
├── README.md                    # User-facing docs with setup guide and screenshots
├── LICENSE                      # MIT
├── .gitignore                   # Ignores .kilo/, .roo/, .claude/, .kiro/, .vscode/, suggestions.md
├── screenshots/                 # Terminal/IDE screenshots (PNG)
├── scripts/                     # Validation and utility scripts
└── config/
    ├── zsh/
    │   └── .zshrc               # ZSH config: aliases, PATH, completions, WezTerm plugins, stderr coloring
    ├── wezterm/
    │   └── .wezterm.lua         # WezTerm terminal: colorscheme, keybindings, fonts, stderr injection
    ├── git/
    │   ├── .gitconfig           # Git aliases, defaults, excludesfile
    │   └── .gitignore_global    # Global gitignore (OS, IDE files)
    ├── vscode/
    │   └── settings.json        # VS Code stable settings
    ├── vscode-insiders/
    │   └── settings.json        # VS Code Insiders settings (identical to stable)
    ├── vscodium/
    │   └── settings.json        # VSCodium settings (no Copilot references)
    ├── kiro-desktop/
    │   ├── settings.json        # Kiro Desktop font/theme settings
    │   └── agents/              # Agent definitions (markdown format)
    ├── kiro-cli/
    │   └── agents/              # Agent definitions (JSON format)
    ├── claude-code/
    │   ├── .claude.json         # Claude Code MCP server config (Context7)
    │   ├── settings.json        # Claude Code settings
    │   └── output-styles/       # Markdown output style templates (ask, architect, review, debug)
    ├── opencode/
    │   ├── opencode.json        # OpenCode config: LSP, permissions, MCP, custom providers
    │   └── agents/              # Agent definitions (markdown, same 4 personas)
    └── brew/
        └── Brewfile             # Hand-curated Homebrew formulae, casks, taps, and App Store apps
```

## Setup & Build Commands

All operations are via `make`:

```sh
make install-deps                  # Install formulae, casks, and App Store apps from config/brew/Brewfile (sign into App Store first on fresh machines)
make copy-all                      # Copy all config files + git config (with backups)
make copy-zsh                      # config/zsh/.zshrc  → ~/.zshrc
make copy-wezterm                  # config/wezterm/.wezterm.lua → ~/.wezterm.lua
make copy-vscode-settings          # → ~/Library/Application Support/Code/User/settings.json
make copy-vscode-insiders-settings # → ~/Library/Application Support/Code - Insiders/User/settings.json
make copy-vscodium-settings        # → ~/Library/Application Support/VSCodium/User/settings.json
make copy-kiro-desktop-settings    # → ~/Library/Application Support/Kiro/User/settings.json
make copy-kiro-desktop-agents      # → ~/.kiro/agents/ (markdown)
make copy-kiro-cli-agents          # → ~/.kiro/agents/ (JSON)
make copy-claude-mcp               # config/claude-code/.claude.json → ~/.claude.json
make copy-claude-settings          # → ~/.claude/settings.json
make copy-claude-output-styles     # → ~/.claude/output-styles/
make copy-opencode                 # → ~/.config/opencode/opencode.json
make copy-opencode-agents          # → ~/.config/opencode/agents/
make copy-gitconfig                # config/git/.gitconfig → ~/.gitconfig
make copy-gitignore-global         # config/git/.gitignore_global → ~/.gitignore_global
make git-config                    # git global config: delta pager + zdiff3 merge + excludesfile
make reload-zsh                    # source ~/.zshrc
make help                          # List all targets
```

There are no tests, linters, or type checkers. Validation is via `scripts/validate.sh` (syntax checks, Makefile target alignment).

## Environment

- **OS:** macOS (Darwin) — Homebrew paths (`/opt/homebrew/...`), macOS app support dirs
- **Shell:** zsh (with powerlevel10k theme)
- **Terminal:** WezTerm nightly (some `.zshrc` features gate on `$TERM_PROGRAM == "WezTerm"`)
- **Font:** MonoLisa (paid, Nerd Font patched) — fallbacks: Hack Nerd Font, FiraCode Nerd Font
- **Package Manager:** Homebrew only (no npm/pip/gem)
- **Modern tools:** fzf (fuzzy finder), zoxide (replaces cd with smart directory tracking)

## Conventions

- **Config source of truth:** Files under `config/` — always edit there, never in `~/`.
- **Makefile-driven setup:** New config additions get a `copy-*` target in the Makefile.
- **Agent persona consistency:** The same 4 agent types (ask, architect, review, debug) exist across OpenCode, Claude Code, Kiro Desktop, and Kiro CLI. Tool permissions align across platforms.
- **Agent format per tool:** OpenCode/Claude Code/Kiro Desktop use markdown; Kiro CLI uses JSON.
- **Security-first:** Sensitive paths (`.ssh`, `.aws`, `.kube`, `.docker`, `.gnupg`, `.azure`, `.config/gcloud`, `.env*`, `*.pem`, `*.key`, `*.p12`, `*.jks`, `*credentials*`) are denied in OpenCode permissions.
- **Output styles** (Claude Code only): Reusable markdown in `config/claude-code/output-styles/` — ask (read-only Q&A), architect (planning), review (code review), debug (debugging).
- **No dotfile manager:** Uses bare `cp` via Makefile rather than stow/chezmoi/yadm.
- **Brewfile is hand-curated:** `config/brew/Brewfile` is authored by hand from `brew leaves --installed-on-request` (formulae) and `brew list --cask` (casks), not generated by `brew bundle dump`. Auto-installed dependency bottles are deliberately excluded. Taps and `mas` entries are reviewed deliberately when added.
- **App Store apps via `mas`:** Mac App Store apps (currently VidHub, WhatsApp, WireGuard, Scrobbles for Last.fm) are listed as `mas "Name", id: <id>` lines in the Brewfile. On a fresh machine, the user must sign into the Mac App Store app once before `make install-deps`; after that, App Store installs are fully non-interactive.
- **Aliases follow patterns:** `eza` for listing, `bat` for viewing, `jaq` for JSON, `git-delta` for diffing.

## File Naming

- WezTerm config: `.wezterm.lua` (dotfile)
- ZSH config: `.zshrc` (dotfile)
- Claude Code config: `.claude.json` (dotfile)
- Everything else: descriptive names without leading dots
- Agent files: one file per persona (`ask.md`, `architect.md`, `review.md`, `debug.md`)
- Screenshots: `screenshots/` directory, PNG format

## Agent Conventions

This repository defines 4 agent personas:

| Agent | Tools | Purpose |
|-------|-------|---------|
| **ask** | read+grep+glob+webfetch | Read-only Q&A, no code changes |
| **architect** | read+grep+glob+webfetch+edit+write+patch+todowrite | Plan & design, creates markdown specs & todos |
| **review** | read+grep+glob+bash+webfetch+todowrite | Code review via git diff, severity tables |
| **debug** | read+grep+glob+bash+webfetch+edit+write+patch+todowrite | Systematic debugging, hypothesis-driven |

All agents follow the same description and tool-permission pattern. The `architect` agent must never provide time estimates and should use `todowrite` as the primary planning tool.

## MCP Servers

Context7 MCP server is configured for both:
- **OpenCode:** `config/opencode/opencode.json` (disabled by default, API key placeholder)
- **Claude Code:** `config/claude-code/.claude.json` (API key placeholder)

Set `CONTEXT7_API_KEY` to enable.

## Security Rules

OpenCode denies access to:
- **Read/Edit:** `~/.ssh/**`, `~/.gnupg/**`, `~/.aws/**`, `~/.azure/**`, `~/.kube/**`, `~/.docker/**`, `~/.config/gcloud/**`
- **Read only:** `.env*`, `*.pem`, `*.key`, `*.p12`, `*.jks`, `*credentials*`
- **Bash:** `rm *credentials*`, `rm *.env*`

When adding new tools or config paths, ensure no sensitive paths are exposed.

## Git History & Branching

- Main branch: `master` (or `main`)
- Conventional commit style: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `build:`
- Commits are direct to the main branch (no PR workflow)
- Do not commit unless explicitly asked


When adding a new tool configuration:
1. Create the config file under the appropriate `config/<tool>/` directory
2. Add a `copy-*` target to the Makefile
3. Update README.md (structure diagram, setup section, dependencies, screenshots)
4. Update AGENTS.md (project structure, setup commands, environment, conventions)
5. If the tool has agent capabilities, follow the existing agent persona pattern
6. If the tool accesses sensitive paths, add deny rules to OpenCode's `opencode.json`

When refactoring an existing tool's config or structure, update README.md and AGENTS.md to reflect the changes.
