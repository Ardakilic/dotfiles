# AGENTS.md — Dotfiles

## Repository Overview

Minimal dotfiles for macOS daily development. Configures shell (zsh), terminal (WezTerm), editors (VS Code, VS Code Insiders, VSCodium, Kiro Desktop), version control (git), and AI coding tools (OpenCode, Claude Code, Kiro CLI/Desktop). Uses Homebrew for package management and a Makefile for setup orchestration.

**Owner:** Arda Kılıçdağı  
**License:** MIT  
**Platform:** macOS (Darwin) only

## Project Structure

```
/
├── AGENTS.md                    # This file — agent instructions (authoritative reference)
├── CLAUDE.md                    # Thin shim: `@AGENTS.md` import + Claude-specific notes
├── Makefile                     # Setup automation (copy configs, install deps, git config)
├── README.md                    # User-facing docs with setup guide and screenshots
├── LICENSE                      # MIT
├── .gitignore                   # Ignores .kilo/, .roo/, .claude/, .kiro/, .vscode/, suggestions.md
├── screenshots/                 # Terminal/IDE screenshots (PNG)
├── scripts/                     # Validation and utility scripts (validate.sh is the only gate)
├── openspec/                    # Spec-driven change tracking (changes/, changes/archive/, specs/, config.yaml)
├── .opencode/                   # OpenCode commands (opsx-*) and skills (openspec workflow tooling)
└── config/
    ├── zsh/
    │   └── .zshrc               # ZSH config: aliases, PATH, completions, WezTerm plugins
    ├── wezterm/
    │   └── .wezterm.lua         # WezTerm terminal: colorscheme, keybindings, fonts
    ├── ghostty/
    │   └── config.ghostty       # Ghostty terminal: font, titlebar, option key, keybinds, mouse, icon
    ├── git/
    │   ├── .gitconfig           # Git user, SSH signing, aliases, excludesfile
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
    │   ├── settings.json        # Claude Code settings (incl. statusLine command)
    │   ├── statusline-command.sh # Status line script: model + effort, context %, 5h/7d usage bars
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
make copy-all                      # Copy all config files + git config (with backups), including copy-ghostty
make copy-zsh                      # config/zsh/.zshrc  → ~/.zshrc
make copy-wezterm                  # config/wezterm/.wezterm.lua → ~/.wezterm.lua
make copy-ghostty                  # config/ghostty/config.ghostty → ~/.config/ghostty/config.ghostty
make copy-vscode-settings          # → ~/Library/Application Support/Code/User/settings.json
make copy-vscode-insiders-settings # → ~/Library/Application Support/Code - Insiders/User/settings.json
make copy-vscodium-settings        # → ~/Library/Application Support/VSCodium/User/settings.json
make copy-kiro-desktop-settings    # → ~/Library/Application Support/Kiro/User/settings.json
make copy-kiro-desktop-agents      # → ~/.kiro/agents/ (markdown)
make copy-kiro-cli-agents          # → ~/.kiro/agents/ (JSON)
make copy-claude-mcp               # config/claude-code/.claude.json → ~/.claude.json
make copy-claude-settings          # → ~/.claude/settings.json + ~/.claude/statusline-command.sh
make copy-claude-output-styles     # → ~/.claude/output-styles/
make copy-opencode                 # → ~/.config/opencode/opencode.json
make copy-opencode-agents          # → ~/.config/opencode/agents/
make copy-gitconfig                # config/git/.gitconfig → ~/.gitconfig
make copy-gitignore-global         # config/git/.gitignore_global → ~/.gitignore_global
make copy-git-allowed-signers      # Rebuild ~/.ssh/allowed_signers from ~/.ssh/arda.pub (no key committed)
make reload-zsh                    # source ~/.zshrc in a subshell
make help                          # List all targets
```

