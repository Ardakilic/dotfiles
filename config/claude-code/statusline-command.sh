#!/usr/bin/env bash

input=$(cat)

# Use jaq if available (user's preferred jq), otherwise fall back to jq
JQ=$(command -v jaq 2>/dev/null || command -v jq 2>/dev/null)

# Build a progress bar: $1=percentage (0-100), $2=width (default 10)
make_bar() {
  local pct="${1:-0}"
  local width="${2:-10}"
  local filled
  filled=$(awk "BEGIN { n=int($pct * $width / 100 + 0.5); if(n>$width) n=$width; if(n<0) n=0; printf \"%d\", n }")
  local empty=$(( width - filled ))
  local bar=""
  local i
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  printf "%s" "$bar"
}

# Extract values from JSON
model=$(echo "$input" | "$JQ" -r '.model.display_name // .model.id // "unknown"')
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

# Build parts array — effort sits right next to the model name
model_segment="$model"
if [ -n "$effort" ]; then
  model_segment="$model · $effort"
fi
parts=("$model_segment")

if [ -n "$ctx_used" ]; then
  bar=$(make_bar "$ctx_used" 10)
  parts+=("ctx [${bar}] $(printf '%.0f' "$ctx_used")%")
fi

if [ -n "$five_h" ]; then
  bar=$(make_bar "$five_h" 10)
  parts+=("5h [${bar}] $(printf '%.0f' "$five_h")%")
fi

if [ -n "$seven_d" ]; then
  bar=$(make_bar "$seven_d" 10)
  parts+=("7d [${bar}] $(printf '%.0f' "$seven_d")%")
fi

# Print parts joined with " | "
printf '%s' "${parts[0]}"
for part in "${parts[@]:1}"; do
  printf '  |  %s' "$part"
done
printf '\n'
