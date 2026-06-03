#!/bin/bash
# scripts/validate.sh — Dotfiles validation script
# Validates JSON syntax, Lua syntax, Makefile target alignment, and agent consistency.
# Exit code: 0 = all clean, 1 = any failure

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

info() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; ((WARNINGS++)) || true; }
error() { echo -e "${RED}[ERR]${NC}  $*"; ((ERRORS++)) || true; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

info "Starting dotfiles validation..."

# ─────────────────────────────────────────────
# 1. JSON Syntax Validation (with --strip-comments for VS Code configs)
info "Checking JSON files..."
JSON_FILES=$(find config -name "*.json" -o -name "*.jsonc" 2>/dev/null || true)
if [[ -n "$JSON_FILES" ]]; then
  for f in $JSON_FILES; do
    if command -v jq >/dev/null 2>&1; then
      # VS Code / VSCodium settings use JSONC (JSON with comments)
      # Standard jq doesn't support comments, so use jaq with relaxed parsing if available
      if [[ "$f" == *.jsonc ]] || grep -qE '^\s*//' "$f" 2>/dev/null; then
        if command -v jaq >/dev/null 2>&1; then
          # Try relaxed parsing first; if that fails, it's truly invalid
          if ! jaq -R 'fromjson? | .' "$f" >/dev/null 2>&1; then
            error "Invalid JSON (with comments): $f"
          fi
        else
          info "Skipping JSON-with-comments validation (install jaq for full validation): $f"
        fi
      else
        if ! jq empty "$f" >/dev/null 2>&1; then
          error "Invalid JSON: $f"
        fi
      fi
    else
      warn "jq not installed — skipping JSON validation"
      break
    fi
  done
else
  info "No JSON files found to validate."
fi
# ─────────────────────────────────────────────
# 2. Lua Syntax Validation (WezTerm config)
# ─────────────────────────────────────────────
info "Checking Lua files..."
if [[ -f "config/wezterm/.wezterm.lua" ]]; then
  if command -v lua >/dev/null 2>&1; then
    if ! lua -c "config/wezterm/.wezterm.lua" >/dev/null 2>&1; then
      # lua -c not standard; try luac -p
      if command -v luac >/dev/null 2>&1; then
        if ! luac -p "config/wezterm/.wezterm.lua" >/dev/null 2>&1; then
          error "Lua syntax error in config/wezterm/.wezterm.lua"
        fi
      else
        warn "Neither lua nor luac installed — skipping Lua validation"
      fi
    fi
  elif command -v luac >/dev/null 2>&1; then
    if ! luac -p "config/wezterm/.wezterm.lua" >/dev/null 2>&1; then
      error "Lua syntax error in config/wezterm/.wezterm.lua"
    fi
  else
    warn "Neither lua nor luac installed — skipping Lua validation"
  fi
fi

# ─────────────────────────────────────────────
# 3. Makefile target alignment
# ─────────────────────────────────────────────
info "Checking Makefile target alignment..."

# Every config/ subdirectory should have a copy-* target
EXPECTED_DIRS=(zsh wezterm git vscode vscode-insiders vscodium kiro-desktop kiro-cli claude-code opencode)
for dir in "${EXPECTED_DIRS[@]}"; do
  if [[ ! -d "config/$dir" ]]; then
    error "Missing config directory: config/$dir"
    continue
  fi

  # Check if there's at least one copy-* target referencing this directory
  if ! grep -q "config/$dir" Makefile 2>/dev/null; then
    warn "No Makefile target references config/$dir"
  fi
done

# ─────────────────────────────────────────────
# 4. Agent consistency checks
# ─────────────────────────────────────────────
info "Checking agent consistency..."

# Check that each of the 4 personas exists in each platform
PERSONAS=(ask architect review debug)
PLATFORMS=("config/opencode/agents" "config/kiro-desktop/agents" "config/kiro-cli/agents" "config/claude-code/output-styles")

for platform in "${PLATFORMS[@]}"; do
  for persona in "${PERSONAS[@]}"; do
    case "$platform" in
      *kiro-cli*)
        if [[ ! -f "$platform/$persona.json" ]]; then
          error "Missing agent: $platform/$persona.json"
        fi
        ;;
      *)
        if [[ ! -f "$platform/$persona.md" ]]; then
          error "Missing agent: $platform/$persona.md"
        fi
        ;;
    esac
  done
done

# ─────────────────────────────────────────────
# 5. .gitignore coverage
# ─────────────────────────────────────────────
info "Checking .gitignore coverage..."
if ! grep -q "\.kilo/" .gitignore 2>/dev/null; then
  warn ".kilo/ not in .gitignore"
fi
if ! grep -q "\.vscode/" .gitignore 2>/dev/null; then
  warn ".vscode/ not in .gitignore"
fi

# ─────────────────────────────────────────────
# 6. Shell script syntax (self-check)
# ─────────────────────────────────────────────
info "Checking shell scripts..."
if [[ -f "scripts/validate.sh" ]]; then
  if ! bash -n "scripts/validate.sh" 2>/dev/null; then
    error "Shell syntax error in scripts/validate.sh"
  fi
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
echo ""
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  info "All checks passed."
  exit 0
else
  echo -e "${YELLOW}Results: $ERRORS error(s), $WARNINGS warning(s)${NC}"
  exit 1
fi
