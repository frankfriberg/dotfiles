local wezterm = require("wezterm")
local act = wezterm.action

local colors = require("colors")
local inputmenu = require("inputmenu")
local tabs = require("tabs")
local rightStatus = require("statusline")
local splitNav = require("smartsplits")

wezterm.on("format-tab-title", tabs)
wezterm.on("update-right-status", rightStatus)

local hyper = "CMD|SHIFT|CTRL|ALT"

local config = {
  term = "wezterm",
  check_for_updates = false,
  audible_bell = "Disabled",
  send_composed_key_when_left_alt_is_pressed = true,
  window_decorations = "RESIZE",
  color_scheme_dirs = { "~/.config/wezterm/colors" },
	color_scheme = "Everforest Dark (Medium)",
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false,
  font = wezterm.font({
    family = "JetBrainsMono Nerd Font",
    weight = "Medium",
    harfbuzz_features = { "calt=0", "clig=0", "liga=0", "cv06=1", "cv07=1", "cv17=1", "zero" },
  }),
  show_new_tab_button_in_tab_bar = false,
  underline_position = -3,
  underline_thickness = 2,
  use_dead_keys = false,
  font_size = 14,
  tab_max_width = 200,
  command_palette_bg_color = colors.bg_dim,
  command_palette_fg_color = colors.fg,
  inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.75,
  },
  colors = {
    tab_bar = {
      background = colors.bg_dim,
      active_tab = {
        bg_color = colors.bg0,
        fg_color = colors.fg,
      },
      inactive_tab = {
        bg_color = colors.bg_dim,
        fg_color = colors.grey2,
      },
    },
  },
  disable_default_key_bindings = true,
  leader = { key = "Space", mods = hyper },
  keys = {
    { key = "t", mods = "CMD",  action = act.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "CMD",  action = act.SpawnWindow },
    { key = "p", mods = hyper,  action = act.ActivateCommandPalette },
    { key = "t", mods = hyper,  action = inputmenu },
    { key = "s", mods = hyper,  action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = hyper,  action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "o", mods = hyper,  action = act.TogglePaneZoomState },
    { key = "c", mods = hyper,  action = act.CloseCurrentPane({ confirm = true }) },
    { key = "w", mods = "CMD",  action = act.CloseCurrentTab({ confirm = true }) },
    { key = "v", mods = "CMD",  action = act.PasteFrom("Clipboard") },
    { key = "c", mods = "CMD",  action = act.CopyTo("ClipboardAndPrimarySelection") },
    { key = "f", mods = "CMD",  action = act.Search({ CaseSensitiveString = "" }) },
    { key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
    splitNav('move', 'h'),
    splitNav('move', 'j'),
    splitNav('move', 'k'),
    splitNav('move', 'l'),
    splitNav('resize', 'h'),
    splitNav('resize', 'j'),
    splitNav('resize', 'k'),
    splitNav('resize', 'l'),
  },
}

for i = 1, 8 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "CMD",
    action = act.ActivateTab(i - 1),
  })
end

return config
