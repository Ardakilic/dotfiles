## Why

The dotfiles ship a shell-level stderr colorizer (enabled via `WEZTERM_DISCRIMINATE_STDERR=1`) that captures fd 2 to a temp file during each command and replays it in red before the next prompt. The capture works by `exec 2>"$tempfile"`, which flips `isatty(2)` to **false** for every child process. That single side effect breaks far more than it colors: docker prompts and build progress bars never render, streaming stderr is buffered until exit, and programs that detect a non-tty stderr disable their *own* colors. The prior fix (process-substitution → synchronous temp-file replay) solved the original cursor-disappearing race but introduced this isatty regression, and no skip-list can ever be complete enough to fix it. The only race-free, streaming-safe alternative (`stderred` via `DYLD_INSERT_LIBRARIES`) is stripped by SIP on macOS system binaries and is absent from Homebrew core — not worth maintaining in a personal dotfiles repo. Retire the feature.

## What Changes

- **BREAKING (local config only)**: Remove the `WEZTERM_DISCRIMINATE_STDERR` stderr-capture block from `config/zsh/.zshrc` (~72 lines: the `preexec`/`precmd`/`zshexit` hooks, the temp file, the `\033[?25h` safety net, and the surrounding comment).
- **BREAKING (local config only)**: Remove the `WEZTERM_DISCRIMINATE_STDERR = '1'` entry and its explanatory comment block from `config/wezterm/.wezterm.lua`.
- Remove the stderr-colorizer bullet from `README.md` Notes and replace it with a short **Retired** note documenting that the feature was attempted and abandoned, with the reason.
- Strip "stderr capture" from the `config/zsh/.zshrc` and `config/wezterm/.wezterm.lua` descriptions in `AGENTS.md`, and drop the stderr-discrimination bullet from Conventions.
- Leave `pr_description.md` as committed history (it documents the prior attempt; superseded by this change but useful as a postmortem artifact).

## Capabilities

### New Capabilities
<!-- None. This is a removal, not a new capability. -->

### Modified Capabilities
<!-- No existing spec covers the stderr colorizer — it was an undocumented-by-spec local feature. `openspec/specs/` contains only `homebrew-bundle`, which is unrelated. No spec delta required. -->

## Impact

- **Config files edited**: `config/zsh/.zshrc`, `config/wezterm/.wezterm.lua`, `README.md`, `AGENTS.md`.
- **Behavioral change for users**: stderr reverts to its default appearance (programs' own colors, real-time streaming, docker/interactive prompts work). The cursor-disappearing race that motivated the colorizer in the first place is also eliminated, because that race was a symptom of the colorizer's async predecessor — removing the colorizer removes the cause.
- **Environment**: `WEZTERM_DISCRIMINATE_STDERR` is no longer set; any external script that gated on it will silently disable (the `.zshrc` block it guarded is gone).
- **No dependencies changed**, no Makefile targets affected, no new tools required.
- **Validation**: `scripts/validate.sh` continues to pass; no new checks needed.