# terminal-zsh-gating Specification

## Purpose

Defines which `TERM_PROGRAM` values cause the shell-quality-of-life
blocks in `config/zsh/.zshrc` to load. These blocks (powerlevel10k
instant prompt, powerlevel10k theme, zsh-autosuggestions, compinit
with fuzzy completion, zsh-syntax-highlighting, zsh-history-substring-
search) are gated on `$TERM_PROGRAM` so that the owner's preferred
rich-shell experience loads in selected terminals (WezTerm, and now
Ghostty) while other terminals (Terminal.app, iTerm2, Warp, etc.)
remain in a minimal-shell mode. The `bindkey "^U"
backward-kill-line` line is terminal-agnostic and is NOT part of this
capability — it is unconditional and pairs with both WezTerm's
`Cmd+Backspace → Ctrl+U` and Ghostty's `cmd+backspace=text:\x15`.

## Requirements

### Requirement: Gate fires for WezTerm and ghostty

The two `$TERM_PROGRAM` gates in `config/zsh/.zshrc` — the
powerlevel10k instant-prompt block at the top of the file and the
main plugin block (zsh-autosuggestions, powerlevel10k theme,
compinit with fuzzy completion, zsh-syntax-highlighting,
zsh-history-substring-search) — MUST fire when `$TERM_PROGRAM` is
either `WezTerm` (the exact value WezTerm sets) or `ghostty` (the
exact lowercase value Ghostty sets, confirmed from Ghostty source
`src/termio/Exec.zig`: `try env.put("TERM_PROGRAM", "ghostty")`).
The gate MUST NOT fire for any other value (Terminal.app sets
`Apple_Terminal`, iTerm2 sets `iTerm.app`, Warp sets `WarpTerminal`,
etc.) — those terminals continue to get the minimal-shell mode.

The gate predicate MUST use the form
`[[ $TERM_PROGRAM == "WezTerm" || $TERM_PROGRAM == ghostty ]]` at
both sites. The string `ghostty` MUST be lowercase (matching the
exact value Ghostty sets). The string `WezTerm` MUST retain its
original casing and quoting.

#### Scenario: gate predicate matches WezTerm

- **WHEN** a developer reads the two `if` predicates in
  `config/zsh/.zshrc` that previously read
  `[[ $TERM_PROGRAM == "WezTerm" ]]`
- **THEN** each predicate now reads
  `[[ $TERM_PROGRAM == "WezTerm" || $TERM_PROGRAM == ghostty ]]`
  (or an equivalent shell test that matches both values)

#### Scenario: plugins load under WezTerm

- **WHEN** a user opens a WezTerm-hosted zsh session
- **THEN** the powerlevel10k instant prompt, powerlevel10k theme,
  zsh-autosuggestions, compinit with fuzzy completion,
  zsh-syntax-highlighting, and zsh-history-substring-search all load
  (unchanged from before this change)

#### Scenario: plugins load under Ghostty

- **WHEN** a user opens a Ghostty-hosted zsh session (after
  `make copy-zsh` has applied this change)
- **THEN** the powerlevel10k instant prompt, powerlevel10k theme,
  zsh-autosuggestions, compinit with fuzzy completion,
  zsh-syntax-highlighting, and zsh-history-substring-search all load
- **AND** the p10k prompt glyphs render correctly (assuming the
  Ghostty `font-family` is `MonoLisaCode Nerd Font`, which is
  required by the `ghostty-terminal` and `font-config` specs)

#### Scenario: plugins do NOT load under other terminals

- **WHEN** a user opens a Terminal.app-hosted or iTerm2-hosted zsh
  session
- **THEN** the gated blocks are skipped (the gate does not match
  `Apple_Terminal` or `iTerm.app`)
- **AND** the shell starts in the minimal-shell mode the owner
  originally intended for non-WezTerm/Ghostty terminals

### Requirement: Input-line editing keybindings

The `.zshrc` MUST define three input-line editing keybindings that
work in both WezTerm and Ghostty:

1. `Ctrl+U` → `kill-whole-line` — kills the entire line regardless
   of cursor position (the zsh default, restored).
2. `Cmd+Backspace` (sent as `ESC+Ctrl+U` / `\x1b\x15` by both
   terminals) → `backward-kill-line` — deletes from the cursor back
   to the start of the line. Both terminals send `\x1b\x15` (not plain
   `\x15`) so this is distinguishable from plain `Ctrl+U`.
3. `Ctrl+Shift+K` (sent as `ESC+Ctrl+K` / `\x1b\x0b` by both
   terminals) → `kill-buffer` — kills the entire input buffer
   (everything typed, including multiline input).

These keybindings MUST be unconditional (not inside the
`$TERM_PROGRAM` gate) and MUST use the escape-prefixed byte sequences
(`$'\x1b\x15'` and `$'\x1b\x0b'`) so the terminal-sent sequences are
distinguishable from plain `Ctrl+U` / `Ctrl+K`.

**Reason**: The owner wants `Ctrl+U` to kill the whole line (zsh
default) while preserving `Cmd+Backspace` as backward-kill-line. Since
both terminals previously sent plain `Ctrl+U` for `Cmd+Backspace`, the
two were indistinguishable. The fix: terminals send `ESC+Ctrl+U` for
`Cmd+Backspace`, and zsh binds that separately. The same pattern is
used for `Ctrl+Shift+K` → `kill-buffer`.

**Migration**: Replaces the prior `bindkey "^U" backward-kill-line`
with `bindkey "^U" kill-whole-line`, adds `bindkey $'\x1b\x15'
backward-kill-line` and `bindkey $'\x1b\x0b' kill-buffer`, and
removes the `export LESS='-R -F -X'` line (delta paging defaults
restored in `.gitconfig`).

#### Scenario: Ctrl+U kills the whole line

- **WHEN** a developer reads the `bindkey "^U"` line in
  `config/zsh/.zshrc`
- **THEN** the bound widget is `kill-whole-line`

#### Scenario: Cmd+Backspace binds to backward-kill-line via escape sequence

- **WHEN** a developer reads the `bindkey $'\x1b\x15'` line in
  `config/zsh/.zshrc`
- **THEN** the bound widget is `backward-kill-line`

#### Scenario: Ctrl+Shift+K binds to kill-buffer via escape sequence

- **WHEN** a developer reads the `bindkey $'\x1b\x0b'` line in
  `config/zsh/.zshrc`
- **THEN** the bound widget is `kill-buffer`

#### Scenario: LESS env var is not set

- **WHEN** a developer greps `config/zsh/.zshrc` for `LESS`
- **THEN** no `export LESS=` line is found

#### Scenario: keybindings are unconditional

- **WHEN** a developer reads the three `bindkey` lines in
  `config/zsh/.zshrc`
- **THEN** none are inside the `$TERM_PROGRAM` gate block