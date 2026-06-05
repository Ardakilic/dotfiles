# Tasks

## 1. Create the Brewfile

- [x] Create `config/brew/` directory and `config/brew/Brewfile` with the hand-curated content from the design (2 taps, 22 formulae, 18 casks, 4 mas apps)
- [x] Add a header comment explaining the curation rules and the regeneration commands
- [x] Verify with `brew bundle check --file=config/brew/Brewfile` that the syntax parses and the existing entries are recognized

## 2. Replace the `install-deps` target in the Makefile

- [x] Replace the 17-line body of `install-deps` with the trust + bootstrap + precheck + brew bundle sequence from the design
- [x] Ensure the trust steps and `mas account` precheck appear *before* the `brew bundle install` call
- [x] Do NOT include any `printf` of App Store URLs (REQ: No App Store URL printing)
- [x] Update the `.PHONY:` line to keep `install-deps` listed (already present)

## 3. Update the Makefile help text

- [x] In the `help:` target's `@echo` lines, rewrite the `install-deps` description to mention the Brewfile and the App Store sign-in requirement on fresh machines

## 4. Update README.md

- [x] In the "Requirements" section, update the description of `make install-deps` to mention the Brewfile, the `mas` install, and the one-time App Store sign-in requirement
- [x] In the "Individual tools" section, add a short note that `wezterm@nightly`, `font-hack-nerd-font`, and `font-fira-code-nerd-font` are also in the Brewfile
- [x] In the "Config Structure" section, add `config/brew/Brewfile` to the directory tree
- [x] In the setup section's individual-targets block, the `install-deps` line stays but the comment is updated

## 5. Update AGENTS.md

- [x] In the project structure, add `config/brew/Brewfile` under `config/`
- [x] In the setup commands list, keep the `make install-deps` line but update its description
- [x] In the conventions section, add a note that the Brewfile is hand-curated, not dumped, and why
- [x] In the conventions section, add a note that App Store apps are installed via `mas` entries in the Brewfile and require a one-time sign-in to the Mac App Store on a fresh machine

## 6. Run `scripts/validate.sh`

- [x] Run `bash scripts/validate.sh` and confirm zero errors
- [x] The validator does not currently check the Brewfile, but the Makefile target alignment check and JSON validation should still pass

## 7. Smoke test the new target

- [x] Run `make install-deps` on the current machine
- [x] Confirm the two `brew trust` lines are silent no-ops (they print "Trusted tap"/"Already trusted tap" status — informational, not a failure)
- [x] Confirm the `mas` bootstrap step either installs `mas` (first run) or is a no-op (subsequent runs)
- [x] Confirm the `mas list` precheck succeeds (the user is signed into the App Store on this machine) — **fixed: was using `mas account` (invented), now uses `mas list` which works**
- [x] Confirm `brew bundle install` reports that `mas`, `lilt`, `rb-scrobbler`, and `feishin` are installed (the new entries), and the rest are already installed
- [x] Confirm no formulae, casks, or `mas` apps are upgraded
- [x] Confirm no formulae, casks, or `mas` apps are removed — second run is a no-op, all entries show "Using"

## 8. Add a categorized apps list to README.md

- [x] In `README.md`, add three new sections after "ZSH plugins":
  - "Casks:" listing all 18 casks with brief descriptions
  - "Mac App Store apps:" listing all 4 mas apps
  - "Private tap packages:" listing the 3 packages from
    `ardakilic/tap` (lilt, rb-scrobbler, feishin) with descriptions
