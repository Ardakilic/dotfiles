#!/usr/bin/env bash

input=$(cat)

# Use jaq if available (user's preferred jq), otherwise fall back to jq
JQ=$(command -v jaq 2>/dev/null || command -v jq 2>/dev/null)

# Nerd Font glyphs (requires a Nerd Font, e.g. MonoLisaCode Nerd Font)
FOLDER_ICON=$'󰉋'      # nf-md-folder (U+F024B)
BRANCH_ICON=$''      # nf-dev-git_branch (U+E725)
STAR_ICON='★'          # model marker

# ANSI colors (ANSI-C quoted so the escape byte is stored literally,
# not as a backslash sequence that only `echo -e`/`printf %b` would expand)
BLUE=$'\033[34m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
ORANGE=$'\033[38;5;208m'
MAGENTA=$'\033[35m'
GRAY=$'\033[90m'
RESET=$'\033[0m'
SEP="${GRAY}|${RESET}"

# Build a progress bar out of "boxes": $1=percentage (0-100), $2=width (default 10)
make_bar() {
  local pct="${1:-0}"
  local width="${2:-10}"
  local filled
  filled=$(awk "BEGIN { n=int($pct * $width / 100 + 0.5); if(n>$width) n=$width; if(n<0) n=0; printf \"%d\", n }")
  local empty=$(( width - filled ))
  local bar=""
  local i
  for ((i=0; i<filled; i++)); do bar+="▰"; done
  for ((i=0; i<empty; i++)); do bar+="▱"; done
  printf "%s" "$bar"
}

# Color for a percentage: green <50%, yellow 50-70%, red >70%
pct_color() {
  local pct_int
  pct_int=$(awk "BEGIN { printf \"%d\", ${1:-0} }")
  if [ "$pct_int" -ge 70 ]; then
    printf '%s' "$RED"
  elif [ "$pct_int" -ge 50 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# Render one "Label: [bar] pct%" segment, or nothing if the value is absent
bar_segment() {
  local label="$1"
  local pct="$2"
  [ -z "$pct" ] && return
  local color bar
  color=$(pct_color "$pct")
  bar=$(make_bar "$pct" 10)
  printf '%s%s:%s %s%s%s %s%s%%%s' \
    "$GRAY" "$label" "$RESET" \
    "$color" "$bar" "$RESET" \
    "$GRAY" "$(printf '%.0f' "$pct")" "$RESET"
}

strip_ansi() {
  printf '%s' "$1" | sed -E $'s/\x1b\\[[0-9;]*m//g'
}

# Extract values from JSON
model=$(echo "$input" | "$JQ" -r '.model.display_name // .model.id // "unknown"')
dir=$(echo "$input" | "$JQ" -r '.workspace.current_dir // .cwd // empty')
ctx_used=$(echo "$input" | "$JQ" -r '.context_window.used_percentage // empty')
five_h=$(echo "$input" | "$JQ" -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | "$JQ" -r '.rate_limits.seven_day.used_percentage // empty')

# Reasoning effort: prefer the live status payload (covers a session-level override),
# falling back to the saved default in ~/.claude/settings.json. The value may be a
# plain string ("xhigh") or an object ({"level":"xhigh"}), so normalise it to a scalar.
effort_filter='if . == null then empty elif type == "object" then (.level // .value // .name // empty) else (. | tostring) end'
effort=$(echo "$input" | "$JQ" -r "(.effort // .effortLevel // .reasoning_effort // .model.effort) | $effort_filter" 2>/dev/null)
if [ -z "$effort" ] && [ -f "$HOME/.claude/settings.json" ]; then
  effort=$("$JQ" -r ".effortLevel | $effort_filter" "$HOME/.claude/settings.json" 2>/dev/null)
fi

# Folder name (~-relativized) and git branch + dirty-file count, looked up via
# -C so this doesn't depend on the script's own working directory
dir_display="$dir"
case "$dir" in
  "$HOME") dir_display="~" ;;
  "$HOME"/*) dir_display="~${dir#"$HOME"}" ;;
esac

branch=""
diff_count=""
if [ -n "$dir" ] && git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  changed=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [ -n "$changed" ] && [ "$changed" -gt 0 ] && diff_count="(+${changed})"
fi

# Left-hand, pipe-separated segments
parts=()
[ -n "$dir" ] && parts+=("${BLUE}${FOLDER_ICON}${RESET} ${dir_display}")
parts+=("${ORANGE}${STAR_ICON}${RESET} ${model}")

seg=$(bar_segment "Context" "$ctx_used"); [ -n "$seg" ] && parts+=("$seg")
seg=$(bar_segment "5h" "$five_h"); [ -n "$seg" ] && parts+=("$seg")
seg=$(bar_segment "7d" "$seven_d"); [ -n "$seg" ] && parts+=("$seg")

if [ -n "$branch" ]; then
  parts+=("${GREEN}${BRANCH_ICON}${RESET} ${CYAN}${branch}${RESET}${GREEN}${diff_count}${RESET}")
fi

left=""
for part in "${parts[@]}"; do
  if [ -z "$left" ]; then
    left="$part"
  else
    left+="  ${SEP}  ${part}"
  fi
done

# Right-hand effort indicator. Built at two widths — full (with the /effort
# hint) and short (bare level) — so it can shrink or disappear instead of
# overflowing and wrapping onto another line in a narrow terminal.
right_full=""
right_short=""
if [ -n "$effort" ]; then
  case "$effort" in
    low) effort_color="$GREEN" ;;
    medium) effort_color="$YELLOW" ;;
    high) effort_color="$ORANGE" ;;
    xhigh) effort_color="$RED" ;;
    max) effort_color="$MAGENTA" ;;
    *) effort_color="$GRAY" ;;
  esac
  right_short="${effort_color}●${RESET} ${effort}"
  right_full="${right_short} ${GRAY}·${RESET} ${BLUE}/effort${RESET}"
fi

left_plain=$(strip_ansi "$left")
left_plain_len=${#left_plain}
min_gap=2

right=""
right_len=0
if [ -n "$right_full" ] && [[ "$COLUMNS" =~ ^[0-9]+$ ]] && [ "$COLUMNS" -gt 0 ]; then
  right_full_plain=$(strip_ansi "$right_full")
  right_short_plain=$(strip_ansi "$right_short")
  available=$(( COLUMNS - left_plain_len - min_gap ))
  if [ "$available" -ge "${#right_full_plain}" ]; then
    right="$right_full"
    right_len=${#right_full_plain}
  elif [ "$available" -ge "${#right_short_plain}" ]; then
    right="$right_short"
    right_len=${#right_short_plain}
  fi
elif [ -n "$right_full" ]; then
  # No terminal width available (older Claude Code) — fall back to the
  # compact form so we're less likely to overflow a narrow pane.
  right="$right_short"
fi

if [ -n "$right" ] && [[ "$COLUMNS" =~ ^[0-9]+$ ]] && [ "$COLUMNS" -gt 0 ]; then
  pad=$(( COLUMNS - left_plain_len - right_len ))
  [ "$pad" -lt "$min_gap" ] && pad=$min_gap
  printf '%s%*s%s\n' "$left" "$pad" "" "$right"
elif [ -n "$right" ]; then
  printf '%s  %s\n' "$left" "$right"
else
  printf '%s\n' "$left"
fi
