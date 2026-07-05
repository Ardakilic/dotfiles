## 1. Create the Ghostty config file

- [x] 1.1 Create the directory `config/ghostty/` in the repo root.
- [x] 1.2 Create `config/ghostty/config.ghostty` with the exact content below. The file is plain-text `key = value`, snake_case, case-sensitive. Comments use `#` on their own line. Do NOT add any keys beyond those listed — the spec's "Features deliberately not set" requirement forbids window-width, window-height, font-feature, window-padding-x/y, scrollbar, scrollback-limit, theme, background-opacity, background-blur.

  ```ini
  # Ghostty terminal configuration
  # Mirrors the relevant subset of ../wezterm/.wezterm.lua plus Ghostty-only extras.
  # Installed to ~/.config/ghostty/config.ghostty by `make copy-ghostty`.
  # Reload after editing with cmd+shift+, (some keys apply only to new windows).

  # ── Font ───────────────────────────────────────────────────────────
  # Nerd Font variant for powerlevel10k glyph rendering (matches WezTerm).
  font-family = "MonoLisaCode Nerd Font"
  font-size = 13

  # ── macOS titlebar ─────────────────────────────────────────────────
  # Integrate the tab bar into the titlebar with traffic-light buttons.
  # Equivalent to WezTerm's INTEGRATED_BUTTONS | RESIZE.
  macos-titlebar-style = tabs

  # ── macOS Option key ───────────────────────────────────────────────
  # LEFT Option = Alt (native word-jump via Alt+b/Alt+f and the opt+arrow
  # keybindings below). RIGHT Option = composed chars (é, ∑).
  # Note: Ghostty's macos-option-as-alt is a blunt per-key toggle, unlike
  # WezTerm's send_composed_key_when_left_alt_is_pressed which intercepts
  # at the keybinding layer. Neither left/right/true perfectly replicates
  # WezTerm's "both options do both" behavior; `left` is the owner's choice.
  macos-option-as-alt = left

  # ── Mouse ──────────────────────────────────────────────────────────
  # Selection copies to system clipboard (mirrors WezTerm left-click-copies).
  copy-on-select = clipboard
  # Cmd-click opens links (explicit even though it's the Ghostty default).
  link-url = true
  # Hide mouse cursor while typing.
  mouse-hide-while-typing = true

  # ── Safety ─────────────────────────────────────────────────────────
  # Prompt before closing a surface with active processes.
  confirm-close-surface = true

  # ── macOS dock icon (custom-style, experimental) ───────────────────
  macos-icon = custom-style
  macos-icon-frame = aluminum
  macos-icon-ghost-color = #ffffff
  macos-icon-screen-color = #1a1b26,#000000

  # ── Keybindings (ported from WezTerm) ──────────────────────────────
  # Syntax: keybind = trigger=action. Modifiers: shift, ctrl, alt (=opt),
  # super (=cmd). Ghostty defaults are accepted for close-pane, close-tab,
  # and move-tab (not re-bound here).

  # Case-insensitive search (case-insensitive is Ghostty's default).
  keybind = ctrl+shift+f=start_search

  # Splits. WezTerm SplitVertical = top/bottom = new_split:down.
  # WezTerm SplitHorizontal = side-by-side = new_split:right.
  keybind = cmd+shift+d=new_split:down
  keybind = cmd+d=new_split:right

  # Clear screen + scrollback (matches WezTerm ClearScrollback 'ScrollbackAndViewport').
  keybind = cmd+k=clear_screen

  # Home / End. csi:H sends ESC[H (CUP to row 1 col 1). csi:F sends ESC[F (CPL).
  keybind = cmd+left=csi:H
  keybind = cmd+right=csi:F

  # Command palette.
  keybind = cmd+shift+p=toggle_command_palette

  # Word-jump (fires reliably on LEFT Option; RIGHT Option produces composed chars).
  keybind = opt+left=esc:b
  keybind = opt+right=esc:f

  # Backward-kill-line: send Ctrl-U. Pairs with .zshrc `bindkey "^U" backward-kill-line`.
  keybind = cmd+backspace=text:\x15

  # Multiline REPL input: send Alt+Enter (ESC + CR). \x1b = ESC, \r = CR.
  keybind = shift+enter=text:\x1b\r
  ```

