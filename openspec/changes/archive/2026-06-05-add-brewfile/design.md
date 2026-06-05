# Design: Homebrew Brewfile for app installation

## Context

The user maintains a macOS development environment via dotfiles. They
have 19 on-request formulae, 17 casks, and 1 third-party tap currently
installed on this machine. Only 3 of those casks and 13 of those
formulae are tracked by the existing `make install-deps` target, which
uses hand-rolled `brew list X &>/dev/null || brew install` lines. Two
private packages from the user's own tap (`lilt` formula, `feishin`
cask) are not tracked at all.

The user's intent is that "make my new machine look like this one"
should be a single command.

## Goals

- Single source of truth for the user's intended Homebrew state.
- Idempotent: re-running on a set-up machine is a no-op.
- Diffable: changes to the Brewfile are visible in `git diff`.
- No surprises: nothing upgrades on install, nothing gets removed.

## Non-Goals

- App Store automation.
- Auto-upgrade on install.
- Cleanup of untracked packages.
- Generated Brewfile from `brew bundle dump`.

## The Brewfile

Location: `config/brew/Brewfile`. This is the only place in the repo
that lists formulae, casks, or taps. The convention `config/brew/`
mirrors the existing `config/<tool>/` layout.

Content shape:

```ruby
# Taps
tap "wxtsky/tap"        # codeisland (cask)
tap "ardakilic/tap"     # lilt (formula), rb-scrobbler (formula), feishin (cask)

# Formulae (on-request only — excludes brew-pulled deps)
brew "mas"              # Mac App Store CLI (needed for mas entries below)
brew "lilt"
brew "rb-scrobbler"
brew "aria2"
brew "bat"
# … 17 more

# Casks
cask "feishin"
cask "alt-tab"
# … 16 more

# Mac App Store apps (require the user to be signed into the App Store)
mas "VidHub",    id: 1659622164
mas "WhatsApp",  id: 310633997
mas "WireGuard", id: 1451685025
mas "Scrobbles for Last.fm", id: 1344679160
```

A header comment explains how to regenerate the formula and cask
sections manually (`brew leaves --installed-on-request`,
`brew list --cask`) and warns that auto-installed deps must not be
added. Tap additions are deliberate and rare; they get a comment
explaining which casks/formulae they provide. `mas` entries are
hand-listed; their IDs are stable.

### Why hand-curated, not `brew bundle dump`

`brew bundle dump` includes every installed package, including the
29 auto-installed dependency bottles (`brotli`, `openssl@3`,
`icu4c@78`, `libgit2`, …) that Homebrew pulls in as transitive deps
of other packages. Including them would couple the Brewfile to
Homebrew's internal dependency resolution and produce false diffs
on every `brew upgrade`. The hand-curated file is a stable,
reviewable snapshot of the user's *direct* dependencies only.

### Taps and trust

Two taps are listed:

- `wxtsky/tap`: provides `codeisland`. Third-party but well-established.
- `ardakilic/tap`: the user's own tap, provides `lilt` (formula),
  `rb-scrobbler` (formula), and `feishin` (cask). Listed without a
  `trust` directive because the Brewfile syntax has no inline trust
  flag; trust is handled by `brew trust --tap` in the Makefile, which
  is a no-op on machines where `HOMEBREW_REQUIRE_TAP_TRUST` is not set.

If the user later needs a tap that lives outside GitHub
(`tap "user/repo", "https://user@bitbucket.org/…"`), the syntax is
already in the Brewfile spec.

## The Makefile target

```make
install-deps:
	@echo "Trusting third-party taps..."
	@brew trust --tap ardakilic/tap 2>/dev/null || true
	@brew trust --tap wxtsky/tap   2>/dev/null || true
	@if ! command -v mas >/dev/null 2>&1; then \
		echo "Installing mas CLI (needed for App Store apps)..."; \
		brew install mas; \
	fi
	@if ! mas list >/dev/null 2>&1; then \
		echo ""; \
		echo "ERROR: Not signed into the Mac App Store."; \
		echo "App Store apps require sign-in. Open the App Store app,"; \
		echo "sign in with your Apple ID, then re-run 'make install-deps'."; \
		exit 1; \
	fi
	@echo "Installing formulae, casks, and App Store apps from Brewfile..."
	@brew bundle install --no-upgrade --file=$(CURRENT_DIR)/config/brew/Brewfile
```

