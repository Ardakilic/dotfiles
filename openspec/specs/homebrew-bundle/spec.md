# Spec: homebrew-bundle

## Purpose

Define how the repository's Homebrew installation is managed via a single,
hand-curated `Brewfile` consumed by `make install-deps`. The Makefile target
MUST be idempotent, MUST drive both Homebrew formulae/casks and Mac App Store
apps in one pass, and MUST require a one-time Mac App Store sign-in on fresh
machines. The Brewfile is the source of truth for what is installed.

## Requirements

### Requirement: Single Brewfile
The repository MUST contain exactly one Brewfile, located at
`config/brew/Brewfile`. No additional Brewfiles MAY be created
elsewhere in the tree.

#### Scenario: only one Brewfile exists
- **WHEN** a developer searches the repository for `Brewfile`
- **THEN** exactly one match is found, at `config/brew/Brewfile`

### Requirement: Hand-curated, not dumped
The Brewfile MUST be hand-authored. `brew bundle dump` MUST NOT be
used to (re)generate it. Auto-installed dependency bottles
(identified by `brew leaves` being a strict subset of `brew list
--formula`) MUST NOT be present.

#### Scenario: Brewfile contains only on-request formulae
- **WHEN** a developer runs `brew leaves --installed-on-request` and
  compares against the `brew "…"` lines in the Brewfile
- **THEN** every `brew` line is in the `brew leaves` output
  *or* the `brew` line is `mas` (which is the only deliberate
  exception, added so that the `mas account` precheck has a binary
  to call before `brew bundle install` runs)
- **AND** no auto-installed dependency bottles appear in the
  Brewfile

### Requirement: Idempotent install
`make install-deps` MUST be idempotent. Running it on a machine that
already matches the Brewfile MUST NOT change the installation state
for formulae, casks, or App Store apps; the brew portion MUST be a
no-op when the machine is in sync.

#### Scenario: re-run on a set-up machine
- **WHEN** a developer runs `make install-deps` twice in a row on a
  machine that already matches the Brewfile
- **THEN** both invocations succeed
- **AND** the second invocation makes no changes to formulae,
  casks, or App Store apps

### Requirement: No upgrade on install
The Makefile target MUST pass `--no-upgrade` to `brew bundle install`.
Outdated packages MUST stay outdated until the user takes a deliberate
upgrade action.

#### Scenario: outdated formulae are not upgraded
- **WHEN** a developer runs `make install-deps` on a machine where
  one or more formulae in the Brewfile have a newer version
  available
- **THEN** no formula is upgraded
- **AND** the install exits successfully

### Requirement: One target, one source
The Makefile MUST contain exactly one target that runs `brew bundle
install`. The existing `install-deps` target name is preserved; no
parallel target (`install-casks`, `install-bundle`, `install-apps`)
MAY be introduced.

#### Scenario: only one brew-bundle target exists
- **WHEN** a developer inspects the Makefile
- **THEN** the only target that invokes `brew bundle install` is
  `install-deps`

### Requirement: App Store installation via mas
The Mac App Store apps the user wants managed by the dotfiles MUST
be listed in the Brewfile as `mas "Name", id: <numeric-id>` lines.
The `mas` CLI MUST be a tracked brew dependency in the Brewfile
(`brew "mas"`). After `make install-deps` completes successfully on a
machine where the user is signed into the Mac App Store, the
Brewfile's `mas` entries MUST be installed and `mas list` MUST
include each one.

#### Scenario: mas entries appear in the Brewfile
- **WHEN** a developer reads the Brewfile
- **THEN** the lines `mas "VidHub", id: 1659622164`,
  `mas "WhatsApp", id: 310633997`,
  `mas "WireGuard", id: 1451685025`, and
  `mas "Scrobbles for Last.fm", id: 1344679160` are all present

#### Scenario: mas is a tracked brew dependency
- **WHEN** a developer reads the Brewfile
- **THEN** `brew "mas"` appears in the formulae section

#### Scenario: App Store apps are installed after a successful run
- **WHEN** a developer runs `make install-deps` on a machine that
  is signed into the Mac App Store and where none of VidHub,
  WhatsApp, WireGuard, or Scrobbles for Last.fm are installed
- **THEN** `mas list` (run afterwards) includes all four apps

### Requirement: App Store sign-in precheck
The Makefile target MUST run `mas list` *before* the
`brew bundle install` call. If `mas list` exits non-zero, the
target MUST print a clear, multi-line error message instructing the
user to open the App Store app, sign in with their Apple ID, and
re-run `make install-deps`, and MUST exit with a non-zero status
without invoking `brew bundle install`. The precheck MUST be skipped
(treated as "signed in") when `mas` is not installed; in that case
the target MUST first run `brew install mas` to make the precheck
available on subsequent invocations.

The Makefile MUST NOT attempt to drive App Store sign-in itself
(`mas signin` is disabled on macOS 10.13+ and cannot be invoked
non-interactively).

#### Scenario: precheck fails when not signed in
- **WHEN** a developer runs `make install-deps` on a machine where
  `mas` is installed and the user is not signed into the Mac App
  Store
- **THEN** the target prints an error message that mentions the
  Mac App Store, Apple ID, and the App Store app
- **AND** the target exits with a non-zero status
- **AND** `brew bundle install` is NOT invoked