There are no tests, linters, or type checkers. Validation is via `scripts/validate.sh` — the only gate. It runs JSON/Lua syntax checks, verifies Makefile↔`config/` target alignment (warns if a `config/` dir has no `copy-*` target), and enforces the 4-persona completeness invariant: it fails if any of `ask`/`architect`/`review`/`debug` is missing from any of the four agent platforms. `EXPECTED_DIRS` in `validate.sh` is the canonical list of `config/` subdirectories that must each have a Makefile target.

## Environment

- **OS:** macOS (Darwin) — Homebrew paths (`/opt/homebrew/...`), macOS app support dirs
- **Shell:** zsh (with powerlevel10k theme)
- **Terminal:** WezTerm nightly and Ghostty (stable). Some `.zshrc` features gate on `$TERM_PROGRAM` and fire for both `WezTerm` and `ghostty`.
- **Font:** MonoLisaCode (paid, Nerd Font patched) — Nerd Font variant: "MonoLisaCode Nerd Font". Fallbacks: Hack Nerd Font, FiraCode Nerd Font
- **Package Manager:** Homebrew only (no npm/pip/gem)
- **Modern tools:** fzf (fuzzy finder), zoxide (replaces cd with smart directory tracking)
- **Pager:** Delta uses its default paging behavior (`less`), invoked via `[pager] diff = delta` in `.gitconfig`. No `paging = never` override and no custom `LESS` env var — both removed in favor of defaults.

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
- **Dual-terminal zsh gate:** The `.zshrc` blocks that load powerlevel10k, autosuggestions, syntax-highlighting, fuzzy completion, and history-substring-search are gated on `$TERM_PROGRAM` matching either `WezTerm` or `ghostty`. Other terminals get a minimal shell. The `bindkey "^U" backward-kill-line` line is terminal-agnostic (unconditional) and pairs with both WezTerm's and Ghostty's Cmd+Backspace mapping.
- **WezTerm vs Ghostty Option key:** WezTerm's `send_composed_key_when_left_alt_is_pressed = true` intercepts at the keybinding layer — `mods = 'OPT'` bindings fire on both option keys, and LEFT additionally does composed chars on unbound keys. Ghostty's `macos-option-as-alt = left` is a blunt per-key toggle (LEFT = Alt, RIGHT = composed). No Ghostty value perfectly replicates WezTerm's "both options do both" behavior; `left` is the owner's choice.
- **SSH signing, not GPG:** Commits and tags are signed with the SSH key at `~/.ssh/arda` (git `gpg.format = ssh`). The public key is **never committed** to the repo — `config/git/.gitconfig` only stores the `~/.ssh/arda.pub` path (git expands `~` itself, so it ports across machines). `~/.ssh/allowed_signers` is regenerated by `make copy-git-allowed-signers` from the on-disk `~/.ssh/arda.pub`, so it stays out of version control too.

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

## OpenSpec Workflow

This repo uses spec-driven change tracking under `openspec/` (`schema: spec-driven`), driven by the `opsx-*` commands in `.opencode/commands/`. Proposals live in `openspec/changes/` and are moved to `openspec/changes/archive/` once applied; finalized specs live in `openspec/specs/`. The `openspec-*` skills in `.opencode/skills/` implement the propose/apply/sync/archive/explore workflows.


When adding a new tool configuration:
1. Create the config file under the appropriate `config/<tool>/` directory
2. Add a `copy-*` target to the Makefile
3. Add the dir to `EXPECTED_DIRS` in `scripts/validate.sh` (this is the canonical list `validate.sh` iterates — a missing entry means the dir won't be checked for target alignment)
4. Update README.md (structure diagram, setup section, dependencies, screenshots)
5. Update AGENTS.md (project structure, setup commands, environment, conventions)
6. If the tool has agent capabilities, follow the existing 4-persona pattern (`ask`/`architect`/`review`/`debug`) across all four platforms — `validate.sh` fails if any persona is missing from any platform
7. If the tool accesses sensitive paths, add deny rules to OpenCode's `opencode.json`

When refactoring an existing tool's config or structure, update README.md and AGENTS.md to reflect the changes.
