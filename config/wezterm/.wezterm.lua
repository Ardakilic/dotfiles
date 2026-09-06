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

config.font = wezterm.font 'MonoLisaCode Nerd Font'
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

    -- Delete whole line (Cmd+Backspace)
    -- Sends ESC+Ctrl+U (\x1b\x15) so Cmd+Backspace is distinguishable from
    -- plain Ctrl+U (which zsh binds to kill-whole-line).
    -- .zshrc binds ESC+Ctrl+U to backward-kill-line (delete back to cursor).
    { key = 'Backspace', mods = 'CMD', action = wezterm.action{SendString = '\x1b\x15'} },

    -- Kill entire input buffer (Ctrl+Shift+K)
    -- Sends ESC+Ctrl+K (\x1b\x0b) so Ctrl+Shift+K is distinguishable from
    -- plain Ctrl+K (which zsh binds to kill-to-end-of-line).
    -- .zshrc binds ESC+Ctrl+K to kill-buffer (wipe everything typed, including multiline).
    { key = 'K', mods = 'CTRL|SHIFT', action = wezterm.action{SendString = '\x1b\x0b'} },

    -- Remap Shift+Enter to send Alt+Enter natively, for multiple line input
    { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendKey { key = 'Enter', mods = 'ALT' } },

    -- Command-line selection (pairs with zsh-edit-select in .zshrc).
    -- WezTerm has no default binding on plain Shift+Arrows, so they pass
    -- through to zsh as xterm sequences (ESC[1;2D etc.), where the plugin
    -- selects command-line text. Made explicit here so the pass-through is
    -- intentional and survives future default changes.
    { key = 'LeftArrow', mods = 'SHIFT', action = 'DisableDefaultAssignment' },
    { key = 'RightArrow', mods = 'SHIFT', action = 'DisableDefaultAssignment' },
    { key = 'UpArrow', mods = 'SHIFT', action = 'DisableDefaultAssignment' },
    { key = 'DownArrow', mods = 'SHIFT', action = 'DisableDefaultAssignment' },

    -- zsh-edit-select Cmd editing shortcuts (macOS): forward CSI-u sequences
    -- so the plugin handles select-all / cut / paste / undo / redo on the
    -- command line instead of WezTerm consuming the keys. Cmd+C below is
    -- smarter: it copies a terminal mouse selection when one exists, else
    -- forwards to the plugin.
    { key = 'a', mods = 'CMD', action = act.SendString '\x1b[97;9u' },
    { key = 'v', mods = 'CMD', action = act.SendString '\x1b[118;9u' },
    { key = 'x', mods = 'CMD', action = act.SendString '\x1b[120;9u' },
    { key = 'z', mods = 'CMD', action = act.SendString '\x1b[122;9u' },
    { key = 'z', mods = 'CMD|SHIFT', action = act.SendString '\x1b[122;10u' },
    {
      key = 'c',
      mods = 'CMD',
      action = wezterm.action_callback(function(window, pane)
        local sel = window:get_selection_text_for_pane(pane)
        if sel ~= '' then
          window:perform_action(act.CopyTo 'Clipboard', pane)
        else
          window:perform_action(act.SendString '\x1b[99;9u', pane)
        end
      end),
    },
    -- zsh-edit-select word/line selection (macOS): Option+Shift+←/→ select a
    -- word at a time; Cmd+Shift+←/→ select to line start/end; Cmd+Shift+↑/↓
    -- select to buffer start/end. Overrides the tab-move bindings above —
    -- move tabs with Cmd+Shift+[ / Cmd+Shift+] (WezTerm defaults) instead.
    { key = 'LeftArrow', mods = 'OPT|SHIFT', action = act.SendString '\x1b[1;4D' },
    { key = 'RightArrow', mods = 'OPT|SHIFT', action = act.SendString '\x1b[1;4C' },
    { key = 'LeftArrow', mods = 'CMD|SHIFT', action = act.SendString '\x1b[1;10D' },
    { key = 'RightArrow', mods = 'CMD|SHIFT', action = act.SendString '\x1b[1;10C' },
    { key = 'UpArrow', mods = 'CMD|SHIFT', action = act.SendString '\x1b[1;10A' },
    { key = 'DownArrow', mods = 'CMD|SHIFT', action = act.SendString '\x1b[1;10B' },

    -- Move the current tab left or right: use Cmd+Shift+[ / ] (WezTerm
    -- defaults). The previous Cmd+Shift+Arrow bindings now select text.

}

config.mouse_bindings = {
  -- zsh-edit-select mouse integration: on left-click Down, notify the shell
  -- (deselect signal CSI >62300u) if a mouse selection was active, so the
  -- plugin doesn't keep targeting a cleared selection. Skipped on the alt
  -- screen (vim/less) where it would arrive as raw input.
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel ~= '' and not pane:is_alt_screen_active() then
        pane:send_text '\x1b[>62300u'
      end
    end),
  },

  -- Left click-drag selects text, release copies to clipboard
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

  -- Shift+click to extend selection is WezTerm's default
  -- (Single Left Down/Up with SHIFT: ExtendSelectionToMouseCursor /
  -- CompleteSelectionOrOpenLink). No custom binding needed — the explicit
  -- one previously here bound only the 'Up' event, which has a gotcha: the
  -- unbound 'Down' would fall through to mouse-reporting programs.
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