### Why `--no-upgrade`

`brew bundle install` upgrades by default. The current `install-deps`
target never upgrades. We preserve the old semantics with
`--no-upgrade` to keep the "I just want my machine to match the
Brewfile" mental model. The user explicitly approved this.

### Why the `brew trust` step is defensive

`HOMEBREW_REQUIRE_TAP_TRUST` is off by default. If it is ever set
(manually or by a future Homebrew default), the install will fail
when it hits the first cask from `ardakilic/tap` (or any cask from
`wxtsky/tap`). Two `brew trust --tap …` lines run *before* the brew
bundle call, covering both third-party taps.

Each `brew trust --tap X 2>/dev/null || true` line:
- Sets trust on machines where the env var is on.
- Errors silently on machines where it is off (the `2>/dev/null`).
- Is a no-op on subsequent runs (`|| true`).

Order matters: the trust steps MUST run before `brew bundle install`,
otherwise the install hits the trust error before trust is set. The
recipe above reflects this.

This costs two process invocations per `make install-deps` and
removes a class of future failure mode.

### App Store URLs

Earlier designs printed App Store URLs at the end of `install-deps`
for the user to click. The current design replaces this with `mas`
entries in the Brewfile plus an App Store sign-in precheck in the
Makefile. The trade-off is:

- One-time App Store sign-in is required on a fresh machine (Apple
  ID + 2FA). After that, `mas install` is non-interactive and
  idempotent.
- `mas` is installed as a brew dependency (it appears in the
  Brewfile's `brew "mas"` line and in the Makefile's bootstrap
  step). Once installed, `mas list` is a stable read-only check
  for sign-in state: it exits 0 when the App Store app is signed in
  and can be read, and exits non-zero otherwise.
- The precheck fails fast with a clear error if the user is not
  signed in, *before* `brew bundle install` runs. This converts a
  partial-failure ("brew bundle dies halfway through with a mas
  error") into a clean failure with a one-line fix.
- Note: `mas signin` is disabled on macOS 10.13+, so the Makefile
  MUST NOT try to drive sign-in itself. The user signs in via the
  App Store app GUI on a fresh machine; `mas list` then succeeds.
- We considered letting `brew bundle install` discover the missing
  sign-in itself (via mas's own error message), but the resulting
  error is not user-friendly and the failure happens after formulae
  and casks have already been installed. The precheck is a small
  price (one process invocation) for a much better failure mode.

## Trade-offs

| Decision | Trade-off |
|----------|-----------|
| Brewfile in `config/brew/` (not repo root) | Slight verbosity (`--file=…`); consistency with the `config/<tool>/` layout |
| Hand-curated, not dumped | Manual upkeep when new apps are installed; no false diffs from brew's auto-deps |
| `--no-upgrade` | Outdated packages stay outdated until user runs `brew upgrade` manually; matches the old target's semantics |
| `mas` entries in the Brewfile | Requires a one-time App Store sign-in on fresh machines; after that, fully non-interactive and idempotent |
| `mas account` precheck in Makefile | One extra process invocation; converts a confusing mid-install failure into a clear pre-install error |
| Two tap trust steps in Makefile | Two extra process invocations; removes a future failure mode |
| `brew install mas` bootstrap in Makefile | Redundant with the Brewfile's `brew "mas"` (which would install it during bundle install); needed because the precheck runs *before* the Brewfile is processed |
| Keep the `install-deps` name | Smallest semantic delta; no need to teach users a new name |

## Open questions

None at proposal time. The two previously-open questions (Path A vs
B, App Store URL storage, on-request filter) were resolved in
exploration.
