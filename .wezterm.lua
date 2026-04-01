-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 13
config.color_scheme = 'AyuMirage (Gogh)'

-- Aci (Gogh), AyuMirage (Gogh),

-- TX-02 = Berkeley Mono
config.font = wezterm.font 'MonoLisa Nerd Font'
-- Font Disable Ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- Case insensitive search
config.keys = {
    {
      key = 'F',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.Search({ CaseInSensitiveString = '' })
    }
  }
-- Casee insensitive search END

-- Finally, return the configuration to wezterm:
return config