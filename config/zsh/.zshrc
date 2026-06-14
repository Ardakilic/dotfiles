# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ $TERM_PROGRAM == "WezTerm" ]]; then
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
alias ls='eza --icons'
alias l='eza -1'
alias la='eza -a'
alias ll='eza -lah --git'
alias lt='eza --tree --level=2'

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

# Change Ctrl+U behaviour (that will be mapped on cmd+backspace on WezTerm)
# Ctrl+U deletes the whole line by default
# However, to set to delete everuthing before the cursor position, we need to use backward-kill-line
bindkey "^U" backward-kill-line

## / Remaps

## Shell init commands here will run in other terminals (iTerm2, Terminal.app, etc.)
if [[ $TERM_PROGRAM == "WezTerm" ]]; then
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

# Color stderr red in WezTerm.
# WezTerm cannot distinguish stdout from stderr at the terminal level, so we
# capture stderr to a temp file while a command runs and replay it in red
# synchronously before the next prompt is drawn. This avoids the cursor-
# disappearing race caused by the previous process-substitution approach.
if [[ $TERM_PROGRAM == "WezTerm" && -n "$WEZTERM_DISCRIMINATE_STDERR" ]]; then
  # Secure temp file for captured stderr.
  _wezterm_stderr_file=$(command mktemp "${TMPDIR:-/tmp}/wezterm_stderr.XXXXXX")
  command chmod 600 "$_wezterm_stderr_file"

  # Save the shell's original stderr fd so we can always restore it.
  exec {_wezterm_stderr_orig}>&2

  _wezterm_stderr_preexec() {
    local cmd="$1"
    local first="${cmd%% *}"
    first="${first##*/}"  # basename of first word

    # Skip commands that need direct stderr/terminal access.
    # Extend this list as needed for your workflow.
    case "$first" in
      sudo|su|doas|ssh|scp|sftp|rsync|\
      vim|nvim|vi|emacs|nano|micro|\
      less|more|most|man|tailf|watch|\
      htop|top|btm|glances|tmux|screen|\
      fzf|zsh|bash)
        _wezterm_stderr_skip=1
        return
        ;;
    esac

    _wezterm_stderr_skip=0
    : >| "$_wezterm_stderr_file"
    exec 2>"$_wezterm_stderr_file"
  }

  _wezterm_stderr_precmd() {
    # If the last command was skipped, stderr is already on the terminal.
    (( _wezterm_stderr_skip )) && { _wezterm_stderr_skip=0; return; }

    # Restore stderr BEFORE replaying, so output goes to the right place.
    exec 2>&${_wezterm_stderr_orig}

    if [[ -s "$_wezterm_stderr_file" ]]; then
      local line
      while IFS= read -r line || [[ -n "$line" ]]; do
        command printf '\033[91m%s\033[0m\n' "$line"
      done < "$_wezterm_stderr_file"
      : >| "$_wezterm_stderr_file"

      # Safety net: ensure the cursor is visible if stderr carried a
      # cursor-hide escape sequence. Kept inside this block so it does not
      # emit output when there is no stderr; an unconditional printf here
      # triggers Powerlevel10k's instant-prompt warning on the first prompt.
      command printf '\033[?25h'
    fi
  }

  _wezterm_stderr_zshexit() {
    [[ -n "$_wezterm_stderr_file" ]] && command rm -f "$_wezterm_stderr_file"
  }

  preexec_functions+=(_wezterm_stderr_preexec)
  precmd_functions+=(_wezterm_stderr_precmd)
  zshexit_functions+=(_wezterm_stderr_zshexit)
fi

# Modern navigation tools (work in any terminal)
# zoxide — smarter cd (replaces cd entirely)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# less options consumed by git-delta's pager (and anything else that shells out to less)
# -R : pass through ANSI color escapes
# -F : quit automatically if the output fits on one screen
# -X : don't switch to the alternate screen buffer, so the diff stays in WezTerm's scrollback after quitting
export LESS='-R -F -X'

# fzf — fuzzy finder
if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi