# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles. There is no application to build — the repo is a collection of
config files under `config/<tool>/` plus a `Makefile` that copies them into place. The unit
of work is "a config file and its install target," not "code."

`AGENTS.md` is the detailed, authoritative reference (full project structure, per-tool paths,
agent persona table, security deny-list). Read it for specifics; this file is the orientation.

## Commands

```sh
make help          # List all copy-* targets
make copy-all      # Install every config into ~/ (each backs up the existing file first)
make copy-zsh      # Single example; one copy-* target exists per config/<tool>/ dir
make install-deps  # brew bundle from config/brew/Brewfile (sign into Mac App Store first)
make reload-zsh

./scripts/validate.sh   # The only "test": JSON/Lua syntax, Makefile↔config alignment, agent-persona completeness
```

There is no compiler, linter, or test framework. `scripts/validate.sh` is the gate — run it
after editing any config and treat a non-zero exit as a failure.

## Architecture / things that span files

- **Source of truth is `config/`, never `~/`.** Every change is made under `config/` and
  propagated by a `copy-*` Makefile target. `make copy-*` always writes a timestamped
  `.bak.<epoch>` backup of the existing file before overwriting (see the `backup-file` macro).

- **Adding a config = three places must stay in sync.** A new `config/<tool>/` dir needs:
  (1) a `copy-*` target in the `Makefile`, (2) an entry in `EXPECTED_DIRS` in
  `scripts/validate.sh`, and (3) updates to `README.md` and `AGENTS.md`. `validate.sh` warns
  if a `config/` dir has no Makefile target referencing it.

- **The 4-persona agent system is the main cross-cutting invariant.** The same four agents —
  `ask`, `architect`, `review`, `debug` — are defined in parallel across four tools, in two
  formats: markdown for OpenCode (`config/opencode/agents/`), Claude Code output-styles
  (`config/claude-code/output-styles/`), and Kiro Desktop (`config/kiro-desktop/agents/`);
  JSON for Kiro CLI (`config/kiro-cli/agents/`). `validate.sh` fails if any persona is missing
  from any platform. Editing one persona's behavior generally means editing all four copies.

- **Brewfile is hand-curated, not generated.** `config/brew/Brewfile` is authored by hand
  (formulae from `brew leaves`, casks from `brew list --cask`); do not regenerate it with
  `brew bundle dump` — that would pull in dependency bottles that are deliberately excluded.

- **Security deny-list lives in `config/opencode/opencode.json`.** When adding a tool that can
  touch sensitive paths (`.ssh`, `.aws`, `.env*`, `*.pem`, etc.), extend those deny rules.

## OpenSpec workflow

This repo uses spec-driven change tracking under `openspec/` (`schema: spec-driven`), driven by
the `opsx-*` commands in `.opencode/commands/`. Proposals live in `openspec/changes/` and are
moved to `openspec/changes/archive/` once applied; finalized specs live in `openspec/specs/`.

## Conventions

- Conventional-commit messages (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `build:`).
- Do not commit unless explicitly asked.
- macOS / Apple-Silicon only (`/opt/homebrew` paths, macOS Application Support dirs).
