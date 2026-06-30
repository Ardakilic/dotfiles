# dotfiles

Minimal dotfiles for my daily setup.

Nothing fancy, just practical improvements.

## Screenshots

### Main Screen
![main](./screenshots/main.png)

### Git Diff (`git diff`)
![git-diff](./screenshots/git-diff.png)

## My Environment

- macOS
- zsh
- [WezTerm](https://wezterm.org/) (nightly)
- [OpenCode](https://opencode.ai/)
- [Claude Code](https://claude.ai/)
- [VS Code](https://code.visualstudio.com/)
- [VSCodium](https://vscodium.com/)
- [Kilo Code](https://www.kilo.ai/)

## Requirements

Install everything with one command:

```sh
make install-deps
```

This installs Homebrew formulae, casks, taps, and Mac App Store apps
listed in [`config/brew/Brewfile`](./config/brew/Brewfile). It is
idempotent and does not upgrade existing packages.

**Note on a fresh machine:** the Mac App Store apps (VidHub, WhatsApp,
WireGuard, Scrobbles for Last.fm) are installed via [`mas`](https://github.com/mas-cli/mas),
which requires you to be signed into the Mac App Store app on the
machine. On a fresh install, open the App Store app and sign in with
your Apple ID before running `make install-deps`.

Or install individually:

```sh
brew install --cask wezterm@nightly && brew install curl eza bat jaq less git-delta powerlevel10k zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search fzf zoxide
```

### Individual tools:

> The canonical list of formulae, casks, taps, and Mac App Store
> apps lives in [`config/brew/Brewfile`](./config/brew/Brewfile).
> The notes below are highlights; the Brewfile is the source of truth.

- [wezterm@nightly](https://formulae.brew.sh/cask/wezterm@nightly) — GPU-accelerated terminal emulator
- [curl](https://curl.se/) — data transfer
- [eza](https://eza.rocks/) — modern `ls` replacement
- [bat](https://github.com/sharkdp/bat) — `cat` with syntax highlighting
- [jaq](https://github.com/01mf02/jaq) — Rust reimplementation of `jq`
- [git-delta](https://github.com/dandavison/delta) — syntax-highlighting pager for git
- [less](https://greenwoodsoftware.com/less/) — modern pager used by delta; required for proper mouse-wheel scrolling inside `git diff`
- [fzf](https://github.com/junegunn/fzf) — fuzzy finder
- [zoxide](https://github.com/ajeetdsouza/zoxide) — smarter `cd` replacement

### ZSH plugins:
- [powerlevel10k](https://github.com/romkatv/powerlevel10k) — ZSH theme
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) — fish-like highlighting
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) — fish-like autosuggestions
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) — fuzzy history search

### Casks:
> Cask apps installed via Homebrew. The full list (with versions) lives in [`config/brew/Brewfile`](./config/brew/Brewfile).

- [alt-tab](https://github.com/lwouis/alt-tab) — Windows-style alt-tab task switcher
- [betterzip](https://macitbetter.com/) — Archive manager
- [codeisland](https://github.com/wxtsky/codeisland) — Floating code editor (from `wxtsky/tap`)
- [forklift](https://binarynights.com/) — Dual-pane file manager
- [helium-browser](https://helium.computer/) — Browser
- [iina](https://iina.io/) — Modern video player
- [joplin](https://joplinapp.org/) — Note-taking and to-do
- [kiro](https://kiro.dev/) — AI-powered IDE
- [megasync](https://mega.io/desktop) — MEGA cloud sync
- [openmtp](https://openmtp.ganeshrvel.com/) — Android file transfer
- [orbstack](https://orbstack.dev/) — Docker / Linux VM replacement
- [raycast](https://www.raycast.com/) — Spotlight replacement / launcher
- [telegram](https://telegram.org/) — Messaging
- [vscodium](https://vscodium.com/) — Open-source VS Code build

### Mac App Store apps:
> Installed via [`mas`](https://github.com/mas-cli/mas) entries in the Brewfile. Requires the App Store app to be signed in on the machine.

- **VidHub** — Video library manager and player
- **WhatsApp** — Messenger
- **WireGuard** — VPN client
- **Scrobbles for Last.fm** — Last.fm scrobbler for Apple Music

### Private tap packages:
> Packages from [`ardakilic/tap`](https://github.com/ardakilic/homebrew-tap). Trust the tap before installing (handled in the Makefile).

- **lilt** — CLI that converts Hi-Res FLAC/ALAC to 16-bit/44.1kHz or 48kHz
- **rb-scrobbler** — Minimal Rockbox Last.fm scrobbler
- **feishin** — Modern self-hosted music player

## Font

### Primary Font

- [MonoLisa Font](https://monolisa.dev/) (MonoLisa is a paid font; v3 renames the family to `MonoLisaCode`)
- [MonoLisa Nerd Font patch](https://github.com/daylinmorgan/monolisa-nerdfont-patch) (`MonoLisaCode Nerd Font`)

Needed for icons and prompt.

### Alternative Fonts (Free)

I recommend Hack for Terminal, and FiraCode for IDEs. Nerd Font patches are required for icons and prompt on Terminal usage.

#### Install via Homebrew
```sh
brew install --cask font-hack-nerd-font
brew install --cask font-fira-code-nerd-font
```

#### Manual Download
- [Hack Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/latest/Hack.zip)
- [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/latest/FiraCode.zip)

---

## Setup

### Using Makefile (Recommended)

Copy all config files with one command:

```sh
make copy-all
```

Individual targets:

```sh
make copy-zsh                      # Copy config/zsh/.zshrc to ~/.zshrc
make copy-wezterm                  # Copy config/wezterm/.wezterm.lua to ~/.wezterm.lua
make copy-vscode-settings          # Copy config/vscode/settings.json to VS Code settings
make copy-vscode-insiders-settings # Copy config/vscode-insiders/settings.json to VS Code Insiders settings
make copy-vscodium-settings        # Copy config/vscodium/settings.json to VSCodium settings
make copy-kiro-desktop-settings    # Copy config/kiro-desktop/settings.json to Kiro desktop settings
make copy-kiro-desktop-agents      # Copy Kiro desktop agents to ~/.kiro/agents/
make copy-kiro-cli-agents          # Copy Kiro CLI agents to ~/.kiro/agents/
make copy-claude-mcp               # Copy config/claude-code/.claude.json to ~/.claude.json
make copy-claude-settings          # Copy config/claude-code/settings.json + statusline-command.sh to ~/.claude/
make copy-claude-output-styles     # Copy output styles to ~/.claude/output-styles/
make copy-opencode                 # Copy config/opencode/opencode.json to ~/.config/opencode/opencode.json
make copy-opencode-agents          # Copy opencode agents to ~/.config/opencode/agents/
make copy-gitconfig                # Copy config/git/.gitconfig to ~/.gitconfig
make copy-gitignore-global         # Copy config/git/.gitignore_global to ~/.gitignore_global
make copy-git-allowed-signers      # Rebuild ~/.ssh/allowed_signers from ~/.ssh/arda.pub (no key committed)
make git-config                    # Configure git with delta and merge settings
make reload-zsh                    # Reload zsh configuration in a subshell
make install-deps                  # Install formulae, casks, and App Store apps from config/brew/Brewfile
```

Run `make help` for all available targets.

### Manual Setup

Clone:

```sh
git clone https://github.com/Ardakilic/dotfiles ~/.dotfiles
```

Copy config:

```sh
cp ~/.dotfiles/config/zsh/.zshrc ~/.zshrc
cp ~/.dotfiles/config/wezterm/.wezterm.lua ~/.wezterm.lua
```

Copy VS Code settings:

```sh
cp ~/.dotfiles/config/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
```

Copy VSCodium settings:

```sh
mkdir -p "$HOME/Library/Application Support/VSCodium/User"
cp ~/.dotfiles/config/vscodium/settings.json "$HOME/Library/Application Support/VSCodium/User/settings.json"
```

Copy Kiro settings:

```sh
cp ~/.dotfiles/config/kiro-desktop/settings.json "$HOME/Library/Application Support/Kiro/User/settings.json"
```

Copy Kiro desktop agents:

```sh
cp -r ~/.dotfiles/config/kiro-desktop/agents/*.md ~/.kiro/agents/
```

Copy Kiro CLI agents:

```sh
mkdir -p ~/.kiro/agents
cp -r ~/.dotfiles/config/kiro-cli/agents/*.json ~/.kiro/agents/
```

Copy Claude Code Settings:

```sh
cp ~/.dotfiles/config/claude-code/.claude.json ~/.claude.json  # MCP servers
cp ~/.dotfiles/config/claude-code/settings.json ~/.claude/settings.json
mkdir -p ~/.claude/output-styles
cp ~/.dotfiles/config/claude-code/output-styles/*.md ~/.claude/output-styles/
```

Copy OpenCode Settings:

```sh
mkdir -p ~/.config/opencode
cp ~/.dotfiles/config/opencode/opencode.json ~/.config/opencode/opencode.json
mkdir -p ~/.config/opencode/agents
cp ~/.dotfiles/config/opencode/agents/*.md ~/.config/opencode/agents/
```

Reload:

```sh
source ~/.zshrc
```

### Git Configuration

Git is configured with `delta` for diff highlighting (side-by-side, dark, line-numbers) and `zdiff3` for merge conflicts. Delta is invoked as the pager via `[pager] diff = delta` but **`paging = never`** tells delta to print the full output to the terminal instead of running it through `less` — so the entire diff lands in WezTerm's scrollback, ready for native scrolling and search (`Ctrl+Shift+F` in WezTerm). The settings live in `config/git/.gitconfig` and are applied with:

```sh
make copy-gitconfig
```

The `LESS='-R -F -X'` env var (set in `.zshrc`) is still exported for other tools (man pages, `git log` outside delta) that shell out to `less`.

### SSH commit & tag signing

Commits and tags are signed with an **SSH key** (not GPG). The `.gitconfig` sets:

- `user.signingkey = ~/.ssh/arda.pub` — path to the public key; the matching private key (or `ssh-agent`) does the signing. Git expands `~` itself, so this ports across machines as long as the key lives at `~/.ssh/arda` everywhere.
- `gpg.format = ssh` and `gpg.ssh.allowedSignersFile = ~/.ssh/allowed_signers` — the `allowed_signers` file lists trusted public keys used to **verify** signatures.
- `commit.gpgsign = true` / `tag.gpgsign = true` — sign by default.

The public key itself is **not committed to this repo** — only the path reference. The `allowed_signers` file is regenerated from the key already on disk at `~/.ssh/arda.pub`:

```sh
make copy-git-allowed-signers
```

This reads `~/.ssh/arda.pub`, extracts the key type and blob, and writes `<email> <type> <blob>` to `~/.ssh/allowed_signers` (mode 600). Re-run it whenever you rotate keys.

---

## Config Structure

```
config/
├── brew/
│   └── Brewfile              # Hand-curated Homebrew formulae, casks, taps, and App Store apps
├── claude-code/
│   ├── .claude.json           # Claude Code MCP servers config
│   ├── settings.json          # Claude Code settings
│   └── output-styles/         # Claude Code output styles
│       ├── ask.md             # Advisory Q&A style
│       ├── architect.md       # Planning and design style
│       ├── review.md          # Code review style
│       └── debug.md           # Systematic debugging style
├── wezterm/
│   └── .wezterm.lua           # WezTerm terminal config
├── zsh/
│   └── .zshrc                 # ZSH shell config
├── git/
│   ├── .gitconfig             # Git user, SSH signing, aliases, delta pager, zdiff3 merge
│   └── .gitignore_global      # Global gitignore for OS/IDE files
├── vscode/
│   └── settings.json          # VS Code editor settings
├── vscode-insiders/
│   └── settings.json          # VS Code Insiders editor settings
├── vscodium/
│   └── settings.json          # VSCodium editor settings
├── kiro-desktop/
│   ├── settings.json          # Kiro desktop settings
│   └── agents/                # Kiro desktop custom agents (markdown format)
│       ├── ask.md             # Advisory Q&A agent
│       ├── architect.md       # Planning and design agent
│       ├── review.md          # Code review agent
│       └── debug.md           # Systematic debugging agent
├── kiro-cli/
│   └── agents/                # Kiro CLI custom agents (JSON format)
│       ├── ask.json           # Advisory Q&A agent
│       ├── architect.json     # Planning and design agent
│       ├── review.json        # Code review agent
│       └── debug.json         # Systematic debugging agent
└── opencode/
    ├── opencode.json          # OpenCode AI config
    └── agents/                # OpenCode custom agents
        ├── ask.md             # Advisory Q&A agent
        ├── architect.md       # Planning and design agent
        ├── review.md          # Code review agent
        └── debug.md           # Systematic debugging agent
```

---

## Notes

* Built for macOS (Homebrew paths)
* Some parts assume WezTerm (`.zshrc` conditionally loads plugins only inside WezTerm)
* Not portable without tweaks
* **Retired — WezTerm stderr coloring.** Previously, stderr was captured to a temp file (`exec 2>"$file"` in `preexec`) and replayed in red before the next prompt. Abandoned because capturing fd 2 forces `isatty(2)=false` for every child process, which breaks docker prompts/progress bars, buffers streaming stderr until exit, and suppresses programs' own native stderr colors. The only race-free, streaming-safe alternative (`stderred` via `DYLD_INSERT_LIBRARIES`) is stripped by SIP on macOS system binaries and isn't in Homebrew core — not worth maintaining. Removing the colorizer also eliminated the cursor-disappearing race it caused. See `openspec/changes/retire-stderr-colorizer/` for the full analysis.

## TODOs

- [x] Add `make install-deps` target to install dependencies
- [x] Add `opencode` support
- [x] Add `.gitconfig` support
- [x] Add `.gitignore_global` support
- [x] Add SSH commit/tag signing (`copy-git-allowed-signers`)
