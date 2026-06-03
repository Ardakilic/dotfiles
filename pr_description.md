# Dotfiles: Bug Fixes, Idempotency & New Tooling

## Summary

Fixed silent bugs in `.zshrc`, added idempotency and backup safety to Makefile, introduced `fzf`/`zoxide` support, added tracked `.gitconfig`/`.gitignore_global` templates, added `scripts/validate.sh` for automated checks, and updated documentation.

**Note on agent files:** Kiro CLI (`config/kiro-cli/agents/`) and Kiro Desktop (`config/kiro-desktop/agents/`) agents were **left in their original state** after the initial implementation incorrectly assumed Kiro = Kilo Code conventions. These tools have different native tool names (Kiro uses `read`/`write`/`shell`, Kiro Desktop adds `@context7`) and should not be forced to match OpenCode's tool set.

---

## Changes by Category

### 🐛 Bug Fixes (High Priority)

| Fix | File | Details |
|-----|------|---------|
| **Typo in `.zshrc`** | `config/zsh/.zshrc` | Changed `# setops HIST_IGNORE_ALL_DUPS` → `# setopt HIST_IGNORE_ALL_DUPS`. `setops` does not exist in zsh; this would error on startup if uncommented. |
| **p10k instant prompt position** | `config/zsh/.zshrc` | Moved Powerlevel10k instant prompt block from inside the `TERM_PROGRAM == "WezTerm"` conditional to the **absolute top** of the file. Per p10k docs, instant prompt must be "close to the top of `~/.zshrc`" and above any console output. Previous placement risked silent disablement. |
| **Idempotent `git-config`** | `Makefile` | Replaced bare `git config --global` with `git config --global --replace-all`. Running `make git-config` twice no longer appends duplicate entries. Also sets `core.excludesfile` to `~/.gitignore_global`. |
| **Destructive copy safety** | `Makefile` | Added `backup-file` macro with timestamped `.bak.<epoch>` backups. Applied to **all** `copy-*` targets. Prevents accidental overwrite of user-customized configs. |
| **Kilo Code ignore update** | `.gitignore` | Added `.kilo-code/` alongside existing `.kilo/` to match current Kilo Code extension cache directory naming. `.kiro/` is for Kiro (different tool). |

### 🔧 Quality & Consistency (Medium Priority)

| Fix | File | Details |
|-----|------|---------|
| **Idempotent `install-deps`** | `Makefile` | Each `brew install` guarded with `brew list <pkg> &>/dev/null || brew install <pkg>`. Added `fzf` and `zoxide`. |
| **Stale README cleanup** | `README.md` | Removed misleading Ghostty config note. Checked off `.gitconfig`/`.gitignore_global` TODOs. |
| **Schema risk documentation** | `config/opencode/opencode.json` | Added inline comment on unversioned `$schema` URL risk. |

### ✨ New Features & Tooling (Low Priority)

| Feature | File | Details |
|---------|------|---------|
| **Git config templates** | `config/git/.gitconfig`<br>`config/git/.gitignore_global` | Added tracked `.gitconfig` with aliases (`lg`, `last`, `undo`, `amend`), `excludesfile`, and defaults. Added `.gitignore_global` for OS and IDE files. Two new Makefile targets: `copy-gitconfig` and `copy-gitignore-global`. |
| **Modern navigation tools** | `config/zsh/.zshrc`<br>`Makefile` | Added `fzf` (fuzzy finder) and `zoxide` (replaces `cd` with smart directory tracking) to `make install-deps`. Initialized in `.zshrc` with `--cmd cd` so `cd` uses zoxide intelligence. |
| **Validation script** | `scripts/validate.sh` | New script checks: JSON syntax (with JSONC support via `jaq`), Lua syntax, Makefile target alignment, agent file existence, `.gitignore` coverage, and shell script syntax. Exits 0 on clean, 1 on failure. |
| **Updated documentation** | `AGENTS.md`<br>`README.md` | Added `config/git/` and `scripts/` to diagrams. Listed new Makefile targets. Documented `fzf`/`zoxide` and validation script. |

---

## Tool Distinctions (Important Context)

This repo configures **four separate AI tools**, each with their own agent formats and native tool names. They are **not interchangeable**:

| Tool | Platform | Agent Format | Native Tools |
|------|----------|-------------|--------------|
| **OpenCode** | Terminal / IDE | Markdown frontmatter | `read`, `grep`, `glob`, `bash`, `webfetch`, `edit`, `write`, `patch`, `todowrite` |
| **Claude Code** | Terminal | Markdown output styles | `Read`, `Bash`, `Glob`, `WebFetch`, `Edit`, `Write`, `Patch`, `TodoWrite` |
| **Kiro CLI** | Terminal | JSON | `read`, `write`, `shell` (plus `@context7` via MCP) |
| **Kiro Desktop** | IDE (VS Code-like) | Markdown frontmatter | `read`, `write`, `shell`, `@context7` |
| **Kilo Code** | VS Code extension | N/A — not configured here | N/A |

The AGENTS.md table documents OpenCode's tool set as the **canonical reference** for planning, but each tool's actual config files must use that tool's **own native tool names**.

---

## Files Changed

**Modified (6):**
- `.gitignore`
- `AGENTS.md`
- `Makefile`
- `README.md`
- `config/opencode/opencode.json`
- `config/zsh/.zshrc`

**Created (5):**
- `config/git/.gitconfig`
- `config/git/.gitignore_global`
- `plans/dotfiles-improvements.md`
- `pr_description.md`
- `scripts/validate.sh`

**Unchanged (preserved original):**
- `config/kiro-cli/agents/*.json` (4 files)
- `config/kiro-desktop/agents/*.md` (4 files)
- `config/claude-code/output-styles/*.md` (4 files)
- `config/opencode/agents/*.md` (4 files)

---

## Validation

- All JSON files pass `jaq` validation (VS Code settings use JSONC with comments).
- Shell script syntax validated with `bash -n`.
- `./scripts/validate.sh` exits **0 errors, 1 warning** (Lua not installed — non-critical).
- `make help` output includes new targets.
- Kiro CLI and Kiro Desktop agent files verified against git HEAD — **no unintended changes**.

---

## Testing Checklist for Reviewers

- [ ] Run `make install-deps` twice — second run should be fast and silent.
- [ ] Run `make git-config` twice — `git config --global --list` should show no duplicates.
- [ ] Run `make copy-zsh` twice — confirm `~/.zshrc.bak.*` backup is created.
- [ ] Run `./scripts/validate.sh` — should exit 0 with 0 errors.
- [ ] Open WezTerm — p10k instant prompt should appear instantly.
- [ ] Type `cd <some dir>` — zoxide replaces native cd with smart directory tracking.
- [ ] Press `Ctrl+R` — fzf history search should activate.

---

*All changes validated with Context7 MCP where applicable. Agent files were left in their original tool-native formats after initial over-normalization was corrected.*
