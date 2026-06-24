## Context

The dotfiles implement a shell-level stderr colorizer in `config/zsh/.zshrc`, gated by `WEZTERM_DISCRIMINATE_STDERR=1` set in `config/wezterm/.wezterm.lua`. The mechanism has gone through two iterations:

1. **v1 — process-substitution** (`exec 2> >(...)`): an async zsh coprocess wrapped each stderr line in red ANSI codes. This caused a cursor-disappearing race: the colorizer could still be flushing after ZLE drew the next prompt, desyncing ZLE's cursor coordinates and occasionally leaving the cursor hidden.
2. **v2 — synchronous temp-file replay** (current): `preexec` redirects fd 2 to a temp file; `precmd` restores fd 2 to the tty and replays the file in red before the next prompt. This fixed the cursor race but introduced a different, worse regression: `exec 2>"$tempfile"` makes `isatty(2)` false for **every** child process for the entire command's lifetime.

The terminal itself (WezTerm, like all terminals) reads a single PTY byte stream and has no stdout-vs-stderr information at that layer. Discriminating the two streams therefore requires shell-level intervention, and every shell-level approach trades one correctness property for another.

```
┌─────────────────────────────────────────────────────────────────┐
│  Terminal layer: one PTY stream, no fd-1/fd-2 metadata. Cannot  │
│  be fixed at the terminal. Requires shell-level capture.        │
└─────────────────────────────────────────────────────────────────┘

Shell-level capture approaches and their cost:
┌──────────────────────┬──────────────────────┬──────────────────────┐
│  Process-sub (v1)    │  Temp-file (v2)      │  stderred (DYLD)     │
│  exec 2> >(...)      │  exec 2>"$file"      │  DYLD_INSERT_LIBRARIES│
├──────────────────────┼──────────────────────┼──────────────────────┤
│  ✓ real-time         │  ✗ buffered to exit  │  ✓ real-time         │
│  ✓ isatty(2)=true    │  ✗ isatty(2)=FALSE   │  ✓ isatty(2)=true    │
│  ✗ race w/ ZLE       │  ✓ race-free         │  ✓ race-free         │
│  ✗ cursor disappears │  ✗ docker/prompts    │  ✗ SIP strips on     │
│    on multiline stderr│     hang, no stream  │     system binaries  │
│                      │  ✗ kills programs'   │  ✗ not in Homebrew   │
│                      │    own stderr colors │  ✗ build from --HEAD │
└──────────────────────┴──────────────────────┴──────────────────────┘
```

No zsh/WezTerm-native option exists in the fourth corner (real-time + isatty-true + race-free). The only thing that achieves it is `stderred`-style library interposition, which on macOS is crippled by SIP (system binaries strip `DYLD_INSERT_LIBRARIES`) and absent from Homebrew core (requires building from `--HEAD`). For a personal dotfiles repo, that maintenance load is not justified.

## Goals / Non-Goals

