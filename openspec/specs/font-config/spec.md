# font-config Specification

## Purpose
TBD - created by archiving change 2026-06-24-rename-monolisa-to-monolisacode. Update Purpose after archive.
## Requirements
### Requirement: Primary font family name
Every configuration file that selects the primary font MUST use the
MonoLisa v3 family names. Editor configuration files (VS Code, VS
Code Insiders, VSCodium, Kiro Desktop) MUST set the editor font
family to `MonoLisaCode`. Terminal and TUI configuration files
(WezTerm) MUST set the font to `MonoLisaCode Nerd Font`. No
configuration file in `config/` MUST reference the pre-v3 names
`MonoLisa` or `MonoLisa Nerd Font`.

#### Scenario: editor settings use MonoLisaCode
- **WHEN** a developer reads the `editor.fontFamily` value in
  `config/vscode/settings.json`, `config/vscode-insiders/settings.json`,
  `config/vscodium/settings.json`, and `config/kiro-desktop/settings.json`
- **THEN** the value is `MonoLisaCode`
- **AND** the inline comment reads `// Or "'MonoLisaCode'"`

#### Scenario: terminal config uses the Nerd Font variant
- **WHEN** a developer reads the `config.font` line in
  `config/wezterm/.wezterm.lua`
- **THEN** the font name is `MonoLisaCode Nerd Font`

#### Scenario: no stale v2 names in active config
- **WHEN** a developer greps `config/` for `MonoLisa` not immediately
  followed by `Code`
- **THEN** no matches are found in any active configuration file
  (archived OpenSpec changes under `openspec/changes/archive/` are
  historical and excluded from this check)

### Requirement: Fallback fonts are unchanged
The rename MUST NOT alter the fallback font configuration. The
commented alternative fonts (`Hack Nerd Font`, `FiraCode Nerd Font`)
in WezTerm and the IDE settings files MUST remain as-is, and the
`font-hack-nerd-font` and `font-fira-code-nerd-font` cask entries
in the Brewfile MUST remain as-is.

#### Scenario: WezTerm fallback comments are preserved
- **WHEN** a developer reads `config/wezterm/.wezterm.lua`
- **THEN** the commented lines for `Hack Nerd Font` and
  `FiraCode Nerd Font` are still present and unchanged

#### Scenario: IDE fallback comments are preserved
- **WHEN** a developer reads the `// Alternatives:` comment in any
  IDE `settings.json`
- **THEN** it still lists `Hack Nerd Font` and `FiraCode Nerd Font`

#### Scenario: Brewfile font casks are unchanged
- **WHEN** a developer reads `config/brew/Brewfile`
- **THEN** `cask "font-fira-code-nerd-font"` and
  `cask "font-hack-nerd-font"` are still present

### Requirement: Role split is preserved
The rename MUST preserve the existing role split: the editor surface
uses the base font (`MonoLisaCode`) and the integrated terminal /
TUI applications use the Nerd Font-patched variant
(`MonoLisaCode Nerd Font`) for powerline glyphs and icons. The rename
MUST NOT collapse the two variants into one or change which file uses
which variant.

#### Scenario: editor settings use the base font
- **WHEN** a developer reads the `editor.fontFamily` value in any
  IDE `settings.json`
- **THEN** the value is `MonoLisaCode` (no `Nerd Font` suffix)

#### Scenario: WezTerm uses the Nerd Font variant
- **WHEN** a developer reads the `config.font` line in
  `config/wezterm/.wezterm.lua`
- **THEN** the font name is `MonoLisaCode Nerd Font`

### Requirement: IDE integrated terminal uses the Nerd Font variant
Each IDE `settings.json` MUST set
`terminal.integrated.fontFamily` to `MonoLisaCode Nerd Font` so the
powerline10k prompt glyphs render correctly in the integrated
terminal. The setting MUST appear inside the existing Font section
(before the `// / Font` marker) with a comment explaining its
purpose. No separate `terminal.integrated.fontSize` MUST be
introduced — the integrated terminal inherits `editor.fontSize`.

#### Scenario: integrated terminal font is set in every IDE
- **WHEN** a developer greps the IDE `settings.json` files for
  `terminal.integrated.fontFamily`
- **THEN** each of `config/vscode/settings.json`,
  `config/vscode-insiders/settings.json`,
  `config/vscodium/settings.json`, and
  `config/kiro-desktop/settings.json` has the key set to
  `MonoLisaCode Nerd Font`

#### Scenario: no separate terminal font size
- **WHEN** a developer greps the IDE `settings.json` files for
  `terminal.integrated.fontSize`
- **THEN** no matches are found

### Requirement: Documentation reflects v3 names
`README.md` and `AGENTS.md` MUST reference the MonoLisa v3 family
names (`MonoLisaCode` and `MonoLisaCode Nerd Font`) rather than the
pre-v3 names. The MonoLisa.dev link and the Nerd Font patch link in
`README.md` MUST remain valid and point to the same projects.

#### Scenario: README uses v3 names
- **WHEN** a developer reads the Font section of `README.md`
- **THEN** the primary font is described as `MonoLisaCode` (base)
  and `MonoLisaCode Nerd Font` (terminal/TUI variant)

#### Scenario: AGENTS.md uses v3 names
- **WHEN** a developer reads the Environment section of `AGENTS.md`
- **THEN** the Font bullet names `MonoLisaCode` and notes the
  `MonoLisaCode Nerd Font` variant for terminals

#### Scenario: README links are preserved
- **WHEN** a developer reads the Font section of `README.md`
- **THEN** the `https://monolisa.dev/` link and the Nerd Font patch
  repository link are still present

