# font-config Specification (Delta — add-ghostty)

## MODIFIED Requirements

### Requirement: Primary font family name

Every configuration file that selects the primary font MUST use the
MonoLisa v3 family names. Editor configuration files (VS Code, VS
Code Insiders, VSCodium, Kiro Desktop) MUST set the editor font
family to `MonoLisaCode`. Terminal and TUI configuration files
(WezTerm AND Ghostty) MUST set the font to `MonoLisaCode Nerd Font`.
No configuration file in `config/` MUST reference the pre-v3 names
`MonoLisa` or `MonoLisa Nerd Font`.

**Reason**: A second terminal config (`config/ghostty/config.ghostty`)
is being added to the repo. The existing requirement already
established that terminal/TUI configs use the Nerd Font variant; this
delta extends the same rule to the new Ghostty config and widens the
"no stale v2 names" grep scenario to cover it. The role split
(editors = base, terminals = Nerd Font) is preserved and extended.

**Migration**: None for existing files. The new `config/ghostty/config.ghostty`
MUST set `font-family = "MonoLisaCode Nerd Font"` from creation. The
"no stale v2 names" grep now also scans `config/ghostty/`, which
contains no v2 names on creation, so the check continues to pass.

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

#### Scenario: Ghostty config uses the Nerd Font variant

- **WHEN** a developer reads the `font-family` line in
  `config/ghostty/config.ghostty`
- **THEN** the font name is `MonoLisaCode Nerd Font`

#### Scenario: no stale v2 names in active config

- **WHEN** a developer greps `config/` for `MonoLisa` not immediately
  followed by `Code`
- **THEN** no matches are found in any active configuration file,
  including `config/wezterm/.wezterm.lua` and
  `config/ghostty/config.ghostty`
  (archived OpenSpec changes under `openspec/changes/archive/` are
  historical and excluded from this check)

### Requirement: Role split is preserved

The rename MUST preserve the existing role split: the editor surface
uses the base font (`MonoLisaCode`) and the integrated terminal /
TUI applications use the Nerd Font-patched variant
(`MonoLisaCode Nerd Font`) for powerline glyphs and icons. The rename
MUST NOT collapse the two variants into one or change which file uses
which variant. The Ghostty terminal config, like the WezTerm terminal
config, MUST use the Nerd Font variant (not the base font), because
it hosts the powerlevel10k prompt which requires Nerd Font glyphs.

**Reason**: A second terminal config is being added; the role split
must extend to it. Ghostty hosts the same p10k prompt as WezTerm
(via the widened `.zshrc` gate), so it requires the Nerd Font variant
for glyph rendering, exactly like WezTerm.

**Migration**: None. The new `config/ghostty/config.ghostty` MUST set
`font-family = "MonoLisaCode Nerd Font"` (not the base `MonoLisaCode`)
from creation.

#### Scenario: editor settings use the base font

- **WHEN** a developer reads the `editor.fontFamily` value in any
  IDE `settings.json`
- **THEN** the value is `MonoLisaCode` (no `Nerd Font` suffix)

#### Scenario: WezTerm uses the Nerd Font variant

- **WHEN** a developer reads the `config.font` line in
  `config/wezterm/.wezterm.lua`
- **THEN** the font name is `MonoLisaCode Nerd Font`

#### Scenario: Ghostty uses the Nerd Font variant

- **WHEN** a developer reads the `font-family` line in
  `config/ghostty/config.ghostty`
- **THEN** the font name is `MonoLisaCode Nerd Font` (no base-font
  fallback without the `Nerd Font` suffix)

### Requirement: Documentation reflects v3 names

`README.md` and `AGENTS.md` MUST reference the MonoLisa v3 family
names (`MonoLisaCode` and `MonoLisaCode Nerd Font`) rather than the
pre-v3 names. The MonoLisa.dev link and the Nerd Font patch link in
`README.md` MUST remain valid and point to the same projects. The
documentation MUST make clear that BOTH terminal configs (WezTerm
and Ghostty) use the `MonoLisaCode Nerd Font` variant.

**Reason**: The docs already require v3 names; this delta clarifies
that the requirement covers the new Ghostty config as well, so a
future doc edit doesn't accidentally describe Ghostty's font with a
v2 or base-font name.

**Migration**: None. The README and AGENTS updates performed as part
of this change MUST use the v3 names when describing the Ghostty
font.

#### Scenario: README uses v3 names

- **WHEN** a developer reads the Font section of `README.md`
- **THEN** the primary font is described as `MonoLisaCode` (base)
  and `MonoLisaCode Nerd Font` (terminal/TUI variant)
- **AND** the description of the terminal/TUI variant explicitly
  covers both WezTerm and Ghostty

#### Scenario: AGENTS.md uses v3 names

- **WHEN** a developer reads the Environment section of `AGENTS.md`
- **THEN** the Font bullet names `MonoLisaCode` and notes the
  `MonoLisaCode Nerd Font` variant for terminals (WezTerm and Ghostty)

#### Scenario: README links are preserved

- **WHEN** a developer reads the Font section of `README.md`
- **THEN** the `https://monolisa.dev/` link and the Nerd Font patch
  repository link are still present