export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/ardakilicdagi/.lmstudio/bin"
# End of LM Studio CLI section


# Arda
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

## Shell init commands here will run in other terminals (iTerm2, Terminal.app, etc.)
if [[ $TERM_PROGRAM == "WezTerm" ]]; then
  # zsh-autosuggestions
  [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

  # powerlevel10k
  # # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # # Initialization code that may require console input (password prompts, [y/n]
  # # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
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
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

  # Nicer colors for completion, hover color on match
  zstyle ':completion:*' menu select
  [[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zmodload zsh/complist

  # zsh-syntax-highlighting
  # should be added last
  [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# other options for ZSH
setopt AUTO_CD # automatically cd for folder names
setopt INC_APPEND_HISTORY # append to history directly without waiting session to end
setopt HIST_FIND_NO_DUPS # skip duplicates
# setopt HIST_REDUCE_BLANKS # clean up whitespaces in commands
setopt HIST_VERIFY # do not execute history command right after 
setopt SHARE_HISTORY # share history between tabs
# /Arda

# Claude Code etc.
export PATH="$HOME/.local/bin:$PATH"