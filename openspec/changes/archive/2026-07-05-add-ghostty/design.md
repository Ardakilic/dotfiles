## Context

The repo currently has one terminal configured (WezTerm, via `config/wezterm/.wezterm.lua` — a Lua API) and one shell config (`config/zsh/.zshrc`) that gates ~8 shell-quality-of-life blocks on `$TERM_PROGRAM == "WezTerm"`. Adding Ghostty means porting a relevant subset of the WezTerm config into Ghostty's *different* config model, and widening the zsh gate so the shell experience survives the terminal swap.

Ghostty's config is plain-text `key = value` (snake_case, case-sensitive), loaded from `~/.config/ghostty/config.ghostty` (or `config` legacy name). It is not Lua, not TOML, not JSON. Keys are documented at `ghostty.org/docs/config/reference`. There is no automatic reload-on-save; reload is via `cmd+shift+,` (`reload_config` action), and some keys apply only to new windows/surfaces.

```
┌─────────────────────────────────────────────────────────────────────┐
│  CONFIG MODEL DIFFERENCES                                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  WezTerm                        Ghostty                              │
│  ────────                       ────────                             │
│  Lua API                        plain text key=value                 │
│  config_builder() + return      ~/.config/ghostty/config.ghostty    │
│  ~/.wezterm.lua                 (snake_case, case-sensitive)        │
│  live reload on save            cmd+shift+, (manual)                │
│                                                                      │
│  WezTerm feature semantics      Ghostty equivalent                  │
│  ───────────────────────        ────────────────────                │
│  initial_cols/rows (cells)      window-width/height (cells)         │
│  harfbuzz_features table        font-feature (repeatable)           │
│  color_scheme (string)          theme (light:X,dark:Y auto)         │
│  scrollback_lines (LINES)       scrollback-limit (BYTES) ⚠          │
│  window_decorations bitmask     macos-titlebar-style (enum)         │
│  send_composed_key_when_        macos-option-as-alt ⚠ INVERSE       │
│   left_alt_is_pressed = true      = right  (left=composed,right=alt)│
│  mouse_bindings table           NOT SUPPORTED (only link-url,       │
│                                 copy-on-select, mouse-hide-…)       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### The three real tensions

**Tension 1 — Option key behavior differs in mechanism, not just polarity.** WezTerm's `send_composed_key_when_left_alt_is_pressed = true` intercepts at the **keybinding layer**: keybindings with `mods = 'OPT'` (like `opt+left=SendString \x1bb`) fire on **BOTH** option keys *before* the composed-char logic runs. For keys *without* a binding, LEFT → composed (é) and RIGHT → Alt+e. **Net: in WezTerm, both option keys do word-jump; LEFT additionally produces composed chars on unbound keys.**

Ghostty's `macos-option-as-alt` is a **blunt per-key toggle**, not a per-keybinding intercept. It chooses which physical option key acts as Alt:
- `true` = both Alt (word-jump on both, but **no composed chars at all** — loses é, ∑)
- `false` = both composed (no word-jump from option at all)
- `left` = LEFT is Alt (word-jump on LEFT), RIGHT = composed
- `right` = RIGHT is Alt (word-jump on RIGHT), LEFT = composed

**None of these values perfectly replicates WezTerm's "both options do both" behavior**, because Ghostty can't intercept at the keybinding layer the way WezTerm does. The owner chose `left` (word-jump on LEFT Option, composed chars on RIGHT Option).

```
  WezTerm (current)                Ghostty (chosen: left)
  ───────────────                  ─────────────────────
  LEFT  Option → word-jump AND     LEFT  Option → Alt (word-jump)   ✓
              composed (unbound)         (no composed chars)
  RIGHT Option → word-jump         RIGHT Option → composed (é, ∑)  ✓
                                     = macos-option-as-alt = left
