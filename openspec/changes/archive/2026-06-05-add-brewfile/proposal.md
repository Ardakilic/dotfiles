# Add Homebrew Brewfile for app installation

## Why

The current `make install-deps` target hand-rolls 17 individual
`brew list X &>/dev/null || brew install` lines, three of which cover
casks. The remaining 14 casks the user has installed
(`alt-tab`, `betterzip`, `codeisland`, `forklift`, `helium-browser`,
`iina`, `joplin`, `kiro`, `megasync`, `openmtp`, `orbstack`, `raycast`,
`telegram`, `vscodium`) are not tracked at all, and several personal
packages (`lilt`, `rb-scrobbler`, `feishin`) live in a private tap
that is also untracked. Four App Store apps (VidHub, WhatsApp,
WireGuard, Scrobbles for Last.fm) are installed but have no
representation in the dotfiles at all. Setting up a fresh machine
from these dotfiles today means losing all of that and re-installing
by hand.

We need a single declarative file that captures the *intended* state
of the user's Homebrew installation — formulae, casks, taps, and Mac
App Store apps — so that `make install-deps` is reproducible,
diffable, and reviewable across machines.

## What Changes

- Add `config/brew/Brewfile`: a hand-curated Brewfile listing
  - 2 taps (`wxtsky/tap` for `codeisland`, `ardakilic/tap` for
    `lilt`, `rb-scrobbler`, and `feishin`)
  - 22 formulae (`brew leaves --installed-on-request` plus `mas`,
    `lilt`, and `rb-scrobbler`)
  - 18 casks (`brew list --cask` plus `feishin`)
  - 4 Mac App Store apps (`mas "VidHub", id: 1659622164`,
    `mas "WhatsApp", id: 310633997`, `mas "WireGuard", id: 1451685025`,
    `mas "Scrobbles for Last.fm", id: 1344679160`)
- Replace the body of the `install-deps` target in the `Makefile` with:
  - Two `brew trust --tap …` steps (for `ardakilic/tap` and
    `wxtsky/tap`) run *before* the Brewfile is processed.
  - A `brew install mas` bootstrap step, so the App Store sign-in
    precheck has a binary to call.
  - A `mas account` precheck that fails fast with a clear error if
    the user is not signed into the Mac App Store.
  - A single `brew bundle install --no-upgrade --file=…` call that
    processes formulae, casks, taps, and `mas` entries from the
    Brewfile in one pass.
- The earlier "print App Store URLs for the user to click" idea is
  superseded: App Store apps are now installed automatically by
  `mas` as part of `brew bundle install`. No URL printing, no
  manual clicks per app.
- Update `README.md` and `AGENTS.md` to reflect the new install
  workflow, the new `config/brew/` directory, and the one-time
  App Store sign-in requirement on fresh machines.

## Non-Goals

- **Auto-upgrade on install.** `brew bundle install` upgrades by
  default; we pass `--no-upgrade` to preserve the old "install if
  missing" semantics. Upgrades are a deliberate user action.
- **Cleanup of untracked casks.** `brew bundle cleanup` (which removes
  casks not in the Brewfile) is intentionally not wired up. It is
  destructive and out of scope for this change.
- **Snapshot automation.** The Brewfile is hand-curated, not generated
  by `brew bundle dump`. We deliberately exclude auto-installed
  dependencies (bottles pulled in by other formulae).
- **Replacing the App Store's sign-in flow.** `mas` itself does not
  handle sign-in; the user must be signed into the Mac App Store app
  on the machine for `mas` to work. The Makefile detects this state
  and prints a clear error; it does not attempt to drive sign-in.

## Impact

- `make install-deps` body shrinks from 17 hand-rolled lines to a
  trust + bootstrap + precheck + brew bundle sequence of ~7 lines.
- The behavior on an already-set-up machine is a no-op for formulae,
  casks, and `mas` apps (because of `--no-upgrade` and `mas install`'s
  built-in idempotency).
- The behavior on a fresh machine is:
  1. Trust the third-party taps.
  2. Install `mas` if absent.
  3. Verify App Store sign-in; fail fast with a clear message if not.
  4. After the user signs into App Store and re-runs, install all
     formulae, casks, taps, and App Store apps.
- Third-party taps (`wxtsky/tap`, `ardakilic/tap`) are now an
  explicit dependency. If either is unavailable, the Brewfile install
  fails loudly, which is the desired behavior.