**Goals:**
- Remove the stderr colorizer and its `isatty(2)` regression so docker prompts, progress bars, streaming stderr, and programs' own native stderr colors all work again.
- Eliminate the cursor-disappearing race *by removing its cause* (the colorizer's async behavior), rather than by patching the symptom with `\033[?25h` safety nets inside a broken mechanism.
- Document the attempt and the reason for abandonment in the repo so future contributors (including the owner) don't re-walk this path.
- Keep the change scoped to config + docs; no new tools, no new Makefile targets.

**Non-Goals:**
- Replacing the colorizer with `stderred` or any other stderr-coloring mechanism. Stderr coloring is **retired** in this repo. If a real-time, streaming, race-free solution ever becomes trivially installable via Homebrew, a *separate* future change can revisit it — this change does not pre-judge that.
- Adding a generic cursor-visibility `precmd` safety net. The cursor race the owner originally hit was a symptom of the colorizer (Cause A) and is gone the moment the colorizer is gone. The orthogonal "TUI killed with cursor hidden" case (Cause B) is rare and is *not* addressed here; if it ever bites, a one-liner can be added in a separate change.
- Touching the Makefile, Brewfile, or any other config. Removal only.

## Decisions

### D1: Remove entirely rather than refine the skip-list

**Decision:** Delete the whole `WEZTERM_DISCRIMINATE_STDERR` block and the env var. Do not attempt to extend the interactive-command skip-list to cover docker and other offenders.

**Rationale:** The skip-list is a heuristic patch over a fundamental problem. `docker` is absent from the current list, but more importantly *no list can ever be complete*: any CLI that writes a prompt, progress bar, or colored diagnostic to stderr breaks when `isatty(2)` is false, and the set is unbounded. Worse, the capture suppresses the very thing it claims to improve — programs that detect a non-tty stderr disable their *own* colors, so the colorizer replaces richer, native, streaming colors with a blanket red replay at exit. The feature is net-negative; refining it only narrows the blast radius without removing the root cause.

**Alternatives considered:**
- *Extend the skip-list with `docker` and other streaming tools.* Rejected: whack-a-mole; the next offender is one `brew install` away. Doesn't restore programs' own colors for non-skipped commands. Doesn't fix buffering.
- *Make the capture opt-in per-command instead of default-on.* Rejected: the owner would have to remember to enable it for exactly the commands where it's safe, which is the inverse of useful. Better to remove.

### D2: Retire stderr coloring as a concept, not just the current implementation

**Decision:** Treat stderr coloring as permanently retired in this repo, and document the attempt + failure reason in README and (via absence) AGENTS.md. Do not leave a commented-out scaffold or a dormant toggle "for future use."

**Rationale:** A dormant toggle invites a future contributor to re-enable it without the context of *why* it was removed. A short "Retired" note in README, plus the surviving `pr_description.md` as a committed postmortem artifact, gives the next attempt the context it needs — and makes clear that the failure was structural (isatty + SIP), not a bug to be fixed.

**Alternatives considered:**
- *Keep `WEZTERM_DISCRIMINATE_STDERR` defined in `.wezterm.lua` but unused, in case a future approach wants the hook point.* Rejected: dead config is debt. The env var costs nothing to re-add if a real solution ever appears.
- *Add `stderred` to the Brewfile and wire it up.* Rejected by the owner: SIP makes it unreliable on system binaries, and it's not in Homebrew core. Not worth maintaining.

### D3: Document the removal inline where the feature used to live

**Decision:** Leave a brief "Retired" comment in `config/wezterm/.wezterm.lua` (where the env var used to be set) and a "Retired" note in `README.md` Notes, both explaining the isatty/SIP failure in one or two lines. Strip "stderr capture" mentions from `AGENTS.md` (which is agent instructions, not history).

**Rationale:** Code comments are read by people editing the file; README is read by people setting up the repo. Both deserve the one-line "we tried, it broke X, we removed it" so the attempt isn't repeated. AGENTS.md is forward-looking agent guidance and should not carry retired-feature descriptions.

**Alternatives considered:**
- *No inline comment, rely only on README.* Rejected: someone editing `.wezterm.lua` directly won't see the README note.
- *A separate `docs/retired-features.md` catalog.* Rejected: overkill for a single retired feature; the note belongs next to where the code lived.

### D4: Leave `pr_description.md` as committed history

**Decision:** Do not modify or delete `pr_description.md`. It documents the v1→v2 fix and is now itself superseded, but it remains a useful postmortem artifact of the attempt.

**Rationale:** The file is already committed history; rewriting it would falsify the record. Its content (the cursor-race analysis, the alternatives table) is exactly the kind of context that prevents a future re-walk. The new README "Retired" note will be the authoritative current state; `pr_description.md` is the trail of how we got here.

**Alternatives considered:**
- *Prepend a `SUPERSEDED` header to `pr_description.md`.* Mildly nice but not worth a touched file in a change that's otherwise pure removal. The README note covers the "current state" job.

## Risks / Trade-offs

- **[Loss of the red-error visual cue]** → Accepted. Programs' own stderr colors (which the capture was suppressing) now render natively, and tools like `git-delta`, `eza`, and `bat` already provide rich color where it matters. The blanket red was a crutch that hid better native coloring.
- **[Cursor race could theoretically recur if a future change re-introduces async stderr handling]** → Mitigated by the README "Retired" note and the surviving `pr_description.md` postmortem, which together document *why* async stderr handling is a trap on ZLE. A future contributor has to consciously override documented history to re-add it.
- **[External scripts that gate on `WEZTERM_DISCRIMINATE_STDERR` silently disable]** → Accepted; the env var was a private toggle, not a public API. No action beyond removal.
- **[Rare Cause B cursor-hide (TUI killed with cursor hidden) is not addressed]** → Accepted by the owner. It's orthogonal to stderr, rare, and a one-liner `precmd` hook can be added in a separate change if it ever becomes a real annoyance. Not in scope here.