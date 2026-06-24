## REMOVED Requirements

### Requirement: Stderr is colored red in WezTerm

The shell SHALL color stderr output red in WezTerm by capturing fd 2 to a temp file during each command (`exec 2>"$tempfile"` in `preexec`) and replaying the captured lines in bright red (`\033[91m...\033[0m`) in `precmd` before the next prompt is drawn. The feature SHALL be gated by the `WEZTERM_DISCRIMINATE_STDERR=1` environment variable set in `.wezterm.lua`. A skip-list of interactive commands (sudo, ssh, vim, less, tmux, etc.) SHALL bypass capture so their stderr remains on a real tty. A `\033[?25h` cursor-show escape SHALL be emitted after replay as a safety net against cursor-hide leaks.

**Reason**: The `exec 2>"$tempfile"` capture flips `isatty(2)` to false for every child process for the command's entire lifetime. This breaks docker prompts and build progress bars (which never render), buffers streaming stderr until exit, and causes programs that detect a non-tty stderr to disable their *own* native colors — net-negative compared to no coloring at all. The skip-list cannot ever be complete (the set of CLIs that write prompts/progress/colored diagnostics to stderr is unbounded). The only race-free, streaming-safe alternative (`stderred` via `DYLD_INSERT_LIBRARIES`) is stripped by SIP on macOS system binaries and is absent from Homebrew core, making it not worth maintaining in a personal dotfiles repo. The cursor-disappearing race that originally motivated the feature was a symptom of the colorizer's earlier async (process-substitution) implementation, and is eliminated by removing the colorizer entirely rather than by patching the symptom.

**Migration**: No migration action required. Stderr reverts to its default terminal appearance: programs' own native stderr colors render, streaming resumes, and docker/interactive prompts work again. The `WEZTERM_DISCRIMINATE_STDERR` environment variable is no longer set; any external script that gated on it silently disables (the `.zshrc` block it guarded is gone). Users who depended on the red-error visual cue will instead see programs' native stderr coloring (which the capture was previously suppressing).

#### Scenario: Stderr is no longer colored red in WezTerm
- **WHEN** a command writes to stderr in a WezTerm-hosted zsh session
- **THEN** the stderr output appears with the program's own native styling (or unstyled), in real time as streamed, and `isatty(2)` is true for the child process

#### Scenario: Docker and interactive prompts stream correctly
- **WHEN** a user runs `docker run -it`, `docker build`, or any CLI that writes a prompt or progress to stderr
- **THEN** the prompt/progress renders and streams normally, with no buffering and no hang, because fd 2 is a real tty

#### Scenario: WEZTERM_DISCRIMINATE_STDERR environment variable is unset
- **WHEN** a new WezTerm session starts after this change is applied
- **THEN** the `WEZTERM_DISCRIMINATE_STDERR` environment variable is not present in the environment, and the `.zshrc` contains no stderr-capture hooks

#### Scenario: Cursor remains visible after commands with multiline stderr
- **WHEN** a command produces multiline stderr (the case that originally triggered the cursor-disappearing race)
- **THEN** the cursor remains visible after the prompt returns, because the async stderr writer that caused the race is no longer present