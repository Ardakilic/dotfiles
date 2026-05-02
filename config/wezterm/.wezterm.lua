-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()


-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28
config.font_size = 13

function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "Ayu Mirage (Gogh)" -- Alternative: Ayu Dark (Gogh)
  else
    return "Ayu Light (Gogh)" -- Alternative: Breadog (Gogh)
  end
end
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

config.font = wezterm.font 'MonoLisa Nerd Font'
-- Alternatives:
-- config.font = wezterm.font 'Hack Nerd Font'       -- Recommended for Terminal
-- config.font = wezterm.font 'FiraCode Nerd Font'   -- Recommended for IDEs
-- Font: Disable Ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- Set to true to allow option key to work for special characters 
-- (better Option+Backspace, Option+Arrow etc. handling)
config.send_composed_key_when_left_alt_is_pressed = true 

config.keys = {
    -- Case insensitive search
    { key = 'F', mods = 'CTRL|SHIFT', action = wezterm.action.Search({ CaseInSensitiveString = '' }) },
    -- Case insensitive search END
    { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },
    { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },
    { key = 'w', mods = 'CMD|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false } },
    { key = 'LeftArrow', mods = 'CMD', action = wezterm.action.SendKey { key = 'Home' } },
    { key = 'RightArrow', mods = 'CMD', action = wezterm.action.SendKey { key = 'End' } },
    { key = 'p', mods = 'CMD|SHIFT', action = wezterm.action.ActivateCommandPalette },
   
    -- Move cursor position word backwards and forwards (Option+Left, Option+Right)
    { key = 'LeftArrow', mods = 'OPT', action = wezterm.action{SendString = '\x1bb'} },
    -- Move cursor position word forwards (Option+Right)
    { key = 'RightArrow', mods = 'OPT', action = wezterm.action{SendString = '\x1bf'} },
    
    -- Delete word backwards (Option+Backspace)
    -- works already, so commented out to prevent override
    -- { key = 'Backspace', mods = 'OPT', action = wezterm.action{SendString = '\x1b\x7f'} },

    -- Delete whole line (Cmd+Backspace / Ctrl+Backspace)
    -- In .zshrc, we need to change Ctrl+U behaviour to delete everything before the cursor position
    -- echo 'bindkey "^U" backward-kill-line' >> ~./zshrc
    -- Otherwise, it deletes the whole line
    { key = 'Backspace', mods = 'CMD', action = wezterm.action.SendKey { key = 'u', mods = 'CTRL' } },

    -- Remap Shift+Enter to send Alt+Enter natively, for multiple line input
    { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendKey { key = 'Enter', mods = 'ALT' } }

}

config.mouse_bindings = {
  -- Left click selects text normally
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },

  -- Cmd-click opens hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = act.OpenLinkAtMouseCursor,
  },
}

config.scrollback_lines = 50000 -- Claude Code outputs a lot
config.enable_scroll_bar = true -- visual indicator of position
-- config.hide_tab_bar_if_only_one_tab = true -- self-explanatory

-- merge macos traffic light buttons into title bar, more vertical space
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
-- add small padding to prevent to accidentally click edges
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }


-- Battery and time in status bar
--[[ wezterm.on('update-right-status', function(window, pane)
  local battery = ''
  for _, b in ipairs(wezterm.battery_info()) do
    battery = string.format('%.0f%% · ', b.state_of_charge * 100)
  end
  window:set_right_status(wezterm.format {
    { Text = ' ' .. battery .. wezterm.strftime('%H:%M') .. ' ' },
  })
end) ]]

-- Finally, return the configuration to wezterm:
return config