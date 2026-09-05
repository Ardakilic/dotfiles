# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ $TERM_PROGRAM == "WezTerm" || $TERM_PROGRAM == ghostty ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi

# Homebrew
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$HOME/.lmstudio/bin:$PATH"
# End of LM Studio CLI section

## Aliases

### Navigation
alias ls='eza --icons=auto'
alias l='eza -1'
alias la='eza -a'
alias ll='eza -lah --icons=auto --git'
alias lt='eza --tree --icons-auto --level=2'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

mkcd() {
  [[ -z "$1" ]] && { echo "usage: mkcd <dir>"; return 1; }
  mkdir -p -- "$1" && cd -- "$1"
}

gccd() {
  [[ -z "$1" ]] && { echo "usage: gccd <repo>"; return 1; }
  git clone --recurse-submodules "$@" && cd "$(basename "${@[-1]}" .git)"
}
### / Navigation

### File operations
alias b='bat --style=numbers,changes,header'
alias bcat='bat --style=plain --paging=never'

### Jaq for better jq
alias jq='jaq'
# fallback to original jq if needed
jqc() {
  command jq "$@"
}

# Extract ALL zip files into current directory
alias unzipallhere='for f in *.zip; do unzip -o "$f"; done'
# Extract ALL zip files into separate folders
alias unzipallfolders='for f in *.zip; do d="${f%.zip}"; mkdir -p "$d" && unzip -o "$f" -d "$d"; done'

# Copy a file's reference to the clipboard (paste as a file in Finder/Mail/etc.)
copyfile() {
  [[ -z "$1" ]] && { echo "usage: copyfile <file>"; return 1; }
  if [[ ! -f "$1" ]]; then
    echo "Error: File '$1' not found." >&2
    return 1
  fi
  osascript -e 'on run argv' -e 'set the clipboard to POSIX file (item 1 of argv)' -e 'end run' "${1:A}"
  echo "Copied '$1' to clipboard."
}

### / File operations

### ports
alias portsl='sudo lsof -iTCP -sTCP:LISTEN -P -n'
alias port='lsof -i' # usage: port :3000
killport() {
  local port="$1"
  local pids

  [[ -z "$port" ]] && { echo "usage: killport <port>"; return 1; }

  pids=$(lsof -tiTCP:"$port")
  if [[ -z "$pids" ]]; then
    echo "no process found on port $port"
    return 0
  fi

  echo "killing port $port: $pids"
  echo "$pids" | xargs kill -9
}

### Process
#### Process Search Helper
#### Example: p node
p() {
  [[ -z "$1" ]] && { echo "usage: p <pattern>"; return 1; }
  pgrep -fl -- "$1"
}

### audio info
alias ainfo='docker run --rm -v "$(pwd)":/audio ardakilic/sox_ng:latest --i'

### function aliases

## / Aliases

## Remaps

# Ctrl+U — kill the whole line (zsh default), regardless of cursor position.
bindkey "^U" kill-whole-line

# Cmd+Backspace → backward-kill-line (delete from cursor back to start of line).
# Both WezTerm and Ghostty send ESC+Ctrl+U (\x1b\x15) for Cmd+Backspace,
# which is a separate key from plain Ctrl+U above.
bindkey $'\x1b\x15' backward-kill-line

# Ctrl+Shift+K — kill the entire input buffer (everything typed, including
# multiline). Both WezTerm and Ghostty send ESC+Ctrl+K (\x1b\x0b) for this
# key, which is distinct from plain Ctrl+K (kill-to-end-of-line).
bindkey $'\x1b\x0b' kill-buffer

## / Remaps

## Command-line selection (Emacs shift-select mode)

# Select text on the command line with Shift+Arrows (and Shift+Home/End),
# then delete it with Backspace/Delete, or copy it with Option+W (Alt+W,
# which arrives as ESC-w). Ctrl+Y yanks the copied text back.
#
# Adapted from zsh-shift-select <https://github.com/jirutka/zsh-shift-select>
# Copyright 2022-present Jakub Jirutka <jakub@jirutka.cz>.
# SPDX-License-Identifier: MIT
#
# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Both WezTerm and Ghostty pass the standard xterm sequences (ESC[1;2D etc.)
# through to the shell when no terminal-level mouse selection is active, so
# no terminal config is needed for the arrows. In Ghostty, Shift+Arrows
# adjust a *mouse* selection instead when one exists (native default).
#
# While a selection is active:
#   Backspace / Delete → delete the selected region
#   Option+W          → copy it to the kill ring AND the clipboard (pbcopy)
#   any other key     → deselect, then the key is processed normally
# These bindings only affect ZLE regions (command-line text), never the
# terminal's own mouse selections.

# Kill the selected region and switch back to the main keymap.
shift-select::kill-region() {
  zle kill-region -w
  zle -K main
}
zle -N shift-select::kill-region

# Deactivate the selection, switch back to the main keymap, and replay the
# typed key so it is processed normally (typing deselects).
shift-select::deselect-and-input() {
  zle deactivate-region -w
  zle -K main
  zle -U "$KEYS"
}
zle -N shift-select::deselect-and-input

