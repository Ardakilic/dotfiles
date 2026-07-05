## Why

The repo ships WezTerm as its only terminal, but the owner wants to add Ghostty as a daily driver alongside it. Two real blockers prevent a copy-paste port: (1) Ghostty's config model differs from WezTerm's Lua API (different keys, different semantics — most notably an Option-key polarity inversion and byte-vs-line scrollback units), and (2) the `.zshrc` gates eight shell-quality-of-life blocks (p10k, autosuggestions, syntax-highlighting, fuzzy completion, history-substring-search) behind `$TERM_PROGRAM == "WezTerm"`, and Ghostty sets `TERM_PROGRAM=ghostty` — so out of the box those blocks silently skip and the shell regresses to bare zsh under Ghostty. This change adds a first-class Ghostty config, wires it into the Makefile/validate.sh/Brewfile, and widens the zsh gate so both terminals get the full shell experience.

## What Changes

- **New config dir & file**: `config/ghostty/config.ghostty` — a Ghostty config mirroring the relevant subset of `.wezterm.lua` plus three Ghostty-only extras (custom-style dock icon, `mouse-hide-while-typing`, `confirm-close-surface`).
- **New Makefile target**: `make copy-ghostty` copies `config/ghostty/config.ghostty` to `~/.config/ghostty/config.ghostty` (creating the directory), with the existing backup-before-overwrite pattern. Added to the `copy-all` dependency chain and the `help` listing.
- **`.zshrc` gate widened**: both `$TERM_PROGRAM == "WezTerm"` checks (line 4 instant-prompt block, line 103 main plugin block) become `[[ $TERM_PROGRAM == "WezTerm" || $TERM_PROGRAM == ghostty ]]`. No other `.zshrc` changes; the `bindkey "^U" backward-kill-line` line is terminal-agnostic and stays as-is (it pairs with Ghostty's `cmd+backspace=text:\x15`).
- **Brewfile**: add `cask "ghostty"` (stable, currently 1.3.1, requires macOS ≥ 13) alongside the existing `cask "wezterm@nightly"`. WezTerm is retained.
- **validate.sh**: append `ghostty` to the `EXPECTED_DIRS` array (so the existing Makefile-alignment check covers `config/ghostty/`), and add a new Ghostty-specific validation block that runs `ghostty +validate-config` when the `ghostty` binary is present (graceful skip when absent, mirroring the Lua/`luac` skip pattern).
- **README.md**: update the Config Structure diagram (add `ghostty/`), the Setup individual-targets list (`make copy-ghostty`), the Individual tools / Casks bullets (`ghostty`), the Environment bullet (WezTerm + Ghostty), and add a Notes bullet explaining the widened `.zshrc` gate fires for both `WezTerm` and `ghostty` `TERM_PROGRAM` values.
- **AGENTS.md**: update Project Structure (add `config/ghostty/config.ghostty`), Setup & Build Commands (add `make copy-ghostty` and add it to `make copy-all`), Environment (add Ghostty), and Conventions (note the dual-terminal `.zshrc` gate and the WezTerm-vs-Ghostty Option-key polarity difference).

### Not ported from WezTerm (deliberate)

The following WezTerm features are **not** carried over to the Ghostty config, per the owner's decisions:

- `initial_cols` / `initial_rows` (window geometry) — Ghostty's `window-width`/`window-height` omitted; accept Ghostty default.
- `harfbuzz_features` ligature disabling — omitted; accept Ghostty's default ligature rendering.
- `window_padding` — omitted; accept Ghostty default padding.
- `enable_scroll_bar` — omitted; accept Ghostty default (`scrollbar = system`).
- `scrollback_lines = 50000` — omitted; accept Ghostty default scrollback.
- Dynamic Ayu light/dark theme — omitted; accept Ghostty's default theme. (Both `Ayu Mirage` and `Ayu Light` are built-in Ghostty themes and can be enabled later with `theme = light:Ayu Light,dark:Ayu Mirage` if desired.)
- `Cmd+W` close pane, `Cmd+Shift+W` close tab, `Cmd+Shift+Left/Right` move tab — omitted; accept Ghostty's built-in defaults for these.

### Ported from WezTerm

- Font: `MonoLisaCode Nerd Font` at size 13.
- `macos-titlebar-style = tabs` (the `INTEGRATED_BUTTONS | RESIZE` equivalent — tab bar merged into titlebar with traffic-light buttons).
- `macos-option-as-alt = left` (LEFT Option = Alt for native word-jump, RIGHT Option = composed chars like é — owner's preference; note that Ghostty's `macos-option-as-alt` is a blunt per-key toggle, unlike WezTerm's `send_composed_key_when_left_alt_is_pressed` which intercepts at the keybinding layer, so no Ghostty value perfectly replicates WezTerm's "both options do both" behavior).
- Nine keybindings: `Ctrl+Shift+F` search, `Cmd+Shift+D` vertical split (down), `Cmd+D` horizontal split (right), `Cmd+K` clear scrollback, `Cmd+Left/Right` Home/End, `Cmd+Shift+P` command palette, `Opt+Left/Right` word-jump (`esc:b`/`esc:f`), `Cmd+Backspace` backward-kill-line (`text:\x15`), `Shift+Enter` multiline (`text:\x1b\r`).
- `copy-on-select = clipboard` (left-click selection copies — mirrors WezTerm's `CompleteSelection`).
- `link-url = true` (Cmd-click opens links — explicit even though it's Ghostty's default).

### Ghostty-only additions

- `macos-icon = custom-style` with `macos-icon-frame = aluminum`, `macos-icon-ghost-color = #ffffff`, `macos-icon-screen-color = #1a1b26,#000000` (custom-style dock icon; experimental but owner-selected).
- `mouse-hide-while-typing = true`.
- `confirm-close-surface = true`.

## Capabilities

### New Capabilities

- `ghostty-terminal`: Ghostty terminal configuration — font, titlebar style, Option-key behavior, keybindings, mouse behaviors, and Ghostty-only extras (custom-style dock icon, mouse-hide-while-typing, confirm-close-surface). Installed via `make copy-ghostty` to `~/.config/ghostty/config.ghostty`. Config format is plain-text `key = value` (snake_case, case-sensitive). Live reload is via `cmd+shift+,` (not automatic on save); some keys apply only to new windows/surfaces.
- `terminal-zsh-gating`: The `.zshrc` blocks that gate shell-quality-of-life features (p10k instant prompt, p10k theme, zsh-autosuggestions, compinit + fuzzy completion, zsh-syntax-highlighting, zsh-history-substring-search) on `$TERM_PROGRAM`. Currently fires only for `WezTerm`; this change widens the gate to also fire for `ghostty`. The `bindkey "^U" backward-kill-line` line is terminal-agnostic and explicitly out of scope for this capability.

### Modified Capabilities

- `font-config`: The existing `font-config` spec requires terminal/TUI configs to use `MonoLisaCode Nerd Font`. It currently names only `config/wezterm/.wezterm.lua`. This change adds `config/ghostty/config.ghostty` as a second terminal config that MUST set the Nerd Font variant, and adds a scenario verifying the Ghostty `font-family` value. The "no stale v2 names" grep scenario is also widened to cover the new file. The role-split requirement (editors = base font, terminals = Nerd Font) is preserved and extended to Ghostty.

## Impact

- **New files**: `config/ghostty/config.ghostty`; four OpenSpec delta spec files under `openspec/changes/add-ghostty/specs/`.
- **Edited files**: `Makefile` (new target + `copy-all` + `.PHONY` + `help`), `config/zsh/.zshrc` (two gate predicates widened), `config/brew/Brewfile` (one cask line), `scripts/validate.sh` (one array entry + one validation block), `README.md` (structure + setup + deps + notes), `AGENTS.md` (structure + commands + environment + conventions).
- **New dependency**: `cask "ghostty"` in the Brewfile. Installed via `make install-deps`. Requires macOS ≥ 13 (Ghostty's minimum). No tap needed — `homebrew/cask` carries it.
- **No removals**: WezTerm config, `copy-wezterm`, `wezterm@nightly` cask, and all WezTerm references in docs are retained. Ghostty is added alongside, not as a replacement.
- **Behavioral change for users**: after `make copy-ghostty` (and a Ghostty restart or `cmd+shift+,` reload), Ghostty uses MonoLisaCode Nerd Font at 13pt, tabs-in-titlebar, right-Option-as-Alt, the nine ported keybindings, copy-on-select, and the three Ghostty-only extras. After `make copy-zsh`, zsh under Ghostty loads p10k + autosuggestions + syntax-highlight + fuzzy completion + history-substring-search (previously skipped).
- **Validation**: `scripts/validate.sh` enforces `config/ghostty/` existence and Makefile reference (via `EXPECTED_DIRS`), and runs `ghostty +validate-config` when the binary is available. The existing JSON/Lua/Makefile/agent checks are unchanged.
- **No security impact**: Ghostty config touches no sensitive paths (`~/.ssh`, `.env`, etc.). The OpenCode permission deny-rules in `config/opencode/opencode.json` need no changes.