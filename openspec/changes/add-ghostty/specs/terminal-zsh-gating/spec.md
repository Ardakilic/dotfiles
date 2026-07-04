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

### Requirement: No other .zshrc changes

The gate widening MUST be the only change to `config/zsh/.zshrc` in
this change. The `bindkey "^U" backward-kill-line` line (which pairs
with both WezTerm's and Ghostty's Cmd+Backspace mapping) MUST remain
unconditional and unchanged. The `LESS='-R -F -X'` export, the
aliases, the `zoxide` init, the `fzf` sources, the history settings,
the `setopt` lines, and all other non-gated content MUST remain
byte-for-byte unchanged.

#### Scenario: bindkey ^U is unchanged and unconditional

- **WHEN** a developer reads the `bindkey "^U" backward-kill-line`
  line in `config/zsh/.zshrc`
- **THEN** the line is present, unconditional (not inside any `if`),
  and unchanged from before this change

#### Scenario: no other gated blocks added or removed

- **WHEN** a developer diffs `config/zsh/.zshrc` before and after
  this change
- **THEN** the only changes are the two gate predicate widening
  edits (adding `|| $TERM_PROGRAM == ghostty`)
- **AND** no other lines are added, removed, or reordered

### Requirement: backward-kill-line pairs with Ghostty Cmd+Backspace

The `bindkey "^U" backward-kill-line` line in `.zshrc` (which changes
Ctrl+U from its zsh default of killing the whole line to killing
only back to the cursor) MUST remain in place so that Ghostty's
`cmd+backspace=text:\x15` keybinding (which sends Ctrl+U) produces
backward-kill-line behavior, matching WezTerm's
`Cmd+Backspace → SendKey Ctrl+U` behavior. This line is
terminal-agnostic and is NOT part of the `$TERM_PROGRAM` gate.

#### Scenario: Cmd+Backspace kills to start of line under Ghostty

- **WHEN** a user presses Cmd+Backspace in a Ghostty-hosted zsh
  session with the cursor mid-line
- **THEN** the text from the cursor back to the start of the line is
  deleted (not the whole line)
- **AND** the text after the cursor remains

#### Scenario: Cmd+Backspace behavior matches WezTerm

- **WHEN** a user presses Cmd+Backspace in a WezTerm-hosted zsh
  session with the cursor mid-line
- **THEN** the behavior is identical to the Ghostty case (backward
  kill to start of line), because both terminals send Ctrl+U and
  `.zshrc` binds Ctrl+U to `backward-kill-line`