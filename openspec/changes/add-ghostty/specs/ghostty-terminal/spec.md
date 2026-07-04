# ghostty-terminal Specification

## Purpose

Defines the Ghostty terminal emulator configuration for this dotfiles
repo. Ghostty is added alongside WezTerm (not as a replacement). The
config lives at `config/ghostty/config.ghostty` in the repo and is
installed to `~/.config/ghostty/config.ghostty` by
`make copy-ghostty`. The format is plain-text `key = value`,
snake_case, case-sensitive. Ghostty does NOT live-reload on save;
reload is via `cmd+shift+,` (the `reload_config` action), and some
keys apply only to new windows/surfaces.

## Requirements

### Requirement: Config file location and format

The Ghostty config MUST live at `config/ghostty/config.ghostty` in
the repository (source of truth) and MUST be installed to
`~/.config/ghostty/config.ghostty` by `make copy-ghostty`. The file
MUST use plain-text `key = value` syntax with snake_case,
case-sensitive keys. Comments MUST use `#` on their own line. The
installed file MUST be backed up before overwriting, using the same
`backup-file` Makefile macro as the other `copy-*` targets.

#### Scenario: repo file exists and is named config.ghostty

- **WHEN** a developer lists `config/ghostty/`
- **THEN** a file named `config.ghostty` is present

#### Scenario: make copy-ghostty installs to XDG config path

- **WHEN** a developer runs `make copy-ghostty`
- **THEN** the file `config/ghostty/config.ghostty` is copied to
  `~/.config/ghostty/config.ghostty`
- **AND** if `~/.config/ghostty/config.ghostty` already existed, it
  was backed up to `~/.config/ghostty/config.ghostty.bak.<timestamp>`
  before the copy
- **AND** the `~/.config/ghostty/` directory was created if missing

#### Scenario: config uses plain-text key = value syntax

- **WHEN** a developer reads `config/ghostty/config.ghostty`
- **THEN** every non-comment, non-blank line matches `key = value`
  with snake_case keys
- **AND** no Lua, TOML, or JSON syntax is present

### Requirement: Font family and size

The Ghostty config MUST set `font-family` to
`MonoLisaCode Nerd Font` and `font-size` to `13`. This matches the
WezTerm config's font and the `font-config` spec's terminal/TUI
requirement (Nerd Font variant for powerline glyphs and icons).

#### Scenario: font-family is MonoLisaCode Nerd Font

- **WHEN** a developer reads the `font-family` line in
  `config/ghostty/config.ghostty`
- **THEN** the value is `MonoLisaCode Nerd Font` (quoted if the
  parser requires it for the space-containing name)

#### Scenario: font-size is 13

- **WHEN** a developer reads the `font-size` line in
  `config/ghostty/config.ghostty`
- **THEN** the value is `13`

### Requirement: macOS titlebar style integrates tabs

The Ghostty config MUST set `macos-titlebar-style = tabs` so the tab
bar is integrated into the titlebar with the macOS traffic-light
buttons present. This is the Ghostty equivalent of WezTerm's
`window_decorations = "INTEGRATED_BUTTONS | RESIZE"`.

#### Scenario: macos-titlebar-style is tabs

- **WHEN** a developer reads the `macos-titlebar-style` line in
  `config/ghostty/config.ghostty`
- **THEN** the value is `tabs`

### Requirement: macOS Option key — right is Alt, left is composed

The Ghostty config MUST set `macos-option-as-alt = right` so the
RIGHT Option key acts as Alt (enabling native shell word-jump via
Alt+b/Alt+f and the explicit `opt+left`/`opt+right` keybindings) and
the LEFT Option key produces composed characters (é, ∑). This is
the inverse-polarity behavioral match to WezTerm's
`send_composed_key_when_left_alt_is_pressed = true`.

#### Scenario: macos-option-as-alt is right

- **WHEN** a developer reads the `macos-option-as-alt` line in
  `config/ghostty/config.ghostty`
- **THEN** the value is `right`

#### Scenario: right Option sends Alt sequences to the shell

- **WHEN** a user presses RightOption+Left in a Ghostty-hosted zsh
  session
- **THEN** the shell receives Alt+b (or the `esc:b` sequence from
  the keybinding) and moves the cursor one word backward

#### Scenario: left Option produces composed characters

- **WHEN** a user presses LeftOption+e in a Ghostty-hosted zsh
  session on a U.S. layout
- **THEN** the composed character é is produced (not Alt+e)

### Requirement: Keybindings ported from WezTerm

The Ghostty config MUST define the following `keybind = …` lines,
each producing the same behavior as the corresponding WezTerm
binding. Keybind syntax is `keybind = trigger=action` (repeatable).
Modifiers: `shift`, `ctrl`, `alt` (aliases `opt`, `option`), `super`
(alias `cmd`).

