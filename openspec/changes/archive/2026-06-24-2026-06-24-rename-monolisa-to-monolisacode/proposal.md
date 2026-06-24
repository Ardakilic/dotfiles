# Rename MonoLisa font references to MonoLisaCode

## Why

MonoLisa v3 renamed its typeface families. The base font that was
previously installed as **MonoLisa** is now installed as
**MonoLisaCode**, and the Nerd Font patch that was installed as
**MonoLisa Nerd Font** is now installed as **MonoLisaCode Nerd
Font**. After upgrading to v3, every configuration file in this
repository that references the old names silently falls back to a
default font (or to the first available fallback) because the old
family name no longer resolves.

The repository currently references the old names in seven active
configuration files across two categories (terminal vs. IDE) plus
two documentation files. The rename is a mechanical 1:1 mapping with
no semantic change — the same files keep the same role (terminal
uses the Nerd Font variant, editors use the base font), only the
family string changes.

## What Changes

- **WezTerm** (`config/wezterm/.wezterm.lua:23`):
  `'MonoLisa Nerd Font'` → `'MonoLisaCode Nerd Font'`
- **VS Code** (`config/vscode/settings.json`):
  - `editor.fontFamily` (line 4): `"MonoLisa"` → `"MonoLisaCode"`,
    inline comment `// Or "'MonoLisa'"` → `// Or "'MonoLisaCode'"`
  - Add `"terminal.integrated.fontFamily": "MonoLisaCode Nerd Font"`
    inside the existing Font section (before `// / Font`), with a
    comment explaining the Nerd Font variant is for powerline glyphs
    in the integrated terminal
- **VS Code Insiders** (`config/vscode-insiders/settings.json`):
  same `editor.fontFamily` + `terminal.integrated.fontFamily` edits
  as VS Code
- **VSCodium** (`config/vscodium/settings.json`):
  same `editor.fontFamily` + `terminal.integrated.fontFamily` edits
  as VS Code
- **Kiro Desktop** (`config/kiro-desktop/settings.json`):
  same `editor.fontFamily` + `terminal.integrated.fontFamily` edits
  as VS Code
- **README.md** (font section, lines ~109-110):
  update the MonoLisa display name / link context to reflect v3 and
  the new family names
- **AGENTS.md** (line ~85):
  update the "Font" environment bullet from `MonoLisa (paid, Nerd Font
  patched)` to `MonoLisaCode (paid, Nerd Font patched)` with the Nerd
  Font variant name noted

No other files reference the MonoLisa family. The Brewfile only
lists the free fallback fonts (`font-hack-nerd-font`,
`font-fira-code-nerd-font`) and is unchanged — MonoLisa is a paid
font installed manually, never via Homebrew.

## Non-Goals

- **Brewfile changes.** The fallback Nerd Fonts (Hack, FiraCode)
  remain unchanged; only the primary font name changes.
- **Font license or source.** MonoLisa remains a paid, manually
  installed font; the Nerd Font patch remains a third-party patch.
- **Terminal font size.** The integrated terminal inherits
  `editor.fontSize` (13); no separate `terminal.integrated.fontSize`
  is introduced.

## Impact

- On a machine where MonoLisa v3 is installed, the old names stop
  resolving and the editor/terminal silently fall back. After this
  change they resolve to the correct v3 families again.
- The VS Code integrated terminal now explicitly uses the Nerd Font
  variant, so powerline10k prompt glyphs render correctly there too
  — previously it inherited the base font (no glyph patch).
- On a machine still on MonoLisa v2, the new names will not resolve
  until v3 is installed. This is expected — the change assumes v3 is
  already installed (the user's situation).
- No structural or dependency changes — string replacement plus one
  added key across seven config files and two docs files.