- [x] 1.3 Verify the file parses: if `ghostty` is installed, run `ghostty +validate-config --config-default-files=false --config-file=$(pwd)/config/ghostty/config.ghostty` from the repo root and confirm exit 0. If `ghostty` is not installed, skip (validation will run in step 7).

## 2. Add the copy-ghostty Makefile target

- [x] 2.1 In `Makefile`, add `copy-ghostty` to the `.PHONY` line (alphabetically near `copy-gitconfig`, `copy-gitignore-global` — the exact position doesn't matter as long as it's in the `.PHONY` list).
- [x] 2.2 Add the `copy-ghostty` target block. Place it near the `copy-wezterm` block for logical grouping. Use this exact content, matching the existing `backup-file` macro pattern:

  ```makefile
  copy-ghostty:
  	@mkdir -p "$(HOME)/.config/ghostty"
  	$(call backup-file,$(HOME)/.config/ghostty/config.ghostty)
  	@cp $(CURRENT_DIR)/config/ghostty/config.ghostty "$(HOME)/.config/ghostty/config.ghostty"
  	@echo "Copied config/ghostty/config.ghostty to ~/.config/ghostty/config.ghostty"
  ```

  Note: the destination path uses `$(HOME)/.config/ghostty/config.ghostty` (XDG). The `mkdir -p` creates the directory if missing. The `backup-file` macro backs up the existing file before overwriting.

- [x] 2.3 Add `copy-ghostty` to the `copy-all` target's dependency chain. The current `copy-all` line is:
  ```makefile
  copy-all: copy-zsh copy-wezterm copy-vscode-settings copy-vscode-insiders-settings copy-vscodium-settings copy-kiro-desktop-settings copy-kiro-desktop-agents copy-kiro-cli-agents copy-claude-mcp copy-claude-settings copy-claude-output-styles copy-opencode copy-opencode-agents copy-gitconfig copy-gitignore-global copy-git-allowed-signers
  ```
  Insert `copy-ghostty` after `copy-wezterm` (logical grouping with the other terminal):
  ```makefile
  copy-all: copy-zsh copy-wezterm copy-ghostty copy-vscode-settings copy-vscode-insiders-settings copy-vscodium-settings copy-kiro-desktop-settings copy-kiro-desktop-agents copy-kiro-cli-agents copy-claude-mcp copy-claude-settings copy-claude-output-styles copy-opencode copy-opencode-agents copy-gitconfig copy-gitignore-global copy-git-allowed-signers
  ```
- [x] 2.4 Add a `help` line for `copy-ghostty` in the `help` target, near the `copy-wezterm` line:
  ```makefile
  	@echo "  copy-ghostty                - Copy config/ghostty/config.ghostty to ~/.config/ghostty/config.ghostty"
  ```

## 3. Widen the .zshrc TERM_PROGRAM gate

- [x] 3.1 In `config/zsh/.zshrc`, find the line (currently line 4):
  ```sh
  if [[ $TERM_PROGRAM == "WezTerm" ]]; then
  ```
  This is the powerlevel10k instant-prompt gate at the top of the file. Replace with:
  ```sh
  if [[ $TERM_PROGRAM == "WezTerm" || $TERM_PROGRAM == ghostty ]]; then
  ```
  Use the exact lowercase string `ghostty` (matches the value Ghostty sets per `src/termio/Exec.zig`). Do NOT change any other line in this block.

