@AGENTS.md

## Claude Code

`AGENTS.md` (imported above) is the single source of truth for this repo:
project structure, setup commands, environment, conventions, agent personas,
security rules, and the OpenSpec workflow. Edit there, not here — content
duplicated here is a drift bug waiting to happen.

This file exists only because Claude Code reads `CLAUDE.md`, not `AGENTS.md`.
The `@AGENTS.md` import inlines the authoritative content into every session
at launch — see https://docs.claude.com/en/docs/claude-code/memory#agents-md.

Anything not already covered in AGENTS.md that should apply to Claude Code
sessions specifically goes here. Currently: nothing — AGENTS.md already
covers the validate.sh gate, commit policy, conventional-commit style, and
the macOS-only constraint.