| WezTerm binding | Ghostty keybind | Behavior |
|-----------------|-----------------|----------|
| Ctrl+Shift+F case-insensitive search | `keybind = ctrl+shift+f=start_search` | Open search UI (case-insensitive is default) |
| Cmd+Shift+D SplitVertical (top/bottom) | `keybind = cmd+shift+d=new_split:down` | New split below |
| Cmd+D SplitHorizontal (side-by-side) | `keybind = cmd+d=new_split:right` | New split to the right |
| Cmd+K ClearScrollback | `keybind = cmd+k=clear_screen` | Clear screen + scrollback |
| Cmd+Left → Home | `keybind = cmd+left=csi:H` | Send ESC[H (Home) |
| Cmd+Right → End | `keybind = cmd+right=csi:F` | Send ESC[F (End) |
| Cmd+Shift+P command palette | `keybind = cmd+shift+p=toggle_command_palette` | Toggle command palette |
| Opt+Left → word back | `keybind = opt+left=esc:b` | Send ESC+b (fires on right Option; see Option-key requirement) |
| Opt+Right → word forward | `keybind = opt+right=esc:f` | Send ESC+f (fires on right Option) |
| Cmd+Backspace → Ctrl+U | `keybind = cmd+backspace=text:\x15` | Send Ctrl-U (backward-kill-line, paired with `.zshrc` `bindkey "^U" backward-kill-line`) |
| Shift+Enter → Alt+Enter | `keybind = shift+enter=text:\x1b\r` | Send ESC+CR (multiline REPL input) |

The config MUST NOT define keybindings for Cmd+W (close pane),
Cmd+Shift+W (close tab), or Cmd+Shift+Left/Right (move tab) —
Ghostty's built-in defaults for these are accepted.

#### Scenario: all nine ported keybindings present

- **WHEN** a developer greps `config/ghostty/config.ghostty` for
  `keybind =`
- **THEN** the lines for all nine bindings above are present with
  the exact triggers and actions shown

#### Scenario: Ctrl+Shift+F opens search

- **WHEN** a user presses Ctrl+Shift+F in Ghostty
- **THEN** the search UI opens (case-insensitive matching is the
  default)

#### Scenario: Cmd+Shift+D creates a vertical split

- **WHEN** a user presses Cmd+Shift+D in Ghostty
- **THEN** a new split opens below the current surface
  (`new_split:down`)

#### Scenario: Cmd+D creates a horizontal split

- **WHEN** a user presses Cmd+D in Ghostty
- **THEN** a new split opens to the right of the current surface
  (`new_split:right`)

#### Scenario: Cmd+K clears screen and scrollback

- **WHEN** a user presses Cmd+K in Ghostty
- **THEN** the visible screen and the scrollback buffer are both
  cleared

#### Scenario: Cmd+Backspace triggers backward-kill-line

- **WHEN** a user presses Cmd+Backspace in a Ghostty-hosted zsh
  session with the `.zshrc` `bindkey "^U" backward-kill-line` active
- **THEN** the text from the cursor back to the start of the line is
  deleted (not the whole line)

#### Scenario: Shift+Enter sends Alt+Enter

- **WHEN** a user presses Shift+Enter in a Ghostty-hosted REPL that
  accepts multiline input
- **THEN** the REPL receives ESC+CR and begins a new line without
  submitting

#### Scenario: tab close and move bindings are NOT overridden

- **WHEN** a developer greps `config/ghostty/config.ghostty` for
  `cmd+w=`, `cmd+shift+w=`, `cmd+shift+left`, and `cmd+shift+right`
- **THEN** no `keybind =` lines match those triggers (Ghostty
  defaults are accepted)

### Requirement: Mouse behaviors — copy-on-select and link-url

The Ghostty config MUST set `copy-on-select = clipboard` (selection
copies to both selection and system clipboard) and `link-url = true`
(Cmd-click opens links; explicit even though it is the Ghostty
default). Ghostty does not support a general `mouse_bindings` table;
these two keys are the full achievable mapping of WezTerm's
left-click-copies and Cmd-click-opens-link behaviors.

#### Scenario: copy-on-select is clipboard

- **WHEN** a developer reads the `copy-on-select` line in
  `config/ghostty/config.ghostty`
- **THEN** the value is `clipboard`

#### Scenario: selection copies to clipboard

- **WHEN** a user selects text in Ghostty with the mouse
- **THEN** the selected text is copied to the system clipboard
  (pasteable with Cmd+V)

#### Scenario: link-url is true

- **WHEN** a developer reads the `link-url` line in
  `config/ghostty/config.ghostty`
- **THEN** the value is `true`

#### Scenario: Cmd-click opens links

- **WHEN** a user Cmd-clicks a URL in Ghostty
- **THEN** the URL opens in the system default browser

### Requirement: Ghostty-only extras — icon, mouse-hide, confirm-close

The Ghostty config MUST set the three Ghostty-only features selected
by the owner:

- `macos-icon = custom-style` with `macos-icon-frame = aluminum`,
  `macos-icon-ghost-color = #ffffff`, and
  `macos-icon-screen-color = #1a1b26,#000000` (custom-style dock
  icon; experimental).
- `mouse-hide-while-typing = true` (hide mouse cursor while typing).
- `confirm-close-surface = true` (prompt before closing a surface
  with active processes).

#### Scenario: macos-icon is custom-style with the owner colors

- **WHEN** a developer reads the `macos-icon`, `macos-icon-frame`,
  `macos-icon-ghost-color`, and `macos-icon-screen-color` lines in
  `config/ghostty/config.ghostty`
- **THEN** the values are `custom-style`, `aluminum`, `#ffffff`, and
  `#1a1b26,#000000` respectively

#### Scenario: mouse-hide-while-typing is true

- **WHEN** a developer reads the `mouse-hide-while-typing` line in
  `config/ghostty/config.ghostty`
- **THEN** the value is `true`

#### Scenario: confirm-close-surface is true

- **WHEN** a developer reads the `confirm-close-surface` line in
  `config/ghostty/config.ghostty`
- **THEN** the value is `true`

### Requirement: Features deliberately not set

The Ghostty config MUST NOT set the following keys (accept Ghostty
defaults): `window-width`, `window-height`, `font-feature`,
`window-padding-x`, `window-padding-y`, `scrollbar`, `scrollback-limit`,
`theme`, `background-opacity`, `background-blur`. The config MUST be
minimal — only the keys explicitly required by the requirements
above.

#### Scenario: no window geometry keys

- **WHEN** a developer greps `config/ghostty/config.ghostty` for
  `window-width` and `window-height`
- **THEN** no matches are found

#### Scenario: no ligature-disabling keys

- **WHEN** a developer greps `config/ghostty/config.ghostty` for
  `font-feature`
- **THEN** no matches are found

#### Scenario: no theme key

- **WHEN** a developer greps `config/ghostty/config.ghostty` for
  `^theme`
- **THEN** no matches are found

#### Scenario: no scrollback-limit key

- **WHEN** a developer greps `config/ghostty/config.ghostty` for
  `scrollback-limit`
- **THEN** no matches are found

#### Scenario: no background opacity or blur keys

- **WHEN** a developer greps `config/ghostty/config.ghostty` for
  `background-opacity` and `background-blur`
- **THEN** no matches are found

### Requirement: Makefile target copy-ghostty

The Makefile MUST define a `copy-ghostty` target that copies
`config/ghostty/config.ghostty` to `~/.config/ghostty/config.ghostty`
with the `backup-file` macro, creates `~/.config/ghostty/` if
missing, prints a confirmation message, and is listed in `.PHONY`.
The target MUST be added to the `copy-all` dependency chain and to
the `help` target's listing.

#### Scenario: copy-ghostty target exists

- **WHEN** a developer runs `make help`
- **THEN** a line for `copy-ghostty` is present describing the copy
  to `~/.config/ghostty/config.ghostty`

#### Scenario: copy-ghostty creates the destination directory

- **WHEN** a developer runs `make copy-ghostty` on a machine where
  `~/.config/ghostty/` does not exist
- **THEN** the directory is created (mkdir -p) and the config file
  is copied into it

#### Scenario: copy-ghostty backs up existing config

- **WHEN** a developer runs `make copy-ghostty` on a machine where
  `~/.config/ghostty/config.ghostty` already exists
- **THEN** the existing file is backed up to
  `~/.config/ghostty/config.ghostty.bak.<timestamp>` before the new
  file is copied

#### Scenario: copy-all includes copy-ghostty

- **WHEN** a developer reads the `copy-all` target in the Makefile
- **THEN** `copy-ghostty` is listed in its dependency chain

#### Scenario: copy-ghostty is in .PHONY

- **WHEN** a developer reads the `.PHONY` line in the Makefile
- **THEN** `copy-ghostty` is present in the list

### Requirement: Brewfile includes the Ghostty cask

The Brewfile MUST include `cask "ghostty"` (stable). The existing
`cask "wezterm@nightly"` MUST remain (both terminals installable).
No `ghostty@tip` (nightly) line is added.

#### Scenario: ghostty cask is present

- **WHEN** a developer reads `config/brew/Brewfile`
- **THEN** a line `cask "ghostty"` is present in the Casks section

#### Scenario: wezterm cask is retained

- **WHEN** a developer reads `config/brew/Brewfile`
- **THEN** the line `cask "wezterm@nightly"` is still present

#### Scenario: no ghostty nightly cask

- **WHEN** a developer greps `config/brew/Brewfile` for `ghostty@tip`
- **THEN** no matches are found

### Requirement: validate.sh enforces Ghostty config

`scripts/validate.sh` MUST include `ghostty` in the
`EXPECTED_DIRS` array (so the existing Makefile-alignment check
enforces `config/ghostty/` existence and a Makefile reference to
it). The script MUST additionally run `ghostty +validate-config` to
validate the repo's `config/ghostty/config.ghostty` in isolation
when the `ghostty` binary is present, and MUST skip the Ghostty
validation with a warning when the binary is absent (mirroring the
Lua/`luac` skip pattern).

#### Scenario: ghostty is in EXPECTED_DIRS

- **WHEN** a developer reads the `EXPECTED_DIRS` array in
  `scripts/validate.sh`
- **THEN** `ghostty` is present in the array

#### Scenario: validate.sh runs ghostty +validate-config when binary present

- **WHEN** a developer runs `scripts/validate.sh` on a machine where
  the `ghostty` binary is on PATH
- **THEN** the script invokes `ghostty +validate-config` against the
  repo's `config/ghostty/config.ghostty` (in isolation, not the
  installed `~/.config/ghostty/config.ghostty`)
- **AND** a non-zero exit from `ghostty +validate-config` is
  reported as an error

#### Scenario: validate.sh skips Ghostty validation when binary absent

- **WHEN** a developer runs `scripts/validate.sh` on a machine where
  the `ghostty` binary is NOT on PATH
- **THEN** the script prints a warning that Ghostty validation is
  skipped (mirroring the Lua skip pattern)
- **AND** the script does NOT exit non-zero solely because Ghostty
  is absent

### Requirement: Documentation reflects Ghostty

`README.md` MUST list Ghostty in the Environment bullet, the
Individual tools / Casks bullets, the Config Structure diagram (with
`config/ghostty/config.ghostty`), the Setup individual-targets list
(with `make copy-ghostty`), and a Notes bullet explaining that the
`.zshrc` gate fires for both `WezTerm` and `ghostty` `TERM_PROGRAM`
values. `AGENTS.md` MUST list `config/ghostty/config.ghostty` in
Project Structure, `make copy-ghostty` in Setup & Build Commands
(including in `make copy-all`), Ghostty in Environment, and a
Conventions note about the dual-terminal `.zshrc` gate and the
WezTerm-vs-Ghostty Option-key polarity difference.

#### Scenario: README Environment lists Ghostty

- **WHEN** a developer reads the "My Environment" section of
  `README.md`
- **THEN** Ghostty is listed (WezTerm remains listed too)

#### Scenario: README Config Structure includes ghostty

- **WHEN** a developer reads the Config Structure diagram in
  `README.md`
- **THEN** an entry for `config/ghostty/config.ghostty` is present

#### Scenario: README Setup lists make copy-ghostty

- **WHEN** a developer reads the Setup individual-targets list in
  `README.md`
- **THEN** a `make copy-ghostty` line is present

#### Scenario: README Notes explain the zsh gate

- **WHEN** a developer reads the Notes section of `README.md`
- **THEN** a bullet explains that the `.zshrc` gate fires for both
  `WezTerm` and `ghostty` `TERM_PROGRAM` values

#### Scenario: AGENTS.md Project Structure includes ghostty

- **WHEN** a developer reads the Project Structure section of
  `AGENTS.md`
- **THEN** an entry for `config/ghostty/config.ghostty` is present

#### Scenario: AGENTS.md Setup lists make copy-ghostty

- **WHEN** a developer reads the Setup & Build Commands section of
  `AGENTS.md`
- **THEN** a `make copy-ghostty` line is present
- **AND** `make copy-all` is updated to include `copy-ghostty`

#### Scenario: AGENTS.md Environment lists Ghostty

- **WHEN** a developer reads the Environment section of `AGENTS.md`
- **THEN** Ghostty is listed (WezTerm remains listed too)

#### Scenario: AGENTS.md Conventions note the dual-terminal gate

- **WHEN** a developer reads the Conventions section of `AGENTS.md`
- **THEN** a note explains that the `.zshrc` `$TERM_PROGRAM` gate
  fires for both `WezTerm` and `ghostty`
- **AND** a note explains the WezTerm-vs-Ghostty Option-key polarity
  difference (WezTerm `send_composed_key_when_left_alt_is_pressed`
  vs Ghostty `macos-option-as-alt` are inverse-polarity keys)