- [x] 3.2 In `config/zsh/.zshrc`, find the line (currently line 103):
  ```sh
  if [[ $TERM_PROGRAM == "WezTerm" ]]; then
  ```
  This is the main plugin block gate (zsh-autosuggestions, powerlevel10k theme, compinit, fuzzy completion, zsh-syntax-highlighting, zsh-history-substring-search). Replace with:
  ```sh
  if [[ $TERM_PROGRAM == "WezTerm" || $TERM_PROGRAM == ghostty ]]; then
  ```
  Do NOT change any other line in this block. The `bindkey "^U" backward-kill-line` line (currently line 98) is terminal-agnostic and MUST remain unconditional and unchanged.

- [x] 3.3 Verify no other `$TERM_PROGRAM` references exist in `.zshrc` besides these two (grep `TERM_PROGRAM` in `config/zsh/.zshrc` — expect exactly 2 matches, both now widened).

## 4. Add the Ghostty cask to the Brewfile

- [x] 4.1 In `config/brew/Brewfile`, find the Casks section. Add `cask "ghostty"` near `cask "wezterm@nightly"` (logical grouping). Do NOT remove or modify the `cask "wezterm@nightly"` line. Do NOT add `cask "ghostty@tip"` (nightly). Example placement:
  ```ruby
  cask "ghostty"
  cask "wezterm@nightly"
  ```
  (Order within the Casks section doesn't matter; grouping them is for readability.)

## 5. Update scripts/validate.sh

- [x] 5.1 In `scripts/validate.sh`, find the `EXPECTED_DIRS` array (currently line 86):
  ```sh
  EXPECTED_DIRS=(zsh wezterm git vscode vscode-insiders vscodium kiro-desktop kiro-cli claude-code opencode)
  ```
  Append `ghostty` to the array:
  ```sh
  EXPECTED_DIRS=(zsh wezterm ghostty git vscode vscode-insiders vscodium kiro-desktop kiro-cli claude-code opencode)
  ```
  (Placing `ghostty` after `wezterm` groups the terminals together. Exact position doesn't matter as long as it's in the array.)

- [x] 5.2 Add a new Ghostty validation block. Place it after the Lua validation block (section 2) and before the Makefile target alignment block (section 3), so it's logically grouped with the other config-syntax checks. Use this exact content:

  ```sh
  # ─────────────────────────────────────────────
  # 2b. Ghostty config validation
  # ─────────────────────────────────────────────
  info "Checking Ghostty config..."
  if [[ -f "config/ghostty/config.ghostty" ]]; then
    if command -v ghostty >/dev/null 2>&1; then
      # Validate the repo file in isolation (not the installed ~/.config/ghostty/config.ghostty).
      # --config-default-files=false prevents loading the user's installed config;
      # --config-file=PATH loads only the repo file.
      if ! ghostty +validate-config --config-default-files=false --config-file="$REPO_ROOT/config/ghostty/config.ghostty" >/dev/null 2>&1; then
        error "Ghostty config validation failed for config/ghostty/config.ghostty"
        # Re-run without suppressing output to show the error for debugging:
        ghostty +validate-config --config-default-files=false --config-file="$REPO_ROOT/config/ghostty/config.ghostty" 2>&1 | head -20 || true
      fi
    else
      warn "ghostty binary not installed — skipping Ghostty config validation"
    fi
  fi
  ```

  Note: the `warn` path matches the existing Lua/`luac` skip pattern — the script does NOT exit non-zero solely because `ghostty` is absent. The `error` path increments `ERRORS` and the script exits non-zero at the end if any errors occurred.

## 6. Update README.md

- [x] 6.1 In the "My Environment" section, add a Ghostty bullet. The current list has `[WezTerm](https://wezterm.org/) (nightly)`. Add after it:
  ```markdown
  - [Ghostty](https://ghostty.org/)
  ```
  (WezTerm remains listed.)

- [x] 6.2 In the `### Casks:` section (the sibling section after `### Individual tools:`), add a Ghostty bullet near the existing cask bullets:
  ```markdown
  - [ghostty](https://ghostty.org/) — terminal emulator
  ```
  (Keep the existing cask bullets including `wezterm@nightly` which is listed in `### Individual tools:` as a highlight. Optionally also add a `ghostty` highlight bullet to `### Individual tools:` for parity with the existing `wezterm@nightly` highlight there.)

- [x] 6.3 In the "Setup" → "Using Makefile" → individual targets list, add a `make copy-ghostty` line near the `make copy-wezterm` line:
  ```markdown
  make copy-ghostty                # Copy config/ghostty/config.ghostty to ~/.config/ghostty/config.ghostty
  ```

- [x] 6.4 In the "Config Structure" diagram, add the `ghostty/` directory. Insert it near `wezterm/`:
  ```
  ├── ghostty/
  │   └── config.ghostty        # Ghostty terminal config
  ├── wezterm/
  │   └── .wezterm.lua           # WezTerm terminal config
  ```

- [x] 6.5 In the "Notes" section, add a bullet explaining the dual-terminal zsh gate:
  ```markdown
  * Some `.zshrc` blocks (powerlevel10k, autosuggestions, syntax-highlighting, fuzzy completion, history-substring-search) are gated on `$TERM_PROGRAM` and load in both WezTerm (`WezTerm`) and Ghostty (`ghostty`). Other terminals (Terminal.app, iTerm2, Warp) get a minimal shell.
  ```

## 7. Update AGENTS.md

- [x] 7.1 In the "Project Structure" diagram (the ascii tree near the top), add `config/ghostty/`. Insert it near `config/wezterm/`:
  ```
  ├── ghostty/
  │   └── config.ghostty        # Ghostty terminal: font, titlebar, option key, keybinds, mouse, icon
  ├── wezterm/
  │   └── .wezterm.lua          # WezTerm terminal: colorscheme, keybindings, fonts
  ```

- [x] 7.2 In the "Setup & Build Commands" section, add `make copy-ghostty` to the command list (near `make copy-wezterm`):
  ```sh
  make copy-ghostty                  # config/ghostty/config.ghostty → ~/.config/ghostty/config.ghostty
  ```

- [x] 7.3 In the "Setup & Build Commands" section, update the `make copy-all` description to mention Ghostty. The current line reads `make copy-all # Copy all config files + git config (with backups)`. Add a note that `copy-all` now includes `copy-ghostty`. If there's an explicit list of what `copy-all` includes, append `copy-ghostty` to it.

- [x] 7.4 In the "Environment" section, add a Ghostty bullet. The current Environment section has `- Terminal: WezTerm nightly`. Change to mention both, e.g.:
  ```markdown
  - **Terminal:** WezTerm nightly and Ghostty (stable). Some `.zshrc` features gate on `$TERM_PROGRAM` and fire for both `WezTerm` and `ghostty`.
  ```

- [x] 7.5 In the "Conventions" section, add two notes:
  1. A note about the dual-terminal zsh gate:
     ```markdown
     - **Dual-terminal zsh gate:** The `.zshrc` blocks that load powerlevel10k, autosuggestions, syntax-highlighting, fuzzy completion, and history-substring-search are gated on `$TERM_PROGRAM` matching either `WezTerm` or `ghostty`. Other terminals get a minimal shell. The `bindkey "^U" backward-kill-line` line is terminal-agnostic (unconditional) and pairs with both WezTerm's and Ghostty's Cmd+Backspace mapping.
     ```
  2. A note about the Option-key polarity difference:
     ```markdown
     - **WezTerm vs Ghostty Option key:** WezTerm's `send_composed_key_when_left_alt_is_pressed = true` intercepts at the keybinding layer — `mods = 'OPT'` bindings fire on both option keys, and LEFT additionally does composed chars on unbound keys. Ghostty's `macos-option-as-alt = left` is a blunt per-key toggle (LEFT = Alt, RIGHT = composed). No Ghostty value perfectly replicates WezTerm's "both options do both" behavior; `left` is the owner's choice.
     ```

## 8. Validate

- [x] 8.1 Run `scripts/validate.sh` from the repo root and confirm it passes (exit 0). If `ghostty` is installed, the new Ghostty validation block runs `ghostty +validate-config` against the repo file; if not, it warns and skips. The `EXPECTED_DIRS` check now enforces `config/ghostty/` exists and the Makefile references it. The existing JSON/Lua/Makefile/agent checks must still pass.

- [x] 8.2 Run `make help` and confirm `copy-ghostty` is listed in the targets.

- [x] 8.3 Run `make copy-ghostty` on the owner's machine and confirm:
  - `~/.config/ghostty/` is created if missing.
  - `~/.config/ghostty/config.ghostty` is written.
  - If a previous `~/.config/ghostty/config.ghostty` existed, a `.bak.<timestamp>` backup is created alongside it.
  - The confirmation message "Copied config/ghostty/config.ghostty to ~/.config/ghostty/config.ghostty" is printed.

- [x] 8.4 If Ghostty is installed, open Ghostty and confirm:
  - Font is MonoLisaCode Nerd Font at 13pt.
  - Tab bar is integrated into the titlebar (macos-titlebar-style = tabs).
  - LeftOption+Left moves the cursor one word back (Alt+b / esc:b).
  - RightOption+e produces é (composed char).
  - Cmd+Shift+D opens a split below; Cmd+D opens a split to the right.
  - Cmd+K clears the screen + scrollback.
  - Ctrl+Shift+F opens the search UI.
  - Cmd+Shift+P opens the command palette.
  - Cmd+Backspace kills to the start of the line (backward-kill-line).
  - Shift+Enter sends Alt+Enter (multiline).
  - Selecting text copies it to the clipboard (paste with Cmd+V).
  - Cmd-click on a URL opens it in the default browser.
  - The dock icon uses the custom-style colors (aluminum frame, white ghost, dark screen gradient).
  - Press `cmd+shift+,` to reload config after any future edit.

- [x] 8.5 Run `make copy-zsh` and open a Ghostty-hosted zsh session. Confirm:
  - The powerlevel10k prompt renders (with Nerd Font glyphs).
  - zsh-autosuggestions shows gray ghost text.
  - zsh-syntax-highlighting colors commands.
  - Tab completion is fuzzy/case-insensitive.
  - Up/Down arrows do history-substring-search.

- [x] 8.6 Grep the repo for stale references:
  - `grep -ri "ghostty" Makefile config/zsh/.zshrc config/brew/Brewfile scripts/validate.sh README.md AGENTS.md` — confirm all expected references are present and no typos.
  - `grep -rE 'MonoLisa([^C]|$)' config/` — confirm no stale v2 font names in any active config (including the new `config/ghostty/config.ghostty`).
  - `grep -n 'TERM_PROGRAM' config/zsh/.zshrc` — confirm exactly 2 matches, both widened to `|| $TERM_PROGRAM == ghostty`.

- [x] 8.7 Confirm WezTerm is unaffected:
  - `grep -n 'wezterm' Makefile config/brew/Brewfile` — confirm `copy-wezterm` target and `cask "wezterm@nightly"` are still present.
  - Open a WezTerm-hosted zsh session and confirm the plugins still load (the widened gate still matches `WezTerm`).

- [x] 8.8 Verify no forbidden keys are set in `config/ghostty/config.ghostty` (per the spec's "Features deliberately not set" requirement). Run:
  ```sh
  grep -nE '^(window-width|window-height|font-feature|window-padding-x|window-padding-y|scrollbar|scrollback-limit|theme|background-opacity|background-blur)\b' config/ghostty/config.ghostty
  ```
  Expect NO matches (exit code 1 from grep). Any match means a forbidden key was added — remove it. This maps to the five "no … key" scenarios in `specs/ghostty-terminal/spec.md`.