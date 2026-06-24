# Tasks

## 1. Rename the font in WezTerm

- [x] In `config/wezterm/.wezterm.lua`, change line 23 from
      `config.font = wezterm.font 'MonoLisa Nerd Font'` to
      `config.font = wezterm.font 'MonoLisaCode Nerd Font'`
- [x] Leave the two commented fallback lines (Hack Nerd Font,
      FiraCode Nerd Font) unchanged

## 2. Rename the font and add the integrated terminal font in the four IDE settings.json files

Apply the same three edits to each of:
- `config/vscode/settings.json`
- `config/vscode-insiders/settings.json`
- `config/vscodium/settings.json`
- `config/kiro-desktop/settings.json`

- [x] Change `"editor.fontFamily": "MonoLisa"` to
      `"editor.fontFamily": "MonoLisaCode"`
- [x] Change the inline comment `// Or "'MonoLisa'"` to
      `// Or "'MonoLisaCode'"`
- [x] Add `"terminal.integrated.fontFamily": "MonoLisaCode Nerd Font"`
      inside the existing Font section (before `// / Font`), with a
      comment noting the Nerd Font variant is for powerline glyphs in
      the integrated terminal
- [x] Leave the `// Alternatives:` comment (Hack Nerd Font, FiraCode
      Nerd Font) unchanged in each file

## 3. Update README.md font section

- [x] Update the "Primary Font" subsection to reflect the v3 family
      names: `MonoLisaCode` (base) and `MonoLisaCode Nerd Font`
      (terminal/TUI variant)
- [x] Keep the MonoLisa.dev and Nerd Font patch links as-is (they
      still point to the right projects)

## 4. Update AGENTS.md

- [x] In the Environment section, change the Font bullet from
      `MonoLisa (paid, Nerd Font patched)` to
      `MonoLisaCode (paid, Nerd Font patched) — Nerd Font variant:
      "MonoLisaCode Nerd Font"`
- [x] Keep the fallback note (Hack Nerd Font, FiraCode Nerd Font)

## 5. Validate

- [x] Run `bash scripts/validate.sh` and confirm zero errors
- [x] Grep the tree for any remaining `MonoLisa` (without `Code`)
      references in active config and confirm none remain in the
      seven config files (archived OpenSpec changes may still
      contain the old name — that's fine, they're historical)