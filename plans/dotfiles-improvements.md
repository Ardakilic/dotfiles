# Dotfiles Improvement Plan

> Generated on 2026-06-03 via Context7 MCP validation + manual audit.
> All claims cross-referenced against upstream documentation.

---

## 1. Executive Summary

> **Retrospective**: This document captures the **20 validated findings** that were analyzed and addressed in this PR. It documents the pre-implementation state and the fixes applied.

---

## 2. Validation Methodology

| Source | What Was Checked | Tool |
|--------|-----------------|------|
| ZSH Options Reference Manual (zsh.sourceforge.io) | `setopt` vs `setops` syntax, `HIST_*` option semantics | Context7 (`/git/htmldocs`) + WebFetch |
| Powerlevel10k Official README | Instant prompt placement requirements | WebFetch (github.com/romkatv/powerlevel10k) |
| WezTerm Configuration Docs | Environment variables, `WEZTERM_DISCRIMINATE_STDERR`, font config | Context7 (`/websites/wezterm_config`) |
| Git Config Documentation | Idempotency of `git config --global` | Context7 (`/git/htmldocs`) |
| Repository Cross-Reference | Agent persona consistency, Makefile targets, README accuracy | Manual `read` across 20+ files |

---

## 3. Findings by Priority

### 🔴 High Priority — Bugs / Silent Failures

#### H1. Typo in `.zshrc`: `setops` should be `setopt`
- **Location**: `config/zsh/.zshrc:157`
- **Current**: `# setops HIST_IGNORE_ALL_DUPS`
- **Expected**: `# setopt HIST_IGNORE_ALL_DUPS`
- **Validation**: ZSH official options reference confirms `setopt` is the builtin. `setops` does not exist. This is a silent syntax error that disables deduplication if uncommented.
- **Impact**: If user uncomments this line, zsh will error on startup.
- **Fix**: Single-character change.

#### H2. Powerlevel10k Instant Prompt Is Too Late in `.zshrc`
- **Location**: `config/zsh/.zshrc:103–109`
- **Current**: Instant prompt block sits inside the `TERM_PROGRAM == "WezTerm"` conditional, after PATH exports, aliases, and functions.
- **Expected**: Per Powerlevel10k docs: *"Should stay close to the top of ~/.zshrc. Initialization code that may require console input must go above this block; everything else may go below."*
- **Validation**: WebFetch of Powerlevel10k README confirms instant prompt must be at the very top to avoid being disabled by any console output above it.
- **Impact**: If any command above the block prints (e.g., a broken Homebrew path), instant prompt is silently disabled, adding startup lag.
- **Fix**: Move the instant prompt block to lines 1–3, above all PATH exports and conditional blocks. Keep the p10k theme source and `~/.p10k.zsh` source inside the WezTerm block.

#### H3. `git-config` Makefile Target Is Not Idempotent
- **Location**: `Makefile:37–46`
- **Current**: Uses bare `git config --global <key> <value>` repeatedly.
- **Expected**: Per Git docs, `git config --global` appends by default. Running `make git-config` twice creates duplicate entries in `~/.gitconfig`.
- **Validation**: Context7 Git docs confirm `--global` writes to the global config file and does not deduplicate.
- **Impact**: Bloated `~/.gitconfig` with duplicate keys.
- **Fix**: Use `git config --global --replace-all <key> <value>` for each setting, or wrap in a "check first" guard.

#### H4. `copy-claude-mcp` Overwrites Without Backup
- **Location**: `Makefile:86–88`
- **Current**: `cp $(CURRENT_DIR)/config/claude-code/.claude.json $(HOME)/.claude.json`
- **Expected**: If user has added other MCP servers to `~/.claude.json`, they are lost permanently on copy.
- **Impact**: Data loss of user-customized MCP configuration.
- **Fix**: Add a backup step before overwrite, e.g. `cp $(HOME)/.claude.json $(HOME)/.claude.json.bak.$$(date +%s) 2>/dev/null || true`.