# If the region is not active yet, set the mark at the cursor, switch to the
# shift-select keymap, and run the movement widget ($WIDGET minus the prefix).
shift-select::select-and-invoke() {
  if (( ! REGION_ACTIVE )); then
    zle set-mark-command -w
    zle -K shift-select
  fi
  zle ${WIDGET#shift-select::} -w
}

# Copy the region to the kill ring; also copy to the system clipboard via
# pbcopy when the region is active. Bound to Option+W (ESC-w), which is
# copy-region-as-kill in stock zsh — same behavior plus the clipboard.
copy-region-to-clipboard() {
  zle copy-region-as-kill -w
  if (( REGION_ACTIVE )) && (( $+commands[pbcopy] )); then
    print -rn -- "$CUTBUFFER" | pbcopy
  fi
}
zle -N copy-region-to-clipboard

function {
  emulate -L zsh

  # Keymap active while a shift selection is in progress. Copied from the
  # current (emacs) keymap so normal bindings keep working.
  bindkey -N shift-select

  # Fallback for unbound keys: deselect, then replay the key.
  bindkey -M shift-select -R '^@'-'^?' shift-select::deselect-and-input

  local seq widget
  for seq widget (
    '\e[1;2D' backward-char        # Shift+Left
    '\e[1;2C' forward-char         # Shift+Right
    '\e[1;2A' up-line              # Shift+Up
    '\e[1;2B' down-line            # Shift+Down
    '\e[1;2H' beginning-of-line    # Shift+Home
    '\e[1;2F' end-of-line          # Shift+End
  ); do
    zle -N shift-select::$widget shift-select::select-and-invoke
    bindkey -M emacs "$seq" shift-select::$widget
    bindkey -M shift-select "$seq" shift-select::$widget
  done

  # While the selection is active, Backspace/Delete remove it.
  bindkey -M shift-select '\e[3~' shift-select::kill-region  # Delete
  bindkey -M shift-select '^?' shift-select::kill-region      # Backspace

  # Option+W copies the selection (works from both keymaps).
  bindkey -M emacs '\ew' copy-region-to-clipboard
  bindkey -M shift-select '\ew' copy-region-to-clipboard
}

## / Command-line selection

## Shell init commands here will run in other terminals (iTerm2, Terminal.app, etc.)
if [[ $TERM_PROGRAM == "WezTerm" || $TERM_PROGRAM == ghostty ]]; then
  # zsh-autosuggestions
  [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

  # powerlevel10k theme (instant prompt already loaded at top of file)
  [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]] && \
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  # case insensitive tab completion
  ## compinit with cache
  autoload -Uz compinit
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-$ZSH_VERSION"
  # zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-$ZSH_VERSION"
  # # Rebuild completion cache daily to avoid stale references (e.g. uninstalled apps)
  # if [[ -f "$zcompdump" && -n "$(find "$zcompdump" -mtime +0 2>/dev/null)" ]]; then
  #   rm -f "$zcompdump"
  # fi
  # compinit -d "$zcompdump"
  ## compinit without cache
  ## autoload -Uz compinit && compinit

  # case insensitive tab completion
  # Enable the following line if you only want
  #### case-insensitive completion and not fuzzy matching
  # zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

  # fuzzy matching
  # it does not work with warp, so it's inside if block
  # smarter path completion: case-insensitive + partial/fuzzy matching
  zstyle ':completion:*' completer _complete _approximate
  zstyle ':completion:*:approximate:*' max-errors 2 numeric
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
  setopt COMPLETE_IN_WORD  # complete even if cursor is mid-word
  setopt ALWAYS_TO_END     # move cursor to end after completion
  # / fuzzy matching

  # Nicer colors for completion, hover color on match
  zstyle ':completion:*' menu select
  [[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zmodload zsh/complist
  ## Tab key for auto completion trigger, use "cat -v" to see the actual key codes
  bindkey '^I' expand-or-complete

  # zsh-syntax-highlighting
  # should be added (almost) last
  [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # zsh-history-substring-search
  # Should be below zsh-syntax-highlighting
  [[ -f /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && \
  source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
  # up and down keys for history substring search, use "cat -v" to see the actual key codes
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# other options for ZSH
setopt AUTO_CD # automatically cd for folder names
setopt HIST_FIND_NO_DUPS # skip duplicates during history search
# setopt HIST_IGNORE_ALL_DUPS # removes all duplicates before inserting
# setopt HIST_REDUCE_BLANKS # clean up whitespaces in commands
setopt HIST_VERIFY # preview history expansion before running
setopt SHARE_HISTORY # share history between tabs
setopt INTERACTIVE_COMMENTS # allow # comments in interactive shell

# history file and size constraints
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# Claude Code, OpenCode etc.
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# App-specific exports
export OPENCODE_ENABLE_EXPERIMENTAL_MODELS=true

# Pager — make `git diff` (delta → less) scrollable with the mouse wheel.
# `less --mouse` enables mouse reporting so wheel-scroll works inside the
# alternate screen buffer, matching vim's set mouse=a behavior. Scoped to
# delta via DELTA_PAGER (delta's own env var) so it doesn't affect plain
# `less` invocations or override PAGER globally. Requires less >= 530.
export DELTA_PAGER="less --mouse --wheel-lines=3"

# Modern navigation tools (work in any terminal)
# zoxide — smarter cd (replaces cd entirely)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# fzf — fuzzy finder
if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi