## 1. Remove stderr colorizer from zsh config

- [x] 1.1 Delete the `WEZTERM_DISCRIMINATE_STDERR` block from `config/zsh/.zshrc` (the comment header "Color stderr red in WezTerm..." through the closing `fi`, approximately lines 178–249): the temp file setup, `_wezterm_stderr_preexec`, `_wezterm_stderr_precmd`, `_wezterm_stderr_zshexit`, the `precmd_functions`/`preexec_functions`/`zshexit_functions` registrations, and the `\033[?25h` safety net.

## 2. Remove stderr toggle from WezTerm config

- [x] 2.1 Delete the `WEZTERM_DISCRIMINATE_STDERR` environment variable and its explanatory comment block from `config/wezterm/.wezterm.lua` (the "Stderr discrimination..." comment through the `set_environment_variables` table, approximately lines 108–116).
- [x] 2.2 Verify no other references to `WEZTERM_DISCRIMINATE_STDERR` remain in `config/` (grep).

## 3. Update README.md

- [x] 3.1 Replace the stderr-colorizer bullet in the Notes section (line 305, "In WezTerm, stderr is captured and replayed in red...") with a "Retired" note: stderr coloring was attempted via shell-level capture, abandoned because `exec 2>"$file"` forces `isatty(2)=false` on every child (breaking docker prompts, progress bars, streaming, and suppressing programs' own stderr colors); the only race-free streaming alternative (stderred / `DYLD_INSERT_LIBRARIES`) is SIP-stripped on system binaries and not in Homebrew — retired as not worth maintaining.

## 4. Update AGENTS.md

- [x] 4.1 Remove "stderr capture" from the `config/zsh/.zshrc` description in the Project Structure section (line 24).
- [x] 4.2 Remove "stderr capture toggle" from the `config/wezterm/.wezterm.lua` description in the Project Structure section (line 26).
- [x] 4.3 Remove the stderr-discrimination bullet from Conventions (none existed — only the two structure-tree lines in 4.1/4.2 mentioned stderr capture).

## 5. Validate

- [x] 5.1 Run `scripts/validate.sh` and confirm it passes (Lua validation may be skipped if `luac` is absent — expected on this machine).
- [x] 5.2 Grep the whole repo for `WEZTERM_DISCRIMINATE_STDERR`, `_wezterm_stderr`, and `?25h` to confirm no stale references remain in `config/` (only `pr_description.md` and `openspec/changes/retire-stderr-colorizer/` should match, both intentional history/artifacts).
- [x] 5.3 Eyeball `config/zsh/.zshrc` and `config/wezterm/.wezterm.lua` to confirm the surrounding structure (zsh plugins block, WezTerm keybindings) is intact and no stray blank lines or orphaned comments remain.