```

Side effect: with `macos-option-as-alt = left`, only the LEFT Option key reliably fires `opt+left=esc:b` / `opt+right=esc:f` and native Alt+b/Alt+f. The RIGHT Option key produces composed chars. The explicit `esc:b`/`esc:f` bindings are a belt-and-suspenders fallback for the left Option key; native Alt+b/Alt+f from the shell also works.

**Tension 2 — `.zshrc` gate.** Eight blocks are gated on `$TERM_PROGRAM == "WezTerm"`. Ghostty sets `TERM_PROGRAM=ghostty` (lowercase — confirmed from `src/termio/Exec.zig`). As-is, all eight blocks skip under Ghostty.

```
  CURRENT                          CHOSEN
  ───────                          ───────
  if [[ $TERM_PROGRAM              if [[ $TERM_PROGRAM
       == "WezTerm" ]]; then            == "WezTerm" ||
    # 8 blocks                        $TERM_PROGRAM == ghostty ]];
                                         then
  ↓                                  # same 8 blocks, unchanged
  Under Ghostty: ALL SKIPPED        ↓
                                     Under Ghostty: ALL FIRE
                                     Under WezTerm: unchanged
```

The widening is a two-character-per-site edit (`|| $TERM_PROGRAM == ghostty`). The string `ghostty` is lowercase to match the exact value Ghostty sets. The gate is NOT removed (going terminal-agnostic was an option; the owner chose to keep the gate so non-WezTerm/Ghostty terminals like Terminal.app remain in the minimal-shell mode the owner originally intended).

**Tension 3 — scrollback units.** Not in scope (the owner chose to accept Ghostty's default scrollback and not set `scrollback-limit`). Noted here for completeness: WezTerm's `scrollback_lines = 50000` is in *lines*; Ghostty's `scrollback-limit` is in *bytes*. A 50k-line equivalent would be ~10MB, but this is moot since the key is omitted from the Ghostty config.

## Goals / Non-Goals

**Goals:**
- Add a first-class `config/ghostty/config.ghostty` that mirrors the owner-selected subset of `.wezterm.lua` plus three Ghostty-only extras.
- Make `make copy-ghostty` install it to the right path with backup, and fold it into `make copy-all`.
- Widen the two `.zshrc` `$TERM_PROGRAM` gates to fire for both `WezTerm` and `ghostty`, with no other `.zshrc` changes.
- Add `cask "ghostty"` to the Brewfile alongside `wezterm@nightly` (both terminals installable).
- Extend `scripts/validate.sh` to enforce `config/ghostty/` existence (via `EXPECTED_DIRS`) and validate the config with `ghostty +validate-config` when the binary is present.
- Update README.md and AGENTS.md to reflect the second terminal.
- Keep WezTerm fully functional — no removals, no behavioral change for WezTerm users.

**Non-Goals:**
- **Replacing WezTerm.** WezTerm config, `copy-wezterm` target, `wezterm@nightly` cask, and all WezTerm doc references are retained. Ghostty is additive.
- **Porting every WezTerm feature.** The owner explicitly excluded: window geometry, ligature disabling, padding, scrollbar, scrollback size, dynamic theme, tab close/move keybindings. These are accepted at Ghostty defaults. A future change can add them if desired.
- **Going terminal-agnostic in `.zshrc`.** The gate is widened, not removed. Terminal.app / iTerm2 / other terminals continue to get the minimal-shell mode the owner originally intended.
- **Config split / includes.** Ghostty supports `config-file = ?sub-file` for splitting config, but a single `config.ghostty` is fine for this size. No sub-files.
- **Custom themes.** Ghostty has built-in `Ayu Mirage` and `Ayu Light` themes, but the owner chose to accept the default theme. No custom theme files under `config/ghostty/themes/`.
- **Quick-terminal, background opacity/blur, unfocused-split-opacity, font-thicken, window-save-state.** Owner did not select these Ghostty-only extras. Not added.
- **SSH integration / `ssh` config.** Out of scope. Ghostty forwards `TERM_PROGRAM` over SSH; the gate on the remote shell would need the remote `.zshrc` to also accept `ghostty`, but that's a remote-machine concern, not this repo.

## Decisions

### D1: `macos-option-as-alt = left` (owner's choice)

**Decision:** Set `macos-option-as-alt = left` in the Ghostty config.

**Rationale:** Ghostty's `macos-option-as-alt` is a blunt per-key toggle (which physical option key acts as Alt), unlike WezTerm's `send_composed_key_when_left_alt_is_pressed` which intercepts at the keybinding layer. In WezTerm, `mods = 'OPT'` keybindings fire on **both** option keys before composed-char logic, so both options do word-jump while LEFT additionally does composed chars on unbound keys. Ghostty cannot replicate this "both options do both" behavior with any single value. The owner chose `left`: LEFT Option = Alt (word-jump via Alt+b/Alt+f and the explicit `opt+left`/`opt+right` keybindings), RIGHT Option = composed chars (é, ∑).

**Alternatives considered:**
- `macos-option-as-alt = true` (both Alt) — rejected: loses composed chars (é, ∑) entirely, which the owner uses.
- `macos-option-as-alt = false` (both composed) — rejected: `opt+left=esc:b` / `opt+right=esc:f` word-jump bindings won't fire reliably when Option produces composed chars.
- `macos-option-as-alt = right` — a valid alternative (word-jump on RIGHT, composed on LEFT); the owner tested both and preferred `left`.
- Leave unset (layout-dependent default) — rejected: non-reproducible across machines/layouts.

### D2: Widen the `.zshrc` gate with `|| $TERM_PROGRAM == ghostty`, do not remove it

**Decision:** Change both `if [[ $TERM_PROGRAM == "WezTerm" ]]; then` sites (line 4 instant-prompt, line 103 main block) to `if [[ $TERM_PROGRAM == "WezTerm" || $TERM_PROGRAM == ghostty ]]; then`. Use the exact lowercase string `ghostty` (confirmed from Ghostty source `src/termio/Exec.zig`: `try env.put("TERM_PROGRAM", "ghostty")`).

**Rationale:** Minimal change, preserves the original WezTerm semantics exactly, and extends the same shell experience to Ghostty. The gate is kept (not removed) because the owner deliberately chose to keep non-WezTerm/Ghostty terminals in a minimal-shell mode — going fully terminal-agnostic was an explicit option the owner declined.

**Alternatives considered:**
- *Remove the gate entirely (fire in any terminal)* — rejected by owner: would change behavior for Terminal.app/iTerm2/Warp, which the owner wants to keep minimal.
- *Duplicate as a separate `if [[ $TERM_PROGRAM == ghostty ]]` block* — rejected: doubles the code for no current benefit; the two terminals want the same plugins. A separate block would only pay off if Ghostty needed different plugins than WezTerm, which it doesn't.
- *Use a case statement* — rejected: heavier syntax for a two-value check.

### D3: `macos-titlebar-style = tabs` for the integrated-buttons equivalent

**Decision:** Set `macos-titlebar-style = tabs`.

**Rationale:** WezTerm's `window_decorations = "INTEGRATED_BUTTONS | RESIZE"` merges the macOS traffic-light buttons into the titlebar and integrates the tab bar there. Ghostty's `macos-titlebar-style = tabs` is the documented equivalent: custom titlebar that integrates the tab bar and always matches the terminal background, with the traffic-light buttons present. The `tabs` style also matches the owner's WezTerm behavior of hiding the tab bar when there's only one tab (native macOS tab behavior already does this).

**Alternatives considered:**
- `transparent` (default) — rejected: keeps a separate titlebar; doesn't integrate tabs.
- `native` — rejected: stock macOS titlebar; no tab integration.
- `hidden` — rejected: hides the titlebar entirely; loses the traffic-light buttons.

### D4: Port nine keybindings, accept Ghostty defaults for tab close/move

**Decision:** Port these nine WezTerm keybindings to Ghostty `keybind = …` lines:
1. `ctrl+shift+f=start_search` (case-insensitive search; case-insensitive is Ghostty's default)
2. `cmd+shift+d=new_split:down` (WezTerm `SplitVertical` = top/bottom = Ghostty `down`)
3. `cmd+d=new_split:right` (WezTerm `SplitHorizontal` = side-by-side = Ghostty `right`)
4. `cmd+k=clear_screen` (clears screen + scrollback; matches WezTerm `ClearScrollback 'ScrollbackAndViewport'`)
5. `cmd+left=csi:H` (Home; `csi:H` sends `ESC[H`)
6. `cmd+right=csi:F` (End; `csi:F` sends `ESC[F`)
7. `cmd+shift+p=toggle_command_palette`
8. `opt+left=esc:b` + `opt+right=esc:f` (word-jump; belt-and-suspenders for right Option, see D1)
9. `cmd+backspace=text:\x15` (Ctrl-U; pairs with `.zshrc` `bindkey "^U" backward-kill-line`)
10. `shift+enter=text:\x1b\r` (Alt+Enter for multiline REPL input; `\x1b` = ESC, `\r` = CR)

Do NOT port: `cmd+w` close pane, `cmd+shift+w` close tab, `cmd+shift+left/right` move tab. Accept Ghostty's built-in defaults for those.

**Rationale:** The nine ported bindings are either non-default in Ghostty, or carry the owner's specific text-send semantics (`text:\x15`, `text:\x1b\r`, `esc:b`/`esc:f`) that Ghostty wouldn't guess. The three omitted bindings (close pane, close tab, move tab) are already Ghostty defaults with sensible macOS-conventional keys, so re-binding them to the same actions would be redundant config.

**Note on the Vertical/Horizontal naming inversion:** WezTerm's `SplitVertical` creates a top/bottom split (a vertical divider), while `SplitHorizontal` creates a side-by-side split (a horizontal divider). Ghostty's `new_split:down` creates a top/bottom split and `new_split:right` creates a side-by-side split. The *geometry* matches; only the vocabulary differs. The mapping is Vertical→down, Horizontal→right.

### D5: `copy-on-select = clipboard` + explicit `link-url = true`

**Decision:** Set `copy-on-select = clipboard` (selection copies to both selection and system clipboard) and `link-url = true` (explicit even though it's the default).

**Rationale:** WezTerm's `mouse_bindings` left-click → `CompleteSelection 'ClipboardAndPrimarySelection'` mirrors Ghostty's `copy-on-select = clipboard`. WezTerm's Cmd-click → `OpenLinkAtMouseCursor` mirrors Ghostty's `link-url = true`. Ghostty does NOT support a general `mouse_bindings` table (only `link-url`, `copy-on-select`, `mouse-hide-while-typing`, `mouse-shift-capture`, `mouse-reporting`, `mouse-scroll-multiplier`), so these two keys are the full achievable mapping. `link-url` is set explicitly for config self-documentation, even though it's the default.

### D6: `macos-icon = custom-style` with the owner-specified colors

**Decision:** Set `macos-icon = custom-style`, `macos-icon-frame = aluminum`, `macos-icon-ghost-color = #ffffff`, `macos-icon-screen-color = #1a1b26,#000000`.

**Rationale:** Owner-selected. `custom-style` is documented as experimental — it renders the official icon shape but with custom layer colors (`macos-icon-frame` for the frame, `macos-icon-ghost-color` for the ghost figure, `macos-icon-screen-color` for the screen gradient — comma-separated hex values form a gradient, ≤64 stops). The values `#1a1b26` (Tokyo Night-style dark blue) and `#000000` give a dark screen gradient; `#ffffff` ghost on `aluminum` frame. If `custom-style` proves unstable, falling back to `official` (or any of the 8 artist variants) is a one-line change.

**Alternatives considered:**
- The 8 artist variants (`blueprint`, `chalkboard`, `microchip`, `glass`, `holographic`, `paper`, `retro`, `xray`) — owner chose `custom-style` instead.
- `official` — the safe default; rejected in favor of the owner's custom colors.
- `custom` (fully custom image at `~/.config/ghostty/Ghostty.icns`) — rejected: would require committing an image file or relying on an out-of-repo file; `custom-style` uses only config keys.

### D7: `mouse-hide-while-typing = true` and `confirm-close-surface = true`

**Decision:** Set both to `true`.

**Rationale:** `mouse-hide-while-typing` is a common QoL preference (cursor hides while typing, reappears on mouse movement). `confirm-close-surface = true` prompts before closing a surface with active processes — a safety net against accidental `cmd+w` when a process is running. Both are Ghostty-only (no WezTerm equivalent in the current `.wezterm.lua`).

### D8: Config filename `config.ghostty` (not legacy `config`)

**Decision:** Name the repo file `config/ghostty/config.ghostty` and install it to `~/.config/ghostty/config.ghostty`.

**Rationale:** `config.ghostty` is the newer name (introduced in Ghostty 1.2.3) that explicitly identifies the file. The legacy `config` name still works on current versions but is less clear in a repo that hosts many config files. Ghostty loads both names from all four search paths (`$XDG_CONFIG_HOME/ghostty/config{.ghostty,}` and `~/Library/Application Support/com.mitchellh.ghostty/config{.ghostty,}`), with XDG taking precedence. Installing to `~/.config/ghostty/` (XDG) matches the repo's existing `copy-opencode` → `~/.config/opencode/` pattern.

**Alternatives considered:**
- `config` (no extension) — rejected: less clear in the repo; `config.ghostty` is the recommended modern name.
- `~/Library/Application Support/com.mitchellh.ghostty/config` — rejected: deeper path; `~/.config/ghostty/` is consistent with the existing `copy-opencode` target and with XDG convention.

### D9: Stable `cask "ghostty"`, not nightly

**Decision:** Add `cask "ghostty"` (stable) to the Brewfile, not `cask "ghostty@tip"` (nightly).

**Rationale:** The owner chose stable. The stable cask is currently at 1.3.1 and requires macOS ≥ 13. The nightly cask `ghostty@tip` exists but conflicts with `ghostty` (can't have both). The owner's WezTerm uses `wezterm@nightly`, but for Ghostty the owner prefers stable releases. If the owner later wants nightly, swapping `cask "ghostty"` → `cask "ghostty@tip"` is a one-line change.

### D10: validate.sh — append to `EXPECTED_DIRS` + gated `ghostty +validate-config` block

**Decision:** Append `ghostty` to the `EXPECTED_DIRS` array in `scripts/validate.sh`, and add a new validation block that runs `ghostty +validate-config` when the `ghostty` binary is present (graceful skip when absent, mirroring the Lua/`luac` skip pattern).

**Rationale:** `EXPECTED_DIRS` already enforces that each `config/<dir>/` exists AND is referenced by the Makefile — adding `ghostty` gets both checks for free. The `ghostty +validate-config` subcommand is the canonical CLI validation (parse + semantic check, non-zero exit on errors). Gating on `command -v ghostty` means the validation script still passes on machines that haven't installed Ghostty yet (matching the existing pattern where Lua validation is skipped if `lua`/`luac` are absent).

**Note on validating a specific file path:** `ghostty +validate-config` validates the *effective* config (all loaded files merged). To validate the repo's `config/ghostty/config.ghostty` in isolation during CI, the validator can pass `--config-default-files=false --config-file=$(pwd)/config/ghostty/config.ghostty` (every config key is also a CLI flag, and `config-file` is the include directive). The tasks.md will specify this incantation so the check validates the repo file, not the user's installed `~/.config/ghostty/config.ghostty`.

## Risks / Trade-offs

- **[macos-icon = custom-style is experimental]** → Accepted by owner. If Ghostty removes or breaks `custom-style`, the dock icon reverts to default. Fallback to `macos-icon = official` is a one-line change. Low blast radius (cosmetic only).
- **[Option-key word-jump only on LEFT Option]** → Accepted. With `macos-option-as-alt = left`, only the LEFT Option key reliably fires `opt+left=esc:b` / `opt+right=esc:f` and native Alt+b/Alt+f. The RIGHT Option key produces composed chars. This is a behavioral difference from WezTerm (where both options did word-jump), accepted by the owner as a Ghostty limitation — Ghostty's `macos-option-as-alt` is a blunt per-key toggle, not a per-keybinding intercept, so no value perfectly replicates WezTerm.
- **[No dynamic theme switching]** → Accepted. WezTerm auto-switches Ayu light/dark with system appearance. Ghostty config omits `theme`, so it uses Ghostty's default (which does NOT auto-switch). If the owner wants Ayu light/dark later, `theme = light:Ayu Light,dark:Ayu Mirage` is a one-line addition (both are built-in themes).
- **[Ghostty config not live-reloaded on save]** → Accepted. Unlike WezTerm (live reload on save), Ghostty requires `cmd+shift+,` to reload. Some keys (macos-titlebar-style, window-padding, scrollback-limit) apply only to new windows/surfaces. This is a workflow difference, not a bug. The README notes will mention `cmd+shift+,`.
- **[Two terminals in the Brewfile]** → Accepted. `wezterm@nightly` and `ghostty` coexist; `make install-deps` installs both. The owner explicitly chose to keep WezTerm. No conflict (different cask names, different apps).
- **[validate.sh `ghostty +validate-config` skips if ghostty absent]** → Accepted. Same pattern as Lua validation skipping when `luac` is absent. CI on a machine without Ghostty will not catch Ghostty config syntax errors, but the `EXPECTED_DIRS` check still catches missing dir / missing Makefile reference.