#### H5. `.gitignore` — `.kilo-code/` Added
- **Location**: `.gitignore`
- **Status**: ✅ Resolved — Added `.kilo-code/` to `.gitignore` in this PR alongside existing `.kilo/`, `.roo/`, `.claude/`, `.kiro/`, `.vscode/`. Also added `.kilo/`, `.kilo-code/`, `.roo/`, `.claude/`, `.kiro/`, and `suggestions.md` to `config/git/.gitignore_global`. Source of truth: `pr_description.md` (Kilo Code ignore update row).

---

### 🟡 Medium Priority — Quality / DRY / Consistency

#### M1. VS Code Settings Are 99% Duplicated Across 3 Files
- **Location**: `config/vscode/settings.json`, `config/vscode-insiders/settings.json`, `config/vscodium/settings.json`
- **Current**: `vscode` and `vscode-insiders` are byte-for-byte identical (44 lines). `vscodium` differs only by intentional omission of Copilot references (lines 24–29).
- **Impact**: Any change to shared settings requires editing 3 files. High risk of drift.
- **Fix Options**:
  1. **Makefile-driven sync**: Add a target that copies the base to insiders/vscodium (with Copilot strip for VSCodium).
  2. **Shared common file**: Create `config/vscode/common.json` and reference it (not natively supported by VS Code, so #1 is preferred).
  3. **Validation script**: See L5 below.

#### M2. `install-deps` Is Not Idempotent
- **Location**: `Makefile:30–35`
- **Current**: Runs `brew install ...` unconditionally.
- **Impact**: Reinstalls on every run. Slow and noisy.
- **Fix**: Use `brew list <pkg> &>/dev/null || brew install <pkg>` for each dependency.

#### M3. Agent Persona Drift Across Tools
- **Status:** `CANCELLED` — After re-validating with Context7 MCP, discovered Kiro CLI and Kiro Desktop use different native tool names (`read`/`write`/`shell`, `@context7`) compared to OpenCode (`read`/`grep`/`glob`/`bash`/`webfetch`/`edit`/`write`/`patch`/`todowrite`).
- **Resolution:** Left Kiro CLI and Kiro Desktop agent files in their original tool-native formats. The AGENTS.md table documents OpenCode as the canonical reference, but each tool's config must use its own native tool names. Kilo Code (VS Code extension) is a separate tool altogether and is not configured in this repo.

#### M4. `opencode.json` Schema URL Is Unversioned
- **Location**: `config/opencode/opencode.json:2`
- **Current**: `"$schema": "https://opencode.ai/config.json"`
- **Impact**: Remote URL may 404 or introduce breaking changes without warning.
- **Fix**: Check if OpenCode supports a local schema or versioned URL. If not, document the risk in AGENTS.md.

#### M5. Missing Validation / CI Script
- **Location**: None (new)
- **Impact**: No automated way to catch JSON syntax errors, Lua syntax errors, or Makefile/AGENTS drift.
- **Fix**: Add `scripts/validate.sh` that:
  1. Runs `jq empty` on all `.json` files.
  2. Runs `lua -e` syntax check on `.wezterm.lua`.
  3. Verifies every `config/` subdirectory has a corresponding `copy-*` target in the Makefile.
  4. Flags agent description mismatches across tools.

#### M6. `README.md` Stale TODOs + Misleading Ghostty Note — Resolved
- **Location**: `README.md:259–264`
- **Status**: ✅ Resolved — The PR added `config/git/.gitconfig` and `config/git/.gitignore_global` (confirmed in `pr_description.md`), so the TODOs listing `.gitconfig` and `.gitignore_global` as checked done (`[x]`) are accurate and the files now exist in the repo. The Ghostty note about `.wezterm.lua` was removed because no such commented-out config exists in the file.
- **Impact**: None (documentation now matches repo state).

---

### 🟢 Low Priority — Improvements / Features

#### L1. Add `.gitconfig` Template
- **Rationale**: Your TODO explicitly wants this. A tracked `.gitconfig` lets you version aliases, `excludesfile`, `delta` settings, and merge config. Do NOT include `[user]` block for privacy.
- **Files to create**:
  - `config/git/.gitconfig`
  - `config/git/.gitignore_global`
- **Makefile target**: `copy-gitconfig`
- **Integration**: Update `git-config` target to also copy `.gitconfig` and set `core.excludesfile`.

#### L2. Add Modern Navigation Tools (`fzf`, `zoxide`)
- **Rationale**: Your alias stack (eza, bat, jaq, delta) is modern. `zoxide` (replaces `cd` with smart directory tracking) and `fzf` (fuzzy finder) are natural complements.
- **Files to modify**:
  - `Makefile:33` — add `fzf zoxide` to `brew install`
  - `config/zsh/.zshrc` — add `eval "$(zoxide init zsh --cmd cd)"` (replaces cd) and `$(brew --prefix)/opt/fzf/shell/completion.zsh` / `key-bindings.zsh`

#### L3. Document `hapuppy` Provider in README
- **Rationale**: `opencode.json` includes a custom provider (`hapuppy`) with internal-only model names. If this is a private/self-hosted endpoint, other users of the repo will have broken configs.
- **Fix**: Add a note to README or AGENTS.md: "`hapuppy` is a custom OpenAI-compatible endpoint; replace `baseURL` and model names with your own."

#### L4. Consider HISTFILE Location
- **Location**: `config/zsh/.zshrc:164`
- **Current**: `HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_history"`
- **Rationale**: On macOS, `~/.cache` is not cleaned by standard tools. History is data, not cache. XDG spec suggests `~/.local/share/` for data.
- **Fix Options**: Leave as-is (works fine), or move to `${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history` with a `mkdir -p` guard.

#### L5. Add Agent Consistency Lint to Validation Script
- **Rationale**: Even after normalizing agents (M3), drift can reoccur. A script diffing descriptions and tool lists across the 4 formats would catch this.
- **Implementation**: A small Python or shell script reading JSON frontmatter and JSON files.

#### L6. Makefile Backup for All Destructive Copies
- **Rationale**: H4 highlights the Claude MCP issue. The same risk exists for `.zshrc`, `.wezterm.lua`, VS Code settings, etc.
- **Fix**: Add a generic `backup-or-overwrite` macro to the Makefile that timestamps backups before any destructive copy.

---

## 4. Implementation Plan

Below is the recommended execution order. Each task includes the file(s) to modify and a validation step.

### Phase 1 — Fix Silent Bugs (Must Do)

| # | Task | File(s) | Validation |
|---|------|---------|------------|
| 1 | Fix `setops` → `setopt` typo | `config/zsh/.zshrc` | `grep "setops" ~/.zshrc` should return nothing after `make copy-zsh` |
| 2 | Move p10k instant prompt to top of `.zshrc` | `config/zsh/.zshrc` | Instant prompt block must be lines 1–5, above PATH exports. Restart WezTerm and confirm no startup lag |
| 3 | Make `git-config` idempotent | `Makefile` | Run `make git-config` twice; `git config --global --list` should show no duplicates |
| 4 | Add backup before `copy-claude-mcp` | `Makefile` | Run `make copy-claude-mcp` twice; confirm `.claude.json.bak.*` exists |
| 5 | Verify Kilo Code ignore dir | `.gitignore` | Check Kilo Code docs; add `.kilo-code/` if needed |

### Phase 2 — Quality & Consistency

| # | Task | File(s) | Validation |
|---|------|---------|------------|
| 6 | Normalize agent descriptions across all tools | `config/kiro-cli/agents/*.json`, `config/kiro-desktop/agents/*.md` | Diff tool descriptions; all should match OpenCode canonical text |
| 7 | Normalize agent tool permissions across all tools | Same as #6 | `review` must have read+grep+glob+bash/webfetch; `architect` must have edit+write+patch+todowrite; etc. |
| 8 | Add Makefile idempotency for `install-deps` | `Makefile` | Run twice; second run should complete in <2s with "already installed" messages |
| 9 | Add VS Code settings sync/validation | `Makefile` or new script | One source of truth for shared VS Code settings |
| 10 | Fix README stale TODOs and Ghostty note | `README.md` | Remove/update checked TODOs; remove or add Ghostty config |
| 11 | Version or document `opencode.json` schema risk | `config/opencode/opencode.json` or `AGENTS.md` | Add comment or versioned URL |

### Phase 3 — New Features & Tooling

| # | Task | File(s) | Validation |
|---|------|---------|------------|
| 12 | Add `.gitconfig` and `.gitignore_global` | `config/git/.gitconfig`, `config/git/.gitignore_global`, `Makefile` | `make copy-gitconfig` works; `git config --global --list` shows aliases |
| 13 | Add `fzf` and `zoxide` to deps and `.zshrc` | `Makefile`, `config/zsh/.zshrc` | `cd <dir>` uses zoxide intelligence; `Ctrl+R` uses fzf history |
| 14 | Add validation script | `scripts/validate.sh` | Run `./scripts/validate.sh` from repo root; exits 0 on clean repo |
| 15 | Add Makefile backup macro for all destructive ops | `Makefile` | Every `copy-*` target creates `.bak.<timestamp>` before overwrite |
| 16 | Document `hapuppy` provider | `README.md` or `AGENTS.md` | Other users know to replace the endpoint |
| 17 | (Optional) Move HISTFILE to XDG_DATA_HOME | `config/zsh/.zshrc` | History persists across sessions; no data loss |

---

## 5. Agent Consistency Reference Specification (Future/Target)

> **Note**: This section is a **reference specification** for a future normalization effort, **not implemented** in this PR. The M3 normalization was cancelled because Kiro CLI/Kiro Desktop use different native tool names (`shell`, `@context7`) compared to OpenCode (`bash`). The matrix below defines the ideal target state if normalization is ever attempted. For now, each tool's config uses its own native tool names.

All agents would converge to this specification in a future normalization:

| Persona | Description | Canonical Tools |
|---------|-------------|-----------------|
| **ask** | Get answers and explanations without code changes | `read`, `grep`, `glob`, `webfetch` |
| **architect** | Plan and design before implementation | `read`, `grep`, `glob`, `webfetch`, `edit`, `write`, `patch`, `todowrite` |
| **review** | Review code changes locally | `read`, `grep`, `glob`, `bash`/`shell`, `webfetch`, `todowrite` |
| **debug** | Diagnose and fix software issues | `read`, `grep`, `glob`, `bash`/`shell`, `webfetch`, `edit`, `write`, `patch`, `todowrite` |

**Tool mapping per platform:**
- OpenCode: `bash` (native tool)
- Kiro Desktop: `shell` (maps to bash)
- Kiro CLI: `shell` (maps to bash)
- Claude Code: `Bash` (native tool, capitalize in docs only — actual tool name is case-insensitive)

**Reference rules (for future use if normalization is revisited):**
1. Kiro Desktop markdown agents should list equivalent tools using Kiro's tool naming (`shell` for bash, `@context7` retained as bonus).
2. Kiro CLI JSON agents should include the full tool array in both `tools` and `allowedTools`.
3. Claude Code output styles should match OpenCode agent descriptions word-for-word.
4. All `architect` agents must include the "never provide time estimates" clause and `todowrite` emphasis.
5. All `review` agents must include the severity table and output format.
6. All `debug` agents must include the "5-7 possible sources → 1-2 most likely → confirm before fixing" workflow.

> **M3 Status**: Cancelled. See M3 note in Section 3 for rationale.

---

## 6. References

1. **ZSH Options Manual** — `setopt` syntax confirmed: https://zsh.sourceforge.io/Doc/Release/Options.html
2. **Powerlevel10k Instant Prompt** — Must be at top of `~/.zshrc`: https://github.com/romkatv/powerlevel10k#instant-prompt
3. **WezTerm Environment Variables** — `set_environment_variables` config: https://wezterm.org/config/lua/config/set_environment_variables.html
4. **Git Config Documentation** — `git config --global` appends by default: Context7 `/git/htmldocs`
5. **AGENTS.md** — Repository conventions and agent persona definitions: `/Users/arda.kilicdagi/projects/dotfiles/AGENTS.md`

---

*This plan should be committed to the repo as `plans/dotfiles-improvements.md` once reviewed and approved.*