#### Scenario: precheck passes when signed in
- **WHEN** a developer runs `make install-deps` on a machine where
  `mas` is installed and the user is signed into the Mac App Store
- **THEN** `mas list` exits 0
- **AND** `brew bundle install` is invoked
- **AND** the install exits successfully

#### Scenario: bootstrap installs mas if missing
- **WHEN** a developer runs `make install-deps` on a machine where
  `mas` is not installed
- **THEN** the target runs `brew install mas` (or an equivalent
  that installs it) before the `mas list` precheck

#### Scenario: precheck runs before brew bundle install
- **WHEN** a developer reads the `install-deps` target in the
  Makefile
- **THEN** the `mas list` precheck appears *before* the
  `brew bundle install` line in the recipe

### Requirement: Tap trust
The Makefile target MUST run `brew trust --tap ardakilic/tap` and
`brew trust --tap wxtsky/tap` as defensive steps, and MUST run them
*before* the `brew bundle install` call. The commands MUST NOT fail
visibly when the taps are already trusted or when
`HOMEBREW_REQUIRE_TAP_TRUST` is unset.

#### Scenario: trust command is a no-op when already trusted
- **WHEN** a developer runs `make install-deps` on a machine where
  both `ardakilic/tap` and `wxtsky/tap` are already trusted
- **THEN** the install exits successfully
- **AND** no trust-related error is visible in the output

#### Scenario: trust command succeeds when required
- **WHEN** a developer runs `make install-deps` on a machine with
  `HOMEBREW_REQUIRE_TAP_TRUST=1` set and both taps untrusted
- **THEN** both taps are trusted before the brew portion continues
- **AND** the install exits successfully

#### Scenario: trust runs before the brew bundle install
- **WHEN** a developer reads the `install-deps` target in the
  Makefile
- **THEN** the `brew trust --tap` lines appear *before* the
  `brew bundle install` line in the recipe

### Requirement: Third-party taps are explicit
Every tap listed in the Brewfile MUST have a comment indicating
which formulae and/or casks it provides. This is so a future
maintainer (or the user, after a long break) can see at a glance
why each tap is in the file.

#### Scenario: every tap has an explanatory comment
- **WHEN** a developer reads the `tap "…"` lines in the Brewfile
- **THEN** every `tap` line is followed (on the next line) by a
  Ruby comment that names the formulae and/or casks it provides

### Requirement: No App Store URL printing
The Makefile `install-deps` target MUST NOT print App Store URLs
for the user to click. App Store apps MUST be installed by `mas`
as part of the `brew bundle install` pass; they MUST NOT be
represented as `printf` lines in the Makefile.

#### Scenario: no App Store URLs in the Makefile
- **WHEN** a developer reads the `install-deps` target in the
  Makefile
- **THEN** no line matches the pattern
  `https://apps.apple.com/app/id`
- **AND** no `printf` of an App Store URL appears in the recipe

### Requirement: No cleanup on install
The Makefile target MUST NOT run `brew bundle cleanup` (or any
equivalent that removes unlisted packages). Removal of apps is a
deliberate user action and is out of scope for `make install-deps`.

#### Scenario: no cleanup is invoked
- **WHEN** a developer reads the `install-deps` target
- **THEN** the substring `cleanup` does not appear in the recipe

### Requirement: Documentation
`README.md` MUST describe the new install workflow, the new
`config/brew/` directory, the `mas`-based App Store install, and
the one-time App Store sign-in requirement on fresh machines.
`README.md` MUST also include a categorized list of all apps
managed by the Brewfile (Casks, Mac App Store apps, and private
tap packages), so a reader does not have to open the Brewfile to
discover what is installed.
`AGENTS.md` MUST list the Brewfile under the project structure and
under setup commands.

#### Scenario: README mentions the Brewfile
- **WHEN** a developer reads the "Config Structure" section of
  `README.md`
- **THEN** `config/brew/Brewfile` appears in the directory tree

#### Scenario: README mentions the App Store sign-in requirement
- **WHEN** a developer reads the install section of `README.md`
- **THEN** the text mentions the Mac App Store, the need to sign in
  once on a fresh machine, and that `mas` handles App Store apps
  from the Brewfile

#### Scenario: README lists the casks
- **WHEN** a developer reads `README.md`
- **THEN** a "Casks" section lists every `cask "…"` line in the
  Brewfile (other than font casks, which already have their own
  section)

#### Scenario: README lists the App Store apps
- **WHEN** a developer reads `README.md`
- **THEN** a "Mac App Store apps" section lists every `mas "…"`
  entry in the Brewfile by name

#### Scenario: README lists the private tap packages
- **WHEN** a developer reads `README.md`
- **THEN** a "Private tap packages" section lists the packages
  provided by `ardakilic/tap` (lilt, rb-scrobbler, feishin) with
  brief descriptions

#### Scenario: AGENTS.md lists the Brewfile
- **WHEN** a developer reads the "Project Structure" section of
  `AGENTS.md`
- **THEN** `config/brew/Brewfile` is listed

#### Scenario: install-deps is documented in AGENTS.md
- **WHEN** a developer reads the "Setup & Build Commands" section
  of `AGENTS.md`
- **THEN** `make install-deps` is listed with a description that
  references the Brewfile and the App Store sign-in requirement
